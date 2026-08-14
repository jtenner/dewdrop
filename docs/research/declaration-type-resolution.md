# Declaration type resolution

Date: 2026-07-29

## Scope

The first Dew type-system phase resolves every declaration-level `HirTypeSyntax` into a canonical immutable type arena. It covers:

- compiler primitive types;
- declaration generic parameters;
- nominal structs, enums, and aliases;
- trait types;
- `Self` contexts for trait and impl methods;
- applied generic types;
- generic arity checking;
- unknown type and unknown trait diagnostics;
- impl trait-versus-target context validation;
- alias dependency extraction;
- iterative strongly connected component analysis for alias cycles;
- transparent alias normalization with generic substitution;
- bounded alias expansion and poison propagation.

The public entry point is:

```moonbit
pub fn resolve_module_types(
  CollectedModule,
) -> ResolvedModuleTypes
```

The phase reads a frozen collected module and writes only a new module-local result. It performs no body inference and mutates no parser or HIR state.

## Primitive types

The initial compiler primitive set is:

```text
Unit
Bool
I32
U32
I64
U64
F32
F64
String
Never
```

Each primitive has one canonical `ResolvedTypeId`. These names are reserved in the module type namespace. A struct, enum, or alias declaration using one of these names receives `ReservedTypeName`; the compiler primitive retains lookup precedence.

`Self` is also reserved as a special semantic type name.

## Resolved type representation

```moonbit
pub enum ResolvedType {
  ErrorType
  PrimitiveType(PrimitiveType)
  GenericParameterType(GenericParameterId)
  NominalType(DeclId)
  TraitType(DeclId)
  SelfType(DeclId)
  AppliedType(ResolvedTypeId, HirSpan)
}
```

`ResolvedTypeId` is an index into a module-local immutable-by-convention arena. Applied arguments occupy spans in one flat `Array[ResolvedTypeId]`.

The arena distinguishes a declaration's constructor from an application of that constructor. For example:

```text
NominalType(List declaration)
AppliedType(List constructor, [I32])
```

This permits generic arity to be checked before constructing an applied type and permits later alias normalization to recognize an alias constructor directly.

## Canonical interning

Resolved types are hash-consed. Equal primitive, generic-parameter, nominal, trait, `Self`, and applied types receive the same `ResolvedTypeId`.

The interner uses:

- a 32-bit structural hash suitable for native, Wasm, WasmGC, and JavaScript runners;
- one hash bucket head map;
- a flat collision-chain array;
- structural comparison on every hash collision;
- copied flat argument spans only when an applied type is new.

Applied hashes combine the base hash, ordered argument hashes, and argument count. Hash equality never defines type equality; collision candidates are compared structurally.

Switching the bucket key and structural hash from `UInt64` to `Int` substantially reduced JavaScript and classic-Wasm resolution cost because those backends no longer perform BigInt-heavy hash-map operations for every type node.

## Declaration constructors

Every collected type or trait declaration receives a canonical constructor ID in source order:

- structs, enums, and aliases produce `NominalType(DeclId)`;
- traits produce `TraitType(DeclId)`;
- non-type declarations map to the shared error type.

`ResolvedModuleTypes::declaration_type` performs constant-time lookup by the packed declaration ID's local component.

## Name resolution precedence

In an ordinary type position, a named type resolves in this order:

1. Generic parameters owned by the immediate declaration
2. Generic parameters inherited from the containing trait or impl for a method
3. `Self` when a containing trait or impl exists
4. Compiler primitive types
5. Module type namespace: structs, enums, and aliases
6. Module trait namespace
7. `UnknownType`

Type declarations outrank traits when both namespaces contain the same spelling in an ordinary type position. Falling back to the trait namespace permits a bare trait name to represent the future erased trait-object type. The exact explicit trait-object spelling may be revisited later.

In an impl's trait position, lookup uses the trait namespace exclusively. A known primitive, generic parameter, `Self`, or module type produces `ExpectedTraitType`; a completely missing spelling produces `UnknownTrait`.

## Generic scopes

Generic parameters resolve to their stable `GenericParameterId`, not merely their spelling. This distinguishes unrelated declarations that both use a name such as `t`.

For methods, lookup checks:

1. Method-level generic parameters
2. Generic parameters on the containing trait or impl

Trait and impl methods use the same method-level generic syntax. Cross-owner shadowing is permitted: a method parameter may reuse a containing trait/impl parameter spelling, stable IDs keep them distinct, and the immediate method scope takes precedence.

## `Self`

`SelfType` stores the declaration that defines the receiver context:

- a trait method stores the containing trait `DeclId`;
- an impl method stores the containing impl `DeclId`.

This is intentionally not immediately rewritten to the impl target. Retaining the context makes trait signature comparison and later impl substitution explicit.

A shorthand receiver with no enclosing trait or impl, such as top-level `fn invalid(self)`, receives `SelfOutsideContext` and the shared error type. A top-level receiver with an explicit concrete type remains resolvable.

## Iterative type-syntax resolution

Type syntax resolution uses reusable parallel task arrays containing:

```text
HirTypeId
visit-or-finish state
name expectation
constructor-position flag
```

There are no recursive host-language calls. A named syntax node resolves immediately. An applied node schedules its base and arguments, then performs arity validation and canonical interning in its finish operation.

The constructor-position flag prevents a generic declaration from receiving a false missing-argument diagnostic when it is the base of an application. Bare use of a generic constructor still reports an arity mismatch.

Examples:

```dew
Box             // expected 1 argument, received 0
Box<I32>        // valid
Box<I32, I64>   // expected 1 argument, received 2
I32<String>     // primitive expects 0 arguments
T<I32>          // generic parameter is not applicable
```

Invalid type syntax resolves to the canonical `ErrorType`. This permits signature resolution to continue without cascaded unknown-type or arity diagnostics.

## Frozen signature tables

`ResolvedModuleTypes` contains arrays aligned with collected semantic records:

- `generic_parameter_types`;
- `parameter_types`;
- `callable_return_types`;
- `field_types`;
- resolved tuple-variant payload spans;
- `alias_target_types`;
- `impl_trait_types`;
- `impl_target_types`;
- `syntax_types` for direct HIR lookup;
- `declaration_types` for constructor lookup.

A shorthand receiver obtains a canonical `SelfType`; an inherent impl stores `-1` in `impl_trait_types` because it has no trait side.

Parameter, callable return, field, tuple-variant payload, and impl type tables are transparently alias-normalized before publication. `alias_target_types` remains resolved but unexpanded because each target is the generic substitution recipe for future alias applications. `syntax_types` and alias declaration constructors likewise preserve source-level alias identity.

These arrays are read-only after resolution and are ready to be shared by independent body-resolution jobs. Transparent normalization details are recorded in `docs/research/transparent-alias-normalization.md`.

## Diagnostics

The phase currently emits:

```moonbit
ReservedTypeName
UnknownType
UnknownTrait
ExpectedTraitType
TypeArityMismatch
TypeNotApplicable
SelfOutsideContext
AliasCycle
AliasExpansionLimit
```

Diagnostics retain the owning declaration and source offset. They are sorted deterministically by offset and diagnostic rank before publication.

`ErrorType` is a poison sentinel: later phases should propagate it without repeatedly reporting consequences of the same invalid signature.

## Alias dependencies

Every alias target is traversed through canonical resolved types. The resolver records direct references to other alias declarations while:

- descending through applied bases and arguments;
- deduplicating repeated references;
- preserving deterministic declaration order;
- ignoring primitive, generic, `Self`, error, and non-alias nominal types.

For example:

```dew
type Element<t> = t
type Wrapped<t> = Pair<Element<t>, Element<t>>
```

records one dependency from `Wrapped` to `Element`, not two.

Dependency traversal is iterative and uses generation-marked reusable arrays rather than allocating one visited set per alias.

## Alias cycle detection

Alias cycles use iterative Kosaraju SCC analysis:

1. Iterative depth-first finish ordering on the alias graph
2. Flat reverse-edge construction with prefix offsets
3. Iterative traversal of the reversed graph
4. Source-order sorting within each cyclic component
5. Source-order sorting of published cycle spans

A component is cyclic when it contains multiple aliases or one alias with a self-edge.

Examples:

```dew
type A = B
type B = C
type C = A

type SelfCycle = SelfCycle
```

produce two `AliasCycle` diagnostics and mark all four aliases as cyclic. Missing names and other error types do not create false dependency edges.

The SCC implementation uses no recursive calls and is covered by a 1,024-alias cycle test.

## Transparent alias normalization

After SCC analysis, non-alias signature roots are normalized through reusable iterative substitution and normalization task machines. Generic substitution is keyed by stable `GenericParameterId`; repeated canonical alias applications share memoized results. Cyclic and transitively cyclic aliases become `ErrorType` without duplicate cycle diagnostics.

A deterministic expansion budget defaults to `max(4096, initial_type_count * 64)`. Exhaustion produces at most one `AliasExpansionLimit` diagnostic per affected alias declaration and poisons that application.

Normalization is demand-driven from callable, field, variant, and impl signature roots. Alias target types remain raw substitution recipes. This avoids quadratic expansion of every open generic alias declaration; a 256-alias generic-chain benchmark improved from approximately 15.41 ms under eager normalization to 294.44 us under demand-driven normalization.

The full design is documented in `docs/research/transparent-alias-normalization.md`.

## Complexity

For `T` declaration type-syntax nodes, `R` unique resolved types, `A` aliases, `E` alias dependency edges, and `N` normalized types reached from signature roots:

- type syntax resolution is `O(T)` expected time;
- canonical interning is expected `O(R)` with structural collision checks;
- signature tables are built in source-record order;
- alias dependency extraction is linear in visited resolved type edges;
- SCC detection is `O(A + E)`;
- memoized normalization is expected `O(N)` plus visited substitution-recipe nodes and newly interned applications;
- alias expansion work is bounded relative to the initial resolved type count;
- task, traversal, substitution, normalization, and dependency scratch arrays are reused.

No global type interner or global allocator is involved. Different module interfaces can resolve independently once their imported namespace snapshots are available.

## Tests

`src/semantic/type_resolution_wbtest.mbt` covers:

- canonical primitive IDs;
- canonical repeated applications;
- distinct stable generic-parameter identities;
- declaration constructor lookup;
- struct fields, function parameters, returns, and enum payloads;
- unknown types;
- missing, excess, and primitive generic arguments;
- applying a generic parameter as a constructor;
- trait-only impl lookup;
- unknown traits and known non-traits;
- trait and impl generic inheritance;
- trait and impl `Self` contexts;
- top-level shorthand-receiver rejection;
- reserved primitive and `Self` declarations;
- deduplicated alias dependencies;
- multi-node and self alias cycles;
- iterative 1,024-alias SCC analysis;
- zero-argument and nested generic alias normalization;
- field, variant, callable, and impl signature normalization;
- cyclic and transitively cyclic alias poisoning;
- expansion-budget diagnostics;
- poison propagation through applied arguments;
- iterative 1,024-alias transparent normalization.

## Benchmarks

Release-mode benchmarks live in `src/semantic/type_resolution_bench_test.mbt`. Times compare only within one backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| resolve-only aliases, n=256 | 168.68 us | 171.61 us | 490.88 us | 468.11 us |
| collect events and resolve aliases, n=256 | 301.53 us | 252.82 us | 699.84 us | 819.35 us |
| tokenize, parse, collect, and resolve aliases, n=256 | 613.43 us | 593.75 us | 1.02 ms | 1.76 ms |
| resolve-only function signatures, n=256 | 219.07 us | 279.63 us | 766.53 us | 597.25 us |
| collect and resolve function signatures, n=256 | 528.95 us | 507.89 us | 1.52 ms | 1.52 ms |
| resolve cyclic aliases, n=256 | 76.90 us | 78.75 us | 265.99 us | 196.62 us |
| normalize transparent alias chain, n=256 | 81.98 us | 93.70 us | 373.08 us | 231.49 us |
| normalize instantiated generic alias chain, n=256 | 294.44 us | 334.53 us | 1.01 ms | 797.34 us |
| full generic alias chain pipeline, n=256 | 811.70 us | 845.80 us | 1.63 ms | 2.28 ms |

The function-signature workload resolves 256 generic functions, each containing two applied parameters and one applied return type. The alias workload resolves 256 generic aliases with nested applications and builds an acyclic dependency graph.

## Current boundary

This phase owns declaration-level type resolution and leaves body inference,
interfaces, nominal-layout planning, trait evidence, lowering, optimization, and
backend emission to later implemented phases. Remaining product work is tracked
in `docs/roadmap.md`.
