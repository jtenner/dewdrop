# Body-local name and control resolution

Date: 2026-07-30

## Scope

Dew now resolves names and functional-loop control transfers for every executable HIR body:

- module-let initializers;
- top-level function bodies;
- impl method bodies;
- parameters and receivers;
- sequential block lets;
- pattern bindings;
- alternative-pattern binding contracts;
- module values and builtin overload names;
- type and trait qualification roots;
- unqualified enum-variant candidates;
- intrinsics;
- functional `while` controls;
- `break` and `continue` targets.

The public entry point is:

```moonbit
pub fn resolve_module_names(
  CollectedModule,
) -> ResolvedModuleNames
```

Name resolution requires frozen declaration namespaces and executable HIR but does not require inferred types. It can therefore run independently from some later signature-layout work, although type inference consumes both name-resolution and resolved-signature artifacts.

The implementation lives in:

- `src/semantic/body_names.mbt`;
- `src/semantic/resolve_body_names.mbt`;
- `src/semantic/body_name_resolution_wbtest.mbt`;
- `src/semantic/body_name_resolution_bench_test.mbt`.

## Body-local identities

```moonbit
pub type LocalId = Int
pub type ControlId = Int
```

Both identities are local to one `BodyId`. They are never allocated through a module-global or process-global counter.

A local records:

```moonbit
pub struct BodyLocal {
  id : LocalId
  name : NameId
  kind : BodyLocalKind
  mutable_ : Bool
  source : Int
  offset : UInt64
}
```

Kinds are:

```moonbit
ParameterLocal
LetLocal
PatternLocal
```

`source` identifies the originating module-wide parameter index, block-item index, or pattern ID according to the local kind.

Local IDs are assigned deterministically in semantic traversal order:

1. Callable parameters and receiver in declaration order
2. Sequential block lets when their initializer has finished resolving
3. Pattern bindings when an arm is entered

Each result body records spans into module-wide local, control, and diagnostic arrays.

## Module-wide side tables

`ResolvedModuleNames` contains flat arrays aligned with existing HIR:

```moonbit
expression_references : Array[BodyNameReference]
pattern_references : Array[BodyPatternReference]
parameter_locals : Array[LocalId]
block_item_locals : Array[LocalId]
transfer_targets : Array[ControlId]
expression_controls : Array[ControlId]
```

Expression and pattern arrays align directly with `CollectedModule.expressions` and `CollectedModule.patterns`. Missing or inapplicable entries use explicit enum variants or `-1` sentinels.

This avoids one map or side-table object per function. `ResolvedModuleNames::local_info` and `ResolvedModuleNames::control` translate body-local IDs through each body's retained spans.

## Lexical scope representation

Each body job owns:

- a current `Map[NameId, LocalId]`;
- a flat stack of names introduced since each scope marker;
- the previous binding for each introduction;
- a flat scope-marker stack.

Entering a scope records the binding-stack length. Binding a name records its previous local and updates the current map. Exiting restores prior entries in reverse order.

Names with no previous binding are restored to the `-1` sentinel. The body-local map may retain keys with `-1`, but it does not retain live bindings from exited scopes.

This supports shadowing without copying the entire environment for blocks or match arms.

## Parameters and receivers

Every parameter belonging to an executable function or impl method receives a `ParameterLocal`. Parameters are inserted into the outer body scope before the root expression or block is traversed.

Parameters are initially immutable. A receiver is treated the same as another parameter after collection; its type and `Self` behavior were already recorded by declaration type resolution.

Trait methods have no executable body and therefore receive no body-local parameter IDs in this phase.

## Sequential lets

Block lets obey initializer-before-binding visibility:

```dew
let mut value = value
```

The right-hand `value` resolves before the new mutable local enters scope. It therefore refers to the preceding parameter, pattern binding, module value, or earlier local.

A task sequence for a let is:

```text
Visit initializer
Bind let local
Visit next block item
```

Same-scope rebinding is permitted and creates a new `LocalId`. Scope exit restores the binding that existed before the entire block scope.

`block_item_locals` maps every `HirLetItem` to its body-local ID and leaves non-let items as `-1`.

## Expression name references

```moonbit
pub enum BodyNameReference {
  NoNameReference
  ErrorNameReference
  LocalNameReference(LocalId)
  ModuleValueNameReference(NameId)
  ModuleTypeNameReference(DeclId)
  ModuleTraitNameReference(DeclId)
  VariantNameReference(NameId)
  IntrinsicNameReference(NameId)
}
```

A module value reference retains `NameId` rather than one `DeclId` because a Dew-visible builtin name may denote a source-ordered overload chain. Later overload selection reads `CollectedModule::value_declarations`.

Unqualified ordinary value lookup uses:

1. Current lexical local
2. Module value binding
3. Unqualified enum-variant candidate
4. `UnknownValueName`

Unqualified enum variants remain `VariantNameReference(NameId)` because multiple enums may contain the same variant spelling. Expected-type analysis selects the final `VariantId`.

A call target additionally recognizes module types and traits. A qualified or construction root prefers:

1. Local
2. Module type
3. Module trait
4. Module value
5. `UnknownQualifiedRoot`

The property segment of `Type::member`, `Trait::method`, or `Enum::Variant` is intentionally deferred until type and member selection.

Intrinsics retain their interned registry name without module lookup.

## Pattern constructor paths

Pattern HIR uses the same parsed identifier node for a binding-position name and the base of a constructor path. Semantic context distinguishes them.

Examples:

```dew
value
Some(value)
Done(value)
Message { payload }
```

The first is normally a binding. The other base positions are constructor contexts.

Pattern references are:

```moonbit
pub enum BodyPatternReference {
  NoPatternReference
  ErrorPatternReference
  PatternBindingReference(LocalId)
  PatternTypeReference(DeclId)
  PatternTraitReference(DeclId)
  PatternVariantReference(NameId)
  PatternQualifiedReference(NameId)
}
```

Known local or imported type, trait, or variant names in a bare pattern position are treated as constructor candidates rather than new locals. Imported variant spellings are discovered from every imported interface, including compiler-owned Option and Result defaults. This supports canonical bare patterns such as `Done`, `Some(value)`, and `Ok(value)` while retaining expected-type disambiguation for repeated variant spellings.

A missing base in an explicit constructor context produces `UnknownPatternConstructor`.

Tuple and struct payload subpatterns return to ordinary binding context. Field shorthand such as `payload` therefore introduces a local even when the enclosing base is a constructor.

## Alternative patterns

For:

```dew
A(value), B(value) if value > 0 => value
```

name resolution treats the first alternative as the binding contract. It allocates one `PatternLocal` for `value` and maps every corresponding binding occurrence in later alternatives to the same `LocalId`.

The shared local is inserted into the arm scope before the guard and body are visited.

Diagnostics include:

```moonbit
DuplicatePatternBinding
AlternativeMissingBinding
AlternativeExtraBinding
```

A duplicate occurrence inside one alternative becomes `ErrorPatternReference`. An extra name in a later alternative also becomes an error reference and is not inserted into the shared arm scope.

Corresponding binding-type compatibility is deliberately deferred to pattern type inference. Name resolution establishes the stable equivalence class by assigning matching occurrences the same local ID.

Small binding sets use direct scans. Sets wider than eight names use reusable hash maps for duplicate and canonical-name lookup. A 128-field alternative benchmark exercises the large-scope path.

## Arm scope

Every match or functional-while arm has an independent scope:

1. Enter arm scope
2. Resolve constructor paths and allocate pattern locals
3. Bind the canonical pattern locals
4. Resolve the optional guard
5. Resolve the arm body
6. Exit arm scope

Pattern bindings do not leak into later arms or into expressions following the match.

A mutable rebinding inside an arm body remains explicit:

```dew
Some(value) => {
  let mut value = value
  value
}
```

The initializer sees the immutable pattern local; subsequent items see the mutable shadow local.

## Functional-loop controls

Every `HirWhileExpr` receives one body-local `ControlId` and `BodyControl`:

```moonbit
pub struct BodyControl {
  id : ControlId
  kind : BodyControlKind
  expression : ExprId
  offset : UInt64
}
```

The while control is not active while resolving its initial-state expression. It becomes active while resolving the ordered arms and is removed after the final arm.

`break` and `continue` select the nearest active control stack entry. Their expression IDs map through `transfer_targets`.

Out-of-loop transfers retain `-1` and produce:

```moonbit
BreakOutsideLoop
ContinueOutsideLoop
```

Nested functional-loop tests verify that inner breaks select the inner control while outer-arm transfers continue selecting the outer control.

## Iterative traversal

Body resolution uses reusable primitive task arrays:

```text
VisitExpression
VisitBlockItems
BindLet
ExitScope
VisitArmList
VisitArm
EnterControl
ExitControl
```

Expression children are scheduled in semantic source/evaluation order despite child-first HIR storage. Blocks process one item at a time so binding visibility is exact. Arm lists process one arm at a time so pattern scopes cannot overlap.

Pattern traversal uses separate iterative pattern/context stacks. No expression, block, arm, or pattern traversal requires recursive MoonBit calls.

A 1,024-local sequential function verifies bounded host stack use.

## Independent body jobs

Each `BodyNameResolver` owns all mutable state for one body:

- scopes;
- local allocation;
- control stack;
- task arrays;
- pattern scratch;
- reference side tables;
- diagnostics.

The module driver stores each completed job by source body index, then merges jobs in stable `BodyId` order. Execution order cannot affect local IDs, control IDs, result spans, or diagnostics.

A white-box test resolves three bodies in forward and reverse job order and compares the complete `ResolvedModuleNames` values for equality.

This structure can be replaced by actual worker execution later without changing the frozen result format.

## Diagnostics

The phase emits:

```moonbit
UnknownValueName
UnknownQualifiedRoot
UnknownPatternConstructor
DuplicatePatternBinding
AlternativeMissingBinding
AlternativeExtraBinding
BreakOutsideLoop
ContinueOutsideLoop
```

Diagnostics are sorted by source offset and deterministic rank within each body. Body job fragments are merged in stable body order.

## Complexity

For a body with `E` expressions, `P` patterns, `L` locals, and `C` controls:

- expression and block traversal is `O(E)`;
- pattern traversal is `O(P)`;
- lexical bind and restore operations are expected `O(1)`;
- small pattern binding sets use bounded direct scans;
- large pattern binding sets use expected `O(P)` hash lookup;
- retained side-table memory is `O(E + P + L + C)`.

Scratch storage is body-job-local and follows the largest active traversal or binding set.

## Tests

`src/semantic/body_name_resolution_wbtest.mbt` covers:

- parameter locals;
- initializer-before-binding lets;
- immutable and mutable shadowing;
- module value references;
- unknown values;
- qualified type roots;
- qualified and unqualified variant candidates;
- unit variants;
- shared alternative binding IDs;
- guard and body visibility;
- qualified pattern roots;
- duplicate pattern bindings;
- missing and extra alternative bindings;
- arm-local scope restoration;
- intrinsics;
- unknown qualified roots and pattern constructors;
- nested functional-loop control selection;
- out-of-loop break and continue;
- forward-versus-reverse body job order;
- 64-field alternative binding sets;
- 1,024 sequential locals.

## Benchmarks

Release-mode benchmarks live in `src/semantic/body_name_resolution_bench_test.mbt`. Times compare only within one backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| resolve-only function bodies, n=256 | 268.74 us | 148.63 us | 260.19 us | 870.37 us |
| collect events and resolve bodies, n=256 | 535.01 us | 332.36 us | 843.72 us | 1.58 ms |
| tokenize, parse, collect, and resolve bodies, n=256 | 1.22 ms | 1.05 ms | 1.46 ms | 3.78 ms |
| resolve match arms, n=256 | 63.90 us | 61.27 us | 200.44 us | 177.47 us |
| resolve sequential locals, n=512 | 62.35 us | 50.38 us | 100.80 us | 162.24 us |
| resolve wide alternatives, fields=128 | 33.52 us | 23.83 us | 51.10 us | 89.03 us |

## Current boundary

This note records body-local name, scope, pattern-binding, and control-target
resolution. Imported qualification, overload/variant selection, member and method
resolution, pattern typing, inference, trait obligations, flow, and lowering are
implemented by later phases described in the architecture and specification.
Current product work is tracked in `docs/roadmap.md`.
