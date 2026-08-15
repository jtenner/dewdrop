# Bounded WASI Bytes marshalling

## Status

Implemented for WASI Preview 1 `fd_write` and `fd_read`.

Public Dew surface:

```dew
wasi_fd_write(fd: U32, value: Bytes) -> U32
wasi_fd_read(fd: U32, limit: U32) -> Bytes
```

`wasi_fd_write` writes the complete logical value and returns its byte length.
`wasi_fd_read` reads at most `limit` bytes. It continues after a full 65,520-byte
host read and stops at the limit, EOF, or the first short read. Any nonzero
WASI errno traps. Invalid host progress also traps.

## Declarative schema

`src/backend/wasi_marshalling_schema.mbt` now describes Preview 1 boundaries as
bounded trees of `I32`, input/output bytes, pointers, and lists. Every schema
has explicit maximum depth and node counts. Byte and list bounds are validated
before code generation. `fd_write` and `fd_read` use the same one-iovec fast
path below, but their pointer shape is no longer implicit in handwritten
address constants. This is the staging boundary for more Preview 1 calls.

## Ownership

Dew `Bytes` remains an immutable WasmGC value:

```text
chunks: array<mut v128>
start:  U32
length: U32
```

Linear memory is never canonical ownership. It is one reusable staging window
with a fixed layout:

```text
0..7       Preview 1 iovec { address: U32, length: U32 }
8..11      host-written byte count
16..65535  65,520-byte data scratch
```

One memory32 page is sufficient. No `memory.grow` operation is needed.
Modules that do not reach a WASI marshalling operation retain neither the WASI
imports nor linear memory.

## Write path

For each remaining logical range:

1. Select `min(remaining, 65520)` bytes.
2. Assemble aligned or independently unaligned logical V128 values directly
   from the GC chunk array.
3. Copy aligned sources in four-vector, 64-byte batches before the generic
   dynamic V128 and scalar-tail paths.
4. Store the complete staged window into scratch once.
5. Call `wasi_snapshot_preview1.fd_write` with one iovec.
6. Validate that the host reported `1..offered_length` bytes.
7. On partial progress, advance the iovec pointer within the already staged
   scratch range and call again without recopying GC data.
8. Stage a new window only after the current scratch range is exhausted.

Partial writes therefore cannot duplicate or skip bytes and no longer cause
repeated copying of overlapping GC ranges.

## Read path

For each available output window:

1. Request `min(limit - total, 65520)` bytes into scratch.
2. Validate that the host did not report more than requested.
3. Stop on zero bytes.
4. Geometrically grow private GC backing when required.
5. Copy aligned destinations in four-vector, 64-byte batches; use dynamic
   masked V128 writes only for independently unaligned destinations.
6. Copy only the exact scalar tail.
7. Continue only when the host filled the requested window.
8. Publish one start-zero `Bytes` wrapper with the exact accumulated length.

New GC chunks are zero-initialized. Masked writes preserve existing bytes and
unused publication tails remain zero.

## Imports and reachability

Compiler-owned raw imports use exact Preview 1 names:

```text
wasi_snapshot_preview1.fd_write
wasi_snapshot_preview1.fd_read
```

The semantic reachability pass freezes each raw import as a private dependency
of its corresponding runtime operation before final function-index assignment.
Unused compiler-owned imports are now elided just like unused compiler-owned
runtime bodies. A module that performs only ordinary text or numeric work has
no WASI imports and does not gain linear memory.

Reachable linear memory is exported as `memory`, allowing standard WASI hosts
to resolve iovec and scratch addresses.

## Failure semantics

The initial API deliberately traps on:

- nonzero WASI errno;
- zero-progress `fd_write` while bytes remain;
- a write count greater than the offered iovec length;
- a read count greater than the offered iovec length.

This keeps partial output from being mistaken for success. A future typed
`WasiResult<T>` surface can preserve errno values without changing the bounded
marshalling engine.

## Differential coverage

`tools/wasi-parity/run.sh` executes 196 fail-closed checks over:

- all 16 GC backing starts;
- zero, scalar-tail, exact-vector, legacy 4 KiB, full-page `65519/65520/65521`, and 100,000-byte lengths;
- arbitrary binary payloads;
- partial writes and short reads;
- read limits and EOF;
- scratch reuse and tail isolation;
- errno, zero-progress, and over-report traps;
- exact imports and memory export;
- single-module and linked-program Starshine validation.

## Optimized Node measurements

Node v26.3.0, warmed release-generated WasmGC, 3,000 iterations and nine
samples:

```text
phase-only:
stage_write_4096          478.29 ns
stage_write_10000       1,290.46 ns
stage_write_65520       9,196.02 ns
stage_read_4096           334.77 ns
stage_read_10000          905.58 ns
stage_read_65520        5,667.17 ns
host_write_callback_4096  130.78 ns
host_read_callback_4096   178.91 ns

complete Preview 1 boundary:
write_4096                 585.19 ns
write_10000              1,503.13 ns
write_65520             10,120.81 ns
write_100000            18,422.78 ns
write_partial_10000_1024 2,350.37 ns
read_4096                  519.33 ns
read_10000               1,058.88 ns
read_65520               6,589.61 ns
read_100000             17,263.51 ns
```

Compared with the original 4 KiB scratch implementation, complete writes
improved by about 10% at 4 KiB and 7% at 10,000 bytes. Reads improved by about
18% at 4 KiB and 55% at 10,000 bytes. The large 10,000-byte read gain comes
primarily from replacing three host windows and two GC backing growth steps
with one host window and one exact initial allocation.

The phase probes are benchmark-only compiler runtime operations and are not
part of the Dew standard API. Full measurements include the JavaScript Preview
1 callback. Read callbacks also fill scratch, and complete reads include GC
backing construction.

## Static-link interaction

The Core Wasm linker preserves the Dew host-facing WASI memory as the first Dew
memory. Guest memories stay private and receive distinct indices. Deep
instruction remapping includes both explicit multi-memory operands and implicit
memory-0 operands.

## Follow-up work

- Add recoverable `WasiReader`/`WasiWriter` adapters implementing the portable `dew.std.io` traits while preserving exact Preview 1 errno values; the existing direct WASI functions remain trapping.
- Add scatter/gather APIs only if profiling justifies more than one iovec.
- Integrate portable streams with the CLI runtime without making `dew.std.io` host-specific.
- Run full WASI marshalling on Wago after its standalone CLI enables Core 3 and the required WASI host plugin is configured; the Core 3 API now accepts V128 GC-array storage.
- Measure larger regular-file and socket-like workloads.
