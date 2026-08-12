# Implementation indexing and method inference

## Status

Implemented for module-local inherent and trait implementations, structural overlap/disjointness, strict specialization, receiver-call syntax, `Type::method(...)`, `Trait::method(...)`, primitive and nominal static methods, generic impl substitution, method-local generics on impl members, deterministic selection, and frozen direct-call targets.

Generic-body trait obligations, trait objects, dynamic dispatch, runtime layouts, lowering, and Starshine emission are implemented by later phases. This note remains the impl-index and method-selection record.

## Frozen implementation index

`build_module_impl_index` consumes `CollectedModule` and `ResolvedModuleTypes` and publishes a deterministic `ModuleImplIndex` containing:

- one source-ordered `IndexedImpl` per impl declaration;
- canonical trait and target types;
- primitive or nominal target heads;
- source-ordered inherent and `(trait, target-head)` buckets;
- validated method-to-requirement evidence;
- coherence and specificity metadata;
- source-sorted diagnostics;
- sorted target-head and trait-qualified static/instance dispatch tables used through binary search rather than whole-index scans.

The index validates trait heads, target heads, unknown/missing/duplicate trait methods, receiver compatibility, value-parameter count, method-generic count, parameter types, return types, and duplicate inherent methods. Trait signature comparison substitutes trait application arguments and contextual `Self` iteratively and treats aliases as already normalized.

## Structural coherence and specificity

Implementations in one `(trait declaration, primitive-or-nominal target head)` bucket are compared structurally using one reusable local solver. Every impl-owned generic becomes a fresh pattern variable. Trait application and target type are imported as one correlated pair, so an impl generic appearing in both positions remains one variable.

For each pair the index determines:

1. whether their trait/target patterns overlap;
2. whether the left pattern can be instantiated to the right;
3. whether the right pattern can be instantiated to the left.

Disjoint patterns coexist. If exactly one directional match succeeds, that implementation is the strict specialization and receives a higher specificity rank. Equivalent or overlapping-incomparable patterns receive `OverlappingTraitImpl` and become incoherent. Examples:

- `Convert<I32> for Item` and `Convert<Bool> for Item` are disjoint;
- `Read for Box<I32>` strictly specializes `Read for Box<t>`;
- `Read for Pair<a, I32>` and `Read for Pair<Bool, b>` overlap but are incomparable and are rejected.

Concrete unequal pairs bypass the solver. Canonically identical pairs use an equality fast path, and each later conflicting declaration reports against the first relevant prior pattern. This keeps a 256-duplicate bucket near the earlier conservative-index cost rather than producing quadratic diagnostics.

All imports and structural unification are iterative. Stress coverage compares and selects a specialization through 512 nested applied types.

## Method selection

Supported source forms are:

```dew
value.method(arguments)
Type::method(value, arguments)
Type::static_function(arguments)
Trait::method(value, arguments)
Trait::static_function(arguments)
```

A `receiver.name(...)` call is deferred from ordinary field inference. Once the receiver exposes a primitive or nominal head, inference binary-searches the immutable dispatch table. Inherent candidates have strict priority over trait candidates. Among viable trait candidates, the highest coherent specificity rank wins.

Type-qualified lookup selects inherent static or instance members attached to the named primitive or nominal target head. Primitive names such as `I32`, `StringBuilder`, and `BytesBuilder` are valid qualified roots, so compiler-known types use the same declaration model as user aggregates. Trait-qualified lookup restricts candidates to coherent implementations of the named trait. Receiver-taking qualified calls treat their first ordinary call argument as the receiver; static methods use only their declared value parameters. Expected return types can select a static trait implementation when `Self` or impl generics occur in the result.

Every candidate is trialed inside a solver rollback snapshot. Impl generics, method-local impl generics, and impl-owned `Self` are instantiated iteratively. Receiver, arguments, and expected result all constrain selection. A unique candidate publishes its exact impl-method `DeclId` and zonked type arguments through `SelectedInferredCallTarget`; selected arguments are ordered as impl arguments followed by method-local arguments.

Nested object arguments participate because member inference is resumable: selected/error member expressions are skipped on later passes, while unresolved object/member work retries after method signatures add expected nominal types. This avoids duplicate diagnostics and preserves object-aware overload behavior.

Impl method bodies substitute their containing target for `Self` before parameter and return inference. Declared impl and method generics remain rigid in their own body, while every call receives fresh local variables.

Failed concrete lookup emits `NoMatchingMethod`; multiple equally specific viable candidates emit `AmbiguousMethod`. An unknown qualified name emits `UnknownQualifiedMember`. Poisoned receivers suppress dependent method and field cascades.

## Determinism and stack safety

The implementation index is built in declaration order. Target dispatch entries sort by target-head key, method name, inherent/trait tier, static/instance shape, implementation index, and method index. A secondary trait-qualified table sorts by trait declaration, name, static/instance shape, implementation, and method. Binary-search spans therefore have stable candidate order on every backend.

Body jobs read the same frozen index and retain solver, candidate, and diagnostic scratch locally. Forward and reverse body schedules compare equal. Signature instantiation, pattern imports, generic substitution, and solver traversal are iterative. Stress tests cover 512 impl buckets, 512 methods plus 512 calls, and 512 applied specialization levels.

## Performance

Release benchmarks:

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| Impl index, 512 nominal buckets | 207.13 µs | 117.44 µs | 321.90 µs | 682.38 µs |
| Impl index, 256 equivalent overlaps | 101.39 µs | 53.03 µs | 180.45 µs | 378.10 µs |
| 256 inherent receiver calls | 557.50 µs | 374.33 µs | 1.47 ms | 1.97 ms |
| 256 trait receiver calls | 260.61 µs | 201.81 µs | 798.78 µs | 905.17 µs |
| 256 generic trait receiver calls | 408.73 µs | 348.89 µs | 1.28 ms | 1.53 ms |
| 256 type-qualified calls | 267.25 µs | 230.46 µs | 897.37 µs | 932.23 µs |
| 256 trait-qualified calls | 248.15 µs | 217.02 µs | 893.88 µs | 836.83 µs |
| Full pipeline, 128 generic trait calls | 378.40 µs | 355.36 µs | 897.55 µs | 1.36 ms |

Sorted dispatch originally reduced the representative native 256-inherent-method workload from about 1.08 ms to roughly 0.60 ms. Subsequent static/instance dispatch and scratch refinements retain that improvement while adding qualified calls and structural specialization.

## Current boundary

Generic-body trait obligations, runtime trait values and dictionaries, imported
and foreign evidence visibility, backend-neutral lowering, and deterministic
Starshine emission are implemented by later phases. Structural generic overload
specificity remains open in `docs/roadmap.md`.
