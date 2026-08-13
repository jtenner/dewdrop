# Retained JSON documents and validated numbers

Date: 2026-08-13

## Scope

The strict eager `JsonValue` API keeps its compact-owning default, but callers
that explicitly accept source retention can now avoid copying every clean String
and exact number token.

New parsing APIs:

```dew
json_parse_with_limits(input, limits)
json_parse_retained(input)
json_parse_retained_with_limits(input, limits)
json_parse_document(input)
json_parse_document_with_limits(input, limits)
json_validate(input)
json_validate_with_limits(input, limits)
```

`json_parse` and checked Bytes/Reader parsing retain the existing compact-token
ownership policy. `json_parse_retained` returns the same strict recursive
`JsonValue`, duplicate policy, exact numbers, source order, limits, and
diagnostics, but clean strings and number lexemes are shared ranges over the
input String. Holding any such value may therefore retain the complete source.
Escaped strings remain freshly decoded and compact.

`JsonDocument` explicitly retains both the validated source and retained tree.
`document.stringify_source()` returns the original source byte-for-byte,
including insignificant whitespace and original escape/number spellings. It is
therefore a source-preserving operation rather than canonical serialization.
`document.value()` exposes the retained strict tree; canonical deterministic
output remains `json_stringify(document.value())`.

`json_validate` now has a specialized strict recursive engine that does not
construct `JsonValue`, `JsonMember`, or value arrays. It retains exact object-key
tracking because duplicate rejection is contractual, but drops all non-key
values after grammar/limit validation. A generic visitor implementation was also
prototyped and rejected after exposing an unresolved recursive generic-method
backend linkage (`MissingFunction`); the specialized validator avoids that
compiler limitation.

## Validated exact numbers

The legacy `JsonValue::Number(String)` variant remains source-compatible and is
validated on every serialization because callers can construct arbitrary
Strings. A new explicit validated path adds:

```dew
json_number(value: String) -> Result<JsonNumber, JsonWriteError>
number.lexeme() -> String
number.value() -> JsonValue
JsonValue::ValidatedNumber(JsonNumber)
```

`JsonNumber` validation occurs once at construction. Serialization of
`ValidatedNumber` appends the exact lexeme directly without re-running the JSON
number grammar. Parsed `JsonValue` numbers remain the legacy variant for
compatibility; callers can migrate constructed hot values explicitly.

## Paired results

All measurements used Node 26.3.0/V8, 30 warmups, 101 samples per round, five
rounds, interleaved or same-module operation measurements, and approximately
256 KiB per timed fixture batch.

### Retained parsing

| Fixture | Compact parse | Retained parse | Delta |
|---|---:|---:|---:|
| small, 44 B | 377.66 ns | 302.76 ns | -19.83% |
| medium, 1,070 B | 4.983 us | 3.576 us | -28.25% |
| large, 5,251 B | 14.328 us | 10.298 us | -28.12% |

### Source-preserving document round trip

| Fixture | Parse document + original-source output |
|---|---:|
| small | 308.05 ns |
| medium | 3.567 us |
| large | 10.317 us |

This operation validates and materializes the retained tree, then returns the
already retained original source. It is not equivalent to canonical tree
serialization, but its semantics are explicit rather than hidden passthrough.

### Specialized validation

Compared with the earlier retained-parse-and-drop implementation:

| Fixture | Previous validation | Specialized validation | Delta |
|---|---:|---:|---:|
| small | 297.31 ns | 262.42 ns | -11.81% |
| medium | 3.533 us | 3.404 us | -3.57% |
| large | 9.799 us | 9.542 us | -2.83% |

The current full benchmark measured 263.16 ns, 3.861 us, and 10.135 us when
interleaved with all retained/document operations.

### Validated-number serialization

A three-number array serialized in 119.68 ns through `JsonNumber`, versus
193.02 ns through legacy `Number(String)`: **38.00% faster**. Construction was
performed once outside the repeated serialization loop, matching the intended
reuse model.

The parser can now directly produce `ValidatedNumber` values through
`json_parse_validated_numbers` and
`json_parse_retained_validated_numbers`. On a 973-byte, 128-number fixture, the
retained parse-and-canonicalize path improved from 12.951 us to 11.033 us:
**14.81% faster**.

Reproducible drivers:

- `tools/benchmark-json-retained.py`
- `tools/benchmark-json-number.py`
- `tools/benchmark-json-parsed-numbers.py`

## Rejected current-API micro-optimizations

Additional prototypes were not retained because they regressed representative
fixtures:

- batching object-key quote/colon punctuation and common escape spellings through
  String appends regressed stringify by 9-13%;
- global builder preallocation, fixed collection capacities, cached writer
  lengths, and scalar fused number scanning remain rejected as previously
  measured;
- a generic recursive visitor/event parser is blocked on general recursive
  generic-method linking rather than JSON semantics;
- SIMD digit-run scanning improved the validated-number benchmark by 2.51% but
  regressed the compatibility parse/stringify path by 0.32%, so the shared
  scanner remains scalar.

## Remaining large work

`JsonRawDocument` now validates and retains only the source; it does not eagerly
construct a value tree. `materialize()` explicitly invokes retained eager parsing.
The measured parse-plus-source-output path is 286.58 ns small, 3.886 us medium,
and 10.135 us large.

Generated typed decoding still requires a schema/derivation design, unknown-field
and duplicate policies, numeric conversion rules, generated code registration,
and code-size budgets. A generic event stream still requires either non-generic
callback carriers or a compiler fix for recursive generic visitor linkage.
Those remain separate architectural tranches.
