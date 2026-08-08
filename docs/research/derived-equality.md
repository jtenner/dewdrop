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
The clause accepts comma-separated names and one trailing comma. Unknown and
duplicate names remain visible collection diagnostics rather than being ignored.
Generic requests currently receive `GenericDeriveRequiresBounds`; enabling them
requires the generic trait-obligation work tracked in the roadmap.

## Expansion

Expansion occurs during collection, immediately after the nominal declaration is
collected. The parser package owns deterministic AST factories because parser AST
constructors are read-only outside that package. A single `derive(Eq)` request
synthesizes both:

- `impl Eq for Type` with `eq(self, right) -> Bool`;
- `impl Ne for Type` with `ne(self, right) -> Bool` as the negation of equality.

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

## Validation

Coverage includes:

- parser retention for struct and enum derive clauses;
- coherent synthetic Eq/Ne implementation indexing;
- diagnostics for unknown, duplicate, and unbounded generic derives;
- executable struct equality and inequality;
- executable unit, tuple, and struct-payload enum equality and inequality;
- Boolean payload equality;
- deterministic Node/Wago output and WAT snapshots.
