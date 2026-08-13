# Dew-native JSON standard library

Status: implemented August 13, 2026.

## Scope

`dew.std.json` provides a strict RFC 8259 value API, deterministic compact
serialization, and bounded Reader/Writer facades. The implementation remains
ordinary Dew source: JSON token classification, whitespace handling, number
validation, escape decoding, duplicate-key policy, delimiter scanning, tree
construction, traversal, and serialization are not compiler builtins.

The public model is intentionally lossless for JSON numbers:

- `JsonValue::Null`, `Bool`, `String`, `Array`, and `Object` represent ordinary
  JSON values;
- `JsonValue::Number(String)` retains the exact accepted number lexeme rather
  than rounding through a host or floating-point carrier;
- `JsonMember` and `Array<JsonMember>` preserve source object-member order;
- parsing and serialization reject duplicate object keys so one deterministic
  object policy applies to both decoded and constructed values;
- `json_object_get` provides source-order lookup without changing object order.

`JsonLimits` independently bounds input bytes, nesting depth, total values, and
decoded string bytes. The defaults are 16 MiB input/string limits, depth 128,
and 1,048,576 values. Limit failures, syntax failures, malformed UTF-8,
malformed escapes, unpaired surrogates, duplicate keys, and trailing data use
explicit typed errors with deterministic byte offsets.

## Strict parsing policy

The parser accepts only RFC 8259 whitespace and grammar:

- literals are exactly `null`, `true`, and `false`;
- numbers reject leading zeroes, missing fraction digits, missing exponent
  digits, signs without integers, and non-JSON spellings such as NaN or
  Infinity;
- strings reject unescaped control bytes and unknown escapes;
- `\uXXXX` decoding combines valid high/low surrogate pairs and rejects every
  unpaired surrogate;
- the complete input must be strict UTF-8 before parsing;
- one complete value plus optional JSON whitespace must consume the input.

Numbers remain exact source strings. Callers can choose a later conversion
policy rather than inheriting an implicit float conversion during parsing.

## SIMD architecture

Whitespace, string-special, and scalar-terminator scanning are implemented in
`std/json.dew` with `U8x16` comparisons, bitmasks, and `u32_ctz`. Scalar loops
handle the final short suffix. This keeps alignment, classification, delimiter
policy, first-match selection, and scalar fallback visible in Dew.

Two narrow representation bridges are compiler-owned:

```dew
wasm_bytes_load_u8x16(value: Bytes, start: U32) -> U8x16
wasm_string_load_u8x16(value: String, start: U32) -> U8x16
```

They load sixteen logical bytes from private GC-backed text views and trap unless
the full chunk is inside the logical view. They share one generic backend
emitter, handle aligned and unaligned backing offsets, and perform no
JSON-specific classification or scan.
The operation is generated into `dew.std.wasm.intrinsics`; the existing
`wasm_v128_load(address: U32)` remains a linear-memory operation and is not used
on GC references.

The other added primitive, `wasm_u32_ctz`, maps directly to Core `i32.ctz`.
There are no `dew_json_*` backend names. Architecture snapshots require the
source parser's `i8x16.eq`, `i8x16.lt_u`, `i8x16.bitmask`, and `i32.ctz`
instructions while rejecting JSON-specific backend helpers.

## Streaming facades

The current streaming surface is bounded I/O over the complete value API:

- `json_parse_reader` and `json_parse_reader_with_limits` consume a `Reader`
  through `io_read_to_end`, then parse the bounded immutable `Bytes` value;
- `json_write` and `json_write_with_limits` serialize once under depth/byte
  limits and complete the write through `io_write_all`;
- `JsonReadError` and `JsonOutputError` preserve whether failure came from the
  portable I/O layer or JSON parsing/serialization.

This is not an incremental SAX/token API. A future incremental API should reuse
the same grammar, limit, UTF-8, duplicate-key, and number-lexeme policies rather
than introduce a second parser contract.

## Backend fixes exposed by recursive JSON values

Recursive `JsonValue` found missing nominal evidence at several WasmGC
boundaries. The fix is general rather than JSON-specific:

- required nominal types are retained transitively when they occur inside
  applied generic arguments such as `Array<JsonValue>`;
- planned expressions carry their exact nominal declaration when one exists;
- struct and enum construction casts nominal and external-nominal fields to the
  precise physical reference type before `struct.new`;
- generic Array operations returning nominal references cast the erased result
  back to the exact nominal type.

Focused backend coverage constructs a recursive enum inside nested generic
arrays and an aggregate field, then validates and encodes the emitted module.
The unoptimized semantic/lowering arenas remain immutable; these changes only
make the existing nominal contract explicit during planning and emission.

## Validation and measurement

Coverage includes:

- direct standard tests for nested values, exact numbers, Unicode escapes,
  malformed UTF-8, malformed syntax, duplicate keys, resource limits,
  deterministic serialization, nested invalid-number reporting, byte limits,
  object lookup, and Reader/Writer facades;
- direct tests for aligned/unaligned GC-backed SIMD loads, out-of-view traps,
  and zero/nonzero `u32_ctz`;
- Node and Wago snapshots for strict parse/stringify, host-independent core
  operation, Reader/Writer operation, and the SIMD bounds trap;
- generated-source, wildcard/selective loading, recursive nominal backend, and
  architecture checks.

`tools/benchmark-json.py` builds a representative nested document and measures a
parse-plus-compact-stringify round trip in Node. A 64-entry, 5,560-byte sample
measured on the development machine at a median **77.442 µs**, or **13.928 ns
per input byte**, across 100 samples with batches of three. The generated module
was 23,431 bytes. The script reports machine-local measurements rather than
encoding them as pass/fail thresholds.

`tools/benchmark-json-comparison.py` additionally extracts json-as's own compact
small, medium, and large fixtures, builds both implementations, and runs them
under one Node/V8 executable. The complete methodology, semantic caveats, and
August 13, 2026 measurements are recorded in
[`json-as-benchmark-comparison.md`](json-as-benchmark-comparison.md). The
comparison shows that String-to-Bytes wrapping is effectively neutral and the
redundant UTF-8 pass accounts for only about 2.4-5.5% of Dew parse time; eager
recursive tree construction and policy work dominate the larger throughput gap.

Wide-object duplicate checking now uses four scalar filters from
`dew.std.bloom_filter` after a 16-key threshold, while every probabilistic
positive still performs the authoritative source-order equality scan. Paired
measurements, threshold analysis, collision coverage, and the exact policy are
recorded in [`json-bloom-prefilter.md`](json-bloom-prefilter.md).

Strict serialization uses index traversal, checks object duplicates against the
existing member prefix rather than a temporary key array, and appends clean text
as validated `StringView` spans. The paired results and remaining costs are
recorded in
[`json-serialization-performance.md`](json-serialization-performance.md).

Validated `String` parsing now uses direct String SIMD, delays builders until an
escape is found, compactly materializes clean StringView spans, validates Bytes
inputs exactly once before a private trusted rewrap, and stores offset/value
count in one fixed two-cell parser state carrier. Serialization stores its error
code and optional typed String payload in fixed cells rather than three growable
arrays. Measurements, rejected workload-dependent candidates, and boundary
coverage are recorded in
[`json-validated-string-performance.md`](json-validated-string-performance.md).
