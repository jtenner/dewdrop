# Direct, generic, and builtin-overload call inference

Date: 2026-07-30

## Scope

Dew body inference now resolves and types direct module calls whose target is a name expression.

The implemented call layer supports:

- direct top-level function calls;
- direct single-signature builtin calls;
- fresh generic instantiation at every call site;
- substitution through arbitrarily deep applied signature types;
- argument-count diagnostics for direct calls;
- source-ordered builtin overload candidate sets;
- expected-result-type participation in overload selection;
- rollback-based speculative candidate checking;
- exact non-generic preference over generic candidates;
- structural generic match-set specificity;
- iterative retry of nested overload obligations;
- selected declaration and instantiated type-argument output;
- ambiguity, no-match, invalid-target, and unresolved-generic diagnostics;
- poison propagation without speculative diagnostic leakage.

Nominal objects, fields, enum constructors, callable local values, receiver/type/trait-qualified methods, generic trait obligations, and dynamic trait calls are implemented by this or later layers.

The implementation extends:

- `src/semantic/body_inference.mbt`;
- `src/semantic/infer_basic_bodies.mbt`;
- `src/semantic/local_unification.mbt`.

Tests and benchmarks live in:

- `src/semantic/call_inference_wbtest.mbt`;
- `src/semantic/call_inference_stress_wbtest.mbt`;
- `src/semantic/call_inference_bench_test.mbt`.

## Frozen call result

`InferredModuleBodies` now includes:

```moonbit
call_targets : Array[InferredCallTarget]
call_type_arguments : Array[BodyTypeId]
```

`call_targets` aligns with the module expression arena:

```moonbit
pub enum InferredCallTarget {
  NoInferredCallTarget
  ErrorInferredCallTarget
  SelectedInferredCallTarget(DeclId, HirSpan)
}
```

For a successful call, the `DeclId` is the exact selected function or builtin declaration. The span indexes `call_type_arguments` and records one fully inferred argument for each declared generic parameter.

Non-generic calls have an empty type-argument span. Failed calls use `ErrorInferredCallTarget` and poison their result type.

Per-body jobs retain call targets sparsely while running and populate the module-aligned table during stable merge. This avoids allocating a body-sized call-target table for every small function.

## Direct call lookup

Name resolution deliberately stores:

```moonbit
ModuleValueNameReference(NameId)
```

rather than committing to one declaration. Call inference reads the corresponding frozen `ValueBinding` and its source-ordered candidate chain.

If the binding has one callable declaration, the call is direct. This covers:

- ordinary top-level functions;
- non-overloaded builtins.

A module let or another non-callable value produces `InvalidCallTarget`.

The initial direct-call layer rejected local function values and field/qualified call targets. Later phases now implement first-class function values, structural callbacks, methods, and qualified calls.

## Constraint ordering and expected types

Call selection runs after the non-call structural constraints have been installed.

The body job currently performs:

1. Parameter, local, expression, and block type initialization
2. Name poison boundaries for deferred module roots
3. Let and return constraints
4. `if`, prefix, and binary structural constraints
5. Callable body-root checking
6. Direct call and overload inference
7. Zonking, unresolved checks, and compaction

This ordering means the call result may already carry an expected type from:

- a declared function return;
- explicit return;
- an `if` branch result;
- a surrounding operator;
- an outer direct call parameter.

For example:

```dew
builtin make() -> I32 = "make_i32"
builtin make() -> F32 = "make_f32"

fn use() -> F32 {
  make()
}
```

The declared `F32` body result reaches `make()` before overload trials, selecting the second candidate.

## Direct generic instantiation

Each call gets one fresh body-local variable for every generic parameter of the selected declaration.

For:

```dew
fn identity<t>(value: t) -> t {
  value
}

let number = identity(1)
let flag = identity(true)
```

call inference creates two independent substitutions:

```text
first call:  t -> fresh alpha, alpha = I32
second call: t -> fresh beta,  beta  = Bool
```

The declaration's canonical `GenericParameterType` remains rigid in its own body and in `ResolvedModuleTypes`. Fresh variables exist only in the caller's `LocalTypeSolver`.

No inference variable enters the frozen module resolved-type interner.

## Iterative signature substitution

Signature instantiation walks canonical resolved types with an explicit visit/finish task machine.

For:

```dew
builtin unwrap<t>(value: Box<t>) -> t = "unwrap"
```

and a `Box<I32>` argument, it constructs a temporary local application equivalent to:

```text
Box<alpha>
```

then unifies it structurally with canonical `Box<I32>`, producing:

```text
alpha = I32
```

The traversal handles:

- primitive types;
- rigid generic parameters not owned by the callee;
- nominal, trait, and `Self` types;
- local substitutions for callee generics;
- nested resolved applications;
- poison.

A generation-marked cache reuses instantiated subgraphs across all parameter and return roots of one candidate. Cache generations change between speculative candidates so rolled-back local term IDs are never reused.

A 1,024-level applied signature stress test passes without recursive semantic traversal.

## Direct call constraints

After instantiation, a direct call adds:

```text
argument[i] = instantiated parameter[i]
call result = instantiated return
```

An argument-count mismatch is diagnosed before signature instantiation:

```moonbit
CallArgumentCountMismatch(ExprId, DeclId, expected, actual, offset)
```

The exact declaration remains available in the diagnostic.

Ordinary type mismatches use the existing origin-bearing `LocalTypeMismatch` with `CallTypeConstraint` origin.

## Speculative builtin overload trials

A builtin name may have multiple declarations. Each candidate trial uses:

```moonbit
let snapshot = solver.snapshot()
```

The trial then:

1. Verifies arity
2. Allocates fresh candidate generic variables
3. Instantiates parameter types
4. Unifies every argument
5. Instantiates and unifies the return type with the call result
6. Records only whether the candidate was viable
7. Rolls the solver back

Rollback removes:

- trial variables;
- trial local applied terms;
- trial argument spans;
- parent, size, and binding mutations;
- mismatch or occurs-check diagnostics.

A losing candidate therefore cannot leak constraints or diagnostics into the body.

If exactly one candidate remains, that signature is instantiated again outside speculation and committed to the body solver.

## Structural specificity

Every arity-compatible candidate is trialed under solver rollback. Viable candidates are then compared by directional structural matching over their complete function types, including nested parameters and results. Candidate `A` is strictly narrower than `B` when `B` can instantiate to `A` but `A` cannot instantiate to `B`.

The unique undominated candidate wins. This preserves concrete-over-generic behavior while handling equal-generic-count cases such as `Box<Box<t>>` versus `Box<t>`, and it permits an expected nested result type to select an otherwise argument-free overload. Declaration order does not affect the winner. Alpha-equivalent signatures and overlapping-incomparable signatures remain ambiguous.

Pairwise containment checks reuse the body-local solver under snapshots. They allocate only rollback-scoped variables and applications, never mutate `ResolvedModuleTypes`, and cannot leak diagnostics.

## Iterative overload worklist

Nested overloaded calls may depend on one another.

For example:

```dew
builtin convert(value: I32) -> I64 = "i32_to_i64"
builtin convert(value: F32) -> F64 = "f32_to_f64"
builtin wrap(value: I64) -> Bool = "wrap_i64"
builtin wrap(value: F64) -> Bool = "wrap_f64"

fn use() -> Bool {
  wrap(convert(1))
}
```

The outer `wrap` initially sees an unresolved argument and has two viable candidates. The inner `convert` selects `I32 -> I64`. The worklist then retries `wrap`, which selects `I64 -> Bool`.

The algorithm is iterative:

1. Direct single-candidate calls are processed parent-first to push expected parameter types inward
2. Overloaded calls enter a pending list
3. A pass commits every unique candidate
4. Deferred obligations are retried if any pass made progress
5. When no progress remains, unresolved obligations become no-match or ambiguity diagnostics

Every successful pass removes at least one pending call, so the loop terminates without recursion.

## Overload diagnostics

The added diagnostics are:

```moonbit
InvalidCallTarget(ExprId, UInt64)
CallArgumentCountMismatch(ExprId, DeclId, Int, Int, UInt64)
NoMatchingCallOverload(NameId, ExprId, UInt64)
AmbiguousCallOverload(NameId, ExprId, DeclId, DeclId, Int, UInt64)
UnresolvedCallTypeArgument(ExprId, Int, UInt64)
```

`AmbiguousCallOverload` retains the first two equally ranked viable declarations in source order plus the complete viable count.

`UnresolvedCallTypeArgument` preserves selected calls whose runtime or lowering plan still lacks a required generic argument. For example:

```dew
fn phantom<t>() -> I32 {
  1
}

phantom()
```

selects `phantom`, infers the result as `I32`, retains the unresolved type variable in the selected-call span, and reports the missing generic inference separately.

## Poison behavior

A failed call forces its original result variable class to `BodyErrorType`, even when expected-type constraints had already bound that variable to a concrete type.

This required an explicit solver operation:

```moonbit
LocalTypeSolver::poison_type
```

Ordinary unification treats poison as compatible to suppress cascades, so merely unifying a previously bound variable with error would not have replaced the existing concrete binding.

If an overload argument is already poison because of an unsupported or invalid child expression, dependent no-match or ambiguity diagnostics are suppressed. The outer call becomes poison while the original child diagnostic remains visible.

## Stable merge and compaction

Selected generic type arguments are zonked before freezing. Unresolved arguments receive diagnostics but remain explicit body variables for tooling.

Call type arguments participate in local-term reachability marking. Any local application or unresolved variable reachable only from selected call metadata is therefore retained. Temporary candidate terms that are unreachable after rollback or final zonking disappear.

Body jobs may run in any order. Forward and reverse schedules produce identical:

- selected declarations;
- call type-argument spans;
- expression types;
- compact local terms;
- diagnostics.

## Performance investigation

The initial correct implementation allocated all call traversal and candidate scratch arrays per body, scanned every expression a second time to find calls, retained body-sized call target arrays, and trialed every overload before discarding less-specific candidates.

Initial native measurements were:

| Workload | Initial |
|---|---:|
| direct functions, n=256 | 293.97 us |
| generic functions, n=256 | 325.70 us |
| overload pairs, n=256 | 370.69 us |
| 17 candidates, 256 calls | 1.63 ms |
| nested overload worklist, n=256 | 637.87 us |
| generic full pipeline, n=256 | 1.25 ms |

The optimization sequence was:

1. Record call expression IDs while the existing initialization scan is already visiting expressions.
2. Retain per-body call results sparsely and populate the module-aligned table only during merge.
3. Reuse one call-instantiation and candidate-trial scratch arena per worker across body jobs.
4. Preserve generation-marked signature-instantiation caches across jobs without reusing stale term IDs.
5. Retain every viable candidate under rollback.
6. Compute deterministic undominated maxima by directional structural signature matching.

The worker-scratch change also restored no-call inference performance from a temporary 392.23 us regression to 346.71 us for the existing 256-function basic workload, effectively returning to the pre-call 347.50 us baseline.

Final native call measurements are:

| Workload | Initial | Final | Change |
|---|---:|---:|---:|
| direct functions, n=256 | 293.97 us | 238.68 us | -19% |
| generic functions, n=256 | 325.70 us | 273.05 us | -16% |
| overload pairs, n=256 | 370.69 us | 326.99 us | -12% |
| 17 candidates, 256 calls | 1.63 ms | 311.95 us | -81% |
| nested overload worklist, n=256 | 637.87 us | 600.49 us | -6% |
| generic full pipeline, n=256 | 1.25 ms | 1.17 ms | -6% |

## Final cross-backend benchmarks

Release-mode measurements compare only within one backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| direct functions, n=256 | 238.68 us | 164.81 us | 634.45 us | 759.01 us |
| generic functions, n=256 | 273.05 us | 200.50 us | 687.09 us | 853.67 us |
| overload pairs, n=256 | 326.99 us | 246.49 us | 981.33 us | 1.03 ms |
| 17 candidates, 256 calls | 311.95 us | 232.48 us | 1.05 ms | 952.15 us |
| nested overload worklist, n=256 | 600.49 us | 465.48 us | 2.10 ms | 1.86 ms |
| generic full pipeline, n=256 | 1.17 ms | 982.92 us | 1.94 ms | 3.49 ms |

The wide-overload result demonstrates the main optimization: selecting an exact tier no longer pays to instantiate sixteen less-specific generic candidates.

## Tests

Call inference tests cover:

- direct function selection;
- non-generic builtin calls;
- independent generic variables at multiple call sites;
- substitution through applied signatures;
- argument-driven overload selection;
- expected-result-driven overload selection;
- exact-over-generic preference;
- strict nested generic/generic containment independent of declaration order;
- result-type structural specificity;
- equivalent and overlapping-incomparable ambiguity;
- nested overload worklist retries;
- no-match diagnostics;
- ambiguity diagnostics with stable declaration identities;
- speculative diagnostic rollback;
- direct arity mismatch;
- invalid local call targets;
- unresolved generic call arguments;
- poison suppression of dependent ambiguity;
- 1,024-level iterative signature instantiation;
- forward/reverse body-job determinism.

## Current boundary

Expected-type enum/pattern inference, matches and functional loops, members,
qualified calls, operator and trait obligations, imported callable/value types,
executable generic evidence, structural overload specificity, and exact
`turbofish` call-site type arguments are implemented by later tranches. Optional
arguments remain open in `docs/roadmap.md`.
