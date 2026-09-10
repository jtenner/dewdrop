# Source fixture repairs, 2026-09-10

The input set is the 46 failures in
`data/starshine-2026-09-10/starshine-committed-O4s.jsonl`.
A clean checkout of `0bb862ed` reproduced all 46 with a freshly built native
compiler. The pinned Starshine commit is `f56444542b0aaa2930eff5b97c3946f124f23192`.
Work proceeds on `fix/source-fixture-failures` to preserve unrelated workspace
edits. All execution results below use source compilation, not saved WAT.

## Optimizer arena ownership

Nine scalar replacement cases left obsolete local records outside all callable
local spans. Compact the active spans once after scalar replacement. Copy lambda
metadata before mutation so the input lowering remains intact.

Twelve enum guard cases appended control nodes outside the owning body spans.
Both known-constructor scalar replacement and guard extraction factoring now
record their generated nodes and rebuild expression, block, and arm arenas in
owner order. Rebase all operands, roots, body/lambda spans, and expression
evidence. Keep the existing arena and capture assertions enabled.

Three regression tests first failed with the actual ownership diagnostics, then
passed. The tests also require useful rewrites and check the input lowering and
later lambda owners. All 21 affected source fixtures pass validation and Node
runtime checks with both O4s and fold-inline. These include evaluation and trap
order checks, allocation budgets, reference fields, and nested payloads.

Measured native compiler builds: 13.265 s initially and 10.185 s after the final
repair. Focused semantic red tests: 9.819 s, 11.138 s, and 10.718 s. The final
semantic selection passed 32 tests in 22.234 s. Each package invocation stayed
below 30 s. An outer measurement of the multi-package test script reported
45.916 s; this is aggregate orchestration, not one compiler invocation. Future
runs use the script's individual package timings without an outer compiler
activity timer.

The remaining failures include pattern coverage, array callback code, startup
cycle detection, and outdated diagnostic expectations. They are still visible;
no runtime mismatch was accepted as a new expected result in this repair.

## Pattern coverage

An enum with one variant and irrefutable payloads is itself irrefutable. The
flow analyzer now uses that fact for nested patterns, including imported enums.
A red-first test rejected a nested three-enum pattern before this fix. Existing
refutable nested enum and guarded-arm coverage checks remain in place.

The two constant-guard fixtures were not exhaustive under the language's rule:
guarded arms do not provide unconditional coverage, even for `if true`. Add an
unreachable fallback for the remaining variant. Keep the guard optimization and
trap-order checks. The value fixture now asserts 42 so its return is observed.
All three source cases pass Node and Wago before and after O4s and fold-inline.

## Startup cycles

Cross-module aliases in a dependency cycle can have no inferred runtime type.
Physical planning checked that type before it checked the cycle and aborted with
invariant 301. Separate structural identity/arena checks from the runtime-carrier
check. Check the selected startup dependency graph first; report a source cycle
with both declarations. Require valid physical carriers when that graph has no
cycle. The original source diagnostic is restored without changing its expected
text. A native red-first regression and both source runs pass; existing malformed
initializer tests continue to exercise the physical assertion.

## Callback reachability

The program and module reachability walks visited named-body expressions but
omitted their lambda bodies. A generic function called from an array callback
could be emitted while one of its private helpers (`array_min`) was removed.
Walk the callable's full owned expression set, including its lambdas, for both
ordinary roots and module initializers. A library-style private helper regression
failed before the fix and now passes. The array mutation fixture passes in Node
and Wago with O4s and fold-inline.

## Callback function signatures

Generic callback specialization matched signatures using broad carrier codes.
That erased fixed nominal results such as `Array<t>` to `eqref` and selected a
function type that the actual callback did not have. Preserve each fixed ABI
slot and substitute only generic slots, including flattened products and erased
Unit slots. Match complete Wasm value types after mapping nominal references to
their program type indices. Keep typed and erased callback alternatives distinct.

The array flat-map fixture and a new user-defined `Box` fixture both trapped
before the repair. Both now pass in Node and Wago with both selected pipelines.
The new fixture checks direct and captured callback results with assertions.
The full native lane passes 1,333 tests over 229 targets; its slowest measured
target takes 17.621 seconds. All 461 source fixtures now meet their baseline
oracles (410 execute and 51 report expected source errors). O4s passes all 410;
fold-inline exposes one separate Starshine recursive-type indexing bug, which
remains visible pending its repair.

## Crash reports

Check for compiler aborts before comparing expected source diagnostics. The
startup-cycle crash was retained in the raw command record, but its short report
only said that the expected source error was missing. The short report now keeps
the invariant and stack too. A red-first unit test checks that case; all six
runner tests pass in 0.258 seconds.

## Source expectations and reproducible snapshots

Nineteen JSON expectations were stale: eight now include real redundant-arm
warnings, seven track current source diagnostics, and four now describe
successful execution. Those four are hash evaluation once, generic Never match,
imported derived methods, and generic derived equality. Their successful runtime
results were checked before their expectations changed. No runtime failure was
converted into expected success.

The official snapshot suite passes all 461 fixtures in Node and Wago. It compiles
every fixture twice and compares module bytes: 922 source compilations, maximum
6.316 seconds, none above 30 seconds. Regenerate all 410 executable WAT snapshots
from that compiler, including the new nominal callback regression. Fifty-one
fixtures still intentionally report source errors. The complete integration lane
passes 270 tests. Its slowest target takes 31.052 seconds while other experiment
jobs are active; retain that timing as a performance bug pending a serial check.

[Saved validation data](data/source-fixture-fixes-2026-09-10/source-validation.json)
includes per-target native times. The accompanying JSONL keeps every official
snapshot command time, including all 922 source compilations.
