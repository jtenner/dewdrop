# Deterministic lowering plans

## Status

Implemented as the first backend-facing phase after collection, type/name inference, implementation selection, and structured flow analysis.

The phase freezes backend-neutral body plans. Selected binary trait operations become `PlannedOperatorCall` values retaining the exact implementation declaration and type arguments. A subsequent immutable WasmGC fragment phase assigns deterministic module-local type/function indices and directization evidence, while a separate backend package constructs complete Starshine modules; body lowering itself still does not mutate Starshine builders. Index expressions remain explicit poison operations until indexing semantics are defined.

## API

```moonbit
pub fn plan_module_lowering(
  CollectedModule,
  ResolvedModuleTypes,
  PlannedModuleTypeLayouts,
  PlannedModuleInitialization,
  PlannedModuleFunctions,
  ResolvedModuleNames,
  InferredModuleBodies,
  AnalyzedModuleFlows,
) -> PlannedModuleLowering
```

All inputs must belong to the same stable `ModuleId`.

## Plan contents

`PlannedModuleLowering` embeds deterministic nominal type-layout recipes, the eager module-initialization schedule, and stable callable ABI plans, then contains HIR-aligned immutable arrays for:

- body plans;
- expressions;
- blocks and block items;
- object fields;
- patterns and pattern arms;
- expression children;
- expression, call, and pattern type arguments;
- lowering-specific diagnostics.

A `PlannedBodyLowering` retains the owning `BodyId` and `DeclId`, body kind/root, inferred root type, runtime value shape, structural flow summary, exact arena spans, and its diagnostic span.

Every `PlannedExpression` combines:

- the frozen inferred `BodyTypeId`;
- a backend-oriented value shape;
- the structured flow summary;
- an exact selected operation;
- the source offset.

Nominal recipes preserve source-ordered struct fields and source-ordered enum tags/payloads as documented in `docs/research/runtime-type-layout-plans.md`. Module-value steps and explicit eager-cycle boundaries are documented in `docs/research/module-initialization-plans.md`. Builtin, function, trait-requirement, and impl-method signatures are documented in `docs/research/function-abi-plans.md`.

The initial value shapes are:

```text
Error, Unit, I32, I64, F32, F64, Ref, Generic, Never
```

`Bool`, `I32`, and `U32` use the Wasm `i32` shape. `I64` and `U64` use `i64`; floating types retain their width; strings, nominal values, and trait values use references. Rigid generic parameters remain `Generic` until ABI specialization or erased representation is chosen. `Never` records that no ordinary value is produced.

## Exact operations

Plans replace inference side-table joins with explicit operations for:

- primitive and string constants;
- local and module-value reads;
- intrinsics;
- struct, tuple-variant, struct-variant, and unit-variant construction;
- blocks and `if`;
- match and functional-loop roots;
- break and continue with exact `ControlId`;
- prefix and binary operations;
- direct function, inherent-method, trait-method, and qualified calls;
- exact field reads.

Direct calls retain the selected implementation/function `DeclId`, inferred type-argument span, ordinary argument span, and an explicit receiver expression for receiver-syntax calls. Type- and trait-qualified receiver calls already include their receiver in the ordinary argument span.

Constructor and field plans retain stable `DeclId`, `VariantId`, and `FieldId` identities selected by inference. Pattern plans retain frozen type, name-resolution reference, selected constructor, source shape, and source offset. Arm and block plans embed structural flow summaries so backend emission does not need to recompute reachability.

Call, construction, and qualification roots consumed by a parent operation become `PlannedConsumedExpression`. They therefore cannot accidentally emit standalone function/type/trait values while a backend walks the expression arena.

## Poison boundaries

Expressions already poisoned by earlier semantic phases become `PlannedPoisonExpression` without duplicating upstream diagnostics. Index expressions additionally emit `UnsupportedIndexLowering`, keeping the currently unsupported backend boundary explicit and testable.

A module value read is planned only for an actual module `let`; standalone function/builtin names cannot become accidental runtime value reads before first-class function types exist.

## Jobs and determinism

Every body is planned into a job-local `BodyLoweringPlanJob`. Jobs own local expression, block, item, field, pattern, arm, and diagnostic arrays. The module merge always visits stable `BodyId` order and copies each job into exclusive HIR-aligned slots.

The test-only `plan_module_lowering_in_order` entry point verifies that forward and reverse job schedules produce exactly equal plans. Stable input spans are reused for immutable expression children and type-argument arenas, avoiding remapping allocation while preserving parser independence.

Traversal is iterative over flat HIR spans. Stress tests cover 1,024 nested prefix expressions and 512 independently selected method calls.

## Performance

Release-mode measurements:

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| Plan 256 functions | 123.86 µs | 50.77 µs | 69.51 µs | 373.59 µs |
| Plan 512 sequential locals | 81.18 µs | 42.91 µs | 50.01 µs | 261.90 µs |
| Plan 256 method calls | 40.28 µs | 22.11 µs | 39.14 µs | 133.77 µs |
| Full pipeline, 128 functions | 705.68 µs | 516.41 µs | 1.01 ms | 2.04 ms |

The method workload is especially compact because selected call targets and type arguments are already frozen; planning performs no candidate search or unification. A reverse child-first pass simultaneously marks consumed roots and builds expression plans, avoiding a separate per-body scan.

## Remaining work

1. Extend the implemented scalar Starshine body emitter beyond constants, locals, direct calls, blocks, `if`, returns, and the initial `i32` builtins.
2. Implement indexing trait selection before lowering index operations.
3. Lower match and functional-loop plans into concrete decision trees and structured Wasm control flow.
4. Emit module-value globals and the frozen eager initialization schedule.
5. Add generic scalar boxing/specialization, trait-object dictionaries, closures, startup logic, and source/name sections.
