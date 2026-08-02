# Dew StringView and StringBuilder benchmark

This harness measures the actual Dew-generated WasmGC representation used by
`String`, `StringView`, `Bytes`, and `StringBuilder`. It separates host-call
cost, flat UTF-16 scanning, shared-view creation, shared-view scanning,
view-to-flat builder copying, and fragmented builder construction.

Generate the benchmark module through the normal semantic, lowering,
Starshine-validation, and binary-encoding pipeline:

```text
moon run --target native --release src/string_bench_gen
```

Run warmed Node measurements and the Wago feature probe:

```text
tools/wago-string-bench/run.sh
```

Node controls are environment variables:

```text
DEW_STRING_BENCH_ITERATIONS=100000
DEW_STRING_BENCH_WARMUP=20000
DEW_STRING_BENCH_SAMPLES=15
```

Exports have the common physical signature `i32 -> i32`:

```text
identity           host invocation baseline
flat_scan          aligned flat String UTF-16 scan
view_create        checked shared StringView allocation
view_scan              unaligned shared StringView UTF-16 scan
string_slice_scan      exact copied String slice, then scan
bytes_subarray_create  checked shared Bytes subarray
bytes_slice_copy          exact copied Bytes slice
string_concat_create      flat String plus String copy
string_concat_view_create flat String plus StringView copy
bytes_find_byte_present   SIMD byte search with a late match
bytes_find_byte_absent       SIMD byte search with no match
bytes_find_substring_present short-needle SIMD candidate search with a late match
bytes_find_substring_absent     short-needle SIMD candidate search with no match
bytes_find_long_substring_present rolling-fingerprint search with a late match
bytes_find_long_substring_absent  rolling-fingerprint search with no match
string_find_string                String haystack plus String needle
string_find_view                  String haystack plus StringView needle
string_view_find_view             StringView haystack plus StringView needle
string_view_find_string           StringView haystack plus String needle
string_prefix_view                String plus StringView prefix matching
string_view_suffix_string         StringView plus String suffix matching
bytes_prefix_match                exact logical prefix comparison
bytes_suffix_match        exact logical suffix comparison
bytes_concat_create       flat arbitrary Bytes copy
repeated_string_concat    repeated left-associated flat concatenation
exact_builder_concat      one exact-capacity builder over the same fragments
view_copy_scan            view copy through StringBuilder, then scan
builder_scalars          ASCII and Unicode scalar StringBuilder construction
builder_checked_bytes    checked Bytes-to-StringBuilder append
builder_fragments        HTTP-like fragmented StringBuilder construction
bytes_builder_fragments  binary fragmented BytesBuilder construction
```

`v128_array_probe.wat` is a minimal hand-written WasmGC module containing the
same essential `array<mut v128>` storage shape. It isolates runtime feature
support from Dew's larger generated type section. As of August 1, 2026, local
checkout `11192167` executes the probe and Dew-generated text smokes through the
Wago API with `CoreFeaturesV3`, including 1,000,000 byte-search calls with a
1 MiB throughput heap. All 31 exports in the complete 22,821-byte generated
benchmark also pass focused compile/instantiate/invoke smokes with that heap.
The `canary-c18b63d-431-g11192167` CLI is on `PATH`, but
its documented default remains WebAssembly 2 and it exposes no Core 3 selection
flag, so `wago run` reports `gc disabled` for these modules. Keep this probe as
both a feature and CLI-configuration gate. Node remains the primary full
benchmark runtime.

Generated binaries are ignored:

```text
tools/wago-string-bench/string_bench.wasm
tools/wago-string-bench/v128_array_probe.wasm
```

Absolute timings are machine- and runtime-specific. Compare same-run ratios,
especially `view_scan / flat_scan` and `view_copy_scan / view_scan`, and retain
the checksum so benchmark work remains observable.
