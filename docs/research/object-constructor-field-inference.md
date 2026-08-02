# Object, constructor, enum-value, and field inference

Date: 2026-07-30

## Scope

Dew body inference now supports:

- explicit nominal struct construction;
- expected-type-driven object literals;
- struct-like enum variant construction;
- tuple enum variant construction through calls;
- qualified and bare unit enum values;
- qualified and bare tuple variant calls;
- generic constructor argument inference;
- generic field-type substitution;
- chained field access;
- nested expected object literals;
- object-literal participation in overload selection;
- construction field validation;
- frozen constructor, field, and generic-argument selections.

The implementation extends:

- `src/semantic/body_inference.mbt`;
- `src/semantic/infer_basic_bodies.mbt`.

Tests and benchmarks are in:

- `src/semantic/object_field_inference_wbtest.mbt`;
- `src/semantic/object_field_inference_stress_wbtest.mbt`;
- `src/semantic/object_field_inference_bench_test.mbt`.

## Frozen output

`InferredModuleBodies` now includes:

```moonbit
expression_selections : Array[InferredExpressionSelection]
expression_type_arguments : Array[BodyTypeId]
object_field_targets : Array[InferredObjectFieldTarget]
```

Expression selections align with the module expression arena:

```moonbit
pub enum InferredExpressionSelection {
  NoExpressionSelection
  ErrorExpressionSelection
  StructConstructionSelection(DeclId, HirSpan)
  VariantConstructionSelection(VariantId, HirSpan)
  UnitVariantValueSelection(VariantId, HirSpan)
  FieldAccessSelection(FieldId)
}
```

Constructor spans index `expression_type_arguments` and retain one zonked argument for each declaration generic.

Object-field targets align with the flat collected object-field arena:

```moonbit
pub enum InferredObjectFieldTarget {
  NoObjectFieldTarget
  ErrorObjectFieldTarget
  SelectedObjectFieldTarget(FieldId)
}
```

Lowering therefore receives exact stable constructor and field identities without repeating name lookup.

## Explicit struct construction

For:

```dew
struct Pair<t> {
  first: t
  second: Bool
}

Pair {
  first: value
  second: true
}
```

name resolution has already classified `Pair` as `ModuleTypeNameReference(DeclId)`.

Inference:

1. Verifies that the target declaration is a struct.
2. Reuses generic arguments from an expected `Pair<...>` type when available.
3. Otherwise creates one fresh variable per struct generic.
4. Constrains the result to the selected struct instance.
5. Instantiates every declared field type.
6. Constrains each field value against its instantiated field type.
7. Records the exact struct declaration and generic arguments.

A constructor target expression is a semantic namespace root rather than a runtime value. It is marked consumed so it does not produce an unsupported-expression or unresolved-expression cascade.

## Expected object literals

An untyped object literal has no syntactic nominal target:

```dew
{
  first: value
  second: true
}
```

It requires an expected nominal struct type from its surrounding constraints.

Expected types may flow from:

- a callable return type;
- a function or builtin parameter;
- a selected overload candidate;
- a let or module-value slot;
- an enclosing struct field;
- a branch or match result;
- a direct equality constraint.

When the expected type is `Pair<I32>`, object inference reuses `I32` as the struct generic argument and checks the field values accordingly.

A concrete non-struct expected type or an unresolved object boundary produces:

```moonbit
ObjectTypeRequired(ExprId, UInt64)
```

## Member worklist

Object and field inference is deferred until ordinary structural constraints, root expectations, and calls have been installed.

A reusable iterative worklist then resolves dependencies between:

- an object literal and its expected type;
- a field access and its base type;
- nested object literals;
- chained field accesses;
- calls whose parameters constrain object arguments.

Field expressions enter in child-first order, allowing chains such as:

```dew
value.inner.x
```

to resolve in one forward pass.

Object literals enter in reverse child-first order, allowing an outer expected struct to constrain nested object fields before their own work item is processed:

```dew
{
  inner: {
    x: 1
  }
}
```

If one class of member unlocks another, deferred jobs are retried. If a complete pass makes no progress, unresolved objects and fields receive one root diagnostic and are poisoned.

The worklist is iterative and passes 512-level nested-object and field-chain stress tests.

## Lazy member storage

Bodies without objects, constructions, fields, qualified enum values, or variant names retain shared empty selection arrays.

Member selection and consumed-root arrays are allocated lazily during the existing expression-type initialization pass when the first relevant HIR node is observed.

This avoids a separate body scan and avoids per-body member arrays for the common no-member case.

## Generic instantiation

Expression constructors share the iterative, generation-cached signature substitution engine already used by calls and patterns.

When an expected nominal instance matches the selected declaration, its arguments are copied directly.

Otherwise inference creates fresh arguments and constrains:

```text
expression result = Selected<alpha, beta, ...>
```

Field and tuple-payload signatures are then instantiated under that mapping.

All selected generic arguments participate in zonking, unresolved-variable diagnostics, reachability marking, compaction, job-local remapping, and stable module merge.

An unresolved constructor generic produces:

```moonbit
UnresolvedExpressionTypeArgument(ExprId, argument_index, UInt64)
```

For example, constructing an empty generic struct without any expected type or constraining field leaves its generic unresolved and receives this diagnostic.

## Struct-like enum variants

For:

```dew
enum Message<t> {
  Empty
  Data {
    value: t
    code: I32
  }
}

Message::Data {
  value: text
  code: 1
}
```

inference:

1. Resolves `Message` as an enum declaration.
2. Selects `Data` only from that enum.
3. Requires `StructVariantDecl` payload kind.
4. Instantiates the enclosing enum generics.
5. Selects fields owned by the exact `VariantId`.
6. Records `VariantConstructionSelection`.

The result type is the enclosing enum instance, not a separate variant type.

## Tuple enum variants

Tuple variants use call syntax:

```dew
Maybe::Some(value)
Some(value)
```

Qualified calls search only the explicit enum. Bare calls use the expected enum when available and otherwise require a globally unique module variant spelling.

Inference checks tuple payload kind and exact arity, instantiates each payload signature, and constrains arguments in source order.

Tuple construction is represented by `VariantConstructionSelection`, while ordinary function and builtin calls continue to use `InferredCallTarget`. Constructor calls leave the ordinary call target as `NoInferredCallTarget`, preventing a variant from masquerading as a function declaration.

Invalid arity produces:

```moonbit
ConstructionPayloadArityMismatch(
  ExprId,
  VariantId,
  expected,
  actual,
  offset,
)
```

## Unit enum values

Unit variants are values without call or object payload syntax:

```dew
Maybe::None
None
```

Qualified values select from the explicit enum. Bare values use expected-type or globally unique selection, matching tuple-variant behavior.

The result is the enclosing enum instance, and output records:

```moonbit
UnitVariantValueSelection(VariantId, generic_arguments)
```

Using a tuple or struct variant without its required payload, or applying the wrong payload syntax to a unit variant, produces `ConstructionPayloadKindMismatch`.

## Field validation

For every nominal object or construction, inference builds the selected owner field set:

- struct fields use `(DeclId, None)` ownership;
- struct-variant fields use `(DeclId, Some(VariantId))` ownership.

Written fields are validated for:

- unknown names;
- duplicate names;
- missing required fields;
- value-type compatibility.

Diagnostics are:

```moonbit
DuplicateConstructionField(NameId, first_offset, duplicate_offset)
UnknownConstructionField(NameId, ExprId, UInt64)
MissingConstructionField(NameId, ExprId, UInt64)
```

Every successful field records its stable `FieldId`. Unknown and duplicate fields record `ErrorObjectFieldTarget`.

Small field sets use linear lookup. Wider sets reuse the worker-local field map and matched-bit scratch already used by pattern inference.

## Declaration field spans

Field metadata is flat and source ordered. A per-declaration `HirSpan` index is built once for body/module inference.

Field access and construction validation scan only the selected declaration's field span rather than the complete module field arena.

This optimization reduced the representative native workloads from:

- nested objects depth 256: 148.88 us to about 94 us;
- field chain depth 512: 214.02 us to about 150 us.

It also preserves source-order lookup and requires no global concurrent map.

## Field access

For:

```dew
pair.first
```

inference:

1. Inspects the zonked representative of the base type.
2. Requires a nominal struct instance.
3. Searches only that declaration's field span.
4. Reuses the base generic arguments.
5. Instantiates the selected field type.
6. Constrains the field expression result.
7. Records `FieldAccessSelection(FieldId)`.

For:

```dew
struct Pair<t> {
  first: t
}

pair: Pair<I32>
```

`pair.first` is inferred as `I32`.

Errors are:

```moonbit
FieldAccessRequiresNominal(ExprId, UInt64)
UnknownFieldForType(NameId, DeclId, ExprId, UInt64)
```

Enum variant-specific fields are not directly accessible through an enum value; they require pattern refinement first.

## Object arguments and overload selection

A raw object expression begins as a fresh type variable. Treating that variable as compatible with every overload would cause primitive and nominal candidates to remain spuriously viable.

Overload speculation therefore performs a no-diagnostic nominal-shape check for object arguments:

- the candidate parameter must resolve to a struct;
- every declared field must appear exactly once;
- no extra field may appear.

Primitive candidates are rejected before unification. A unique nominal candidate can then constrain the object expression, after which the ordinary member worklist performs complete field typing and publishes selections.

If no candidate supplies a valid nominal context, call no-match/ambiguity is suppressed and the object expression emits one `ObjectTypeRequired` root diagnostic.

This preserves the existing poison/no-cascade policy while allowing object shape to participate in overload selection.

## Consumed member roots

Qualified or field-shaped expressions used as method/static-call targets are marked consumed before ordinary field inference. The subsequent impl-index phase either publishes a selected method or one method/qualified-member diagnostic.

This prevents `value.method()` from also producing a false unknown-field diagnostic for `method`. Constructor namespace roots are consumed similarly.

## Diagnostics

The added body-inference diagnostics are:

```moonbit
InvalidConstructionTarget(ExprId, UInt64)
ObjectTypeRequired(ExprId, UInt64)
ConstructionPayloadKindMismatch(ExprId, UInt64, UInt64)
ConstructionPayloadArityMismatch(ExprId, VariantId, Int, Int, UInt64)
UnknownVariantValue(NameId, ExprId, UInt64)
AmbiguousVariantValue(NameId, ExprId, VariantId, VariantId, Int, UInt64)
DuplicateConstructionField(NameId, UInt64, UInt64)
UnknownConstructionField(NameId, ExprId, UInt64)
MissingConstructionField(NameId, ExprId, UInt64)
FieldAccessRequiresNominal(ExprId, UInt64)
UnknownFieldForType(NameId, DeclId, ExprId, UInt64)
UnknownQualifiedMember(NameId, DeclId, ExprId, UInt64)
UnresolvedExpressionTypeArgument(ExprId, Int, UInt64)
```

Field value, tuple payload, constructor result, and field result incompatibilities continue to use origin-bearing `LocalTypeMismatch` diagnostics.

## Determinism

Constructor and field inference remains body-job-local.

Forward and reverse body schedules compare equal for:

- expression selections;
- expression generic arguments;
- object-field targets;
- inferred types;
- diagnostics.

The final merge remaps constructor argument spans into one module-wide arena in stable `BodyId` order.

## Stress coverage

The implementation passes:

- 512-field struct construction;
- 512 nested expected object literals;
- a 512-link nominal field chain;
- generic structs and generic enum variants;
- nested object/field worklist dependencies;
- forward/reverse body-job determinism.

All traversals remain iterative.

## Performance investigation

The first correct implementation used whole-module field scans and an ascending mixed member worklist.

Retained optimizations include:

1. Per-declaration field spans.
2. Child-first field ordering and reverse child-first object ordering.
3. Reusable worker-local field maps and matched bits.
4. Lazy expression-selection and consumed-root arrays.
5. Shared empty member arrays for bodies without member syntax.
6. One worklist for nested object/field dependencies rather than recursive descent.

Representative native changes from the first correct implementation are:

| Workload | Initial | Final | Change |
|---|---:|---:|---:|
| construction fields, n=128 | 26.02 us | 27.38 us | +5% |
| nested expected objects, depth=256 | 148.88 us | 94.34 us | -37% |
| field chain, depth=512 | 214.02 us | 150.37 us | -30% |
| tuple variant functions, n=256 | 395.40 us | 411.65 us | +4% |
| object overload calls, n=256 | 329.61 us | 331.10 us | approximately flat |
| full pipeline fields, n=128 | 187.32 us | 187.63 us | approximately flat |

The basic no-member 256-function workload is currently about 431 us versus roughly 383 us at the previous milestone. Lazy member arrays recovered a substantial temporary regression, but publishing the new expression-selection side table and broader inference dispatch still adds measurable overhead to this small-body-heavy synthetic case.

## Cross-backend benchmarks

Release-mode measurements compare within each backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| construction fields, n=128 | 27.38 us | 16.85 us | 59.25 us | 84.34 us |
| nested objects, depth=256 | 94.34 us | 71.37 us | 255.59 us | 314.71 us |
| field chain, depth=512 | 150.37 us | 114.23 us | 396.00 us | 489.31 us |
| tuple variant functions, n=256 | 411.65 us | 324.63 us | 958.43 us | 1.21 ms |
| object overload calls, n=256 | 331.10 us | 279.26 us | 1.12 ms | 1.04 ms |
| full pipeline fields, n=128 | 187.63 us | 183.73 us | 296.58 us | 568.37 us |

## Current boundaries

This object/field stage does not itself implement method selection; the subsequent impl-index phase now handles receiver, type-qualified, and trait-qualified static/instance calls. Remaining boundaries include:

- trait-provided fields;
- tuple indexing or collection indexing;
- object structural types independent of an expected nominal struct;
- direct access to enum variant-specific fields without pattern refinement;
- explicit generic qualification syntax;
- constructor visibility across modules;
- layout offsets and WasmGC field operations;
- pattern decision-tree lowering.

## Next steps

1. Define indexing through builtin/operator traits.
2. Add generic trait obligations and evidence passing.
3. Lower selected constructors, fields, and methods into deterministic WasmGC plans.
