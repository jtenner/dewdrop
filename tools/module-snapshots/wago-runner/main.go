package main

import (
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"strings"
	"unicode/utf8"

	wago "github.com/wago-org/wago"
)

type hostConfig struct {
	StdinHex        string `json:"stdin_hex"`
	WriteLimit      *int   `json:"write_limit"`
	ReadLimit       *int   `json:"read_limit"`
	WriteErrno      int    `json:"write_errno"`
	ReadErrno       int    `json:"read_errno"`
	WriteZero       bool   `json:"write_zero"`
	WriteOverreport bool   `json:"write_overreport"`
	ReadOverreport  bool   `json:"read_overreport"`
}

type runtimeResult struct {
	Output []string `json:"output"`
	Trap   *string  `json:"trap"`
}

type snapshotHost struct {
	config      hostConfig
	stdin       []byte
	stdinOffset int
	stdout      []byte
	err         error
}

func fail(format string, args ...any) {
	fmt.Fprintf(os.Stderr, format+"\n", args...)
	os.Exit(2)
}

func configuredLimit(value *int, fallback int) int {
	if value == nil {
		return fallback
	}
	return *value
}

func memoryRange(memory []byte, offset, length uint32) ([]byte, bool) {
	end := uint64(offset) + uint64(length)
	if end > uint64(len(memory)) {
		return nil, false
	}
	return memory[offset:end], true
}

func iovecCapacity(memory []byte, iovs, iovsLength uint32) (uint32, bool) {
	var total uint64
	for index := uint32(0); index < iovsLength; index++ {
		iovec, ok := memoryRange(memory, iovs+index*8, 8)
		if !ok {
			return 0, false
		}
		total += uint64(binary.LittleEndian.Uint32(iovec[4:8]))
		if total > uint64(^uint32(0)) {
			return 0, false
		}
	}
	return uint32(total), true
}

func (h *snapshotHost) captureIovecs(memory []byte, iovs, iovsLength, count uint32) bool {
	remaining := count
	for index := uint32(0); index < iovsLength && remaining > 0; index++ {
		iovec, ok := memoryRange(memory, iovs+index*8, 8)
		if !ok {
			return false
		}
		pointer := binary.LittleEndian.Uint32(iovec[0:4])
		length := binary.LittleEndian.Uint32(iovec[4:8])
		if length > remaining {
			length = remaining
		}
		bytes, ok := memoryRange(memory, pointer, length)
		if !ok {
			return false
		}
		h.stdout = append(h.stdout, bytes...)
		remaining -= length
	}
	return remaining == 0
}

func (h *snapshotHost) fillIovecs(memory []byte, iovs, iovsLength, count uint32) bool {
	remaining := count
	for index := uint32(0); index < iovsLength && remaining > 0; index++ {
		iovec, ok := memoryRange(memory, iovs+index*8, 8)
		if !ok {
			return false
		}
		pointer := binary.LittleEndian.Uint32(iovec[0:4])
		length := binary.LittleEndian.Uint32(iovec[4:8])
		if length > remaining {
			length = remaining
		}
		target, ok := memoryRange(memory, pointer, length)
		if !ok || h.stdinOffset+int(length) > len(h.stdin) {
			return false
		}
		copy(target, h.stdin[h.stdinOffset:h.stdinOffset+int(length)])
		h.stdinOffset += int(length)
		remaining -= length
	}
	return remaining == 0
}

func (h *snapshotHost) hostError(message string) {
	if h.err == nil {
		h.err = errors.New(message)
	}
}

func (h *snapshotHost) fdWrite(module wago.HostModule, params, results []uint64) {
	if len(params) != 4 || len(results) < 1 {
		h.hostError(fmt.Sprintf("fd_write received params=%d results=%d", len(params), len(results)))
		return
	}
	if h.config.WriteErrno != 0 {
		results[0] = wago.I32(int32(h.config.WriteErrno))
		return
	}
	memory := module.Memory()
	fd := uint32(wago.AsI32(params[0]))
	iovs := uint32(wago.AsI32(params[1]))
	iovsLength := uint32(wago.AsI32(params[2]))
	written := uint32(wago.AsI32(params[3]))
	requested, ok := iovecCapacity(memory, iovs, iovsLength)
	if !ok {
		h.hostError("fd_write iovec range is outside linear memory")
		results[0] = wago.I32(21)
		return
	}
	count := requested
	if h.config.WriteOverreport {
		count++
	} else if h.config.WriteZero {
		count = 0
	} else if limit := configuredLimit(h.config.WriteLimit, int(requested)); limit < int(count) {
		count = uint32(limit)
	}
	if fd == 1 && count <= requested && !h.captureIovecs(memory, iovs, iovsLength, count) {
		h.hostError("fd_write payload range is outside linear memory")
		results[0] = wago.I32(21)
		return
	}
	writtenBytes, ok := memoryRange(memory, written, 4)
	if !ok {
		h.hostError("fd_write result pointer is outside linear memory")
		results[0] = wago.I32(21)
		return
	}
	binary.LittleEndian.PutUint32(writtenBytes, count)
	results[0] = wago.I32(0)
}

func (h *snapshotHost) fdRead(module wago.HostModule, params, results []uint64) {
	if len(params) != 4 || len(results) < 1 {
		h.hostError(fmt.Sprintf("fd_read received params=%d results=%d", len(params), len(results)))
		return
	}
	if h.config.ReadErrno != 0 {
		results[0] = wago.I32(int32(h.config.ReadErrno))
		return
	}
	memory := module.Memory()
	iovs := uint32(wago.AsI32(params[1]))
	iovsLength := uint32(wago.AsI32(params[2]))
	read := uint32(wago.AsI32(params[3]))
	requested, ok := iovecCapacity(memory, iovs, iovsLength)
	if !ok {
		h.hostError("fd_read iovec range is outside linear memory")
		results[0] = wago.I32(21)
		return
	}
	count := requested
	if h.config.ReadOverreport {
		count++
	} else {
		available := len(h.stdin) - h.stdinOffset
		if available < int(count) {
			count = uint32(available)
		}
		if limit := configuredLimit(h.config.ReadLimit, int(requested)); limit < int(count) {
			count = uint32(limit)
		}
		if !h.fillIovecs(memory, iovs, iovsLength, count) {
			h.hostError("fd_read payload range is outside linear memory")
			results[0] = wago.I32(21)
			return
		}
	}
	readBytes, ok := memoryRange(memory, read, 4)
	if !ok {
		h.hostError("fd_read result pointer is outside linear memory")
		results[0] = wago.I32(21)
		return
	}
	binary.LittleEndian.PutUint32(readBytes, count)
	results[0] = wago.I32(0)
}

func normalizeTrap(err error) (string, bool) {
	var trap *wago.TrapError
	if !errors.As(err, &trap) {
		return "", false
	}
	switch trap.Code {
	case wago.TrapUnreachable:
		return "unreachable", true
	case wago.TrapLinMemOutOfBounds, wago.TrapLinkedMemOutOfBounds:
		return "memory-out-of-bounds", true
	case wago.TrapDivZero:
		return "integer-divide-by-zero", true
	case wago.TrapDivOverflow:
		return "integer-overflow", true
	case wago.TrapTruncOverflow:
		return "invalid-conversion-to-integer", true
	default:
		message := strings.ToLower(err.Error())
		if (strings.Contains(message, "array") && strings.Contains(message, "out of bounds")) ||
			strings.Contains(message, "builtin.trap executed") ||
			strings.Contains(message, "cast failure") ||
			strings.Contains(message, "stack fence breached") {
			return "array-out-of-bounds", true
		}
		return "", false
	}
}

func outputLines(stdout []byte) ([]string, error) {
	if len(stdout) == 0 {
		return []string{}, nil
	}
	if !utf8.Valid(stdout) {
		return nil, errors.New("captured stdout is not strict UTF-8")
	}
	lines := strings.Split(string(stdout), "\n")
	for index, line := range lines {
		lines[index] = strings.TrimSuffix(line, "\r")
	}
	if len(lines) > 0 && lines[len(lines)-1] == "" {
		lines = lines[:len(lines)-1]
	}
	return lines, nil
}

func main() {
	if len(os.Args) != 4 {
		fail("usage: wago-runner BINARY HOST_JSON MODE")
	}
	binaryPath, hostJSON, mode := os.Args[1], os.Args[2], os.Args[3]
	if mode != "production" && mode != "test" {
		fail("runtime mode must be production or test")
	}
	var config hostConfig
	decoder := json.NewDecoder(strings.NewReader(hostJSON))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&config); err != nil {
		fail("invalid host JSON: %v", err)
	}
	if config.WriteLimit != nil && *config.WriteLimit <= 0 {
		fail("write_limit must be positive")
	}
	if config.ReadLimit != nil && *config.ReadLimit <= 0 {
		fail("read_limit must be positive")
	}
	stdin, err := hex.DecodeString(config.StdinHex)
	if err != nil {
		fail("stdin_hex must be hexadecimal: %v", err)
	}
	binaryBytes, err := os.ReadFile(binaryPath)
	if err != nil {
		fail("cannot read module: %v", err)
	}

	host := &snapshotHost{config: config, stdin: stdin}
	compiled, err := wago.Compile(
		wago.NewRuntimeConfig().
			WithCoreFeatures(wago.CoreFeaturesV3).
			WithBoundsChecks(wago.BoundsChecksExplicit),
		binaryBytes,
	)
	if err != nil {
		fail("compile: %v", err)
	}
	defer compiled.Close()
	instance, err := wago.Instantiate(compiled, wago.InstantiateOptions{
		Imports: wago.Imports{
			"wasi_snapshot_preview1.fd_write": wago.HostFunc(host.fdWrite),
			"wasi_snapshot_preview1.fd_read":  wago.HostFunc(host.fdRead),
		},
		GC: wago.GCConfig{ThroughputHeapBytes: 64 << 20},
	})
	if err != nil {
		fail("instantiate: %v", err)
	}
	defer instance.Close()

	invoke := func(name string) error {
		_, invokeErr := instance.Invoke(name)
		if host.err != nil {
			fail("host callback: %v", host.err)
		}
		return invokeErr
	}
	var invokeErr error
	if mode == "test" {
		for _, name := range compiled.ExportedFunctions() {
			if strings.HasPrefix(name, "__dew_test_") {
				if invokeErr = invoke(name); invokeErr != nil {
					break
				}
			}
		}
	}
	if invokeErr == nil {
		invokeErr = invoke("main")
	}
	lines, err := outputLines(host.stdout)
	if err != nil {
		fail("stdout: %v", err)
	}
	result := runtimeResult{Output: lines}
	if invokeErr != nil {
		trap, ok := normalizeTrap(invokeErr)
		if !ok {
			fail("fixture main failed with unsupported error: %v", invokeErr)
		}
		result.Trap = &trap
	}
	encoded, err := json.Marshal(result)
	if err != nil {
		fail("encode result: %v", err)
	}
	os.Stdout.Write(encoded)
}
