# Validated-String JSON parsing

Date: 2026-08-13

## Scope

This tranche optimizes the existing strict eager `JsonValue` parser without
changing its grammar, recursive value model, exact-number representation,
duplicate-key policy, resource limits, UTF-8 policy, source order, or compact
ownership policy.

The parser now retains both views of one immutable backing:

- `source: String` is the trusted validated input used by direct String SIMD
  scans and compact String/StringView materialization;
- `input: Bytes` is the zero-copy representation view reused by existing
  byte-oriented grammar, number, and delimiter helpers.

`json_parse(String)` trusts the public `String` UTF-8 invariant and enters the
validated parser directly. `json_parse_bytes(Bytes)` still checks the input
limit and strict UTF-8 exactly once, then uses a private JSON implementation
bridge to rewrap those already-validated bytes as `String` without a second
scan. The unchecked bridge is not exported from a public standard module.

## Generic representation bridge

The generated intrinsic module adds:

```dew
wasm_string_load_u8x16(value: String, start: U32) -> U8x16
```

It is the String analogue of `wasm_bytes_load_u8x16`: a bounds-checked logical
16-byte load over private GC-backed text storage. Both operations share one
generic backend emitter parameterized by the physical text wrapper type. The
bridge performs no JSON classification, alignment policy, delimiter handling,
or scan loop.

Direct tests cover aligned and unaligned String loads and out-of-view traps. A
Node/Wago trap fixture provides cross-runtime coverage.

## No-escape path

`json_parse_string` scans from the opening quote to the first quote, backslash,
or control byte with direct String SIMD. If the first special byte is the closing
quote, the parser:

1. checks the decoded-string byte limit;
2. advances the parser offset;
3. copies the exact `StringView` span into a compact String;
4. allocates no `StringBuilder` and performs no substring UTF-8 validation.

The escaped path still creates a builder, but clean spans append as validated
`StringView` values. Escapes, Unicode hex decoding, surrogate pairs, controls,
errors, and byte-limit checks retain their previous behavior.

Exact number lexemes now also compact a validated source String span directly,
rather than converting a Bytes view through checked UTF-8 conversion.

## Measurement

The primary A/B benchmark used isolated standard-package roots for serializer
commit `90bea02` and the optimized working tree, the same compiler executable,
the json-as compact fixtures, Node 26.3.0/V8, 30 warmups, 101 paired interleaved
samples per round, five rounds, and approximately 256 KiB per timed batch.
Reported percentages are median paired deltas across rounds.

| Fixture | Parse String | Parse Bytes | Stringify | Round trip |
|---|---:|---:|---:|---:|
| small, 44 B | -12.07% | -7.01% | +0.34% | -9.36% |
| medium, 1,070 B | -14.96% | -13.53% | -0.36% | -8.85% |
| large, 5,251 B | -14.64% | -12.66% | +0.50% | -8.20% |

Negative values are faster. Serialization differences are noise because the
writer intentionally remains on its previously faster zero-copy Bytes SIMD
scan. String parsing improves about 12-15%; checked Bytes parsing improves about
7-14% because it validates once and shares the no-escape/materialization path.

A fresh json-as comparison after the change measured:

| Fixture | Dew parse | json-as `JSON.Obj` | Dew / dynamic | json-as typed | Dew / typed |
|---|---:|---:|---:|---:|---:|
| small | 374.62 ns | 229.68 ns | 1.63x | 82.38 ns | 4.55x |
| medium | 5.196 us | 742.69 ns | 7.00x | 1.691 us | 3.07x |
| large | 14.935 us | 2.597 us | 5.75x | 3.344 us | 4.47x |

The large dynamic ratio has fallen from the original 8.70x to 5.75x after Bloom
and validated-String work. The remaining gap still includes eager recursive tree
construction, compact ownership of every String, exact number materialization,
generic collection growth, recursive enum dispatch, and stricter duplicate and
resource policies.

`tools/benchmark-json-strings.py` separately exercises long clean String,
checked clean Bytes, escaped String, Unicode clean String, and malformed Bytes
paths. On the development machine it measured 316.63 ns, 353.59 ns, 1.428 us,
358.07 ns, and 22.25 ns respectively. These are absolute path costs rather than
baseline deltas and are intended for future regression analysis.

## Fixed parser state follow-up

The parser previously allocated two one-element growable `Array<U32>` values for
its mutable offset and total-value count. The follow-up state tranche stores both
cells in one `FixedArray<U32>` instead. This removes capacity/length metadata,
array growth initialization, and one GC allocation without changing recursive
parser signatures or mutation visibility.

`tools/benchmark-json-parser-state.py` builds isolated array-state and fixed-state
standard roots and measures the same compact fixtures with 30 warmups, 101 paired
interleaved samples per round, five rounds, and approximately 256 KiB per batch.
Median paired changes were:

| Fixture | Parse String | Parse Bytes | Round trip |
|---|---:|---:|---:|
| small, 44 B | -1.79% | +0.34% | -2.97% |
| medium, 1,070 B | -3.05% | -3.37% | -0.77% |
| large, 5,251 B | -3.14% | -2.78% | -1.39% |

Negative values are faster. The small checked-Bytes difference is noise; medium
and large parsing improve about 2.8-3.4%. Generated benchmark modules are 625
bytes smaller for every fixture.

## Writer-state follow-up

The writer previously allocated three growable arrays on every serialization:
one scalar error-code cell and two empty payload arrays for invalid numbers and
duplicate keys. The retained follow-up replaces them with one fixed error-code
cell and one fixed String payload cell. The payload is written only for the two
payload-bearing failures. This removes growable length/capacity metadata and
success-path push/growth behavior while preserving the first-error, typed-payload,
byte-limit, depth-limit, and fail-stop contracts.

A five-round paired benchmark with 101 interleaved samples per round measured:

| Fixture | Stringify | Round trip |
|---|---:|---:|
| small, 44 B | -4.53% | -0.02% |
| medium, 1,070 B | -2.82% | -1.32% |
| large, 5,251 B | -3.53% | -1.84% |

Negative values are faster. The small round-trip result is neutral because parsing
dominates that combined path. `tools/benchmark-json-writer-state.py` retains the
broader rejected state experiment: caching every output-length update in a second
fixed cell regressed small and large serialization despite helping medium, so it
was not adopted.

## Measured but rejected follow-ups

The following ideas were implemented in isolated standard roots and rejected
because they did not improve every representative fixture:

- pre-sizing every parsed Array/Object to 4 elements: medium improved about
  1.2-1.6%, but large parse regressed 0.1-0.3%; capacities 1, 2, 8, and 16 were
  likewise workload-dependent;
- pre-sizing every output builder to 256 bytes: small serialization regressed
  about 3.9% and round trips about 4.4%;
- fusing scalar terminator scanning with number grammar: small improved 1.5-2.8%,
  but large parse regressed about 1.0-1.2%;
- caching writer length in fixed state: medium improved, but small and large
  serialization regressed roughly 7-8%.

These candidates remain useful profiling evidence, not production changes.

## Remaining priorities

1. Measure Array growth and recursive `JsonValue` construction independently.
2. Consider workload-sensitive capacity hints only through an explicit API or a
   proven general Array policy, not JSON-local guesses.
3. Consider opaque validated numbers only as an explicit API change.
4. Keep lazy/raw documents and generated typed decoding as separate APIs rather
   than weakening strict eager `JsonValue`.
