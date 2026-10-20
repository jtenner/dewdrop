package main

import (
	"context"
	"encoding/binary"
	"fmt"
	"os"
	"sync"
	"time"

	wago "github.com/wago-org/wago"
)

const (
	workerModule        = "dewdrop.transform.workers"
	workerCapability    = wago.Capability("dewdrop.transform.workers")
	workerCount         = 2
	workerMaxJobs       = 64
	workerMaxJobBytes   = 16 << 20
	workerMaxBatchBytes = 32 << 20
	workerTimeout       = 120 * time.Second
)

var workerDefinition = wago.PluginDefinition{
	ID: "dewdrop.local/transform-workers", Name: "Dewdrop transform workers",
	Version: "1.0.0", Stability: wago.Experimental,
	Provenance:    wago.PluginProvenance{Repository: "https://github.com/jtenner/dewdrop", License: "Apache-2.0"},
	Description:   "Bounded, isolated instances of the calling compiler; copied byte messages only.",
	Compatibility: wago.Compatibility{Engines: map[string]string{"wago": ">=0.1.0"}},
	Authorities: []wago.AuthorityRequest{
		{Name: wago.AuthorityHostImportDefine, Mode: wago.AuthorityRequired,
			Reason: "define the local transform worker byte channel", Scope: wago.AuthorityScope{Modules: []string{workerModule}}},
		{Name: wago.AuthorityInstanceManage, Mode: wago.AuthorityRequired,
			Reason: "own at most two isolated compiler instances", Scope: wago.AuthorityScope{MaxInstances: workerCount, MaxMemoryBytes: workerCount * (16 << 20)}},
		{Name: wago.AuthorityHostCallerIdentify, Mode: wago.AuthorityRequired,
			Reason: "inherit caller cancellation without exposing its instance"},
	},
}

type workerSlot struct {
	input     []byte
	output    []byte
	running   bool
	published bool
}

type workerPlugin struct {
	enabled bool
	manager *wago.InstanceManager
	callers *wago.CallerResolver
	gate    chan struct{}
	mu      sync.Mutex
	slots   map[*wago.ManagedInstance]*workerSlot
}

func workerProvider(enabled bool) (wago.PluginProvider, wago.PluginSelection, error) {
	provider := wago.PluginProvider{Definition: workerDefinition, New: func() wago.Plugin { return &workerPlugin{enabled: enabled} }}
	digest, err := wago.DefinitionDigest(workerDefinition)
	if err != nil {
		return provider, wago.PluginSelection{}, err
	}
	selection := wago.PluginSelection{ID: workerDefinition.ID, DefinitionDigest: digest, Direct: true, Dependencies: map[string]string{}}
	for _, authority := range workerDefinition.Authorities {
		selection.Grants = append(selection.Grants, wago.AuthorityGrant{Name: authority.Name, Scope: authority.Scope})
	}
	return provider, selection, nil
}

func (p *workerPlugin) Register(reg *wago.Registrar) error {
	var err error
	if p.manager, err = reg.ManagedInstances(); err != nil {
		return err
	}
	if p.callers, err = reg.HostCallers(); err != nil {
		return err
	}
	p.gate = make(chan struct{}, 1)
	p.slots = make(map[*wago.ManagedInstance]*workerSlot)
	if err = reg.GuestCapability(workerCapability, wago.CapabilityDocs("run source transforms in bounded compiler workers")); err != nil {
		return err
	}
	imports, err := reg.HostImports()
	if err != nil {
		return err
	}
	module, err := imports.Module(workerModule)
	if err != nil {
		return err
	}
	module.Func("capacity", func(caller wago.HostModule, _, results []uint64) {
		if _, err := p.manager.ManagedCaller(caller); !p.enabled || err == nil {
			results[0] = 0
		} else {
			results[0] = workerCount
		}
	}).Results(wago.ValI32).Capability(workerCapability)
	module.Func("run_batch", func(caller wago.HostModule, args, results []uint64) {
		if !p.enabled {
			workerTrap(fmt.Errorf("transform workers are disabled"))
		}
		if _, err := p.manager.ManagedCaller(caller); err == nil {
			workerTrap(fmt.Errorf("nested transform workers are not allowed"))
		}
		select {
		case p.gate <- struct{}{}:
		default:
			workerTrap(fmt.Errorf("worker pool is busy"))
		}
		defer func() { <-p.gate }()
		payload, err := workerReadArray(caller, args[0], workerMaxBatchBytes)
		if err != nil {
			workerTrap(err)
		}
		jobs, err := decodeWorkerBatch(payload)
		if err != nil {
			workerTrap(err)
		}
		result, err := p.run(caller, jobs)
		if err != nil {
			workerTrap(err)
		}
		if err = workerWriteArray(caller, args[1], result); err != nil {
			workerTrap(err)
		}
		results[0] = uint64(len(result))
	}).Params(wago.ValAnyRef, wago.ValAnyRef).Results(wago.ValI32).Capability(workerCapability)
	module.Func("input_size", func(caller wago.HostModule, _, results []uint64) {
		slot, err := p.slot(caller)
		if err != nil {
			workerTrap(err)
		}
		p.mu.Lock()
		length, running := len(slot.input), slot.running
		p.mu.Unlock()
		if !running {
			workerTrap(fmt.Errorf("worker input is outside a job"))
		}
		results[0] = uint64(length)
	}).Results(wago.ValI32).Capability(workerCapability)
	module.Func("input", func(caller wago.HostModule, args, _ []uint64) {
		slot, err := p.slot(caller)
		if err != nil {
			workerTrap(err)
		}
		p.mu.Lock()
		data, running := slot.input, slot.running
		p.mu.Unlock()
		if !running {
			workerTrap(fmt.Errorf("worker input is outside a job"))
		}
		if err = workerWriteArray(caller, args[0], data); err != nil {
			workerTrap(err)
		}
	}).Params(wago.ValAnyRef).Capability(workerCapability)
	module.Func("output", func(caller wago.HostModule, args, _ []uint64) {
		slot, err := p.slot(caller)
		if err != nil {
			workerTrap(err)
		}
		data, err := workerReadArray(caller, args[0], workerMaxJobBytes)
		if err != nil {
			workerTrap(err)
		}
		p.mu.Lock()
		defer p.mu.Unlock()
		if !slot.running || slot.published {
			workerTrap(fmt.Errorf("worker output must be published once per job"))
		}
		slot.output, slot.published = data, true
	}).Params(wago.ValAnyRef).Capability(workerCapability)
	return nil
}

func workerTrap(err error) { panic(wago.HostTrap{Err: fmt.Errorf("transform workers: %w", err)}) }

func (p *workerPlugin) slot(caller wago.HostModule) (*workerSlot, error) {
	child, err := p.manager.ManagedCaller(caller)
	if err != nil {
		return nil, fmt.Errorf("worker byte channel requires an owned worker: %w", err)
	}
	p.mu.Lock()
	slot := p.slots[child]
	p.mu.Unlock()
	if slot == nil {
		return nil, fmt.Errorf("worker byte channel has no active slot")
	}
	return slot, nil
}

func workerReadArray(caller wago.HostModule, token uint64, limit int) ([]byte, error) {
	storage, ok := caller.(wago.GuestStorageHostModule)
	if !ok {
		return nil, fmt.Errorf("guest byte storage is unavailable")
	}
	var data []byte
	err := storage.WithGuestStorage(func(view wago.GuestStorage) error {
		ref, err := view.GCRef(token)
		if err != nil {
			return err
		}
		info, err := view.GCArrayInfo(ref)
		if err != nil {
			return err
		}
		if info.Storage != wago.GuestGCArrayI8 || uint64(info.Length) > uint64(limit) {
			return fmt.Errorf("worker byte array has invalid storage or exceeds %d bytes", limit)
		}
		bytes, _, err := view.GCArrayBytes(ref, wago.GuestStorageRead)
		if err != nil {
			return err
		}
		data = append([]byte(nil), bytes...)
		return nil
	})
	return data, err
}

func workerWriteArray(caller wago.HostModule, token uint64, data []byte) error {
	if len(data) > workerMaxBatchBytes {
		return fmt.Errorf("worker result exceeds byte limit")
	}
	storage, ok := caller.(wago.GuestStorageHostModule)
	if !ok {
		return fmt.Errorf("guest byte storage is unavailable")
	}
	return storage.WithGuestStorage(func(view wago.GuestStorage) error {
		ref, err := view.GCRef(token)
		if err != nil {
			return err
		}
		info, err := view.GCArrayInfo(ref)
		if err != nil {
			return err
		}
		if info.Storage != wago.GuestGCArrayI8 || !info.Mutable || uint64(info.Length) < uint64(len(data)) {
			return fmt.Errorf("worker output requires a mutable i8 buffer with enough space")
		}
		bytes, _, err := view.GCArrayBytes(ref, wago.GuestStorageWrite)
		if err != nil {
			return err
		}
		copy(bytes, data)
		return nil
	})
}

// Only copied byte messages cross instance boundaries. Each worker executes
// one job at a time, with a fresh input/output slot, and never runs another
// Wasm payload. Compiled code is retained and reused by InstanceManager.Fork.
func (p *workerPlugin) run(caller wago.HostModule, jobs [][]byte) (result []byte, err error) {
	parent, err := p.callers.InvocationContext(caller)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(parent, workerTimeout)
	defer cancel()
	expired, unwatch, err := p.manager.WatchCaller(caller)
	if err != nil {
		return nil, err
	}
	defer unwatch()
	go func() {
		select {
		case <-expired:
			cancel()
		case <-ctx.Done():
		}
	}()
	children := make([]*wago.ManagedInstance, 0, workerCount)
	defer func() {
		for _, child := range children {
			closeErr := child.Close()
			waitErr := child.WaitClosed()
			p.mu.Lock()
			delete(p.slots, child)
			p.mu.Unlock()
			if err == nil && closeErr != nil {
				err = closeErr
			}
			if err == nil && waitErr != nil {
				err = waitErr
			}
		}
	}()
	count := min(workerCount, len(jobs))
	fmt.Fprintf(os.Stderr, "transform workers: %d applications, %d workers\n", len(jobs), count)
	for range count {
		child, forkErr := p.manager.ForkIsolated(ctx, caller)
		if forkErr != nil {
			return nil, forkErr
		}
		children = append(children, child)
		p.mu.Lock()
		p.slots[child] = &workerSlot{}
		p.mu.Unlock()
	}
	results := make([][]byte, len(jobs))
	errors := make([]error, len(jobs))
	retained := 12 + 4*len(jobs)
	overflow := false
	var wait sync.WaitGroup
	for workerIndex, child := range children {
		wait.Add(1)
		go func(workerIndex int, child *wago.ManagedInstance) {
			defer wait.Done()
			for index := workerIndex; index < len(jobs); index += count {
				p.mu.Lock()
				slot := p.slots[child]
				slot.input, slot.output, slot.running, slot.published = jobs[index], nil, true, false
				p.mu.Unlock()
				_, invokeErr := child.Instance().InvokeContext(ctx, "__dew_transform_worker_run")
				p.mu.Lock()
				if invokeErr == nil && !slot.published {
					invokeErr = fmt.Errorf("worker did not publish its result")
				}
				if len(slot.output) > workerMaxBatchBytes-retained {
					overflow = true
				} else {
					retained += len(slot.output)
					results[index] = slot.output
				}
				errors[index] = invokeErr
				slot.input, slot.output, slot.running = nil, nil, false
				p.mu.Unlock()
			}
		}(workerIndex, child)
	}
	wait.Wait()
	// Select failures in source order, regardless of completion order.
	for index, jobErr := range errors {
		if jobErr != nil {
			return nil, fmt.Errorf("job %d: %w", index, jobErr)
		}
	}
	if overflow {
		return nil, fmt.Errorf("worker results exceed byte limit")
	}
	return encodeWorkerResults(results)
}

func decodeWorkerBatch(data []byte) ([][]byte, error) {
	if len(data) > workerMaxBatchBytes || len(data) < 12 || string(data[:4]) != "DWWB" || binary.LittleEndian.Uint32(data[4:]) != 1 {
		return nil, fmt.Errorf("invalid worker batch header")
	}
	count := binary.LittleEndian.Uint32(data[8:])
	if count == 0 || count > workerMaxJobs {
		return nil, fmt.Errorf("worker batch job count must be 1..%d", workerMaxJobs)
	}
	jobs := make([][]byte, 0, count)
	offset := 12
	for range count {
		if len(data)-offset < 4 {
			return nil, fmt.Errorf("truncated worker job length")
		}
		length := uint64(binary.LittleEndian.Uint32(data[offset:]))
		offset += 4
		if length > workerMaxJobBytes || length > uint64(len(data)-offset) {
			return nil, fmt.Errorf("invalid worker job length")
		}
		jobs = append(jobs, data[offset:offset+int(length)])
		offset += int(length)
	}
	if offset != len(data) {
		return nil, fmt.Errorf("trailing worker batch bytes")
	}
	return jobs, nil
}

func encodeWorkerResults(results [][]byte) ([]byte, error) {
	total := 12
	for _, result := range results {
		if len(result) > workerMaxJobBytes || len(result) > workerMaxBatchBytes-total-4 {
			return nil, fmt.Errorf("worker results exceed byte limit")
		}
		total += 4 + len(result)
	}
	data := make([]byte, total)
	copy(data, "DWWR")
	binary.LittleEndian.PutUint32(data[4:], 1)
	binary.LittleEndian.PutUint32(data[8:], uint32(len(results)))
	offset := 12
	for _, result := range results {
		binary.LittleEndian.PutUint32(data[offset:], uint32(len(result)))
		offset += 4
		copy(data[offset:], result)
		offset += len(result)
	}
	return data, nil
}
