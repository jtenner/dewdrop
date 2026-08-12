# Portable I/O abstractions

## Scope

`dew.std.io` defines host-independent byte-stream contracts. It deliberately
contains no WASI imports, file descriptors, sockets, filesystem paths, console
policy, or ambient global streams. Host modules such as `dew.std.wasi` remain
separate adapters.

The initial public contracts are:

```dew
trait Reader {
  fn read(self, limit: U32) -> Result<Bytes, IoError>
}

trait Writer {
  fn write(self, value: Bytes) -> Result<U32, IoError>
}
```

A reader returns at most `limit` bytes. `Ok(b"")` represents end of input. A
writer reports progress from zero through the supplied logical byte length.
Implementations return typed errors rather than trapping for ordinary I/O
failure.

## Error policy

`IoError` has portable structural failures plus one adapter-owned numeric code:

- `UnexpectedEnd`: exact-length input ended early;
- `ZeroProgress`: a helper requiring progress observed zero progress;
- `InvalidProgress`: an implementation reported more bytes than requested or
  supplied;
- `Closed`: a one-shot sink was already finished;
- `LimitExceeded`: a configured or U32 total byte bound would be exceeded;
- `Backend(U32)`: an adapter-specific recoverable error code.

The portable layer never interprets `Backend` values. A WASI adapter may use the
Preview 1 errno value, while another host can define a different stable mapping.
Unexpected implementation traps remain traps; `Result` is not trap unwinding.

## Helpers

- `io_read` and `io_write` perform one trait dispatch.
- `io_read_exact` accumulates exactly the requested length or returns
  `UnexpectedEnd`.
- `io_write_all` retries partial writes over shared `Bytes` views and rejects
  zero progress or over-reporting.
- `io_read_to_end` uses explicit `chunk_limit` and `max_bytes` bounds. It never
  performs an unbounded read.
- `io_copy` transfers bounded chunks, retries partial output, checks U32 total
  overflow, and stops on the first empty read.

All source values and chunks execute once in traversal order. Helpers preserve
the first returned error and do not retry an error implicitly.

## In-memory implementations

`BytesInput` is a mutable reference-identity reader over immutable `Bytes`.
Reads return shared ranges and advance one U32 cursor stored in a fixed array.
EOF is repeatable and returns empty Bytes.

`BytesOutput` is a mutable reference-identity writer backed by `BytesBuilder`.
Every accepted write appends the complete supplied range. `finish` publishes
once; later writes or finishes return `Closed`. Its U32 byte total is checked
before append.

These implementations make portable algorithms testable without a host import
and provide deterministic adapters for parsers, serializers, and protocol code.

## Module and runtime boundary

Importing `dew.std.io` selects `Result`, FixedArray, Bytes, and BytesBuilder, but
not `dew.std.wasi`. The source is embedded through
`tools/generate_io_std.py` for bootstrap builds and loaded as reserved standard
module slot 49.

The `io/portable-core-runtime` WAT architecture case forbids Preview 1 import
names and linear memory, proving that a program using only the portable module
remains a pure WasmGC module. A separate Node/Wago fixture opens WASI only for
observable test output.

## Deferred adapters

This tranche does not change the existing trapping `wasi_fd_read` and
`wasi_fd_write` surface. A later adapter tranche can introduce `WasiReader` and
`WasiWriter` backed by recoverable errno-aware runtime operations without
coupling the portable traits to Preview 1. Filesystem, process, terminal,
network, async, seek, buffering, and text-decoding layers remain separate
modules and roadmap work.
