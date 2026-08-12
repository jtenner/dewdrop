# Body-local type terms and unification

Date: 2026-07-30

## Scope

The first executable part of Dew body-local type inference is now implemented:

- body-local type terms;
- body-local inference variables;
- union-find equivalence classes;
- rigid resolved type references;
- local applied types containing inference variables;
- structural unification across resolved and local applications;
- iterative occurs checking;
- poison-type propagation;
- rollback snapshots for future overload trials;
- iterative final type substitution, called zonking;
- unresolved-variable detection.

This is the inference engine foundation. Expression, pattern, call, operator, and flow constraint generation remains the next layer.

The implementation lives in:

- `src/semantic/inference_types.mbt`;
- `src/semantic/local_unification.mbt`;
- `src/semantic/local_unification_wbtest.mbt`;
- `src/semantic/local_unification_bench_test.mbt`.

## Public low-level API

The semantic package exposes the low-level solver so later inference stages and compiler extensions can build body-local constraints without mutating `ResolvedModuleTypes`:

```moonbit
LocalTypeSolver::new
LocalTypeSolver::error_type
LocalTypeSolver::resolved_type
LocalTypeSolver::fresh_variable
LocalTypeSolver::applied_type
LocalTypeSolver::type_term
LocalTypeSolver::representative_type
LocalTypeSolver::unify
LocalTypeSolver::snapshot
LocalTypeSolver::rollback
LocalTypeSolver::commit
LocalTypeSolver::zonk_type
LocalTypeSolver::has_unresolved_variable
```

The solver is mutable and must remain owned by one body or module-let SCC job. It is not shared between workers.

## Type terms

```moonbit
pub enum BodyTypeTerm {
  BodyErrorType
  BodyResolvedType(ResolvedTypeId)
  BodyVariableType(TypeVariableId)
  BodyAppliedType(BodyTypeId, HirSpan)
}
```

A body term may refer directly to one rigid canonical module type, one inference variable, or a body-local application whose arguments may contain variables.

Examples:

```text
BodyResolvedType(I32)
BodyVariableType(alpha)
BodyAppliedType(Pair, [alpha, String])
```

Body-local applied arguments occupy one shared flat arena.

## Compact type-ID encoding

`BodyTypeId` is an `Int` interpreted through `LocalTypeSolver::type_term`:

- `0` is the shared body error type;
- negative values below `-1` encode rigid `ResolvedTypeId` references;
- positive values index body-local terms;
- `-1` is reserved internally as the unbound-variable binding sentinel.

Encoding rigid resolved references directly avoids allocating one wrapper record every time a declaration signature or primitive enters a body job.

Consumers should use `type_term` rather than depending on the numeric encoding.

## Rigid types and variables

Resolved signature types are rigid. A declaration generic such as `t` remains a canonical `GenericParameterType` and cannot be assigned a concrete type while checking its own body.

Call-site generic instantiation will instead replace a callee's generic parameters with fresh body-local variables.

Every fresh variable receives:

```text
parent = itself
size = 1
binding = unbound
body type term = BodyVariableType(variable ID)
```

Variables never enter the shared module resolved-type interner.

## Union-find

Variable equivalence uses union by size. Outside a speculative snapshot, root lookup also performs path compression.

During an active snapshot, path compression is disabled so speculative candidate trials do not create a large undo stream merely from reads. Parent changes caused by actual unions remain logged.

A variable class may be:

- unbound;
- equivalent to another variable class;
- bound to a rigid resolved type;
- bound to a body-local applied type;
- poisoned by the body error type.

## Structural unification

`LocalTypeSolver::unify` uses two reusable work arrays of type pairs. It performs no recursive calls.

Supported combinations include:

```text
variable           with variable
variable           with resolved type
variable           with local application
resolved type      with resolved type
local application  with local application
resolved applied   with local application
```

Equal canonical resolved IDs succeed immediately.

Applied types compare their argument counts, then schedule constructor and ordered argument pairs. This permits:

```text
Pair<alpha, String> = Pair<I32, beta>
```

to produce:

```text
alpha = I32
beta = String
```

Nominal constructors remain rigid. `List<I32>` does not unify with `Option<I32>` merely because both have one argument.

## Occurs checking

Before binding an unbound variable to a structured term, the solver checks whether that variable occurs anywhere inside the candidate type.

For example:

```text
alpha = List<alpha>
```

is rejected with:

```moonbit
InfiniteLocalType
```

Occurs traversal descends through both local applications and canonical resolved applications. Generation-marked local and resolved arrays avoid allocating a visited set for every check.

The traversal is iterative and has 1,024-level stress coverage.

## Poison handling

The body error type is absorbing for later equality checks. Unifying error with another type succeeds without another diagnostic.

When an already-bound variable conflicts with another concrete type, the solver emits one `LocalTypeMismatch` and changes that variable class's binding to the error type.

For example:

```text
alpha = I32
alpha = String
```

produces one mismatch and leaves:

```text
alpha = Error
```

Subsequent constraints involving `alpha` do not repeat the original mismatch.

## Constraint origins

Every unification receives:

```moonbit
pub struct TypeConstraintOrigin {
  kind : TypeConstraintOriginKind
  source : Int
  offset : UInt64
}
```

Origin kinds are prepared for:

- expressions;
- patterns;
- locals;
- returns;
- calls;
- operators;
- synthetic engine tests or constraints.

Factory functions construct each origin kind. Future diagnostics can therefore report why two types were required to match rather than showing only two unrelated type terms.

## Rollback snapshots

Future overload selection must test candidate signatures without copying the complete solver.

`LocalTypeSolver::snapshot` records:

- undo-log position;
- variable count;
- local type-term count;
- type-argument count;
- diagnostic count.

Mutations to variable parents, sizes, and bindings append primitive undo records while any snapshot is active.

Rollback:

1. Restores mutations in reverse order
2. Truncates variables allocated during the trial
3. Truncates terms and arguments allocated during the trial
4. Removes speculative diagnostics
5. Removes the snapshot marker

Commit retains mutations and allocations. Nested snapshots are supported and must commit or roll back in LIFO order. If an inner snapshot commits, an enclosing snapshot can still roll back all inner changes.

This gives future builtin overload and trait-candidate selection a low-copy speculative mechanism.

## Zonking

After constraints are solved, `zonk_type` follows variable representatives and rebuilds structured terms with final argument types.

For example:

```text
Pair<alpha, beta>
alpha = I32
beta = String
```

zonks to:

```text
Pair<I32, String>
```

If any application component zonks to error, the complete application becomes the shared body error type.

Zonking uses iterative visit/finish tasks, generation-marked memo arrays, one result stack, and reusable application scratch. It does not run while a speculative snapshot is active.

`has_unresolved_variable` iteratively checks whether a final term still contains any unbound variable.

## Determinism and ownership

One solver belongs to one semantic job. Variable IDs and local term IDs are allocated only by deterministic traversal within that job.

The engine uses no:

- global type-variable allocator;
- concurrent interner insertion;
- allocation-address identity;
- worker-order-dependent numbering.

Resolved types remain frozen and are referenced by stable IDs. Body-local terms are discarded or frozen with their owning inference result.

## Complexity

For `V` variables and `C` structural constraints:

- ordinary variable union/find is effectively amortized constant time;
- structural equality work is linear in visited type-term edges;
- occurs checking is linear in the candidate type graph;
- rollback is linear in mutations and allocations made after the snapshot;
- zonking is linear in the reachable final type graph.

Reusable pair, traversal, mark, task, and result arrays retain capacity between operations in one solver. `LocalTypeSolver::reset` clears logical contents while preserving capacity so one worker can reuse its solver across many independent bodies. Resolved occurs-check marks are allocated lazily, and rigid/error zonking and unresolved checks use direct fast paths.

## Tests

`src/semantic/local_unification_wbtest.mbt` covers:

- variable binding;
- variable union;
- rigid primitive binding;
- mixed resolved/local applied unification;
- mismatch diagnostics;
- poison suppression of cascades;
- infinite-type rejection;
- allocation, binding, and diagnostic rollback;
- committed snapshots;
- nested snapshot rollback;
- zonking bound applications;
- poison propagation through zonking;
- 1,024-level occurs checking;
- union of 1,024 variables.

## Benchmarks

Release-mode benchmarks live in `src/semantic/local_unification_bench_test.mbt`. Times compare only within one backend runner.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| union variables, n=4096 | 234.70 us | 256.12 us | 675.13 us | 658.67 us |
| unify nested applications, depth=512 | 63.05 us | 44.49 us | 86.97 us | 234.29 us |
| occurs check, depth=1024 | 60.33 us | 40.20 us | 78.29 us | 224.63 us |
| rollback candidate trials, n=256 | 35.50 us | 32.43 us | 188.26 us | 108.51 us |
| mixed resolved application unifications, n=1024 | 264.51 us | 217.65 us | 640.91 us | 898.85 us |
| zonk applications, depth=512 | 57.52 us | 58.35 us | 146.15 us | 197.98 us |

## Current boundary

The solver remains body-job-local and is consumed by the implemented expression,
pattern, loop, member, method, indexing, overload, and trait-obligation phases.
Full generic/generic structural overload specificity remains open and is tracked
in `docs/roadmap.md`; other downstream compiler phases are implemented.
