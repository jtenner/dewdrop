# Wago enum representation benchmark

This small Go module compares Dew-generated WasmGC binaries with the
Wago `wasm3` API. It measures cold compilation, instance creation,
host-to-Wasm execution, Go allocation volume, and encoded bytes.

Use Go 1.26 or later. The module pins Wago `v0.1.0-beta.13` in `go.mod`.
Go downloads this release; a sibling Wago checkout is not required.

Generate Dew binaries through the normal Starshine-validated emission path, then
run:

```text
cd tools/wago-enum-bench
go run . ../../enum-base-envelope.wasm ../../enum-base-subtype.wasm
```

Useful controls:

```text
-compile 300
-instantiate 2000
-warmup 100000
-exec 1000000
-heap-mib 512
-export run
```

The current Wago Wasm 3 API runs generated WasmGC inside a bounded collecting
throughput heap. The benchmark sets an explicit heap size so GC pressure remains
reproducible. On checkout `11192167`, Dew generic-enum and V128-backed text
smokes each completed 1,000,000 calls with a 1 MiB heap. Heap exhaustion remains
a visible runtime failure rather than an ignored sample.

Use binaries exporting `run(i32) -> i32`. The checksum prevents the host loop
from discarding results.
