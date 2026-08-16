# Raw WebAssembly WASI Preview 1 package — August 16, 2026

## Result

`dew.std.wasm.wasi` exposes all 46 functions in the
`wasi_snapshot_preview1` Core Wasm import namespace.

The package is low level and requires an explicit import; `open dew.std.*` does
not select it. Pointers are U32 linear-memory offsets. Callers own all
Preview 1 record, string, iovec, event, and output-buffer layouts. Functions
return the raw U32 errno except `proc_exit`, whose Core Wasm signature has no
result.

Public aliases name the ABI carriers:

- `WasiErrno`, `WasiFd`, `WasiSize`, and `WasiPointer` use U32;
- `WasiTimestamp`, `WasiFilesize`, `WasiRights`, and `WasiDircookie` use U64;
- `WasiFiledelta` uses I64.

## Function groups

The package includes:

- arguments and environment;
- clocks;
- descriptor advice, allocation, close, sync, stat, seek, tell, read, write,
  positional I/O, renumber, and directory reads;
- preopened-directory inspection;
- path create, stat, time update, link, open, readlink, remove, rename, symlink,
  and unlink;
- polling;
- process exit, signal raise, and scheduler yield;
- random bytes;
- socket accept, receive, send, and shutdown.

Builtin names beginning with `wasi_snapshot_preview1.` now map generically to the
exact WASI module and stripped field name. They no longer require one compiler
special case per function.

Any reachable raw WASI import causes memory 0 to be exported as `memory`, as
required by Preview 1 hosts. Unreachable imports remain removed.

## Existing Bytes adapter

`dew.std.wasi` remains compatible. Its `wasi_fd_read` and `wasi_fd_write`
functions still marshal WasmGC `Bytes` through the bounded 65,520-byte scratch
window. It retains only its two private raw imports, so ordinary Bytes-I/O
programs do not pay for the complete raw package's signature surface. If both
packages are selected, equal WASI import identities still coalesce.

Use the nested package for direct ABI work:

```dew
import dew.std.wasm.wasi as @wasi

let errno = @wasi.sched_yield()
```

Use `dew.std.wasi` when GC-owned Bytes are required.

## Validation

`wasm/wasi-preview1-runtime` reaches every one of the 46 functions in one
module. The snapshot host records every call and validates each parameter count
and result-slot count. Node and Wago must observe the complete set before the
fixture can pass.

The WAT snapshot requires:

- exactly 46 `wasi_snapshot_preview1` function imports;
- exact first and last fields, `args_get` and `sock_shutdown`;
- no accidental `dew` module import containing a WASI-prefixed field;
- exported linear memory.

The prior differential Bytes marshalling suite still passes 196 checks, proving
that the old high-level adapter remains compatible.
