# Structured flow, exhaustiveness, and redundancy analysis

Date: 2026-07-30

## Scope

Dew now has a frozen semantic phase after body inference:

```moonbit
pub fn analyze_module_flows(
  CollectedModule,
  ResolvedModuleTypes,
  InferredModuleBodies,
) -> AnalyzedModuleFlows
```

The phase computes:

- expression flow summaries;
- block flow summaries;
- pattern-arm flow summaries;
- body-root flow summaries;
- match exhaustiveness;
- functional-loop exhaustiveness;
- conservative redundant-arm diagnostics;
- functional-loop arm fallthrough diagnostics;
- unreachable block-item diagnostics;
- stable missing-case witnesses.

The implementation is in `src/semantic/body_flow.mbt`.

Tests and benchmarks are in:

- `src/semantic/body_flow_wbtest.mbt`;
- `src/semantic/body_flow_stress_wbtest.mbt`;
- `src/semantic/body_flow_bench_test.mbt`.

## Phase boundary

Flow analysis reads only frozen inputs:

- collected child-first HIR;
- canonical resolved declaration types;
- frozen body-local inferred types;
- frozen selected pattern constructors.

It does not mutate type solvers, body-name results, inferred constructor selections, or parser objects.

Each body is analyzed as an independent job. A test-only order entry point executes jobs in forward and reverse order, while final merging always follows stable `BodyId` order.

## Public result

```moonbit
pub struct AnalyzedModuleFlows {
  module_id : ModuleId
  bodies : Array[AnalyzedBodyFlow]
  expression_flows : Array[BodyFlowSummary]
  block_flows : Array[BodyFlowSummary]
  arm_flows : Array[BodyFlowSummary]
  missing_cases : Array[MissingPatternCase]
  diagnostics : Array[BodyFlowDiagnostic]
}
```

The first three side tables align with the module expression, block, and pattern-arm arenas.

Each body result contains:

```moonbit
pub struct AnalyzedBodyFlow {
  body : BodyId
  flow : BodyFlowSummary
  diagnostics : HirSpan
}
```

`AnalyzedModuleFlows::body` performs stable packed-ID lookup.

## Flow outcomes

A flow summary is a compact bit set of possible exits:

```text
FallsThrough
Returns
Breaks
Continues
Diverges
```

Public queries are:

```moonbit
BodyFlowSummary::may_fall_through
BodyFlowSummary::may_return
BodyFlowSummary::may_break
BodyFlowSummary::may_continue
BodyFlowSummary::may_diverge
```

The representation records possible outcomes rather than one mutually exclusive state. An expression may, for example, either return or complete normally depending on a condition.

## Sequential composition

For statements or operands evaluated in order:

```text
sequence(A, B)
```

preserves every non-fallthrough exit from `A`. `B` contributes outcomes only when `A` may fall through.

Conceptually:

```text
exits = outcomes(A) - FallsThrough
if A may fall through:
  exits |= outcomes(B)
```

This rule handles:

- call targets and arguments;
- object and constructor fields;
- binary operands;
- index base and index expressions;
- return operands;
- break and continue operands;
- block items.

## Branch union

Conditional alternatives combine by outcome union.

An `if` summary sequences its condition with the union of then and else summaries. A missing else contributes ordinary fallthrough.

A match sequences its scrutinee with the union of reachable arm outcomes. A non-exhaustive match additionally has a diverging unmatched path, representing the failed dispatch boundary without pretending it returns a value.

## Short-circuit operators

Logical `&&` and `||` do not always evaluate their right operand.

Flow therefore includes both:

- a skipped-right path that produces the operator result;
- an evaluated-right path.

This matters when the right operand returns, breaks, continues, or diverges. The test suite includes a functional-loop arm where `break` is the right operand of `||`; the skipped path correctly remains an arm fallthrough path.

## Never expressions

An ordinary expression whose frozen inferred type is `Never` contributes `Diverges` instead of `FallsThrough`.

This catches unreachable code after calls such as:

```dew
fn stop() -> Never {
  stop()
}

fn use() -> I32 {
  stop()
  1
}
```

The second expression is unreachable even though the first is a call rather than a syntactic `return`, `break`, or `continue`.

Structural transfers retain their precise outcome instead of being collapsed to generic divergence.

## Blocks and unreachable items

Blocks are summarized in item order.

Once the accumulated block summary no longer contains `FallsThrough`, every later block item receives:

```moonbit
UnreachableBlockItem(BlockId, item_index, offset)
```

Unreachable items do not alter the block's actual flow summary.

The analysis covers:

- explicit return;
- calls returning `Never`;
- if expressions whose branches both transfer;
- exhaustive matches whose arms all transfer;
- functional loops that cannot complete normally.

## Return flow

A valued return first evaluates its operand. If the operand falls through, the item contributes `Returns`. Any return, break, continue, or divergence from the operand itself remains visible.

A bare return contributes `Returns` directly.

Callable body-root fallthrough remains distinguishable from explicit return. Both eventually return to the caller, but preserving the distinction is useful for lowering and unreachable diagnostics.

## Functional loops

The initial expression is evaluated before the loop control becomes active, matching name-resolution semantics.

Arm summaries may contain:

- `Breaks`, which become loop-expression `FallsThrough`;
- `Continues`, which become loop continuation and therefore possible divergence;
- arm `FallsThrough`, which is diagnosed and treated as a non-completing invalid loop path;
- `Returns`, which propagate out of the loop;
- `Diverges`, which propagate.

Break and continue outcomes produced by nested functional loops have already been consumed by the nested loop summary. Any remaining transfer in an outer arm therefore belongs to that surrounding control under nearest-control resolution.

A loop with no completing break path has no ordinary fallthrough outcome.

## Loop-arm fallthrough migration

`FunctionalLoopArmFallsThrough` is now a `BodyFlowDiagnostic` rather than a `BodyInferenceDiagnostic`.

The previous inference implementation checked whether the arm body type was `Never`. The flow phase now checks the structural arm summary:

```text
arm summary contains FallsThrough
```

This recognizes return, branch, match, call-`Never`, break, continue, and short-circuit behavior without coupling flow legality to type-inference diagnostics.

## Exhaustiveness domains

Coverage analysis classifies the expected scrutinee or loop-state type into one of four domains:

```text
Error
Bool
Enum(DeclId)
Open
```

`Error` suppresses dependent coverage diagnostics.

`Bool` has two finite witnesses:

```text
false
true
```

`Enum` uses the selected enum declaration's complete source-ordered variant span.

`Open` covers primitives other than `Bool`, structs, generic open domains, and other types where a finite constructor list is unavailable. These require an irrefutable catch-all pattern.

## Missing-case witnesses

Missing cases are retained as stable semantic values:

```moonbit
pub enum MissingPatternCase {
  MissingCatchAllCase
  MissingBoolCase(Bool)
  MissingVariantCase(VariantId)
}
```

A non-exhaustive diagnostic contains a span into the module-wide `missing_cases` arena:

```moonbit
NonExhaustiveMatch(ExprId, HirSpan, UInt64)
NonExhaustiveFunctionalLoop(ExprId, HirSpan, UInt64)
```

Enum witnesses preserve declaration source order. Boolean witnesses are reported `false`, then `true` when both are absent.

This representation is suitable for diagnostics today and decision-tree lowering later.

## Guards

A guarded arm is useful for flow and result typing, but it contributes no unconditional coverage.

For example:

```dew
match flag {
  On if condition => 1
  Off => 0
}
```

still reports `On` as missing because the guard may fail.

An arm after a previously unconditional catch-all remains redundant even if the later arm has a guard.

## Pattern coverage atoms

Top-level alternatives are flattened iteratively into conservative coverage atoms:

```text
Error
Unknown/refutable
CatchAll
Bool(value)
Variant(VariantId)
```

`Error` suppresses dependent non-exhaustiveness.

`Unknown/refutable` keeps an arm useful but does not claim complete constructor coverage.

`CatchAll` covers the complete domain.

Boolean and variant atoms cover one finite witness.

No recursive pattern traversal is needed during arm coverage; alternative patterns use a reusable explicit task array.

## Pattern shape errors

Flow analysis indexes pattern-related inference diagnostics for each body.

Patterns with any of these errors do not claim coverage:

- invalid constructor;
- unknown or ambiguous variant;
- payload kind mismatch;
- payload arity mismatch;
- unknown field;
- missing field;
- unresolved constructor type argument.

This prevents a malformed pattern from both producing its root diagnostic and hiding a real missing case. It also suppresses dependent exhaustiveness cascades when constructor selection itself failed.

## Irrefutable patterns

A wildcard or ordinary binding is irrefutable.

A literal is refutable.

A nominal struct pattern is irrefutable only when:

- every written field pattern is irrefutable;
- the payload has no shape diagnostic;
- omitted fields are covered by struct rest or all declared fields are present.

An enum variant pattern never covers the whole enum. It covers its one variant only when its payload is irrefutable.

Unit variants have irrefutable payloads.

Tuple-variant payloads are irrefutable when every explicit child is irrefutable. Tuple rest itself imposes no refutable condition.

Struct-variant payloads follow the field rule above.

## Nested payloads

Whole-pattern irrefutability and constructor-payload irrefutability are stored separately during a body job.

This distinction is required for:

```dew
enum Inner {
  A
  B
}

enum Outer {
  Wrap(Inner)
}

Wrap(A)
```

`A` is an irrefutable payload for the `A` unit variant, but it is not irrefutable over `Inner`. Therefore `Wrap(A)` does not cover all `Wrap` values.

The analyzer retains two body-local Boolean arrays:

```text
pattern matches every value of its expected type
pattern accepts every payload of its selected constructor
```

## Alternatives

Each alternative contributes independently to arm coverage.

For:

```dew
On, Off => ...
```

both variants are marked covered by one unguarded arm.

Corresponding payload type compatibility remains the responsibility of body inference through shared `LocalId` types.

## Redundancy

An arm is diagnosed as redundant when none of its alternatives can add a case beyond prior unconditional coverage:

```moonbit
RedundantPatternArm(PatternArmId, UInt64)
```

Examples include:

- a repeated unit variant after the same unguarded variant;
- any arm after an unguarded catch-all;
- a catch-all after all Boolean cases;
- a catch-all after every enum variant is fully covered;
- a variant after every enum variant is fully covered.

Redundancy is intentionally conservative for refutable nested payloads. The current phase does not build a full pattern matrix, so patterns such as `Some(0)` and `Some(1)` are not considered mutually redundant merely because they share the same outer constructor.

A later pattern-matrix phase may add alternative-level redundancy and nested literal/tuple specialization without invalidating these stable constructor-level results.

## Diagnostic ordering

Body diagnostics are sorted by:

1. source offset;
2. stable diagnostic rank.

Jobs may execute in any order. Missing-case and diagnostic spans are remapped during the final source-ordered body merge.

No output depends on worker order, allocation addresses, or hash-map iteration order.

## Iterative stress coverage

The phase passes stress tests for:

- 1,024 enum variants with complete coverage;
- 1,024 ordered redundant arms;
- 1,024 unreachable block items;
- existing 512 nested generic payload patterns;
- existing 512 functional-loop arms.

Expression flow uses child-first HIR and one forward arena pass. Blocks use iterative item scans. Alternatives use an explicit task stack. Enum coverage uses flat source-ordered spans and Boolean marks.

## Performance work

The implementation was benchmarked before and after allocation-oriented cleanup.

Retained optimizations include:

- shared immutable empty flow arrays for bodies without expressions, blocks, arms, or patterns;
- no variant-span allocation for modules without enums;
- one reusable alternative-pattern task array per sequential worker;
- compact integer outcome masks;
- flat Boolean variant coverage marks;
- body-local jobs followed by stable merge.

A generation-mark experiment for finite coverage and conditional diagnostic sorting were not retained because they regressed representative native workloads.

The clearest retained gain is the 256 ordinary-function workload, which improved from 121.39 us to 110.68 us, roughly 9%. Finite enum and diagnostic-heavy workloads remain within a few percent of the first correct implementation.

## Final cross-backend benchmarks

Release-mode measurements compare within each backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| enum exhaustiveness, 256 arms | 20.73 us | 14.29 us | 34.31 us | 58.99 us |
| redundant arms, 512 | 48.28 us | 28.36 us | 65.27 us | 168.37 us |
| alternatives, 256 arms | 35.42 us | 26.78 us | 56.33 us | 116.00 us |
| functional-loop flow, 256 arms | 26.91 us | 17.48 us | 39.80 us | 73.18 us |
| ordinary functions, 256 | 110.68 us | 49.37 us | 64.29 us | 359.23 us |
| unreachable items, 512 | 31.18 us | 16.35 us | 25.24 us | 116.96 us |
| full pipeline enum match, 256 arms | 658.90 us | 617.38 us | 1.22 ms | 1.99 ms |

## Diagnostics

```moonbit
pub enum BodyFlowDiagnostic {
  NonExhaustiveMatch(ExprId, HirSpan, UInt64)
  NonExhaustiveFunctionalLoop(ExprId, HirSpan, UInt64)
  RedundantPatternArm(PatternArmId, UInt64)
  FunctionalLoopArmFallsThrough(PatternArmId, UInt64)
  UnreachableBlockItem(BlockId, Int, UInt64)
}
```

## Current boundary

Objects, methods, trait obligations, indexing, deterministic pattern lowering,
and WasmGC branch/tag/cast/payload emission are implemented by later phases.
Full nested pattern-matrix usefulness and witness construction remain open only
when the current constructor-level analysis is insufficient; see
`docs/roadmap.md`.
