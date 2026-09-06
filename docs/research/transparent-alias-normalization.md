# Transparent alias normalization

Date: 2026-07-29

## Scope

Dew type aliases are semantically transparent. Declaration type resolution now normalizes aliases after name resolution, generic arity checking, alias dependency extraction, and alias SCC diagnosis.

The public entry point remains:

```moonbit
pub fn resolve_module_types(
  CollectedModule,
) -> ResolvedModuleTypes
```

The externally published result is immutable-by-convention. Internally, resolution has explicit barriers:

1. Resolve declaration type syntax
2. Build alias dependencies
3. Diagnose alias SCCs
4. Normalize non-alias declaration signatures
5. Sort diagnostics and freeze the result

## Semantic behavior

A zero-argument alias expands directly:

```dew
type Count = I32
fn identity(value: Count) -> Count
```

Both callable signature entries become the canonical `I32` type ID.

A generic alias substitutes its stable generic parameter identities:

```dew
struct Pair<a, b> {}
type Left<t> = Pair<t, I32>
type Wrapped<u> = Left<Pair<u, u>>
```

`Wrapped<String>` normalizes to:

```text
Pair<Pair<String, String>, I32>
```

Substitution is keyed by `GenericParameterId`, not by spelling. Unrelated parameters named `t` cannot capture one another.

## Preserved constructors and recipes

Alias declarations remain nominal constructors in `declaration_types`. This is required so a use of `Alias<T>` can still identify the alias declaration and its expected arity.

`alias_target_types` deliberately retains resolved, unexpanded alias targets as substitution recipes. For example, the stored target for:

```dew
type Left<t> = Pair<t, I32>
```

contains the alias-owned `GenericParameterType(t)`. Destroying that recipe would make later instantiations impossible.

Likewise, `syntax_types` remains source-preserving resolved type syntax. The signature tables consumed by later semantic phases are normalized:

- `parameter_types`;
- `callable_return_types`;
- `field_types`;
- tuple-variant entries in `signature_type_lists`;
- `impl_trait_types`;
- `impl_target_types`.

`declaration_types`, `syntax_types`, and `alias_target_types` preserve constructors or source recipes rather than pretending every occurrence is an already-instantiated semantic type.

## Iterative substitution

Alias substitution uses its own reusable task machine:

```text
Visit(type)
FinishApplication(type, result_start)
```

For one alias application, the substitution environment is represented by:

- the alias declaration's contiguous generic-parameter span;
- one ordered scratch array of normalized argument IDs.

A `GenericParameterType` belongs to the alias when its packed module-local index falls within that span. Its replacement is selected in constant time from the corresponding argument position.

Applied targets are rebuilt through the existing canonical type interner. Primitive, nominal, trait, `Self`, error, and unrelated generic types are reused directly.

Generation-marked substitution arrays memoize repeated target nodes without allocating one map per expansion.

## Iterative normalization

Normalization uses a separate reusable task machine with four states:

```text
Visit(type)
FinishApplication(type, result_start)
FinishAliasArguments(type, result_start)
FinishAliasExpansion(type, result_start)
```

For an ordinary application, normalization:

1. Normalizes the constructor and ordered arguments
2. Propagates `ErrorType` if any component is poisoned
3. Re-interns the canonical normalized application
4. Memoizes the original-to-normalized type mapping

For an alias application, normalization:

1. Normalizes the alias arguments
2. Rejects cyclic aliases
3. Charges the expansion budget
4. Substitutes the arguments into the retained alias target recipe
5. Normalizes the instantiated target
6. Memoizes the alias application result

A zero-argument alias follows the same path with an empty argument array.

No host-language recursion is used by substitution or normalization.

## Memoization

Normalization is memoized by canonical input `ResolvedTypeId`.

This is sufficient because an instantiated alias application is itself canonical:

```text
AppliedType(Alias constructor, [canonical arguments])
```

Two occurrences of `Wrapped<String>` therefore share one input type ID and one normalized result. Newly constructed applications are interned into the same module-local arena, so normalized outputs also retain canonical identity.

The memo table is resolver-local and grows alongside the type arena.

## Cycles and poison propagation

Alias SCC analysis runs before normalization. Any direct application of a cyclic alias normalizes immediately to the shared `ErrorType`.

An acyclic alias that reaches a cyclic component also becomes `ErrorType` transitively without another cycle diagnostic:

```dew
type A = B
type B = A
type C = A
```

`A` and `B` form the diagnosed SCC. A use of `C` is poisoned by that existing error but does not create a second misleading cycle report.

Ordinary applied types propagate poison from their base or arguments. Thus:

```dew
struct Box<t> {}
fn invalid(value: Box<Missing>) -> Unit
```

stores `ErrorType` for the parameter rather than retaining `Box<ErrorType>` as if it were a valid signature.

## Expansion budget

Normalization includes a deterministic alias-expansion work budget.

The default limit is:

```text
max(4096, initial_resolved_type_count * 64)
```

One memo-missing, non-cyclic alias expansion consumes one work unit. Memo hits consume no additional work.

If the limit is exhausted, the affected alias application becomes `ErrorType` and the resolver emits at most one diagnostic per alias declaration:

```moonbit
AliasExpansionLimit(DeclId, Int, UInt64)
```

The diagnostic records the alias declaration, active limit, and source offset. A private white-box entry point permits tests to set a small limit without weakening the normal compiler default.

The budget protects the compiler from generated type growth that is much larger than the source-level type graph. It is intentionally proportional to module type complexity so legitimate large alias chains receive a correspondingly large allowance.

## Demand-driven signature roots

Normalization is initiated from semantic signature roots rather than eagerly normalizing every alias target recipe.

This distinction is critical for performance. Consider:

```dew
type A0<t> = Pair<t, I32>
type A1<t> = A0<Pair<t, I32>>
type A2<t> = A1<Pair<t, I32>>
```

Eagerly normalizing every open generic alias target gives each declaration a different free `GenericParameterId`. That produces a quadratic family of semantically unnecessary open instantiations.

The initial eager implementation took approximately **15.41 ms** on native for a 256-alias instantiated generic chain. Normalizing only callable, field, variant, and impl signature roots reduced the same workload to **294.44 us**, about a **52x improvement**.

Raw alias targets remain compact recipes, while actual closed or contextually generic use sites normalize on demand and share memoized results.

## Determinism and post-self-hosting parallelism

The normalizer uses only:

- frozen collected declarations;
- frozen resolved syntax and alias graph data;
- one module-local canonical type arena;
- resolver-local scratch arrays;
- resolver-local diagnostics.

No identity depends on allocation addresses, global insertion order, or worker scheduling. Signature roots are visited in stable collected-record order. Diagnostics are sorted by source offset and diagnostic rank before publication.

Once Dewdrop is self-hosted and Dew supports parallel computation, body jobs can read a frozen module's normalized signatures concurrently. The MoonBit compiler runs these jobs sequentially.

## Complexity

Let:

- `U` be the number of unique normalized input types reached from signature roots;
- `X` be the number of memo-missing alias expansions;
- `S` be the total alias-target syntax visited during substitution;
- `N` be the number of newly interned normalized applications.

Expected work is:

```text
O(U + X + S + N)
```

subject to structural hash-collision checks. The expansion budget bounds `X` for adversarial modules.

Open generic alias recipes not demanded by signatures are not expanded merely because they were declared.

## Tests

`src/semantic/type_resolution_wbtest.mbt` covers:

- zero-argument alias normalization;
- preservation of nominal alias declaration constructors;
- preservation of source-level syntax type IDs;
- generic substitution by stable parameter identity;
- nested generic alias applications;
- canonical repeated alias applications;
- field normalization;
- tuple-variant payload normalization;
- inherent impl target normalization;
- cyclic alias poisoning;
- transitive poisoning through an acyclic alias;
- one deterministic expansion-limit diagnostic;
- poison propagation through ordinary applied arguments;
- iterative normalization of a 1,024-alias acyclic chain.

## Benchmarks

Release-mode benchmarks are in `src/semantic/type_resolution_bench_test.mbt`. Times compare only within one backend runner.

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

## Current boundary

This phase remains responsible only for transparent alias normalization. Imported
interfaces, visibility checks, nominal-layout legality, module-value inference,
trait obligations, runtime representation, and backend planning are implemented
by later phases. Body-local type-annotation syntax remains a separate language
design question. Current product work is tracked in `docs/roadmap.md`.

## Explicit call arguments (September 5, 2026)

Both compilers now normalize aliases in explicit call type arguments, not only
declaration signatures. The self-host regression checks aliases to Unit, I8,
and U8 through an imported generic callable. Logical signedness and width remain
intact; normalization does not replace types with Wasm carriers.

Validation: the self-host hardening lane passed 162 tests and 27 invariant-record
checks. It took 119.148 seconds, including 99.237 seconds for test generation.
These times exceed the 30-second threshold and remain performance bugs.
