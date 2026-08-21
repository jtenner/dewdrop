# Self-host derive expansion — August 20, 2026

## Status

The Dew self-host compiler now expands valid struct and enum derive requests
into ordinary implementation, method, body, type, pattern, and expression HIR.

The port adds:

- `parser_derive_core.dew`: Eq, Ne, Hash, generic prerequisite, nominal target,
  enum pattern, and hash-expression synthesis;
- `parser_derive_format.dew`: Debug and Show body synthesis for structs and all
  enum variant forms;
- `semantic_derive_expansion_test.dew`: implementation shape, source order,
  offsets, generic bounds, generated name resolution, duplicate, and unknown
  derive coverage.

## Expansion order

A valid request expands immediately after its owner declaration is collected.
The stable order is:

1. `Eq` implementation;
2. companion `Ne` implementation;
3. `Debug` implementation;
4. `Hash` implementation;
5. `Show` implementation.

The request offset is used for every synthetic declaration, method, expression,
pattern, and generated diagnostic location. Handwritten declarations before the
owner remain before synthetic declarations. Handwritten declarations after the
owner remain after them.

The original valid requests remain in `SelfHostCollectedDeriveRequest` records
for diagnostics, tooling, and future cache artifacts.

## Generic prerequisites

A derived implementation copies all owner generic parameters and their existing
bounds. A trait prerequisite is added only when the parameter occurs in a field
or enum payload type.

The dependency scan covers named, product, applied, and function types and uses
an explicit task stack. Phantom parameters receive no new bound. Existing equal
bounds are not duplicated.

`Ne` uses the same `Eq` prerequisites as its generated body because it evaluates
ordinary equality and negates the result.

## Generated behavior

- Struct equality compares fields from left to right.
- Enum equality first matches the left variant, then the corresponding right
  variant, and returns false for a different right variant.
- Hash uses the existing FNV-style seed and multiplier and includes the enum
  variant index before payload values.
- Hash equality delegates to each field or payload value's `hash_eq` method.
- Debug writes deterministic labels and recursively calls `debug` for values.
- Show appends deterministic labels and recursively calls `show_append` through
  the supplied formatter.

Synthetic implementations pass through the ordinary collection, type
resolution, body name resolution, implementation indexing, coherence, and
inference paths. They are not special semantic records.

## Current boundary

Implementation indexing, coherence, inferred obligations, and evidence are
still provided only by the MoonBit compiler. The Dew port now supplies the same
synthetic HIR inputs required by those phases.

Imported callable, field, variant, and implementation recipes have since
landed, and local unification is now complete. The next dependency phase is
body inference.
