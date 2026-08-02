package main

import (
	"encoding/binary"
	"reflect"
	"testing"

	wago "github.com/wago-org/wago"
)

type testHostModule struct{ memory []byte }

func (m testHostModule) Memory() []byte { return m.memory }

func TestOutputLines(t *testing.T) {
	got, err := outputLines([]byte("one\r\ntwo\n"))
	if err != nil {
		t.Fatal(err)
	}
	if want := []string{"one", "two"}; !reflect.DeepEqual(got, want) {
		t.Fatalf("output lines = %q, want %q", got, want)
	}
	if _, err := outputLines([]byte{0xff}); err == nil {
		t.Fatal("invalid UTF-8 stdout was accepted")
	}
}

func TestNormalizeTrap(t *testing.T) {
	for _, tc := range []struct {
		code wago.TrapCode
		want string
	}{
		{wago.TrapUnreachable, "unreachable"},
		{wago.TrapLinMemOutOfBounds, "memory-out-of-bounds"},
		{wago.TrapDivZero, "integer-divide-by-zero"},
		{wago.TrapDivOverflow, "integer-overflow"},
		{wago.TrapTruncOverflow, "invalid-conversion-to-integer"},
	} {
		got, ok := normalizeTrap(&wago.TrapError{Code: tc.code})
		if !ok || got != tc.want {
			t.Fatalf("trap %v = %q, %v; want %q, true", tc.code, got, ok, tc.want)
		}
	}
}

func TestSnapshotHostWriteAndRead(t *testing.T) {
	memory := make([]byte, 64)
	binary.LittleEndian.PutUint32(memory[0:4], 16)
	binary.LittleEndian.PutUint32(memory[4:8], 3)
	copy(memory[16:19], "abc")
	host := &snapshotHost{config: hostConfig{}, stdin: []byte("xyz")}
	results := make([]uint64, 64)
	host.fdWrite(
		testHostModule{memory},
		[]uint64{wago.I32(1), wago.I32(0), wago.I32(1), wago.I32(8)},
		results,
	)
	if host.err != nil || string(host.stdout) != "abc" || binary.LittleEndian.Uint32(memory[8:12]) != 3 {
		t.Fatalf("fd_write err=%v stdout=%q written=%d", host.err, host.stdout, binary.LittleEndian.Uint32(memory[8:12]))
	}

	binary.LittleEndian.PutUint32(memory[0:4], 24)
	binary.LittleEndian.PutUint32(memory[4:8], 3)
	host.fdRead(
		testHostModule{memory},
		[]uint64{wago.I32(0), wago.I32(0), wago.I32(1), wago.I32(12)},
		results,
	)
	if host.err != nil || string(memory[24:27]) != "xyz" || binary.LittleEndian.Uint32(memory[12:16]) != 3 {
		t.Fatalf("fd_read err=%v input=%q read=%d", host.err, memory[24:27], binary.LittleEndian.Uint32(memory[12:16]))
	}
}
