# Derived equality

## Surface syntax

Non-generic structs and enums may request equality immediately after the closing
brace:

```dew
struct Point {
  x: I32
  y: I32
} derive(Eq)

enum Choice {
  None
  Number(I32)
} derive(Eq)
```

The parser retains ordered `DeriveRequest` records with exact source offsets.
The clause accepts comma-separated names and one trailing comma. Unknown names remain visible collection diagnostics rather than being ignored.
Duplicate names use a dedicated diagnostic whose primary location is the repeated
request and whose secondary label identifies the first request.
Generic requests currently receive `GenericDeriveRequiresBounds`; enabling them
requires the generic trait-obligation work tracked in the roadmap.

## Expansion

Expansion occurs during collection, immediately after the nominal declaration is
collected. The parser package owns deterministic AST factories because parser AST
constructors are read-only outside that package. A single `derive(Eq)` request synthesizes both:

- `impl Eq for Type` with `eq(self, right) -> Bool`;
- `impl Ne for Type` with `ne(self, right) -> Bool` delegating once to the
  generated `Eq` implementation and negating that result.

The generated declarations and every synthetic expression carry the exact
`Eq` request offset, so missing field evidence and coherence conflicts point at
`derive(Eq)` rather than the beginning of the nominal declaration.

These are ordinary collected implementations and methods. They pass through the
same type resolution, coherence validation, body inference, lowering,
reachability, and WasmGC emission as handwritten implementations. There is no
backend-only equality path.

Struct equality compares fields in declaration order and combines comparisons
with short-circuiting logical `&&`. Empty structs produce `true`.

Enum equality first matches the left variant, then matches the right value against
the same variant. Different variants produce `false`; tuple and struct payloads
compare in source order. This reuses ordinary enum pattern selection and payload
extraction, so representation choices remain encapsulated by existing lowering.

## Primitive support

`Bool` now has ambient `Eq` and `Ne` implementations. This lets derived nominal
values contain Boolean fields through the same trait dispatch used for numeric
fields.

## Performance

Nominals with no derive requests do not construct any synthetic parser AST. The
collector first validates requests and only invokes the parser-owned expansion
factory after finding one supported non-generic request. On August 8, 2026, the
release native collection benchmarks measured:

```text
512 one-field structs without derives     595.76 us
128 one-field structs with derive(Eq)      515.80 us
```

The empty-request fast path avoids even a derive-name map allocation; in the
measured run it reduced the no-derive workload from 609.82 us to 595.76 us
(about 2.3%). The runtime fixture's WAT fell from 715 to 566 lines after changing generated
`Ne` to call generated `Eq` instead of duplicating every field/variant comparison,
a 20.8% reduction for that fixture. Measurements are development observations,
not regression budgets.

## Validation

Coverage includes:

- parser retention for struct and enum derive clauses;
- coherent synthetic Eq/Ne implementation indexing;
- diagnostics for unknown, duplicate, and unbounded generic derives;
- derive-site diagnostics when a field type has no matching equality evidence;
- no synthetic impl/method/body records for ordinary nominal declarations;
- empty-enum derivation without spurious analysis diagnostics;
- executable struct equality and inequality;
- executable unit, tuple, and struct-payload enum equality and inequality;
- Boolean payload equality;
- deterministic Node/Wago output and WAT snapshots.
