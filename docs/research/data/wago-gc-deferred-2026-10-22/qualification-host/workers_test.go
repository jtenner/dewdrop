package main

import (
	"bytes"
	"context"
	"encoding/binary"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	wago "github.com/wago-org/wago"
)

func workerBatch(jobs ...[]byte) []byte {
	out := []byte("DWWB\x01\x00\x00\x00")
	out = binary.LittleEndian.AppendUint32(out, uint32(len(jobs)))
	for _, job := range jobs {
		out = binary.LittleEndian.AppendUint32(out, uint32(len(job)))
		out = append(out, job...)
	}
	return out
}

func TestWorkerBatchBounds(t *testing.T) {
	good := workerBatch([]byte("first"), []byte{0, 255})
	jobs, err := decodeWorkerBatch(good)
	if err != nil || len(jobs) != 2 || string(jobs[0]) != "first" || !bytes.Equal(jobs[1], []byte{0, 255}) {
		t.Fatalf("decoded %q, %v", jobs, err)
	}
	cases := map[string][]byte{"empty": nil, "no jobs": workerBatch(), "truncated": good[:len(good)-1], "trailing": append(bytes.Clone(good), 0)}
	for _, name := range []string{"version", "count", "length"} {
		data := bytes.Clone(good)
		at, value := 4, uint32(2)
		if name == "count" {
			at, value = 8, workerMaxJobs+1
		}
		if name == "length" {
			at, value = 12, workerMaxJobBytes+1
		}
		binary.LittleEndian.PutUint32(data[at:], value)
		cases[name] = data
	}
	for name, data := range cases {
		t.Run(name, func(t *testing.T) {
			if _, err := decodeWorkerBatch(data); err == nil {
				t.Fatal("invalid batch accepted")
			}
		})
	}
	if _, err := encodeWorkerResults([][]byte{make([]byte, workerMaxJobBytes+1)}); err == nil {
		t.Fatal("oversized result accepted")
	}
}

type workerBarrier struct {
	mu      sync.Mutex
	arrived int
	both    chan struct{}
	ctx     context.Context
}

func (b *workerBarrier) Register(reg *wago.Registrar) error {
	imports, err := reg.HostImports()
	if err != nil {
		return err
	}
	imports.HostFunc("worker.test", "hold", func(wago.HostCall) {
		b.mu.Lock()
		b.arrived++
		if b.arrived == 2 {
			close(b.both)
		}
		b.mu.Unlock()
		select {
		case <-b.both:
		case <-b.ctx.Done():
			workerTrap(fmt.Errorf("workers failed to overlap: %w", b.ctx.Err()))
		}
	})
	return nil
}

func workerTestWasm(t *testing.T, body string) []byte {
	t.Helper()
	return workerTestWasmBatch(t, body, workerBatch([]byte{16}, []byte{32}))
}

func workerTestWasmBatch(t *testing.T, body string, batch []byte) []byte {
	t.Helper()
	var encoded strings.Builder
	for _, value := range batch {
		fmt.Fprintf(&encoded, `\%02x`, value)
	}
	jobs, decodeErr := decodeWorkerBatch(batch)
	if decodeErr != nil {
		t.Fatal(decodeErr)
	}
	expected, encodeErr := encodeWorkerResults(jobs)
	if encodeErr != nil {
		t.Fatal(encodeErr)
	}
	var checks strings.Builder
	for index, value := range expected {
		fmt.Fprintf(&checks, "local.get $result i32.const %d array.get_u $bytes i32.const %d i32.ne if unreachable end\n", index, value)
	}
	text := `(module
      (type $bytes (array (mut i8)))
      (type $readonly (array i8))
      (type $words (array (mut i32)))
      (import "dewdrop.transform.workers" "capacity" (func $capacity (result i32)))
      (import "dewdrop.transform.workers" "run_batch" (func $batch (param eqref eqref) (result i32)))
      (import "dewdrop.transform.workers" "input" (func $input (param eqref)))
      (import "dewdrop.transform.workers" "input_size" (func $input_size (result i32)))
      (import "dewdrop.transform.workers" "output" (func $output (param eqref)))
      (import "worker.test" "hold" (func $hold))
      (memory 1 2)
      (global $state (mut i32) (i32.const 0))
      (func $init i32.const 7 global.set $state)
      (start $init)
      (func (export "capacity") (result i32) call $capacity)
      (func (export "set_state") (param i32) local.get 0 global.set $state)
      (func (export "state") (result i32) global.get $state)
      (func (export "__dew_transform_worker_run") (local $data (ref null $bytes))
        ` + body + `)
      (func (export "run") (param i32) (result i32)
        (local $result (ref null $bytes))
        i32.const 64 array.new_default $bytes local.set $result
        i32.const 0 local.get 0 array.new_data $bytes 0 local.get $result call $batch drop
        local.get $result i32.const 16 array.get_u $bytes)
      (func (export "run_exact") (result i32)
        (local $result (ref null $bytes)) (local $length i32)
        i32.const 64 array.new_default $bytes local.set $result
        i32.const 0 i32.const ` + fmt.Sprint(len(batch)) + ` array.new_data $bytes 0
        local.get $result call $batch local.tee $length
        i32.const ` + fmt.Sprint(len(expected)) + ` i32.ne if unreachable end
        ` + checks.String() + `
        local.get $length)
      (func (export "output_null") (result i32)
        i32.const 0 i32.const 22 array.new_data $bytes 0 ref.null eq call $batch)
      (func (export "output_words") (result i32)
        i32.const 0 i32.const 22 array.new_data $bytes 0
        i32.const 64 array.new_default $words call $batch)
      (func (export "output_readonly") (result i32)
        i32.const 0 i32.const 22 array.new_data $bytes 0
        i32.const 64 array.new_default $readonly call $batch)
      (func (export "output_short") (result i32)
        i32.const 0 i32.const 22 array.new_data $bytes 0
        i32.const 0 array.new_default $bytes call $batch)
      (func (export "run_null") (result i32)
        ref.null eq ref.null eq call $batch)
      (data "` + encoded.String() + `")
    )`
	directory := t.TempDir()
	input, output := filepath.Join(directory, "workers.wat"), filepath.Join(directory, "workers.wasm")
	if err := os.WriteFile(input, []byte(text), 0600); err != nil {
		t.Fatal(err)
	}
	if log, err := exec.Command("wasm-tools", "parse", input, "-o", output).CombinedOutput(); err != nil {
		t.Fatalf("wat: %v\n%s", err, log)
	}
	data, err := os.ReadFile(output)
	if err != nil {
		t.Fatal(err)
	}
	return data
}

func workerTestRuntime(t *testing.T) (*wago.Runtime, *workerBarrier, *workerPlugin) {
	t.Helper()
	return workerTestRuntimeWithSetting(t, true)
}

func workerTestRuntimeWithSetting(t *testing.T, enabled bool) (*wago.Runtime, *workerBarrier, *workerPlugin) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	t.Cleanup(cancel)
	barrier := &workerBarrier{both: make(chan struct{}), ctx: ctx}
	provider, selection, err := workerProvider(enabled)
	plugin := &workerPlugin{enabled: enabled}
	provider.New = func() wago.Plugin { return plugin }
	if err != nil {
		t.Fatal(err)
	}
	definition := wago.PluginDefinition{ID: "dewdrop.local/worker-test", Name: "Worker test", Version: "1.0.0", Stability: wago.Experimental,
		Provenance:    wago.PluginProvenance{Repository: "https://github.com/jtenner/dewdrop", License: "Apache-2.0"},
		Compatibility: wago.Compatibility{Engines: map[string]string{"wago": ">=0.1.0"}},
		Authorities:   []wago.AuthorityRequest{{Name: wago.AuthorityHostImportDefine, Mode: wago.AuthorityRequired, Reason: "worker overlap test", Scope: wago.AuthorityScope{Modules: []string{"worker.test"}}}},
	}
	digest, err := wago.DefinitionDigest(definition)
	if err != nil {
		t.Fatal(err)
	}
	barrierSelection := wago.PluginSelection{ID: definition.ID, DefinitionDigest: digest, Direct: true, Dependencies: map[string]string{},
		Grants: []wago.AuthorityGrant{{Name: wago.AuthorityHostImportDefine, Scope: definition.Authorities[0].Scope}}}
	runtime := wago.NewRuntime()
	t.Cleanup(func() {
		if err := runtime.Close(); err != nil {
			t.Error(err)
		}
	})
	err = runtime.LoadPlugins(ctx, wago.PluginSet{Providers: []wago.PluginProvider{provider, {Definition: definition, New: func() wago.Plugin { return barrier }}}, Selections: []wago.PluginSelection{selection, barrierSelection}})
	if err != nil {
		t.Fatal(err)
	}
	return runtime, barrier, plugin
}

func TestWorkerInstancesOverlapAndKeepStateSeparate(t *testing.T) {
	runtime, barrier, _ := workerTestRuntime(t)
	source := workerTestWasm(t, `
      call $capacity if unreachable end
      call $input_size array.new_default $bytes local.set $data
      local.get $data call $input
      call $hold
      global.get $state i32.const 1 i32.add global.set $state
      local.get $data i32.const 0 global.get $state array.set $bytes
      local.get $data ref.as_non_null call $output`)
	module, err := runtime.Compile(source)
	if err != nil {
		t.Fatal(err)
	}
	defer module.Close()
	instance, err := runtime.Instantiate(barrier.ctx, module)
	if err != nil {
		t.Fatal(err)
	}
	defer instance.Close()
	if _, err = instance.Invoke("set_state", 99); err != nil {
		t.Fatal(err)
	}
	for range 2 {
		values, err := instance.InvokeContext(barrier.ctx, "run", 22)
		if err != nil || len(values) != 1 || values[0] != 8 {
			t.Fatalf("first job=%v, %v; want 8", values, err)
		}
	}
	state, err := instance.Invoke("state")
	if err != nil || state[0] != 99 {
		t.Fatalf("parent state=%v, %v", state, err)
	}
	if barrier.arrived != 4 {
		t.Fatalf("workers did not all run: %d", barrier.arrived)
	}
}

func TestWorkerTrapReturnsNoSuccessfulBatchAndReclaimsPool(t *testing.T) {
	runtime, barrier, _ := workerTestRuntime(t)
	module, err := runtime.Compile(workerTestWasm(t, `unreachable`))
	if err != nil {
		t.Fatal(err)
	}
	defer module.Close()
	instance, err := runtime.Instantiate(barrier.ctx, module)
	if err != nil {
		t.Fatal(err)
	}
	defer instance.Close()
	for range 2 {
		if _, err := instance.InvokeContext(barrier.ctx, "run", 22); err == nil || !strings.Contains(err.Error(), "job 0") {
			t.Fatalf("worker trap=%v; want source-first job error", err)
		}
	}
}

func TestWorkerCancellationReclaimsPool(t *testing.T) {
	runtime, barrier, _ := workerTestRuntime(t)
	module, err := runtime.Compile(workerTestWasm(t, `(loop br 0)`))
	if err != nil {
		t.Fatal(err)
	}
	defer module.Close()
	instance, err := runtime.Instantiate(barrier.ctx, module)
	if err != nil {
		t.Fatal(err)
	}
	defer instance.Close()
	for range 2 {
		ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
		_, err := instance.InvokeContext(ctx, "run", 22)
		cancel()
		if err == nil || !strings.Contains(err.Error(), "deadline") {
			t.Fatalf("cancellation=%v; want deadline", err)
		}
	}
}

func TestWorkerBusyRejectsBeforeReadingInput(t *testing.T) {
	runtime, barrier, plugin := workerTestRuntime(t)
	module, err := runtime.Compile(workerTestWasm(t, `unreachable`))
	if err != nil {
		t.Fatal(err)
	}
	defer module.Close()
	instance, err := runtime.Instantiate(barrier.ctx, module)
	if err != nil {
		t.Fatal(err)
	}
	defer instance.Close()
	plugin.gate <- struct{}{}
	_, err = instance.InvokeContext(barrier.ctx, "run_null")
	<-plugin.gate
	if err == nil || !strings.Contains(err.Error(), "pool is busy") {
		t.Fatalf("busy pool=%v; want busy before invalid input access", err)
	}
	if _, err = instance.InvokeContext(barrier.ctx, "run", 22); err == nil || !strings.Contains(err.Error(), "job 0") {
		t.Fatalf("pool after busy=%v; want normal worker trap", err)
	}
}

func TestWorkerSourceErrorPrecedesResultOverflow(t *testing.T) {
	runtime, barrier, _ := workerTestRuntime(t)
	batch := workerBatch([]byte{0}, []byte{1}, []byte{2})
	module, err := runtime.Compile(workerTestWasmBatch(t, `
      call $input_size array.new_default $bytes local.set $data
      local.get $data call $input
      local.get $data i32.const 0 array.get_u $bytes i32.eqz if unreachable end
      i32.const 16777216 array.new_default $bytes call $output`, batch))
	if err != nil {
		t.Fatal(err)
	}
	defer module.Close()
	instance, err := runtime.Instantiate(barrier.ctx, module)
	if err != nil {
		t.Fatal(err)
	}
	defer instance.Close()
	for range 2 {
		_, err = instance.InvokeContext(barrier.ctx, "run", uint64(len(batch)))
		if err == nil || !strings.Contains(err.Error(), "job 0") || strings.Contains(err.Error(), "exceed byte limit") {
			t.Fatalf("source error and oversized results=%v; want job 0", err)
		}
	}
}

func TestWorkerPublicationChecks(t *testing.T) {
	cases := map[string]struct{ body, message string }{
		"missing":        {`nop`, "did not publish"},
		"duplicate":      {`i32.const 1 array.new_default $bytes local.tee $data call $output local.get $data call $output`, "once per job"},
		"input capacity": {`i32.const 0 array.new_default $bytes call $input`, "enough space"},
		"nested":         {`ref.null eq ref.null eq call $batch drop`, "nested"},
	}
	for name, test := range cases {
		t.Run(name, func(t *testing.T) {
			runtime, barrier, _ := workerTestRuntime(t)
			module, err := runtime.Compile(workerTestWasm(t, test.body))
			if err != nil {
				t.Fatal(err)
			}
			defer module.Close()
			instance, err := runtime.Instantiate(barrier.ctx, module)
			if err != nil {
				t.Fatal(err)
			}
			defer instance.Close()
			_, err = instance.InvokeContext(barrier.ctx, "run", 22)
			if err == nil || !strings.Contains(err.Error(), test.message) {
				t.Fatalf("publication check=%v; want %q", err, test.message)
			}
		})
	}
}

func TestWorkerInvalidResultBuffersLeavePoolAvailable(t *testing.T) {
	runtime, barrier, _ := workerTestRuntime(t)
	module, err := runtime.Compile(workerTestWasm(t, `
      call $input_size array.new_default $bytes local.set $data
      local.get $data call $input
      local.get $data call $output`))
	if err != nil {
		t.Fatal(err)
	}
	defer module.Close()
	instance, err := runtime.Instantiate(barrier.ctx, module)
	if err != nil {
		t.Fatal(err)
	}
	defer instance.Close()
	if values, err := instance.InvokeContext(barrier.ctx, "run_exact"); err != nil || len(values) != 1 || values[0] != 22 {
		t.Fatalf("complete source-order result bytes=%v, %v", values, err)
	}
	for _, name := range []string{"output_null", "output_words", "output_readonly", "output_short"} {
		if _, err = instance.InvokeContext(barrier.ctx, name); err == nil {
			t.Fatalf("%s accepted an invalid result buffer", name)
		}
		values, err := instance.InvokeContext(barrier.ctx, "run", 22)
		if err != nil || len(values) != 1 || values[0] != 16 {
			t.Fatalf("pool after %s=%v, %v; want a copied first result", name, values, err)
		}
	}
}

func TestWorkerDisabledRejectsBeforeReadingInput(t *testing.T) {
	runtime, barrier, _ := workerTestRuntimeWithSetting(t, false)
	module, err := runtime.Compile(workerTestWasm(t, `unreachable`))
	if err != nil {
		t.Fatal(err)
	}
	defer module.Close()
	instance, err := runtime.Instantiate(barrier.ctx, module)
	if err != nil {
		t.Fatal(err)
	}
	defer instance.Close()
	values, err := instance.InvokeContext(barrier.ctx, "capacity")
	if err != nil || len(values) != 1 || values[0] != 0 {
		t.Fatalf("disabled capacity=%v, %v", values, err)
	}
	if _, err = instance.InvokeContext(barrier.ctx, "run_null"); err == nil || !strings.Contains(err.Error(), "disabled") {
		t.Fatalf("disabled pool=%v; want disabled before invalid input access", err)
	}
}
