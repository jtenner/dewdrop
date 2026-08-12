# Executable body HIR

Date: 2026-07-29

## Scope

Dew declaration collection now lowers every executable module body into compact module-wide HIR arenas while consuming the parser's lazy `Iter[ParseEvent]`:

- module-level let initializers;
- top-level function blocks;
- impl method blocks.

Builtin and trait method declarations retain callable signatures but have no executable body. Recursive parser expressions, patterns, blocks, object fields, and pattern arms are released after their declaration is lowered and are not retained in `CollectedModule`.

The implementation lives in:

- `src/semantic/hir_bodies.mbt`;
- `src/semantic/hir_body_lowering.mbt`;
- `src/semantic/body_hir_wbtest.mbt`;
- `src/semantic/collect_bench_test.mbt`.

## Stable body ownership

`BodyId` uses the same packed layout as other stable semantic entities:

```text
high 32 bits: ModuleId
low 32 bits:  source-order body index
```

Body IDs have an independent local sequence. A body records its owning `DeclId` and one of three kinds:

```moonbit
pub enum HirBodyKind {
  ModuleLetBody
  FunctionBody
  ImplMethodBody
}
```

`CollectedModule::body_of` uses a declaration-indexed location array and performs constant-time lookup. Declarations with no executable body retain `-1` in that table.

## Module-wide arenas

Executable HIR uses module-wide arrays rather than allocating a complete arena set per function:

- `Array[HirBody]`;
- `Array[HirExpr]`;
- `Array[ExprId]` for call and other expression child lists;
- `Array[HirBlock]`;
- `Array[HirBlockItem]`;
- `Array[HirObjectField]`;
- `Array[HirPattern]`;
- `Array[PatternId]` for tuple and alternative pattern children;
- `Array[HirPatternField]`;
- `Array[HirPatternArm]`;
- `Array[PatternArmId]` for match and while arm lists.

Each `HirBody` records spans covering its expressions, expression children, blocks, block items, patterns, pattern children, pattern arms, arm children, object fields, and pattern fields. These spans provide exact body-local side-table sizes without allocating per-body arena objects.

HIR node IDs are module-local `Int` indices. They are not exported through module interfaces and do not require globally packed identities.

## Child-first lowering

Expressions and patterns are emitted after their children. For example:

```dew
left + right * value
```

becomes conceptually:

```text
0: Name(left)
1: Name(right)
2: Name(value)
3: Binary(Multiply, 1, 2)
4: Binary(Add, 0, 3)
```

This ordering permits later name resolution, type inference, and lowering to use array-indexed side tables without recursive AST traversal.

Nested blocks, object fields, match arms, while arms, and pattern fields may emit their own arena records before their enclosing node. Variable-length direct children are copied into shared flat child-list arenas when the parent finish operation runs.

## Iterative task machine

Body lowering does not use recursive MoonBit calls. `CollectionBuilder` owns reusable primitive task stacks:

```text
task kind
source-pool index
first result-stack start
second result-stack start
```

Task kinds are:

```text
VisitExpr
FinishExpr
VisitBlock
FinishBlock
VisitPattern
FinishPattern
VisitArm
FinishArm
```

Parser nodes are held temporarily in reusable typed source pools for expressions, blocks, patterns, and arms. Result stacks separately hold lowered expression, block, pattern, and arm IDs.

Scheduling uses LIFO reversal to preserve source order. A finish task truncates its child result range and replaces it with one parent ID. This allows nested blocks and nested match expressions to preserve enclosing child results without recursive calls or one allocated wrapper task per node.

All task, source, and result arrays are cleared and reused between bodies. Their capacity follows the largest body encountered in the module rather than the sum of all body sizes.

## Expression coverage

`HirExpr` covers every currently parsed expression form:

- all integer, floating-point, Boolean, and string literals;
- names and intrinsics using module-local `NameId`;
- inline objects and postfix construction;
- reusable block expressions;
- `if` and iterative else-if trees;
- match expressions;
- functional while expressions;
- break and continue values;
- prefix and binary operations converted to semantic-owned HIR operator enums;
- calls;
- fields and qualification;
- indexes.

Calls store argument spans in the expression-child arena. Objects and constructors store spans in the object-field arena. Match and while nodes store spans in the arm-child arena.

Absent optional expression values use `-1` rather than an `Option` in hot HIR records. This includes no-else `if`, unguarded arms, and bare function `return`.

## Blocks

Function and expression blocks share:

```moonbit
pub struct HirBlock {
  items : HirSpan
  offset : UInt64
}
```

Block items retain:

- mutable versus immutable local lets;
- interned local names and name offsets;
- return values or the `-1` empty-return sentinel;
- expression items and source offsets.

Module-level let mutability is retained separately in `CollectedLet`; local block lets retain it directly on `HirLetItem`. Local declarations do not receive `LocalId` during HIR collection. Lexical name resolution will allocate body-local identities after initializer visibility and pattern scopes are understood.

## Patterns and arms

`HirPattern` covers:

- wildcard and discard-normalized patterns;
- bindings using `NameId`;
- rest patterns;
- literal patterns referencing lowered expression IDs;
- qualified patterns;
- tuple payloads;
- struct payloads and optional rest offsets;
- alternative patterns.

Match and functional while reuse `HirPatternArm`. Each arm records one pattern ID, an optional guard expression ID, a body expression ID, and its source offset.

Pattern children and arm lists use explicit child arenas because nested matches and nested payload patterns mean their direct children are not necessarily contiguous in the primary node arenas.

## Parallel analysis properties

After collection finishes, executable HIR is immutable by convention. A future body-analysis worker receives:

- one `HirBody`;
- read-only module arenas;
- read-only declaration namespaces and signatures;
- job-local scope, inference, diagnostic, and scratch state.

No body job needs to append to or mutate module HIR. Per-body expression and pattern side tables can be sized from the recorded spans. Body job order therefore cannot change semantic identities or HIR layout.

## Complexity and memory

For a body with `N` syntax nodes:

- lowering is `O(N)` time;
- task execution is iterative;
- reusable scratch capacity is `O(maximum active body size)` for the module;
- retained HIR is `O(N)` compact arena records;
- parser body ASTs become unreachable after collection of their declaration.

Module-wide arenas avoid the fixed overhead of many arrays per tiny function. Shared child arenas avoid allocating one child array for every call, pattern, match, or object node.

## Tests

`src/semantic/body_hir_wbtest.mbt` covers:

- stable body IDs and declaration ownership;
- module lets, functions, and impl methods;
- declarations without bodies;
- child-first binary and prefix lowering;
- contiguous function block items;
- local lets, valued returns, and empty returns;
- every literal kind;
- names and intrinsics;
- objects and construction;
- calls, fields, qualification, and indexing;
- if blocks and else block expressions;
- match and functional while shared arms;
- guarded alternative patterns;
- qualified, tuple, struct, and rest patterns;
- 1,024 nested prefix operations;
- 512 object fields;
- 513 match arms including the catch-all;
- 512 nested else-if branches.

## Benchmarks

Release-mode benchmarks use pre-parsed collection, pre-tokenized parse-and-collect, and end-to-end tokenize/parse/collect workloads. Times compare only within one backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| collect-only aliases, n=256 | 105.71 us | 64.93 us | 200.17 us | 301.57 us |
| parse and collect aliases, n=256 | 225.82 us | 128.98 us | 263.54 us | 649.12 us |
| tokenize, parse, and collect aliases, n=256 | 410.06 us | 416.76 us | 484.91 us | 1.19 ms |
| collect-only mixed declarations with bodies, n=192 | 103.01 us | 64.97 us | 239.91 us | 280.49 us |
| tokenize, parse, and collect mixed declarations with bodies, n=192 | 438.31 us | 443.99 us | 542.86 us | 1.31 ms |
| collect-only function bodies, n=256 | 248.74 us | 193.91 us | 643.15 us | 701.62 us |
| parse and collect function bodies, n=256 | 519.03 us | 348.45 us | 840.36 us | 1.40 ms |
| tokenize, parse, and collect function bodies, n=256 | 936.99 us | 994.39 us | 1.30 ms | 2.62 ms |
| collect-only match body, arms=256 | 46.62 us | 45.41 us | 97.05 us | 137.08 us |
| tokenize, parse, and collect match body, arms=256 | 146.77 us | 119.73 us | 211.43 us | 418.17 us |
| collect-only nested declaration type, depth=256 | 24.47 us | 13.50 us | 39.30 us | 74.36 us |

The native collect-only function workload lowers 256 function blocks containing 1,280 expressions in about 249 microseconds, slightly under one microsecond per complete function body including declaration identities, parameter/type collection, name interning, block items, and expression HIR.

## Current boundary

The downstream milestones originally listed here are implemented: declaration and
body resolution, inference, module-value SCCs, patterns and loops, members,
methods, trait obligations, lowering, optimization, layouts, linking, and
Starshine emission. This note remains the HIR construction and benchmark record;
current priorities are in `docs/roadmap.md`.
