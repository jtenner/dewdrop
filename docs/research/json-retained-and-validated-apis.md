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

`json_validate` currently uses the retained strict parser and drops the produced
tree. It avoids token copies but does not yet avoid recursive value/collection
allocation; a generic visitor implementation was prototyped but rejected after
exposing an unresolved generic recursive-method backend linkage (`MissingFunction`).
The API is still useful for validation-only callers and leaves room for a future
allocation-free specialized event engine.

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

### Retained validation

| Fixture | `json_validate` |
|---|---:|
| small | 295.08 ns |
| medium | 3.564 us |
| large | 10.346 us |

### Validated-number serialization

A three-number array serialized in 119.68 ns through `JsonNumber`, versus
193.02 ns through legacy `Number(String)`: **38.00% faster**. Construction was
performed once outside the repeated serialization loop, matching the intended
reuse model.

Reproducible drivers:

- `tools/benchmark-json-retained.py`
- `tools/benchmark-json-number.py`

## Rejected current-API micro-optimizations

Additional prototypes were not retained because they regressed representative
fixtures:

- batching object-key quote/colon punctuation and common escape spellings through
  String appends regressed stringify by 9-13%;
- global builder preallocation, fixed collection capacities, cached writer
  lengths, and scalar fused number scanning remain rejected as previously
  measured;
- a generic recursive visitor/event parser is blocked on general recursive
  generic-method linking rather than JSON semantics.

## Remaining large work

Generated typed decoding still requires a schema/derivation design, unknown-field
and duplicate policies, numeric conversion rules, generated code registration,
and code-size budgets. A genuinely allocation-free event stream requires either
non-generic callback carriers or a compiler fix for recursive generic visitor
linkage. Those are separate architectural tranches, not safe additions to the
strict eager implementation commit.
