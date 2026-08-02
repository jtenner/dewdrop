# StringView, StringBuilder, and BytesBuilder runtime benchmark

## Purpose

This benchmark decides whether shared String ranges and mutable-at-construction String/Bytes builders justify their runtime and ABI complexity. It executes the exact
Dew-generated WasmGC runtime shapes rather than a host-language approximation.

The harness lives under `tools/wago-string-bench/`. `src/string_bench_gen`
compiles the Dew source through semantic analysis, lowering, Starshine
validation, and Wasm encoding.

## Workloads

All exports use physical `i32 -> i32` signatures and return accumulated
checksums:

```text
identity                  host invocation baseline
flat_scan                 aligned flat String UTF-16 scan
view_create               checked shared StringView allocation
view_scan                 unaligned shared StringView UTF-16 scan
string_slice_scan         exact copied String slice, then scan
bytes_subarray_create     checked shared Bytes subarray
bytes_slice_copy          exact copied Bytes slice
string_concat_create      exact flat String plus String concatenation
string_concat_view_create exact flat String plus StringView concatenation
bytes_find_byte_present   SIMD scan with a match at logical byte 63
bytes_find_byte_absent       SIMD scan with no matching byte
bytes_find_substring_present short-needle SIMD candidates with a late match
bytes_find_substring_absent     short-needle SIMD candidates with no match
bytes_find_long_substring_present rolling fingerprint with a late match
bytes_find_long_substring_absent  rolling fingerprint with no match
string_find_string                String plus String search
string_find_view                  String plus StringView search
string_view_find_view             StringView plus StringView search
string_view_find_string           StringView plus String search
string_prefix_view                String plus StringView prefix match
string_view_suffix_string         StringView plus String suffix match
bytes_prefix_match                exact 16-byte logical prefix match
bytes_suffix_match        exact 16-byte logical suffix match
bytes_concat_create       exact flat arbitrary Bytes concatenation
repeated_string_concat    eight left-associated flat String fragments
exact_builder_concat      one exact-capacity builder over those fragments
view_copy_scan            view copy through StringBuilder, then scan
builder_scalars           ASCII and Unicode scalar StringBuilder construction
builder_checked_bytes     checked Bytes-to-StringBuilder append
builder_fragments         HTTP-like fragmented StringBuilder construction
bytes_builder_fragments   binary fragmented BytesBuilder construction
```

The runtime uses dynamic two-chunk swizzle assembly for unaligned logical V128
loads. Builder append uses logical V128 loads and unaligned two-chunk writes for
full blocks, with scalar handling only for tails.

## Node result

Warmed release run on July 31, 2026:

```text
Node: v26.3.0
iterations per sample: 50000
warmup calls: 15000
samples: 9

identity                       median   9.18 ns
flat_scan                      median  29.48 ns
view_create                    median  17.46 ns
view_scan                      median  25.12 ns
string_slice_scan              median  47.39 ns
bytes_subarray_create          median   9.57 ns
bytes_slice_copy               median  34.62 ns
string_concat_create           median  50.33 ns
string_concat_view_create      median  46.51 ns
bytes_find_byte_present        median  27.67 ns
bytes_find_byte_absent         median  28.29 ns
bytes_find_substring_present   median  75.39 ns
bytes_find_substring_absent    median  96.11 ns
bytes_find_long_substring_present median 312.86 ns
bytes_find_long_substring_absent  median 266.85 ns
string_find_string             median  45.70 ns
string_find_view               median  44.90 ns
string_view_find_view          median  41.80 ns
string_view_find_string        median  43.29 ns
string_prefix_view             median  31.54 ns
string_view_suffix_string      median  23.61 ns
bytes_prefix_match             median  16.44 ns
bytes_suffix_match             median  24.14 ns
bytes_concat_create            median  37.27 ns
repeated_string_concat         median 279.68 ns
exact_builder_concat           median 136.76 ns
view_copy_scan                 median  46.64 ns
builder_scalars                median  49.75 ns
builder_checked_bytes          median  67.44 ns
builder_fragments              median 186.24 ns
bytes_builder_fragments        median 101.56 ns
```

Absolute nanoseconds remain machine- and runtime-specific. The same-run result
shows the important representation ratios:

```text
view_scan / flat_scan                    = 0.85
string_slice_scan / view_scan            = 1.89
bytes_slice_copy / bytes_subarray        = 3.62
view_copy_scan / view_scan               = 1.86
repeated_string_concat / exact_builder   = 2.05
```

For the current 36-byte scan workload, an unaligned shared StringView is slightly faster than the aligned flat baseline in this run. Exact-copy String slice followed by one scan costs about 89% more than scanning the shared view. Creating an exact-copy Bytes slice costs about 3.6 times as much as creating the corresponding shared Bytes subarray. These results support explicit copy semantics rather than automatic compaction and keep StringView as an O(1) shared range for one-shot consumers.

One exact 36-byte concatenation costs about 37–50 ns for String, StringView, and arbitrary Bytes inputs. A 64-byte SIMD byte search costs about 28 ns whether the match is at the final byte or absent. A 124-byte short-needle substring search costs about 75 ns for a late match and 96 ns when absent; before SIMD candidate filtering, the same workloads measured roughly 240 ns and 234 ns. Long 28-byte rolling-fingerprint search over the same haystack costs about 313 ns for a late verified match and 267 ns when absent. Unicode String/StringView searches over the current 26-byte logical range cost about 42–46 ns across all four operand combinations; mixed prefix/suffix checks cost about 24–32 ns. Eight left-associated flat String fragments cost about 280 ns, versus about 137 ns through one exact-capacity builder. The 2.05 ratio confirms the intended policy: `concat` is the simple two-value operation, while builders are the sequential many-fragment path; Dew does not need rope nodes for these workloads.

Direct ASCII plus Unicode scalar construction takes about 50 ns, while checked Bytes append takes about 67 ns for the current small workload. The 141-byte HTTP-like StringBuilder workload takes about 186 ns including literal construction, builder allocation, capacity growth, multiple appends, finish, and byte-length observation. The SIMD append path remains substantially below the earlier roughly 360 ns scalar-byte baseline. The 96-byte arbitrary binary BytesBuilder workload, including two individual-byte appends and growth from one byte of requested capacity, takes about 102 ns.

## Wago status

`v128_array_probe.wat` isolates the essential runtime shape:

```wat
(type $chunks (array (mut v128)))
```

On August 1, 2026, checkout `11192167` accepts and executes this probe through
the Wago API when the runtime config explicitly enables `CoreFeaturesV3`. The
same path also executes Dew-generated generic `Option<I32>` and `Bytes.find_byte`
smokes over the V128 GC-array text representation. The earlier
`unsupported v128 storage` blocker is resolved for the Core 3 API path.

The current `canary-c18b63d-431-g11192167` binary is on `PATH`, but the
standalone CLI deliberately starts from Wago's documented WebAssembly 2 default
runtime config and currently exposes no Core 3 selection flag. It therefore
reports `gc disabled` for Dew WasmGC binaries even though the same engine accepts
them through `CoreFeaturesV3`. The Core 3 API sustained 1,000,000 generic-enum
calls and 1,000,000 V128-backed byte-search calls with a 1 MiB throughput heap,
confirming collection and repeated execution rather than only one-shot startup.
All 31 exports in the complete 22,821-byte Dew String/StringView/Bytes/builder
benchmark also compiled, instantiated, and executed through that API with a
1 MiB heap.
The checked-in WAT probe remains a deterministic CLI-configuration gate. Node
remains the primary full benchmark runtime, while Starshine remains the
compiler-side validator.

## Current decision

- Keep `String` and `Bytes` as shared ranges over V128 chunks.
- Keep `StringView` as a distinct strict-UTF-8 nominal range.
- Keep `view` and `subarray` shared and zero-copy.
- Keep `slice` and `compact` explicit exact-copy operations.
- Keep two-value `concat` flat, overflow-checked, exact-sized, and start-zero.
- Keep byte, String, and StringView substring and prefix/suffix matching allocation-free over logical ranges.
- Use SIMD first/last-byte candidate masks for needles through sixteen bytes and rolling fingerprints with exact verification for longer needles.
- Use builders rather than repeated left-associated concatenation for many fragments.
- Do not compact shared ranges automatically.
- Keep `StringBuilder` as the sequential text construction path.
- Keep `BytesBuilder` as the arbitrary binary construction path and future WASI input target.
- Defer ropes until representative concat/persistent-edit workloads can beat
  StringBuilder without regressing scan and output workloads.
- Add explicit `compact()` only with retained-backing benchmarks and policy.
