# Self-host type resolution — August 20, 2026

## Status

The Dew self-host compiler now resolves declaration-level type syntax for one
collected module. The port adds:

- `semantic_resolved_types.dew`: primitive, nominal, trait, generic, Self,
  product, application, and function types plus canonical interning;
- `semantic_type_resolution.dew`: generic scopes, trait expectations,
  constructor arity checks, signature tables, lambda signatures, fields,
  variants, aliases, implementations, and deterministic diagnostics;
- `semantic_alias_resolution.dew`: iterative alias dependency traversal,
  strongly connected component detection, generic substitution, transparent
  normalization, poison propagation, and bounded expansion;
- `semantic_type_resolution_test.dew`: focused parity and 1,024-alias stress
  coverage.

The implementation keeps source syntax types separate from normalized signature
types. Alias declaration constructors remain nominal. Parameter, result, field,
variant payload, lambda, and implementation types use transparent normalized
forms.

## Correctness and bounds

Resolved types are hash-consed into one canonical arena. Type IDs and arena
indexes use U32. Semantic declaration and generic parameter identities retain
the packed U64 module/local layout.

Type syntax resolution, alias dependency traversal, alias SCC discovery, alias
substitution, and normalization are iterative. Tests cover 1,024-node cyclic and
acyclic alias graphs. Alias expansion has a deterministic work limit and emits
one diagnostic per limited alias.

The SCC reverse walk currently scans source-order dependency spans instead of
building nested Array adjacency lists. This avoids unsupported nested generic
Array operations in the current Dew compiler. Its worst case is quadratic in
alias count. Replace it with the production compact reverse graph after nested
compiler container operations are stable and benchmarked.

## Compiler-shaped aggregate staging

The new resolver exposed unsafe optimizer interactions when a computed enum,
struct, or type value was constructed directly inside an Array write. The Dew
port now materializes such results in named locals before it updates semantic
arenas. This gives Starshine explicit effect order and avoids stack-carried
aggregate values across nested calls.

The `collections/nested-array-set-runtime` snapshot also locks in ordinary nested
Array-set evaluation in Node and Wago. Production `heap2local` remains enabled,
and the focused type resolver suite passes after optimization.

## Current boundary

This tranche resolves local module declarations only. Qualified and wildcard
imports still require the module-interface and import-scope port. Nullable
foreign-reference validation also remains with imported and standard semantic
identity support.

Derive requests are collected but are not expanded. Body names, inference,
trait evidence, flow, lowering, layouts, specialization, WasmGC planning,
linking, encoding, and the Dew compiler driver remain to port.

## Next phase

1. Port frozen module interfaces and import scopes.
2. Resolve qualified and wildcard imported types and traits.
3. Port imported alias substitution and ambiguity diagnostics.
4. Expand deterministic derive requests.
5. Port body name resolution before inference.
