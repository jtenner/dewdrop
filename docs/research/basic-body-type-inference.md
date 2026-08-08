# Basic HIR-driven body type inference

Date: 2026-07-30

## Scope

Dew now runs the body-local unification engine over executable HIR and publishes the first immutable inferred body types.

The implemented constraint layer covers:

- fixed primitive literal types;
- declared parameter and receiver types;
- local-name references;
- sequential immutable and mutable lets;
- block result types;
- function tail expressions;
- empty blocks;
- valued and bare returns;
- `if` conditions, branches, and no-else `Unit` results;
- prefix equality constraints;
- binary operand/result equality constraints;
- `Never` for break, continue, and guaranteed-return block tails;
- one poison diagnostic boundary for unsupported expression forms.

Direct functions and overloads are documented in `docs/research/direct-generic-overload-call-inference.md`; pattern and loop inference in `docs/research/pattern-match-functional-loop-inference.md`; nominal objects, enum constructors, and fields in `docs/research/object-constructor-field-inference.md`; and impl/method selection in `docs/research/impl-index-instance-method-inference.md`. Indexing and generic trait obligations remain later layers.

The public entry point is:

```moonbit
pub fn infer_module_bodies(
  CollectedModule,
  ResolvedModuleTypes,
  ResolvedModuleNames,
) -> InferredModuleBodies
```

The implementation lives in:

- `src/semantic/body_inference.mbt`;
- `src/semantic/infer_basic_bodies.mbt`;
- `src/semantic/basic_body_inference_wbtest.mbt`;
- `src/semantic/basic_body_inference_bench_test.mbt`.

## Frozen result

```moonbit
pub struct InferredModuleBodies {
  module_id : ModuleId
  bodies : Array[InferredBody]
  types : Array[BodyTypeTerm]
  type_arguments : Array[BodyTypeId]
  expression_types : Array[BodyTypeId]
  local_types : Array[BodyTypeId]
  block_types : Array[BodyTypeId]
  pattern_types : Array[BodyTypeId]
  diagnostics : Array[BodyInferenceDiagnostic]
}
```

`expression_types` and `block_types` align directly with the collected module arenas. `local_types` aligns with the module-wide local records produced by `ResolvedModuleNames`.

Each body records:

```moonbit
pub struct InferredBody {
  body : BodyId
  root_type : BodyTypeId
  types : HirSpan
  type_arguments : HirSpan
  diagnostics : HirSpan
}
```

`root_type` is the type of the body's root expression or block. A callable whose final operation is guaranteed return therefore has root type `Never`, while its declared callable return type remains in `ResolvedModuleTypes`.

`pattern_types` currently contains the shared error type because pattern inference has not yet been enabled. Reserving the aligned table now avoids changing the result shape when that phase lands.

## Job inputs

Each body job reads:

- one frozen `HirBody` and module HIR arenas;
- normalized declaration signatures from `ResolvedModuleTypes`;
- local and module references from `ResolvedModuleNames`;
- one worker-local reusable `LocalTypeSolver`.

The three module IDs are validated before inference starts.

## Parameter seeding

Every `ParameterLocal` is assigned its normalized declared parameter type directly:

```text
local type = BodyResolvedType(parameter signature type)
```

Current declaration generic parameters remain rigid resolved terms. They are not replaced by inference variables while checking their own function body.

Let locals receive fresh inference variables. Pattern locals currently receive poison until pattern inference supplies expected types.

## Literal types

Literal spellings already determine fixed primitive types:

```text
I8 literal     -> I8
I16 literal    -> I16
I32 literal    -> I32
I64 literal    -> I64
U8 literal     -> U8
U16 literal    -> U16
U32 literal    -> U32
U64 literal    -> U64
F32 literal    -> F32
F64 literal    -> F64
Boolean        -> Bool
String         -> String
```

Literal expression tables therefore store encoded rigid resolved type IDs and allocate no body-local variable.

## Local references

Name resolution already maps each local use to a `LocalId`. During type initialization, a local-name expression reuses the exact same `BodyTypeId` as the local slot:

```text
expression_types[name expression] = local_types[local ID]
```

No equality constraint or temporary expression variable is necessary.

This direct identity is semantically stronger and cheaper than allocating an expression variable and immediately unifying it with the local.

Module value roots are initially poisoned until the call layer consumes them. A successful direct or overloaded call clears the root's deferred diagnostic and records its exact selected declaration. Types, traits, variants, and intrinsics still require constructor, qualification, or later module-value inference.

## Sequential lets

For:

```dew
let result = initializer
```

name resolution has already guaranteed initializer-before-binding visibility. Type inference adds:

```text
type(local result) = type(initializer)
```

Mutable and immutable lets use the same equality rule. Mutability affects later assignment and borrow semantics, not the inferred value type.

Local lets are monomorphic. This phase performs no implicit let-generalization.

## Block types

Block result types are selected directly rather than through one fresh variable per block:

- empty block: `Unit`;
- final let item: `Unit`;
- final return item: `Never`;
- final expression item: the exact expression type ID.

A `HirBlockExpr` likewise reuses its block's type ID directly.

Earlier expression items may produce values that are evaluated and discarded. They are still inferred but do not constrain the block result.

This establishes the function-tail policy:

> The final expression item is the block value. Earlier expression values may be discarded. An empty block is `Unit`.

## Returns

A valued return adds an assignability constraint:

```text
type(return value) assignable to declared return type
```

A bare return checks:

```text
Unit assignable to declared return type
```

A return inside a module-let expression receives `ReturnOutsideCallable`.

A block whose final item is return has root type `Never`. The callable's declared return type is checked by the return item itself, so the `Never` root is not incorrectly equated with that declared type.

## `Never` assignability

`Never` represents an expression that cannot produce an ordinary value because control transfers elsewhere.

At this stage:

- `break` expressions have type `Never`;
- `continue` expressions have type `Never`;
- a block ending in return has type `Never`.

When an actual type is `Never`, assignability to an expected value type succeeds without ordinary equality. This permits:

```dew
if condition {
  return value
} else {
  fallback
}
```

to infer the `if` result from `fallback` rather than requiring `Never = type(fallback)`.

If both branches are `Never`, the complete `if` is `Never`.

## `if` inference

Every condition is constrained to `Bool`.

For an `if` with `else`:

```text
then block assignable to result
else expression assignable to result
```

The result variable is shared by both non-diverging branches.

For an `if` without `else`:

```text
if expression = Unit
condition = Bool
```

The then-block value is evaluated and discarded under the existing no-else semantics.

No-else `if` expressions store `Unit` directly during initialization rather than allocating and then binding a variable.

## Prefix and binary constraints

The current layer establishes structural equalities but deliberately does not yet select operator implementations.

### Logical operations

```text
!value       : operand Bool, result Bool
left && right: operands Bool, result Bool
left || right: operands Bool, result Bool
```

### Comparison operations

Equality and relational operators require equal operand types and produce `Bool`:

```text
left type = right type
result = Bool
```

Whether the operand type actually supports equality or ordering remains an operator/trait obligation.

### Arithmetic, bitwise, shifts, and exponentiation

The current structural rule is:

```text
left type = right type
result type = left type
```

Numeric, integer, shift-count, exponentiation, and trait applicability checks remain deferred. Therefore this stage can propagate `I32` through `value + 1`, but it does not yet claim that every same-typed operand pair implements `+`.

Unary positive and negative similarly equate operand and result while deferring operator-domain validation.

## Unsupported forms and poison coalescing

Unsupported forms currently include:

- method calls through fields or other non-name targets;
- general static qualification;
- indexing;
- match;
- functional while.

The outer unsupported expression is poisoned and receives one `UnsupportedExpressionInference` diagnostic.

Constructor, function, type, trait, or variant name roots consumed by that outer expression are also poisoned but do not receive duplicate diagnostics. For example:

```dew
identity(value)
```

produces one unsupported call diagnostic rather than separate diagnostics for `identity` and the call node.

Poison then propagates into a let or function tail without unresolved-type cascades.

## Unresolved types

After constraints are generated, every expression, local, block, and body root is zonked.

A supported expression that still contains an unconstrained variable receives:

```moonbit
UnresolvedExpressionType
```

An unresolved local receives:

```moonbit
UnresolvedLocalType
```

Unsupported expressions are already poisoned and do not also produce unresolved diagnostics.

## Compact output terms

The solver may allocate temporary variables and intermediate terms that become irrelevant after zonking. They are not retained automatically.

Each body job:

1. Marks positive local terms reachable from frozen expression, local, block, body-root, and diagnostic types
2. Traverses applied children iteratively
3. Copies marked terms in original child-first order
4. Remaps flat argument spans and side-table IDs
5. Discards all unreachable solver terms

If every final type is rigid or error, compaction takes a fast path and retains no body-local terms beyond the shared error entry.

Module merge then remaps each compact positive ID into one module-wide type arena while negative rigid references remain unchanged.

## Independent jobs and worker scratch reuse

Body jobs may execute in any order. Completed fragments are stored by body index and merged in stable `BodyId` order.

The sequential implementation reuses one `LocalTypeSolver` across body jobs after resetting its logical lengths. This retains array capacity and eliminates repeated allocation for modules containing many small functions.

This remains compatible with future parallel execution: each worker owns one reusable solver and processes independent body jobs. No solver is shared concurrently.

Forward and reverse body order produce identical complete `InferredModuleBodies` artifacts.

## Performance investigation

The first correct implementation allocated fresh variables for every non-literal expression, allocated block variables, wrapped local uses in equality constraints, eagerly allocated resolved occurs-check marks, zonked every rigid type through the task machine, and allocated compaction maps for every body.

Representative native resolve-only time for 256 functions was:

```text
809.74 us
```

The following changes were measured:

1. Lazily allocate resolved occurs-check marks.
2. Return immediately when zonking or checking a rigid/error type.
3. Skip compaction maps when no positive local terms survive.
4. Reuse local type IDs directly for local-name expressions.
5. Store known `Bool`, `Unit`, and block result types directly.
6. Reuse one solver scratch arena across sequential body jobs.
7. Skip the initial reset for a newly created worker solver.
8. Coalesce unsupported-root diagnostics without an extra full prepass.

Final representative native resolve-only time is:

```text
347.50 us
```

This is approximately a **57% reduction** from the initial implementation.

Other native changes from the same optimization sequence:

| Workload | Initial | Final | Change |
|---|---:|---:|---:|
| resolve-only functions, n=256 | 809.74 us | 347.50 us | -57% |
| full pipeline, n=256 | 2.57 ms | 2.19 ms | -15% |
| sequential locals, n=512 | 196.78 us | 148.55 us | -25% |
| else-if branches, n=256 | 116.44 us | 83.15 us | -29% |
| prefix depth=1024 | 151.25 us | 81.44 us | -46% |

## Final benchmarks

Release-mode benchmarks live in `src/semantic/basic_body_inference_bench_test.mbt`. Times compare only within one backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| resolve-only functions, n=256 | 347.50 us | 297.84 us | 856.01 us | 1.06 ms |
| collect events through inference, n=256 | 1.10 ms | 852.90 us | 2.73 ms | 3.24 ms |
| tokenize, parse, collect, and infer, n=256 | 2.19 ms | 1.90 ms | 3.56 ms | 6.82 ms |
| sequential locals, n=512 | 148.55 us | 134.52 us | 380.66 us | 458.27 us |
| else-if branches, n=256 | 83.15 us | 58.94 us | 169.41 us | 266.20 us |
| prefix depth=1024 | 81.44 us | 57.31 us | 236.82 us | 283.32 us |

## Tests

`src/semantic/basic_body_inference_wbtest.mbt` covers:

- parameter seeding;
- local-name identity;
- sequential lets;
- mutable shadow locals;
- arithmetic equality propagation;
- function tail types;
- if/else branch unification;
- no-else `Unit` inference;
- valued returns;
- bare returns;
- return and tail mismatches;
- empty `Unit` functions;
- module-let literal root inference;
- one poisoned branch mismatch without cascades;
- one coalesced unsupported-call diagnostic;
- forward-versus-reverse body job order;
- 1,024 nested logical prefixes.

## Current boundaries

This layer does not yet:

- validate arithmetic or comparison operator domains;
- infer indexing;
- solve generic trait obligations or dynamic trait calls.

Structured flow, constructor-level exhaustiveness, and unreachable block-item diagnostics are implemented by the later phase in `docs/research/structured-flow-exhaustiveness.md`.

## Next steps

Direct callable instantiation and rollback-based overload selection are complete in `docs/research/direct-generic-overload-call-inference.md`. The remaining next steps are:

Module-let dependency SCCs and frozen value imports are now implemented in `docs/research/module-value-scc-inference.md`. The remaining next steps are:

Pattern/loop inference, flow, objects, constructors, fields, impl coherence, qualified method calls, and backend-neutral lowering plans are implemented. Remaining work includes indexing/operator domains, generic trait obligations, trait objects, runtime layouts, and Starshine emission.
