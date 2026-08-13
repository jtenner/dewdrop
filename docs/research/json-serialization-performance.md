# Strict JSON serialization performance

Date: 2026-08-13

## Scope

This tranche optimizes deterministic serialization of the existing eager
`JsonValue` tree without changing its public model, duplicate-key policy, exact
number policy, escaping, resource limits, source order, or error behavior.

The serializer now:

- traverses `Array<JsonValue>` and `Array<JsonMember>` by index instead of
  allocating iterator objects;
- checks constructed object keys directly against the prior prefix of the
  authoritative member array instead of allocating and filling a second
  `Array<String>`;
- retains the four-shard Bloom prefilter for wide objects and performs the exact
  prior-prefix equality scan on every positive;
- appends clean string spans as `StringView` values, avoiding conversion through
  `Bytes` and redundant UTF-8 validation in `StringBuilder.append_checked`.

Escaped bytes still use the deterministic scalar escape path. Invalid number
lexemes are still revalidated because the public variant remains
`JsonValue::Number(String)` and callers may construct arbitrary values.

## Measurement

The primary comparison used isolated standard-package roots for commit
`8f8969d` and the optimized working tree, the same compiler executable, the
json-as compact small/medium/large fixture strings, Node 26.3.0/V8, 30 warmups,
101 paired interleaved samples per round, five rounds, and approximately 256 KiB
per timed batch. Reported percentages are median paired deltas across rounds.

| Fixture | Parse String | Parse Bytes | Stringify | Round trip |
|---|---:|---:|---:|---:|
| small, 44 B | -0.98% | -0.73% | -16.80% | -6.12% |
| medium, 1,070 B | -0.58% | -0.82% | -21.55% | -10.67% |
| large, 5,251 B | -0.94% | -0.84% | -17.14% | -9.46% |

Negative values are faster. Parse differences are noise because the parser is
unchanged. Stringification improves consistently by about 17-22%, and complete
round trips improve by about 6-11%.

A fresh complete json-as comparison after the change measured:

| Fixture | Dew stringify | json-as typed stringify | Dew / typed | json-as `JSON.Obj` stringify |
|---|---:|---:|---:|---:|
| small | 245.27 ns | 56.18 ns | 4.37x | 44.81 ns |
| medium | 4.354 us | 479.82 ns | 9.07x | 81.94 ns |
| large | 13.046 us | 1.606 us | 8.12x | 255.55 ns |

The `JSON.Obj` rows remain non-equivalent passthrough measurements: an untouched
json-as object may serialize retained source ranges, while Dew traverses and
validates a newly materialized exact tree. The typed comparison is closer but
still benefits from generated schema-specific code and different number/string
representations.

## Remaining costs

The largest removable strict-eager serialization costs are now:

1. per-append byte-limit and error-state checks plus repeated builder-length
   reads;
2. revalidation of every `JsonValue::Number(String)` lexeme;
3. repeated recursive enum dispatch and result/error bookkeeping;
4. string-special scanning through a zero-copy `String.as_bytes()` wrapper
   rather than a direct checked String SIMD bridge;
5. no sizing pass or capacity estimate for the output builder.

Changing `JsonValue::Number(String)` to an opaque validated number type, or
adding raw/lazy passthrough serialization, remains a separate API tranche rather
than an internal optimization of the current contract.
