# Dew JSON and json-as benchmark comparison

Status: initial comparison and post-optimization measurements recorded August 13, 2026.

## Purpose

This benchmark answers two separate questions:

1. How does Dew's strict, eager `JsonValue` implementation compare with
   json-as on the same documents?
2. How much of Dew's String parsing time is caused by the current
   `String -> Bytes -> UTF-8 validation` route?

The comparison is intentionally explicit about semantic differences. Dew parses
schema-less JSON into a complete recursive tree, preserves every number as its
exact source lexeme, decodes every string eagerly, rejects duplicate object
keys, and validates strict UTF-8. json-as has both a generated schema-specific
struct path and a dynamic `JSON.Obj` path; the latter may retain source slices
for nested values and serialize an untouched object from its original source.
Those are useful public APIs, but they do not perform identical work.

## Reproduction

Run:

```text
python3 tools/benchmark-json-comparison.py \
  --json-as-dir .tmp/json-as \
  --samples 101 \
  --target-batch-bytes 262144 \
  --output .tmp/json-comparison/results.json
```

The script extracts the compact `small`, `medium`, and `large` fixture strings
from json-as itself, builds one Dew module per fixture, builds json-as in SIMD
mode with its documented AssemblyScript and `wasm-opt` speed settings, and runs
both under the same Node/V8 executable.

Measured revisions and tools:

- Dew: `f6d8ab3467ea7407f249d458879e30b1c89a45c7`;
- json-as: `22369a3fdca709a02dd81a19da528a02b62e3088`, package version 1.6.0;
- Node: 26.3.0;
- AssemblyScript: 0.28.20;
- Binaryen `wasm-opt`: 116;
- host: AMD Ryzen 7 8845HS, Linux x86-64.

Dew measurements use 101 interleaved samples and enough repeated operations to
process approximately 256 KiB per timed call. The reported value is the median;
the result artifact also records the 25th and 75th percentiles. json-as uses its
own benchmark loop, operation counts, warmup, black box, and incremental
runtime, with preallocation capped at 64 MiB for this local comparison.

## Results

### Deserialization

| Fixture | Input | Dew eager `JsonValue` | json-as `JSON.Obj` | json-as typed struct | Dew / `JSON.Obj` |
|---|---:|---:|---:|---:|---:|
| small | 44 B | 414.22 ns, 106.22 MB/s | 227.99 ns, 192.99 MB/s | 81.20 ns, 541.89 MB/s | 1.82x |
| medium | 1,070 B | 6.050 us, 176.87 MB/s | 734.48 ns, 1,456.82 MB/s | 1.691 us, 632.94 MB/s | 8.24x |
| large | 5,251 B | 22.872 us, 229.58 MB/s | 2.628 us, 1,998.26 MB/s | 3.784 us, 1,387.83 MB/s | 8.70x |

The typed path is 5.10x, 3.58x, and 6.05x faster than Dew for the small, medium,
and large fixtures respectively. It is generated for the exact destination
schema, so it is not a substitute for Dew's schema-less `JsonValue` API, but it
shows the potential value of future typed decoding.

The dynamic comparison is closer in API shape, but not in completed work:
json-as `JSON.Obj` stores flat NaN-boxed slots and can retain lazy source ranges
for nested strings and composites. Dew allocates the complete recursive tree,
materializes all keys and values, validates exact number lexemes, and performs
quadratic array-backed duplicate-key checks within each object. The widening
medium/large gap is therefore not primarily a SIMD-width problem.

### Serialization

| Fixture | Dew eager tree | json-as `JSON.Obj` | json-as typed struct | Dew / `JSON.Obj` |
|---|---:|---:|---:|---:|
| small | 294.18 ns, 149.57 MB/s | 44.93 ns, 979.34 MB/s | 56.88 ns, 773.49 MB/s | 6.55x |
| medium | 5.331 us, 200.73 MB/s | 81.52 ns, 13,125.11 MB/s | 484.04 ns, 2,210.55 MB/s | 65.39x |
| large | 20.193 us, 260.04 MB/s | 266.98 ns, 19,668.35 MB/s | 1.674 us, 3,136.14 MB/s | 75.63x |

The `JSON.Obj` serialization numbers are not an algorithm-for-algorithm
comparison. json-as records the untouched source range and can stream that range
back out; Dew traverses the tree, revalidates exact number lexemes, rechecks
object duplicates, escapes strings, and builds a fresh compact String. The typed
struct path also uses generated field-specific serialization. A future fair
serialization comparison needs either forced materialization/mutation of
`JSON.Obj` or a Dew raw/lazy document API with the same passthrough contract.

### String versus Bytes in Dew

| Fixture | String parse | Bytes parse | String / Bytes | UTF-8 validation alone |
|---|---:|---:|---:|---:|
| small | 414.22 ns | 412.13 ns | 1.005x | 22.87 ns, 5.52% of parse |
| medium | 6.050 us | 6.051 us | 1.000x | 143.67 ns, 2.37% of parse |
| large | 22.872 us | 22.765 us | 1.005x | 610.94 ns, 2.67% of parse |

On these fixtures, `String.as_bytes()` is a zero-copy wrapper and does not
materially change whole-parse throughput. The redundant UTF-8 validation pass
costs about 2.4-5.5% of current parse time. A direct String SIMD bridge remains
a sound cleanup and should remove that pass, but it cannot explain an 8x gap.
The dominant costs are eager tree construction, generic recursive dispatch,
per-token/string allocation, exact-number materialization, duplicate checking,
and the absence of typed or lazy parsing modes.

## Code-size context

The generated Dew benchmark modules are 18.1-24.0 KiB. The json-as modules are
78.7-167.7 KiB, or about 4.35-7.00x larger for these fixtures. json-as's speed
includes generated schema code, dynamic/lazy machinery, an AssemblyScript
runtime, and aggressive Binaryen speed optimization. Dew therefore currently
trades substantial throughput for a smaller generic module and stricter eager
semantics.

## Post-Bloom and serializer measurements

After the four-shard exact Bloom prefilter, index/StringView serializer, and
validated-String parser tranches, a fresh run measured:

### Deserialization

| Fixture | Dew eager `JsonValue` | json-as `JSON.Obj` | json-as typed struct | Dew / `JSON.Obj` | Dew / typed |
|---|---:|---:|---:|---:|---:|
| small | 374.62 ns | 229.68 ns | 82.38 ns | 1.63x | 4.55x |
| medium | 5.196 us | 742.69 ns | 1.691 us | 7.00x | 3.07x |
| large | 14.935 us | 2.597 us | 3.344 us | 5.75x | 4.47x |

The large dynamic parse ratio improved from 8.70x to 5.75x by removing most
wide-object duplicate scans and then eliminating redundant validation and
builder work for clean validated strings. Medium remains dominated by eager tree
and compact string materialization.

### Serialization

| Fixture | Dew eager tree | json-as `JSON.Obj` | json-as typed struct | Dew / `JSON.Obj` | Dew / typed |
|---|---:|---:|---:|---:|---:|
| small | 245.27 ns | 44.81 ns | 56.18 ns | 5.47x | 4.37x |
| medium | 4.354 us | 81.94 ns | 479.82 ns | 53.14x | 9.07x |
| large | 13.046 us | 255.55 ns | 1.606 us | 51.05x | 8.12x |

The serializer tranche is 17-22% faster than the post-Bloom baseline, but the
remaining `JSON.Obj` gap is still mostly semantic passthrough rather than an
implementation deficit. Against generated typed serialization, the remaining
strict eager gap is approximately 4.4-9.1x.

## Conclusions and next optimization order

1. Replace parser `Array<U32>` one-cell counters with cheaper fixed/scalar state
   and consolidate writer error/length state.
2. Profile Array growth and recursive `JsonValue` construction independently on
   string-heavy and aggregate-heavy fixtures.
3. Fuse number-end discovery and grammar validation where exact diagnostics can
   remain identical; profile serialization revalidation separately.
4. Consider an opaque validated `JsonNumber` only as a separate API change.
5. Add a separate lazy/raw document API if passthrough and selective access are
   desired. Do not silently weaken `JsonValue`'s eager, strict contract.
6. Consider generated typed decoding only as a distinct API. Its semantics,
   unknown-field policy, duplicate handling, number conversion policy, and code
   size must be explicit.

Direct String SIMD was useful because it enabled the broader no-escape and
compact-span tranche. It still does not replace eager tree construction or make
the dynamic/lazy json-as path semantically equivalent.
