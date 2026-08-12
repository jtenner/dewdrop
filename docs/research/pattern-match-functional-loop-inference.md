# Pattern, match, and functional-loop type inference

Date: 2026-07-30

## Scope

Dew now performs expected-type-driven inference for patterns, match expressions, and functional state loops.

The implemented stage covers:

- wildcard and binding patterns;
- literal patterns;
- unit, tuple-like, and struct-like enum variants;
- nominal struct destructuring;
- qualified enum variants;
- expected-type and globally unique bare-variant selection;
- generic enum and struct argument substitution;
- tuple payload arity and rest patterns;
- struct field lookup, missing fields, unknown fields, and struct rest;
- alternative patterns sharing one local type contract;
- Boolean match and loop guards;
- match arm result unification;
- diverging match arms;
- functional-loop state and result types;
- `continue` state constraints;
- `break` result constraints;
- continue-only loop `Never` results;
- basic loop-arm fallthrough diagnostics;
- frozen selected pattern constructors and generic arguments.

The implementation extends:

- `src/semantic/body_inference.mbt`;
- `src/semantic/infer_basic_bodies.mbt`.

Tests and benchmarks live in:

- `src/semantic/pattern_match_loop_inference_wbtest.mbt`;
- `src/semantic/pattern_match_loop_stress_wbtest.mbt`;
- `src/semantic/pattern_match_loop_inference_bench_test.mbt`.

## Frozen output

`InferredModuleBodies` now includes:

```moonbit
pattern_types : Array[BodyTypeId]
pattern_constructors : Array[InferredPatternConstructor]
pattern_type_arguments : Array[BodyTypeId]
control_state_types : Array[BodyTypeId]
control_result_types : Array[BodyTypeId]
```

Pattern types align with the module pattern arena. Control types align with `ResolvedModuleNames.controls`.

Selected constructors use:

```moonbit
pub enum InferredPatternConstructor {
  NoInferredPatternConstructor
  ErrorInferredPatternConstructor
  StructInferredPatternConstructor(DeclId, HirSpan)
  VariantInferredPatternConstructor(VariantId, HirSpan)
}
```

The span indexes `pattern_type_arguments` and contains one zonked argument for every declared generic parameter of the selected struct or enum.

Constructor metadata is attached to the complete payload pattern:

- a bare or qualified unit-variant pattern;
- a tuple variant pattern;
- a struct variant pattern;
- a nominal struct pattern.

Wildcard, ordinary binding, literal, rest, and alternative wrapper patterns have no constructor selection.

## Expected-type propagation

Every match arm pattern receives the scrutinee type as its expected type.

Every functional-loop arm pattern receives the loop state type.

Pattern inference uses an explicit stack of:

```text
(pattern ID, expected BodyTypeId)
```

The expected type flows from outer patterns into payload children rather than being inferred bottom-up from parser shape.

The task stack is worker scratch reused across body jobs. No recursive semantic pattern traversal is required.

## Wildcards and bindings

A wildcard accepts the expected type without creating a local.

A binding pattern already refers to a stable `LocalId` from name resolution. Inference adds:

```text
type(pattern local) = expected pattern type
```

Pattern locals now begin as fresh body-local variables rather than poison.

Every occurrence of one alternative-pattern binding name already shares the same `LocalId`. Constraining those occurrences naturally enforces compatible types.

For:

```dew
enum State {
  Number(I32)
  Flag(Bool)
}

Number(value), Flag(value) => ...
```

one occurrence constrains `value` to `I32` and the other constrains it to `Bool`, producing a pattern-origin `LocalTypeMismatch`.

## Literal patterns

Literal patterns reuse their lowered literal expression. The literal expression type is constrained to the pattern's expected type.

For example, in a `Bool` match:

```dew
true => ...
```

checks the literal expression against `Bool`.

No independent literal-pattern type representation is required.

## Nominal type inspection

Constructor selection needs the nominal head and generic arguments of an expected body type.

Inference recognizes:

- canonical resolved `NominalType`;
- canonical resolved `AppliedType` whose base is nominal;
- body-local `BodyAppliedType` whose base resolves to a nominal constructor.

The extracted generic arguments remain `BodyTypeId` values and may therefore be:

- rigid resolved types;
- rigid declaration generics;
- local inference variables;
- local applications.

## Bare enum variant selection

For a bare variant such as:

```dew
Some(value)
```

selection first inspects the expected nominal type.

If the expected type is an enum, inference searches only that enum's source-ordered variant span. A missing name produces `UnknownVariantForType`.

If the expected type is not yet nominal, inference searches all module variants:

- one matching variant: select it and constrain the expected type to its enum;
- more than one: emit `AmbiguousPatternVariant`;
- none: emit `InvalidPatternConstructor`.

The ambiguity diagnostic retains the first two `VariantId` values and the total candidate count.

Variant spans are precomputed from the flat collected variant arena. Lookup remains a small source-order scan within one enum. A hash lookup experiment for wide enums was measured and rejected because construction overhead outweighed the saved comparisons in the current benchmark.

## Qualified variants

For:

```dew
Maybe::Some(value)
```

name resolution has already classified:

- `Maybe` as `PatternTypeReference(DeclId)`;
- the qualified node as `PatternQualifiedReference(NameId)`.

Inference selects `Some` exclusively from the explicitly named enum and constrains the expected type to that enum instance.

A qualified unit variant such as `Maybe::None` follows the same path.

## Generic constructor substitution

Once a struct or enum declaration is selected, inference prepares one substitution value for every declaration generic.

If the expected type is already an instance of the selected declaration, its exact generic arguments are reused.

For:

```dew
enum Maybe<t> {
  None
  Some(t)
}

value: Maybe<I32>
```

`Some(item)` receives:

```text
t -> I32
item -> I32
```

If the expected type is unresolved, fresh variables are created and an instance is built:

```text
Expected = Selected<alpha, beta, ...>
```

Payload signature types are instantiated by the same iterative, generation-cached signature substitution machine used for generic calls.

When the expected type already has the selected nominal head and arguments, inference skips rebuilding and re-unifying an equivalent nominal application. This optimization improved enum, alternative, and functional-loop workloads.

## Unit variants

A bare or qualified constructor without payload must select a `UnitVariantDecl`.

Using a tuple or struct variant without its payload produces `PatternPayloadKindMismatch`.

The selected variant and enum generic arguments are retained in `pattern_constructors`.

## Tuple variant payloads

A tuple pattern must select a `TupleVariantDecl`.

Without rest syntax, explicit pattern count must equal payload count.

With one rest pattern:

```dew
Tuple(first, ..., last)
```

explicit pattern count may be smaller than the payload count. Patterns before rest map from the beginning, and patterns after rest map from the end.

For a payload:

```text
(I32, Bool, String)
```

that example produces:

```text
first : I32
last  : String
```

The rest node has no singular value type and retains the shared pattern error sentinel without a diagnostic.

Invalid counts produce:

```moonbit
PatternPayloadArityMismatch(PatternId, expected, actual, offset)
```

Payload child types are instantiated after enum generic substitution.

## Struct variant and nominal struct payloads

A struct-like pattern may select either:

- a `StructDecl` directly;
- a `StructVariantDecl` from an enum.

Field records are selected by declaration and optional `VariantId` owner.

For each written field:

1. Look up the semantic field by `NameId`
2. Instantiate its resolved type under the constructor substitution
3. Push the child pattern with that expected type
4. Mark the field as present

Unknown fields produce `UnknownPatternField`.

Without `...`, every declared field must appear; omitted fields produce one `MissingPatternField` each.

With struct rest, omitted fields are accepted.

Small field sets use a linear scan. Wider field sets use a reusable worker-local name map and matched-bit array, avoiding quadratic behavior for large records without imposing map allocation on small patterns.

## Alternative patterns

The HIR alternative wrapper contains one first pattern and a flat span of remaining alternatives.

Every alternative receives the same expected scrutinee or loop state type.

Name resolution has already guaranteed the binding-name contract and assigned corresponding occurrences the same `LocalId`. Type inference therefore needs no second name-matching table: every corresponding payload occurrence constrains the same local variable.

This catches incompatible alternative payloads while preserving one local visible to the shared guard and body.

## Match guards

Every present guard is constrained to `Bool`:

```text
type(guard) = Bool
```

Guard-local pattern bindings have already been resolved into the arm scope.

A non-Boolean guard produces an ordinary origin-bearing mismatch.

## Match result inference

For:

```dew
match scrutinee {
  pattern_a => result_a
  pattern_b => result_b
}
```

inference allocates or reuses one match result type and adds:

```text
result_a assignable to match result
result_b assignable to match result
```

`Never` arms do not constrain ordinary result values.

If every arm is already known to be `Never`, the match expression is constrained to `Never`.

Expected types from a function return, surrounding call, operator, let, or outer branch flow into the shared match result before call overload selection completes. Calls inside arm bodies can therefore use the eventual expected result through the existing equality graph.

Selected variant IDs, wildcard patterns, guards, and expected nominal types are consumed by the implemented exhaustiveness and redundancy phase described in `docs/research/structured-flow-exhaustiveness.md`.

## Functional-loop state and result types

Every resolved functional loop control receives two independent body-local variables:

```text
state type  S
result type R
```

The while expression itself reuses `R`.

For:

```dew
while initial {
  pattern => body
}
```

inference adds:

```text
type(initial) = S
pattern expected type = S
guard type = Bool
```

Each transfer uses its resolved nearest `ControlId`:

```text
continue next: type(next) assignable to target S
break result:  type(result) assignable to target R
```

Nested loops therefore constrain the state and result variables of the correct lexical control.

## Continue-only loops

If no `break` expression targets a control, its result is constrained to `Never`.

Therefore:

```dew
while initial {
  _ => continue initial
}
```

has type `Never` and is assignable to any surrounding expected return type under the existing bottom-type rule.

## Loop-arm transfer checking

The initial milestone diagnosed loop-arm fallthrough from whether the arm root inferred as `Never`. This provisional check has now moved out of type inference.

`analyze_module_flows` computes structural expression and arm outcome summaries, then emits `BodyFlowDiagnostic::FunctionalLoopArmFallsThrough` whenever an arm retains an ordinary completion path. The flow phase handles branches, matches, short-circuit operators, explicit transfers, returns, and calls inferred as `Never`. See `docs/research/structured-flow-exhaustiveness.md`.

## Diagnostics

The added diagnostics are:

```moonbit
InvalidPatternConstructor(PatternId, UInt64)
UnknownVariantForType(NameId, DeclId, PatternId, UInt64)
AmbiguousPatternVariant(NameId, PatternId, VariantId, VariantId, Int, UInt64)
PatternPayloadKindMismatch(PatternId, UInt64, UInt64)
PatternPayloadArityMismatch(PatternId, Int, Int, UInt64)
UnknownPatternField(NameId, PatternId, UInt64)
MissingPatternField(NameId, PatternId, UInt64)
UnresolvedPatternTypeArgument(PatternId, Int, UInt64)
```

Ordinary payload, guard, arm-result, state, continue, and break type incompatibilities continue to use `LocalTypeMismatch` with pattern or expression origins.

## Compaction and merge

The following now participate in zonking and reachable-term compaction:

- pattern node types;
- selected constructor type arguments;
- control state types;
- control result types.

Selected constructor spans are remapped into one module-wide `pattern_type_arguments` arena during stable body merge.

Control-local arrays are remapped into the module-wide control span from `ResolvedModuleNames`.

Forward and reverse body schedules remain byte-for-byte equal.

## Iterative stress coverage

The implementation passes:

- 512 nested generic enum payload patterns;
- 512 functional-loop arms;
- existing 513-arm match HIR stress;
- wide alternative binding sets;
- nested functional-loop control resolution.

Pattern propagation, generic signature substitution, match-arm iteration, and loop-arm iteration use explicit arrays rather than recursive semantic traversal.

## Performance investigation

The initial implementation was already iterative but added several empty arrays and control scans to every body, including bodies with no patterns or loops.

Optimizations included:

1. Move pattern task, field-index, matched-bit, and field-map scratch into the worker-owned reusable call/inference scratch object.
2. Share immutable empty arrays for bodies with no patterns or controls.
3. Skip control initialization, transfer scans, and fallthrough scans when a body has no functional-loop controls.
4. Retain linear variant lookup after a measured hash-map experiment regressed the representative enum workload.
5. Skip equivalent nominal reconstruction and unification when the expected type already has the selected constructor and generic arguments.
6. Use a small-linear/wide-map field lookup policy.

The no-pattern 256-function workload improved from a temporary 405.14 us feature regression to 383.39 us. The preceding module-value milestone measured 357.14 us, so the frozen pattern and control output currently adds roughly 7% to this small-body-heavy synthetic workload.

Representative native pattern changes from the first correct implementation to the final implementation are:

| Workload | Initial | Final | Change |
|---|---:|---:|---:|
| enum variant arms, n=256 | 130.31 us | 125.60 us | -4% |
| literal arms, n=512 | 90.10 us | 94.66 us | +5% |
| struct fields, n=128 | 27.32 us | 29.42 us | +8% |
| alternative arms, n=256 | 182.08 us | 170.16 us | -7% |
| functional-loop arms, n=256 | 142.07 us | 132.95 us | -6% |
| full pipeline variant arms, n=256 | 617.27 us | 613.86 us | -1% |

The literal and 128-field differences are small absolute changes and include the cost of publishing the new pattern side tables. The wide-field map is retained for asymptotic protection beyond the benchmark width.

## Final cross-backend benchmarks

Release-mode measurements compare only within one backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| enum variant arms, n=256 | 125.60 us | 106.76 us | 317.45 us | 376.91 us |
| literal arms, n=512 | 94.66 us | 63.72 us | 195.10 us | 265.26 us |
| struct fields, n=128 | 29.42 us | 21.18 us | 68.72 us | 88.75 us |
| alternative arms, n=256 | 170.16 us | 121.61 us | 386.84 us | 533.21 us |
| functional-loop arms, n=256 | 132.95 us | 120.35 us | 328.62 us | 386.03 us |
| full pipeline variant arms, n=256 | 613.86 us | 587.12 us | 1.16 ms | 1.84 ms |

## Tests

Coverage includes:

- generic tuple and unit variants;
- qualified variants;
- expected-type variant selection;
- globally ambiguous bare variants;
- generic payload substitution;
- nominal struct patterns;
- struct enum variants;
- tuple payload arity;
- tuple rest prefix/suffix mapping;
- struct unknown and missing fields;
- struct rest;
- wildcard and literal patterns;
- alternative binding type compatibility;
- Boolean guards;
- incompatible match arm results;
- selected constructor metadata;
- functional-loop state types;
- functional-loop result types;
- continue constraints;
- break constraints;
- loop guards and patterns;
- continue-only `Never` loops;
- loop-arm fallthrough;
- 512 nested generic payload levels;
- 512 functional-loop arms.

## Current boundary

Structured flow, aggregates, methods and trait obligations, deterministic match
and functional-loop lowering, and WasmGC payload access are implemented. Full
nested pattern-matrix usefulness/witness construction and deeper alternative
extraction sharing remain open in `docs/roadmap.md`.
