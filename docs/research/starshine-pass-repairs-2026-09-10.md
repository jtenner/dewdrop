# Starshine pass repairs, September 2026

This repair effort follows the [deep pipeline study](starshine-deep-pipeline-2026-09-10.md).
The starting Starshine commit is `6d17355e5`. All 17 selected fault probes fail
at that commit after their unoptimized inputs pass Node and Wago. The goal is
to repair the transforms and replay every failed fixture/order from the study.
Passing the selected `speed-deep` order is not sufficient to close these faults.

## Active repair groups

- Heap2Local after inlining: reference-local initialization, JSON state, and
  portable I/O lowering.
- SSANoMerge after inlining: map and generic-never-match execution.
- CoalesceLocals, including CFG coalescing: repeated cleanup corrupts map/set.
- SimplifyLocalsNoStructure: nested patterns and deep/wide-loop compile time.
- MergeLocals: JSON reader output.
- PrecomputePropagate: pattern-matrix output and short-circuit optimizer error.
- OptimizeInstructions: two wrong results and one wrong trap.
- DAE and optimizing DAE: trait output, plus optimizing cleanup faults.
- OptimizeCasts: three wrong collection/show traps.
- Optimizing inlining: invalid locals, wrong results/traps, and timeouts.
- HeapStoreOptimization: four JSON optimizer timeouts.
- Full SimplifyLocals: deep/wide-loop optimizer timeout.
- Flatten: fixed-array optimizer error and WASI optimizer timeouts.
- Engine feature handling: exact references/custom descriptors appear in
  several outputs that target the default Node configuration.

## First reduced shape: Heap2Local reference fields

A two-field struct holds an integer and a non-null reference. A local tee feeds
the first field read; a later local read feeds the second field read. Scalar
replacement puts both field writes inside the first read's result block. The
second scalar local is non-nullable but is read outside the block that sets it.
Independent validation rejects it as an uninitialized local. The input is valid
and the optimized module still removes the allocation, so a positive regression
must check both the scalar replacement and the resulting local declarations.

Temporary builds, reduced inputs, and command timings are under
`.tmp/starshine-pass-repairs`. The baseline release binary is saved there before
any edits. Known fault records and the full previous corpus remain in the
deep-study evidence directory.

## Repair checkpoint: full failed-case replay

The first full replay covers all **1,000** failed fixture/order combinations
from discovery, ordered-screen, and ordered waves 2–4. This is broader than
the 17 selected probes. With the current repair snapshot, **764 pass and 236
still fail**. The exact command records are in
`.tmp/starshine-pass-repairs/full-replay-wave1/report.json`; the immutable
binary is `replay-wave1-starshine.exe` in the same evidence directory.
This snapshot predates the DAE nested-write repair below. These counts are
not a final result and none of the remaining faults are being waived.

Confirmed transform repairs so far:

| Owner | Offending shape | Focused evidence |
| --- | --- | --- |
| Heap2Local | Reference-field writes inside a result block followed by outer reads | 53 native tests; 30 external runtime checks |
| OptimizeInstructions | Zero used as a call argument mistaken for an addition operand | Reduced 13 versus old 26; original deep/wide case passes |
| HeapStoreOptimization | Nested region visited twice per depth | JSON reader timeout becomes 20.79 ms; Node and Wago pass |
| HOT lowering | Added value block rebased inner branch targets | Reduced branch results restored; MergeLocals JSON and late Heap cases pass |
| OptimizeCasts | Cast fact survived a write to the same local | Old object 41 no longer replaces new object 42 |
| CoalesceLocals | Parameter shared storage with a branch-visible default body local | Repeated deep-core map passes Node and Wago |
| RedundantSetElimination | Same-value write removed despite outer-frame initialization requirement | 43 native tests; original optimizing-inlining array-carriers passes both engines |
| SimplifyLocals | Local-read query traversed nested bodies twice | 24-block case 3.402 ms; original deep/wide 16.192 ms; 99 tests |
| LocalSubtyping | Block-local write exported as non-null initialization proof | Concrete heap narrowing retained with nullable storage |
| HOT lift / Flatten | SIMD constant treated as consuming a preceding scalar on a polymorphic stack | Reduced case and 99 related tests pass; original fixed-array now passes |
| HOT lift / SSANoMerge | Dropped unreachable accesses and synthetic captures shifted raw access ordinals | Generic-never-match passes both engines; map passes Node |
| PrecomputePropagate | Transitive local copy used an incomplete conditional reaching-write graph | Pattern-matrix passes both engines; stale moved-branch ownership also repaired |
| DAE / optimizing DAE | Constant argument proof ignored nested local writes | Reduced expected `[55,54]`, old `[55,55]`; new native test passes |

The map SSA module exposes a Wago backend limit: 17 pinned locals exceed its
conditional GC store bound. The module passes Node. That engine issue needs a
separate local Wago repair and pull request, as authorized.

The feature-boundary changes keep ordinary GC constructors from emitting exact
reference types unless the input uses the custom-descriptors proposal. The full
replay now gets past those prior engine feature errors and exposes additional
runtime faults. Feature-preservation tests and generated pass lanes remain open.

Native test builds for these edits take roughly 45–59 seconds. Debug CLI builds
take roughly 17–23 seconds. Every timed command is recorded; test builds exceed
the requested 30-second compiler activity limit and remain performance work.

## Second failed-case replay

The second replay reran the 236 failures from wave 1. Of these, 114 now pass
and 122 still fail. The cumulative result is **878 of 1,000 known failed
fixture/order combinations repaired**. This is an intermediate checkpoint;
a final full rerun must also check for regressions in the earlier successes.
The command log is `.tmp/starshine-pass-repairs/full-replay-wave2/report.json`.
The immutable debug CLI is `replay-wave2-starshine.exe`, SHA-256
`34506dcda61a1d15b43b07aebe696200e8d135775c01535cc9ee3abb3171a3ae`.
The replay took 139.897 seconds, including bounded runtime timeout cases.

Additional repairs included in wave 2:

- RedundantSetElimination now checks the actual stack operand type before it
  narrows an aggregate access. A widening cast must not be undone by value
  identity alone. The reduced result is 42, and all 44 focused tests pass.
- Flatten preserves the source order of a local set split from a tee. The
  reduced reference case returns 42 instead of trapping on a stale local.
- Precompute clears the old region after it moves a constant branch's roots.
  This removes the stale owner that caused the short-circuit compiler abort.
  The reduced case returns each input unchanged: 0, 41, and -7.

The 122 remaining cases include 57 stock O4z failures, 20 optimizing-inlining
failures, 14 `deep-both-no-shrink` failures, four optimizing-DAE failures, two
Flatten compile timeouts, two Wago pinned-local failures, and 23 remaining
ordered local/CFG cases. Their exact fixture names and error text remain in
the replay report. Some failures share a transform bug; counts are cases,
not distinct bugs.

## Published checkpoint, September 11

All 16 Starshine repair commits through `5f74d54b1` are pushed directly to
`jtenner/starshine-mb` master. The rebase found no newer remote commits.
This includes the shared source-access mapping, local lifetime captures, and
exact-reference feature boundary. The new constructor test passes ordinary and
exact input modes. The latest focused shared lift/lower/Flatten run is 99/100;
one old whole-function layout assertion still expects no capture local. The
older MergeLocals Fibonacci layout assertion also needs a semantic check.
These tests remain visible, and full native/generated/performance signoff is
still pending. This publication is a user-requested progress checkpoint.

Wago [PR #606](https://github.com/wago-org/wago/pull/606) repairs the conditional
GC-store snapshot bound. Struct and array reference stores now use pooled state
storage above the inline capacity. Both new 19-pin regression cases failed
before the change and pass after it. The branch is rebased on Wago main
`963b74d9f`; its fix commit is `dfedc15cb`.

The rebased Wago build passed in 4.872 seconds, and focused runtime/backend
checks passed in 9.296 seconds. A freshly built runner executes both saved
17-pin map failures successfully in 3.580 and 3.804 milliseconds. Thus two of
the 122 wave-2 failures are now closed by the engine repair. Further Starshine
changes require a fresh replay before updating the full failure count.

A second reduced Flatten case exposed a pending tee before a later root's read:
its old result was 0 instead of 7. Shared lift now captures this write dependency;
the scalar result is 7 and the GC call variant returns 1. The map CodeFolding
replay now gets past its illegal cast but still fails a later value assertion.
That remaining heap/call ordering fault is not closed by the local repair.

## Further repair checkpoint

Starshine master now includes the repairs through `6e756520a`. Wago PR #606
also includes `8d20861e4`, which keeps the small inline state buffer on the stack;
Go escape analysis and the focused runtime/backend tests pass. The PR remains
open, and all Wago changes are on its remote branch.

The remaining-case replays progressed as follows. Each row only retries the
previous row's failures; a full regression replay of all 1,000 cases is still
required before the cumulative count is final.

| Replay | Retried | Now pass | Still fail | Wall time |
| --- | ---: | ---: | ---: | ---: |
| Wave 3 | 122 | 10 | 112 | 156.629 s |
| Wave 4 | 112 | 6 | 106 | 154.256 s |
| Wave 5 | 106 | 8 | 98 | 112.694 s |
| Wave 6 | 98 | 10 | 88 | 95.451 s |

The cumulative known-case count is **912 of 1,000** passing across these
checkpoints. The immutable binaries, engine hashes, exact commands and runtime
results are in `.tmp/starshine-pass-repairs/full-replay-wave*/report.json`.
The 88 remaining cases include 43 stock O4z cases, 13 optimizing-inlining
cases, 12 `deep-both-no-shrink` cases, and 20 other ordered/direct cases. These
are case counts, not distinct bug counts.

Additional reduced faults and repairs:

- Shared HOT lowering orders a pending call before a later heap/global effect
  and caches effect masks per function. The saved map CodeFolding stage now
  passes both engines. Source positions must survive newly allocated wrappers.
- LocalSubtyping uses a tee's declared storage type for its stack result. A
  struct/array two-tee case no longer emits an invalid narrowed destination.
  All six saved closure orders now pass.
- Flatten scalar spills retain the captured value's source position. The
  double-cast initialization case validates, and the enum O4z prefix advanced
  through 47 passes before exposing the nested cleanup fault below.
- HeapStoreOptimization checks constructor operand local dependencies separately
  from its relaxed descriptor effect masks. The reduced result changes from
  wrong 7 to correct 42. Its native suite passes 433/433. The trait dictionary
  inlining stage returns the required 427 instead of 77 in Node and Wago.
- Full SimplifyLocals preserves writes before branches to enclosing blocks.
  The reduced result changes from wrong 0 to correct 31. The saved enum nested
  cleanup stage and the full stock O4z enum case now pass both engines.

The full pinned native suite was run at the capture checkpoint. It aborted in
an old OptimizeInstructions test that assumed a tee stayed under the first root.
That test now executes the captured comparison for 0, 41, and -7 and passes.
The subsequent 1,540-test focused run passes 1,519 and exposes 21 other failures:
two SimplifyLocals checks and 19 OptimizeInstructions checks involving capture
layouts, reference facts, and bulk-memory effect order. These are active work.
The bulk-memory checks include a real reordered-call fault, not only changed
layouts. The full native run took 69.819 seconds; native test builds remain
above the 30-second performance limit.
