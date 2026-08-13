# Dewdrop generated-code optimization opportunities

Date: 2026-08-02

## Scope and ownership

This document records optimization opportunities in the **Dewdrop compiler and
its generated Wasm**, not in the Wago runtime. They were identified while
compiling a small allocation-heavy Dew program in which a private recursive
function repeatedly constructs an immutable one-field `Box`:

```dew
struct Box {
  remaining: I32
}

fn churn(boxed: Box) -> I32 {
  if boxed.remaining == 0 {
    0
  } else {
    churn(Box::{
      remaining: boxed.remaining - 1
    })
  }
}

pub fn main() -> I32 {
  churn(Box::{
    remaining: 10000
  })
}
```

The current output is already compact, but each nonterminal call executes one
`struct.get`, one `struct.new`, and one ordinary recursive `call`. The initial
call performs another `struct.new`. The workload therefore exposes generated
allocation and stack growth without requiring a large source program.

Wago runtime findings and candidates are tracked separately in
`docs/research/wago-map-set-performance.md`. An optimization that changes Dew
HIR, ABI, representation, instruction selection, or emitted Wasm belongs here.
An optimization that makes an unchanged Wasm instruction execute faster belongs
in Wago.

## Measurement requirements

Optimization work should retain an unoptimized output mode or baseline snapshot
and measure at least:

- emitted Wasm bytes and WAT instruction counts;
- `struct.new`, `array.new*`, `struct.get`, `array.get`, `ref.cast`, and call sites;
- execution time in Node and Wago;
- Wago generated native-code bytes and helper-transition counts;
- host allocation, WasmGC heap allocation, collection count, and peak heap when
  the runtime exposes those values;
- maximum call depth or stack failure for recursive workloads.

A constant, pure zero-argument benchmark can legally disappear under
whole-program evaluation. Allocation benchmarks must therefore include a
runtime-dependent input or another observable result when measuring passes that
perform constant evaluation.

## Priority opportunities

### 1. Escape analysis and scalar replacement

Track aggregate identity and uses. Replace a non-escaping immutable aggregate
with its field values when allocation identity is not observable. The example's
`Box` can become one `i32`, eliminating both `struct.new` and `struct.get`.

The analysis must conservatively materialize values that are returned as
references, stored into reachable aggregates, passed to unknown calls, or used
by future identity-sensitive operations.

### 2. Internal aggregate ABI flattening

Rewrite private statically linked function parameters and results from small
aggregate references to their physical fields when all call sites are known.
For the example, the internal ABI can change from `(ref Box) -> i32` to
`i32 -> i32`.

This is interprocedural scalar replacement. Public, imported, exported, erased,
and recursively shared ABI boundaries must retain their frozen representation
unless specialization creates a private adapter.

### 3. Tail-recursion elimination

Recognize self-calls in tail position and lower them to state-local updates plus
a structured Wasm `loop`. This removes call-stack growth even when allocation
cannot be removed.

### 4. Combined scalar replacement and tail-loop conversion

The target result for the motivating example is one scalar state local, one
structured loop, zero GC allocations, and constant stack use. This combined
case should be a focused optimization fixture because it verifies pass ordering
and interprocedural cooperation.

### 5. Controlled interprocedural inlining

Inline small private functions to expose aggregate construction, field access,
and constant operands to local optimization. Recursive SCCs require budgets:
the entry edge may be inlined without recursively expanding the self-edge.
Inlining should be guided by runtime benefit and code-size growth.

### 6. Allocation sinking and lazy materialization

Represent a newly constructed aggregate virtually until an operation requires a
real reference. Forward virtual fields through local bindings, branches, direct
calls, and returns that are themselves flattened. Emit `struct.new` only at the
first escaping or identity-sensitive boundary.

### 7. Constructor-to-field forwarding

Replace a field read from a known constructor with the corresponding constructor
operand while preserving source evaluation order. This is the local,
allocation-independent foundation for scalar replacement.

### 8. Immutable field-load common-subexpression elimination

Reuse repeated `struct.get` and nested payload extraction when the base
reference and intervening effects prove the field unchanged. This is especially
important for enum guards and arm bodies that repeatedly cast and traverse the
same payload.

### 9. Local copy propagation and local coalescing

Remove trivial `local.set`/`local.get` chains, forward scalar and reference
values, and reuse compatible scratch locals when live ranges do not overlap.
Reference-local coalescing must preserve precise GC root information.

### 10. Dead allocation elimination

Remove an allocation after all observable uses disappear. Dew must first define
whether reference identity, allocation failure, or GC timing is observable.
Absent such observability, an unused successful WasmGC allocation is removable.

### 11. Dead branch, dead default, and unreachable-code elimination

Use constant conditions, local enum exhaustiveness, imported closed-enum
interfaces, and flow summaries to remove unreachable arms and conservative
match defaults. This should run after match planning and again after constant
propagation.

### 12. Pattern payload extraction CSE and cast elimination

Share enum tag tests, `ref.cast`, payload locals, and field extraction across
pattern alternatives, guards, and arm bodies. Preserve trap behavior when a cast
cannot be proven redundant. This extends the existing planned typed
payload-local reuse work.

### 13. Purity and effect summaries

Record whether a function may perform I/O, mutate reachable state, trap,
allocate observably, call unknown code, or diverge. Stable summaries enable dead
call elimination, stronger inlining, allocation removal, and bounded compile-time
evaluation.

### 14. Bounded recursive constant evaluation

Evaluate pure calls with constant arguments under explicit recursion, step,
memory, and diagnostic budgets. The motivating `main` can legally fold to
`i32.const 0`; benchmarks intended to retain work must prevent this with dynamic
input.

### 15. Function specialization

Clone internal functions for profitable concrete calling contexts, including
known aggregate shapes and generic runtime carriers. Specialization should be
bounded by code-size budgets and share equivalent Wasm representation shapes.

### 16. Reachability-guided signature rewriting

Use exact static-link reachability to rewrite only non-exported signatures and
all of their known call sites. This supplies the safety boundary for aggregate
flattening, return-value narrowing, and private specialized adapters.

### 17. Return-value narrowing and multi-value replacement

When all callers consume only selected fields of an aggregate result, return
those fields directly. Multiple consumed scalar fields can use Wasm multi-value
results where that is cheaper than allocating a result struct.

### 18. Early reference-root death

Shorten generated reference live ranges and avoid retaining dead references in
scratch locals. The engine may already calculate precise native liveness, so
this is a measurement candidate rather than an assumed win. Generated code must
never clear a non-nullable local with an invalid null value.

### 19. Uniqueness-based mutable reuse

For a mutable aggregate with a proven unique reference, update fields in place
instead of allocating a replacement object. This is not valid for immutable
objects or values with reachable aliases. Functional-loop state is now executable; further loop-state scalar replacement remains a possible measured workload.

### 20. Scalar unboxed enum representations

The bounded implementations represent proven private unit-only body locals and
direct parameter/results with scalar Wasm tags instead of GC structs. A second
closed proof packs private unit-or-single-`I32`-payload parameter/results into one
`i64`. Broader public, generic, function-value, imported, method, nested,
multi-field, and non-`I32` payload ABIs remain measurement-driven candidates.
Every candidate remains compared against Dewdrop's optimized subtype-family
baseline and must preserve source tags, exhaustive matching, source order, and
ABI stability.

### 21. Canonical nullary enum values

If reference identity is not observable, avoid allocating a fresh object for
each nullary variant. Possible representations include scalar tags, direct base
values, or canonical shared instances after module-global initialization exists.

### 22. Generic carrier specialization

Specialize generic functions and aggregates by physical Wasm shape so scalar and
vector values remain unboxed. Use erased nullable-`eqref` carrier layouts only at
genuinely erased boundaries, with private adapters where required.

### 23. Range-proven `i31ref` use

Use `i31ref` only for erased integer values or tags proven to fit its signed
31-bit payload. It is not a transparent representation for arbitrary Dew
`I32`, `U32`, or `I64` values and requires an explicit representation boundary.

### 24. Post-lowering Wasm peephole optimization

Before deterministic validation and encoding, simplify redundant local traffic,
duplicate safe casts, repeated immutable field loads, constant comparisons,
dead drops, and unnecessary wrappers. Optimized output should receive separate
intentional WAT snapshots rather than silently replacing baseline snapshots.

### 25. Wasm tail-call emission as a fallback

Where the selected target supports the tail-call proposal, emit `return_call`
for eligible tail calls that have not been converted into structured loops. This
controls stack growth but does not remove GC allocation and must remain
feature-gated.

## Implementation dependencies exposed by the experiment

These are correctness or feature prerequisites rather than optimizations:

- functional `while` now has executable state/result-local Wasm lowering, so
  allocation churn can use structured loops without recursive call-stack noise;
- nested aggregate and recursive-reference variants need reduced validation
  fixtures before they become optimization benchmarks;
- optimized snapshots need a separate contract from the current deterministic
  baseline WAT snapshots;
- runtime allocation and collection counters are needed to distinguish fewer
  host helper allocations from fewer WasmGC heap allocations.

## Suggested implementation sequence

1. Add reduced dynamic-input allocation benchmarks and counters using executable
   functional loops.
2. Add constructor forwarding, copy propagation, and local field CSE.
3. Add local escape analysis, virtual aggregates, and scalar replacement.
4. Extend scalar replacement through private function signatures.
5. Add tail-recursion-to-loop conversion.
6. Add pattern payload-local reuse, cast elimination, and dead defaults.
7. Add effect summaries and bounded constant evaluation.
8. Add generic carrier specialization and scalar enum experiments.
9. Add a deterministic post-lowering optimization pipeline with explicit
   optimized snapshots.
