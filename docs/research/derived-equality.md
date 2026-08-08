# Derived equality

## Surface syntax

Structs and enums may request equality immediately after the closing brace:

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
For a generic nominal, expansion adds an `Eq` prerequisite to each generated
implementation owner parameter that occurs anywhere in a field or variant
payload type, while preserving source-declared bounds. A parameter that already
names `Eq` is not duplicated, and an unused phantom parameter remains
unconstrained. Concrete field types are validated by ordinary generated-body
method selection. The derive request is therefore available exactly when its
stored values supply coherent equality evidence.

## Expansion

Expansion occurs during collection, immediately after the nominal declaration is
collected. The parser package owns deterministic AST factories because parser AST
constructors are read-only outside that package. A single `derive(Eq)` request synthesizes both:

- `impl<t: Eq> Eq for Type<t>` with `eq(self, right) -> Bool`;
- `impl<t: Eq> Ne for Type<t>` with `ne(self, right) -> Bool` delegating once to
  the generated `Eq` implementation and negating that result.

The generic form is applied to every field-referenced owner parameter and
preserves additional source bounds. Non-generic declarations use the same
factory with an empty owner parameter list.

The generated declarations and every synthetic expression carry the exact
`Eq` request offset, so missing field evidence and coherence conflicts point at
`derive(Eq)` rather than the beginning of the nominal declaration.

These are ordinary collected implementations and methods. They pass through the
same type resolution, coherence validation, symbolic generic-body selection,
recursive evidence freezing, evidence-aware specialization, reachability,
lowering, and WasmGC emission as handwritten implementations. There is no
backend-only equality path. Generic field and payload comparisons resolve their
source-ordered `Eq` bound slots to concrete methods when a closed specialization
is materialized.

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
512 one-field structs without derives     658.17 us
128 one-field structs with derive(Eq)      593.75 us
```

The empty-request fast path avoids even a derive-name map allocation. Generated
`Ne` continues to call generated `Eq` rather than duplicating every
field/variant comparison. Measurements are development observations, not
regression budgets.

## Validation

Coverage includes:

- parser retention for struct and enum derive clauses;
- coherent synthetic Eq/Ne implementation indexing;
- diagnostics for unknown and duplicate derives;
- field- and payload-referenced generic Eq/Ne prerequisites without duplicate `Eq` bounds;
- unconstrained phantom owner parameters;
- derive-site diagnostics when a field type or concrete generic argument has no matching equality evidence;
- no synthetic impl/method/body records for ordinary nominal declarations;
- empty-enum derivation without spurious analysis diagnostics;
- executable non-generic and bounded-generic struct equality and inequality;
- executable non-generic and bounded-generic unit, tuple, and struct-payload enum equality and inequality;
- nested generic derived nominals forwarding prerequisite evidence transitively;
- Boolean payload equality;
- deterministic Node/Wago output and WAT snapshots.
