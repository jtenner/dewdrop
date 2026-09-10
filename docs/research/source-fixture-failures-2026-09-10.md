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
fold-inline initially exposed one separate Starshine recursive-type indexing
bug. The repair and full rerun are recorded below.

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

## Starshine recursive type indexing

`modules/cross-module-recursive-types-runtime` first failed after plain inlining.
The inliner used an outer recursive-group position as a flat Wasm type index.
A two-member group shifted subsequent function signatures; an `i32` argument
could receive an `i64` local. Count every subtype in both direct lookup and the
signature map. Reuse Starshine's indexed module context for function summaries.
Red-first pass, white-box, and CLI regressions now pass for plain and optimizing
inlining, including function members inside and after recursive groups.

The release CLI has SHA-256
`efab56b63e08234a8dbcb44fd9b32f6f836072eae185b862e1b04d4d423a6a6f`.
Both regular GenValid and aggregate `pass-inlining` match Binaryen 131 on all
10,000 cases at seed `0x5eed`, with zero mismatches or validation, property,
generator, or command failures. Canonical totals match; raw bytes are still
larger than Binaryen. These are normalization checks, not extra runtime proofs.
The two lanes took 117.969 and 217.561 seconds in total, with eight workers.

## All pipeline source rerun

The complete 17-pipeline sweep compiles all 461 fixtures from source: no baseline
failures, 410 runtime cases, and 51 expected source errors. Eleven pipelines
pass all 410 runtime cases in both Node and Wago: O4s, prune, heap-prune,
inline-prune, cse-prune, precompute-prune, inline-cse, fold-inline, inline-fold,
inline-small, and inline-budget. This includes every originally failing source
fixture and the new nominal callback fixture.

The retained trial pipelines still fail and are not selected:

| Pipeline | Pass | Fail |
| --- | ---: | ---: |
| cleanup | 287 | 123 |
| speed | 284 | 126 |
| gc-speed | 293 | 117 |
| peephole | 308 | 102 |
| casts | 407 | 3 |
| heap | 407 | 3 |

The broad runner therefore correctly returns failure, with 157 fixtures failing
at least one rejected trial. This does not conceal or reclassify those failures
as source fixes. The source sweep took 575.901 seconds across four workers;
the longest source compile took 10.566 seconds under concurrent validation load.
Forty-six commands in rejected trials exceeded the 30-second optimizer limit
(cleanup 21, speed 12, gc-speed 13); all remain explicit performance failures.
`heap-prune`, which had failed on the old saved-WAT corpus, now passes this fresh
source corpus. It is not a new speed recommendation without a benchmark.

The cold Starshine release build took 215.782 seconds, and a cold focused native
regression build took 51.581 seconds. Both remain build performance bugs. The
warm CLI regression takes 0.026 seconds. No diagnostic assertion was disabled.

Starshine commit `ecf316925` contains the recursive-group fix. The full pinned
Starshine native suite passes 10,988 tests in 429.197 seconds. API generation
passes in 3.857 seconds with no public API change. A serial repeat of the
previously slow Dew program-link integration target passes all 41 tests in
17.452 seconds; its earlier 31.052-second measurement included CPU contention.
The full suite's aggregate over-budget result remains visible in the data.
