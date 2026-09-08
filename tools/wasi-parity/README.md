# WASI Bytes parity and benchmark harness

This harness compiles real Dew source to WasmGC and executes the bounded
`Bytes` library functions against deterministic Preview 1 `fd_write` and
`fd_read` host implementations.

```bash
tools/wasi-parity/run.sh
```

The runtime uses this fixed one-page linear-memory layout:

```text
0..7       one WASI iovec
8..11      fd_write/fd_read result count
16..65535  reusable 65,520-byte data scratch
```

Linear memory is temporary staging only. Dew `Bytes` remains owned by an
immutable GC struct over `array<mut v128>` storage.

The deterministic host suite checks complete output and explicit host failures. Coverage includes:

- scalar, vector, old 4 KiB, full-page `65519/65520/65521`, and 100,000-byte boundary lengths;
- every GC backing start alignment from 0 through 15;
- arbitrary bytes including zero and `0xFF`;
- complete and partial writes;
- complete, short, bounded, and multi-window reads;
- exact scratch-capacity and multi-scratch transfers;
- scratch-tail isolation between calls;
- WASI errno traps;
- zero-progress write traps;
- host over-report traps for reads and writes;
- exact Preview 1 import module and field names;
- exported linear memory for the WASI host.

The generated Dew source and Wasm binary are ignored.

The benchmark stage functions are ordinary Dew code in [staging.dew](staging.dew).
They use byte loads/stores and BytesBuilder, with a 65,520-byte bound checked
before any copy. Neither compiler provides a staging runtime builtin. Raw host
probes call the same foreign declarations as other Dew code.

[staging-cases.mjs](staging-cases.mjs) has 54 shared native/self-host checks for
empty/full windows, vector boundaries, all 16 source alignments, exact bytes,
header/tail preservation, immutable read results after scratch changes, and
oversized-range traps before scratch mutation. These run in the normal library
and self-host hardening lanes, not only in the benchmark. Standalone CLI builds
need the test-only memory export helper before this host inspection; that helper
adds a memory export and validates the resulting module.

## Benchmark

After running the parity harness:

```bash
DEW_WASI_BENCH_ITERATIONS=3000 \
DEW_WASI_BENCH_WARMUP=1000 \
DEW_WASI_BENCH_SAMPLES=9 \
node tools/wasi-parity/bench.mjs
```

The benchmark reports benchmark-only GC-to-scratch and scratch-to-GC phases,
raw 4 KiB host callbacks, complete 4 KiB/10,000/65,520/100,000-byte operations,
and a partial-write workload. Full operation measurements retain the executable
Preview 1 boundary, while the phase probes show where time is spent.
The staging migration does not include speed tuning or new benchmark results.
