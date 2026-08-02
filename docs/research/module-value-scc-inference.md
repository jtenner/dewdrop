# Module-value dependency SCC inference

Date: 2026-07-30

## Scope

Dew now infers module-level `let` declarations before independent function-body jobs.

The implemented stage provides:

- deterministic module-let dependency extraction;
- deduplicated dependency edges;
- iterative strongly connected component analysis;
- dependency-first SCC scheduling;
- one shared inference solver and value slot set per SCC;
- forward references;
- mutually recursive module values when another constraint determines their type;
- explicit diagnostics for unconstrained recursive values;
- calls, generic instantiation, and builtin overload selection inside module lets;
- immutable frozen module-value type output;
- iterative import of frozen module-value types into function solvers;
- support for frozen local applied types such as `Box<I32>`;
- stable integration with the existing per-body inferred HIR tables.

The public entry points are now:

```moonbit
pub fn analyze_module_value_dependencies(
  CollectedModule,
  ResolvedModuleNames,
) -> ModuleValueDependencies

pub fn infer_module_values(
  CollectedModule,
  ResolvedModuleTypes,
  ResolvedModuleNames,
) -> InferredModuleValues

pub fn infer_module_bodies(
  CollectedModule,
  ResolvedModuleTypes,
  ResolvedModuleNames,
) -> InferredModuleBodies
```

`infer_module_bodies` performs the module-value barrier internally and embeds the frozen result in its output.

Implementation files include:

- `src/semantic/module_value_dependencies.mbt`;
- `src/semantic/infer_basic_bodies.mbt`;
- `src/semantic/body_inference.mbt`;
- `src/semantic/module_value_dependencies_wbtest.mbt`;
- `src/semantic/module_value_inference_wbtest.mbt`;
- `src/semantic/module_value_inference_bench_test.mbt`.

## Dependency artifact

```moonbit
pub struct ModuleValueDependencies {
  module_id : ModuleId
  let_dependencies : Array[HirSpan]
  dependency_declarations : Array[DeclId]
  sccs : Array[HirSpan]
  scc_declarations : Array[DeclId]
}
```

`let_dependencies` aligns with `CollectedModule.lets`. Each span points into the flat `dependency_declarations` arena.

`sccs` is already scheduled in dependency-first order. Members inside an SCC remain in module source order.

## Dependency extraction

Name resolution has already classified every module reference as:

```moonbit
ModuleValueNameReference(NameId)
```

Dependency extraction scans each module-let body's expression span. For each module value reference it:

1. Reads the frozen module value binding
2. Selects its source-ordered head declaration
3. Checks whether that declaration is a module let
4. Maps the stable declaration ID to its module-let index
5. Adds one edge from the current let to the referenced let

References to functions and builtins are not module-let dependency edges. Local names cannot become edges because name resolution has already classified them as `LocalNameReference`.

A generation-marked integer array deduplicates dependencies without allocating one hash map per declaration. The final dependency indices are sorted into source order before their declaration IDs are appended.

For:

```dew
let first = second + second
let second = 1
```

`first` records one dependency on `second`, not two.

## Iterative SCC analysis

SCC discovery uses iterative Kosaraju traversal:

1. Iterative depth-first traversal records graph finish order
2. Flat reverse-edge counts are accumulated
3. Prefix offsets allocate one reverse adjacency array
4. Iterative reverse traversal assigns components
5. Component members are sorted into source order
6. Components are ordered by their minimum dependency-graph finish rank

For an edge:

```text
first -> second
```

`second` finishes first and its SCC is scheduled first.

Independent components preserve deterministic source ordering through their finish ranks and source-index tie break.

No recursive graph traversal is used. A 1,024-let dependency chain passes stress coverage.

## Frozen module-value output

```moonbit
pub struct InferredModuleValues {
  module_id : ModuleId
  dependencies : ModuleValueDependencies
  let_declarations : Array[DeclId]
  let_types : Array[BodyTypeId]
  types : Array[BodyTypeTerm]
  type_arguments : Array[BodyTypeId]
  diagnostics : Array[BodyInferenceDiagnostic]
}
```

`let_declarations` and `let_types` align with `CollectedModule.lets`.

Rigid primitive and canonical resolved types retain the compact negative `BodyTypeId` encoding. Local applied values use the artifact's own flat `types` and `type_arguments` arenas.

`InferredModuleValues` is immutable after construction and forms the barrier before function jobs.

`InferredModuleBodies` now contains:

```moonbit
module_values : InferredModuleValues
```

so downstream lowering receives one coherent semantic artifact.

## Shared SCC inference

Every SCC receives one reusable `LocalTypeSolver` and one fresh type variable per member declaration.

For:

```dew
let first = second
let second = first + 1
```

inference starts with:

```text
first  = alpha
second = beta
```

The two bodies add:

```text
alpha = beta
beta  = alpha
beta  = I32
```

Both values therefore freeze as `I32`.

Each module-let body uses the existing HIR-driven constraints for:

- literals;
- local lets and blocks;
- operators;
- `if`;
- direct and generic calls;
- builtin overloads;
- returns and unsupported poison boundaries.

Its body root is additionally equated with its declaration's SCC slot.

## Forward references

SCC ordering makes forward source references ordinary dependency reads.

For:

```dew
let first = second + 1
let second = 2
```

`second` is inferred and frozen first even though it occurs later in source order. `first` then imports the frozen `I32` type.

No parser or name-resolution ordering restriction is required.

## Recursive values

A recursive SCC is not automatically an error. It is valid when other constraints determine all member types.

For example:

```dew
let first = second
let second = first + 1
```

is type-resolvable as `I32`. The subsequent eager initialization planner nevertheless rejects the SCC because either initializer would read an uninitialized value.

By contrast:

```dew
let first = second
let second = first
```

contains no type-determining constraint. Both member slots still contain unresolved variables after SCC constraint generation.

Inference checks every member before poisoning any of them, then emits:

```moonbit
UnresolvedModuleValue(DeclId, UInt64)
```

for every affected declaration. This avoids reporting only the first member after a shared union-find class becomes poison.

A self-reference such as:

```dew
let self = self
```

receives the same diagnostic.

Type inference answers only whether recursive equations determine a type. Runtime legality is now handled separately by `plan_module_initialization`, documented in `docs/research/module-initialization-plans.md`.

## Diagnostic ownership in shared solvers

Multiple bodies in one SCC write constraints into one solver, but diagnostics must remain attached to the body that emitted them.

Each `BasicBodyInferencer` records:

```text
solver diagnostic start
solver diagnostic end
```

around its constraint generation. Finalization copies only that range.

This prevents every body in an SCC from duplicating all solver diagnostics produced by its peers.

SCC-level unresolved diagnostics are attached directly to the corresponding declaration body.

## Calls inside module values

Module lets use the complete call-inference stage.

For example:

```dew
fn identity<t>(value: t) -> t {
  value
}

builtin convert(value: I32) -> I64 = "i32_to_i64"
builtin convert(value: F32) -> F64 = "f32_to_f64"

let flag = identity(true)
let converted = convert(1)
```

freezes:

```text
flag      : Bool
converted : I64
```

Selected declarations and inferred generic arguments are retained in the module-let body jobs that are merged into `InferredModuleBodies`.

## Import into function jobs

Function bodies run only after all module values are frozen.

A module reference expression reads its declaration's frozen `let_type` rather than allocating an unconstrained expression variable.

Rigid types are imported directly. Positive local applications are rebuilt iteratively in the function's solver.

For:

```dew
struct Box<t> {
  value: t
}

builtin box<t>(value: t) -> Box<t> = "box"

let boxed = box(1)

fn read() -> Box<I32> {
  boxed
}
```

module inference freezes a local applied representation of `Box<I32>`. Each independent function job imports that application into its own solver, where it can unify structurally with the canonical declared `Box<I32>` return type.

The importer uses:

- explicit visit/finish task arrays;
- generation-marked source-term caching;
- flat rebuilt argument spans;
- no shared mutable type variables between jobs.

Unresolved body variables should never enter the frozen module-value artifact. If encountered defensively, the importer maps them to poison.

## Phase and job ordering

The integrated schedule is:

1. Collect declarations and HIR
2. Resolve declaration types and aliases
3. Resolve body names
4. Extract module-let dependencies
5. Infer module-let SCCs in dependency order
6. Freeze `InferredModuleValues`
7. Run function and impl-method jobs independently
8. Merge all module-let and callable body jobs in stable `BodyId` order

Module-let body jobs produced during SCC inference are retained internally and reused by the final merge. `infer_module_bodies` does not infer them a second time.

Function body order remains arbitrary. Forward and reverse body schedules produce identical complete module-value and body artifacts.

Calling the standalone `infer_module_values` API and then separately calling the convenience `infer_module_bodies` performs two independent API invocations; each result remains deterministic and immutable.

## Performance investigation

The first implementation allocated general multi-member SCC arrays even for every independent one-member let and always built module-value import context for modules with no lets.

The main optimizations were:

1. Add a one-member SCC fast path with no inferencer or unresolved-status arrays.
2. Reuse one solver and call scratch arena across SCC jobs.
3. Preserve module-let body job results for final merge instead of reinference.
4. Make module-value context optional for modules containing no lets.
5. Skip dependency graph construction entirely in the no-let fast path.
6. Import frozen module applications lazily and cache them only when referenced.

Representative native changes were:

| Workload | Initial | Final | Change |
|---|---:|---:|---:|
| independent module values, n=512 | 406.39 us | 372.66 us | -8% |
| one constrained SCC, n=512 | 349.44 us | 348.25 us | approximately unchanged |
| module values imported by 256 functions | 219.68 us | 216.14 us | -2% |
| applied value imported by 256 functions | 276.60 us | 277.45 us | measurement noise |
| full pipeline chain, n=256 | 691.27 us | 660.55 us | -4% |

The temporary no-let regression was reduced from 390.99 us to 357.14 us for the existing 256-function basic inference workload. The pre-module-value result was 346.71 us, so the final barrier adds about 3% to this small-body-heavy synthetic workload while preserving all new frozen output.

## Final benchmarks

Release-mode measurements compare only within one backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| dependency analysis chain, n=1024 | 124.04 us | 146.73 us | 408.22 us | 403.87 us |
| independent module values, n=512 | 372.66 us | 239.30 us | 1.03 ms | 1.38 ms |
| one constrained SCC, n=512 | 348.25 us | 255.97 us | 616.93 us | 1.13 ms |
| primitive value imports, functions=256 | 216.14 us | 143.89 us | 493.47 us | 698.82 us |
| applied value imports, functions=256 | 277.45 us | 287.18 us | 925.89 us | 932.00 us |
| full pipeline chain, n=256 | 660.55 us | 486.59 us | 1.16 ms | 2.24 ms |

## Tests

Coverage includes:

- edge deduplication;
- source-stable dependency spans;
- dependency-first SCC order;
- mutual cycles;
- self cycles;
- 1,024-let iterative dependency analysis;
- forward acyclic references;
- shared constraints across mutually recursive values;
- one unresolved diagnostic per affected declaration;
- positive local applied value freezing;
- iterative applied-type import into functions;
- generic calls inside module lets;
- builtin overload selection inside module lets;
- function references to primitive module values;
- function references to applied module values;
- forward/reverse body-job determinism.

## Current boundaries

This stage does not yet provide:

- explicit module-let type annotations;
- polymorphic module lets;
- generalization of inferred module values;
- constant evaluation;
- cross-module imported value dependencies;
- lazy or explicitly recursive value syntax;
- exported interface publication rules for unresolved values;
- assignment semantics for mutable module lets.

Module lets remain monomorphic.

## Next steps

Pattern/loop inference, flow, objects/fields, methods, eager initialization-cycle diagnostics, type-layout recipes, and backend-neutral lowering plans are implemented. Remaining module-value work includes constant evaluation, imported-module ordering, optional lazy storage classes, and Starshine initializer emission.
