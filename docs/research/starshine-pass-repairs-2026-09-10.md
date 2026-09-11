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


## Full regression replay and control-scope repairs

Starshine master now contains `3501cb009`. This adds four proven fixes after the
previous pin: static-source reference-cast proof, raw SimplifyLocals read/loop
ordering, shared HOT control-exit tracking, and CoalesceLocals capture/operand
control analysis. The Wago fix remains in PR 606; its current pushed head is
`8d20861e4686f8880f2bb97fc6aa3256188ccf35`.

The full replay of all 1,000 original failed fixture/pass-order pairs is required:
rerunning only remaining failures missed regressions. The complete wave 8 result
was 825 passes and 175 failures. Wave 10 now passes 915 and fails 85 in 131.886
seconds. It fixes 90 wave 8 cases and regresses none of that wave's passing cases.
Both baselines and optimized outputs are checked in Node and Wago, with
`wasm-tools validate --features all` on each optimized module. These are case
counts, not counts of distinct compiler bugs.

The shared HOT bug lost earlier branches to outer labels. A later conditional
array load then had no consuming local stores because its live continuation was
marked unreachable. HOT now shares the validator's block/loop/if completion
helpers, without rescanning nested bodies. Native IR tests pass 380/380 in 8.519
seconds; validator tests pass 1,787/1,787 in 24.134 seconds.

CoalesceLocals analyzes every captured local and applies its coloring to that
same lowered body. Its CFG now includes control flow inside root operands; a
consumer cannot recount its already evaluated producer's local accesses. A
live default body local also interferes with unused caller parameters. Native
CoalesceLocals tests pass 116/116 in 47.012 seconds. The saved array-carriers
prefix now passes Node and Wago, with a 25.203 ms pass time. The raw SimplifyLocals
map-iterator prefix passes both engines with an 11.364 ms pass time. These are
smoke measurements, not benchmark conclusions. The debug CLI build (31.373 s)
and CoalesceLocals native test build remain over the 30-second performance limit.

Twelve invalid inlining-optimizing cases are now traced to CodeFolding's nested
cleanup step. It hoists a common call that reads a non-defaultable reference
local, but keeps the local's initialization inside the two conditional arms.
Wasm initialization proof does not leave those control scopes. A positive
regression and transform repair are in progress; the shared call must remain
while its reference reads stay valid. The 85 remaining failed cases, full native
pass suite, 461-fixture coverage, release GenValid gates, ordered CLI pipeline,
and size/speed benchmark signoff remain active work.

Local evidence: `.tmp/starshine-pass-repairs/full-replay-regression-wave10/`,
`check-local-lifetimes.json`, `hot-reachable-exit-suite.log`,
`hot-control-validator-tests.log`, `coalesce-control-captures-native.log`, and
`nested-inlining-wave10/report.json`. Frozen CLI snapshots preserve the exact
source and binary used by each replay.


## CodeFolding reference scopes and the next runtime failure

The pin advances to Starshine `5a5f9ec6c`, already pushed to master. CodeFolding
now repairs non-defaultable reference storage after it moves shared tails out
of conditional arms. Only locals read outside their initialization scope become
nullable; their original reads and tee results retain explicit non-null checks.
Locals initialized in the enclosing scope keep their original type. The common
call stays shared. Three positive regression cases cover these rules.

All 587 IR and CodeFolding native tests pass (40.339 s). All 12 saved invalid
CodeFolding cleanup stages now validate and execute correctly in Node and Wago.
Pass command time ranges from 5.437 to 35.201 ms, median 7.367 ms. After removing
custom sections, the three small outputs match Binaryen 131 byte for byte, with
sizes 130 to 125, 84 to 78, and 140 to 136 bytes.

Full wave 11 replays all 1,000 original failure cases: 926 pass and 74 fail in
122.787 s. No wave 10 passing case regresses. The remaining failures are still
open. The JSON bloom duplicate case gets past CodeFolding, then first fails at
SSANoMerge in the next inlining cleanup. A reduced nested-branch join returns
42, 41, and 9 before the pass, but 0, 0, and 9 afterward. Its repair is active.

The tiny CodeFolding case is a size win, but not a speed win. Three runtime
trials use 31 samples, 150 ms warmup, 3 ms target batches, rotated order, and
checked parameter results. Baseline versus optimized median time is 14.599 vs
15.544 ns/call, 12.677 vs 13.542 ns/call, and 12.647 vs 13.768 ns/call: a 6.5 to
8.9 percent slowdown. Binaryen produces the same bytes and is deduplicated in
these timings. This does not establish a whole-program slowdown, but prevents
claiming CodeFolding belongs in the speed pipeline on this evidence alone.

The clean release CLI build takes 176.402 s, an open build performance bug.
Regular and aggregate GenValid gates (10,000 cases each) for CodeFolding and
CoalesceLocals are running with this prebuilt binary and eight workers. Their
results, the remaining native failures, complete Dew fixture coverage, and
ordered pipeline benchmarks are not yet signed off.

Local evidence: `full-replay-regression-wave11/report.json`,
`code-folding-fixture-replays/report.json`, `code-folding-scope-canonical-size.json`,
`code-folding-scope-benchmark.json`, `ssa-nested-branch-join-red.json`, and
`generated-signoff-wave11-commands.json` under `.tmp/starshine-pass-repairs/`.


## SSA branch joins, copy chains, and a real Node oracle

The pin advances to Starshine `009ad983b`, pushed to master. The preceding
`26355e8dd` fixes the generated runtime test runner. All earlier work remains
in these commits. Wago's tested fix remains in open PR 606.

SSANoMerge has two repaired faults. Its raw suffix scan lost writes that feed
reads after nested branch exits. LocalGraph itself retained all three sources.
The new structured backward analysis follows branch targets, joins conditional
and table successors, and solves loop headers to a fixed point. The small case
now returns 42, 41, and 9 instead of 0, 0, and 9. A second cleanup used stale
copy destinations when collapsing A to B to C; this could lose the final write,
including a loop counter update. Cleanup now follows rewritten destinations.
Its bounded native regression changes from wrong 0 to correct 42.

Seven focused native tests pass. The last native build/test takes 49.317 s,
still over the compiler-work budget; scoped Starshine interface generation
passes in 2.749 s. The complete wave 13 replay passes 931/1000 original failed
fixture/order pairs and fails 69 in 122.930 s. None of the 926 wave 11 passing
cases regress. Four saved nested functional-while SSA stages pass. The saved
JSON bloom SSA stage and default-level inlining pass in Node and Wago, but the
original optimize-level-4/shrink-level-1 inlining composition still returns
FAIL later. This distinction prevents closing the whole JSON fault too early.

Isolated native SSA tests establish the baseline: 495/496 pass before the new
analysis. One stack-carried-tee local-count assertion already fails. The more
precise liveness also makes 50 old fresh-local/branch-copy layout assertions
fail; they need semantic and size review before changing expectations. These
are visible open checks, not a claimed green native suite.

The generated `node-v2` oracle used host worker threads. When the harness ran
under Bun, those observations came from Bun while reporting its emulated Node
version. Timed-out Wasm workers also remained alive: observed threads grew from
162 to 243 while CPU use reached about 1,500 percent. The old wave 11 generated
queue was stopped. Its partial runtime observations are not Node signoff.

The oracle now launches explicit Node children, kills timed-out processes, and
waits for process exit before freeing a worker slot. Cache keys include the
actual Node version and the process protocol. All 75 executor/compare-task
tests pass in 2.128 s. A 128-case generated smoke run takes 28.256 s: all 128
canonical outputs match Binaryen; 67 complete runtime observations match;
61 original runs are blocked; there are no command, validation, property, or
semantic mismatches. Blocked originals do not establish runtime equivalence.
The large generated gates will restart with the real Node runner and a fresh
release binary. Full fixture/native coverage and speed pipeline measurements
remain open.

Evidence under `.tmp/starshine-pass-repairs/`:
`full-replay-regression-wave13/report.json`, `ssa-copy-chain-red.log`,
`ssa-branch-depth-check.log`, `ssa-wave11-native-isolated.json`,
`ssa-wave12-native-isolated.json`, `runtime-oracle-node-identity-red.log`,
`runtime-oracle-process-suite.json`, `genvalid-node-process-smoke/result.json`,
and `generated-signoff-wave11-stopped.json`.


## SimplifyLocals conditional order and wave 15

Starshine `eaad345a2` fixes the next JSON inlining failure. The first bad nested
stage was SimplifyLocals after LocalCSE. It gave a new source order to the write
of a conditional hash result. Lowering then ran the bucket read before the hash
write. A third conditional that reads both values reduces the fault to a small
module: the old output returns 0 instead of 84.

All synthetic local captures in this pass now keep the source position of the
value they store. The positive native regression checks false, positive true,
negative true, and the exact hash/bucket call order. Nine reduced variants pass
Node, Wago, and external validation. Stripped outputs are 11..17 bytes smaller
than input and 7..10 bytes smaller than Binaryen 131. Speed is not established.
The exact O4/shrink-1/strip-debug JSON inlining case now passes both engines.

The full wave 15 replay passes 936/1000 and fails 64 in 157.438 seconds. It fixes
five cases and regresses none of the earlier 931 passes: JSON inlining plus O4z
numeric-literal match, narrow-payload match, invalid UTF-8 classes, and derived
field prerequisites. The native SimplifyLocals family is 278/282 in 72.517 s.
Three old exact-reference assertions conflict with the repaired input feature
boundary; all three also fail with the earlier binary. One old pending-effects
assertion assumes a pre-capture root layout. These checks remain open.

Release build: 254.423 s, SHA-256
`145b9829bc4d468cc54a3038da3a4e987fea0e4b28b61b196ebcd46eac1ef18e`.
Scoped interface generation passes in 5.244 s. Compiler work over 30 seconds is
still a performance bug. The original generated queue continues with the real
Node runner; large gate signoff is pending. Full native and fixture coverage and
the measured CLI speed schedule remain open.

The next reduced owner is OptimizeCasts. Removing a static cast on an earlier
pending call reverses two calls, changing an unreachable trap into integer
division by zero in both Node and Wago. The first bad O4z prefix is pass 27 on
`optimization/scalar-replacement-reference-components-order-trap`.

Evidence under `.tmp/starshine-pass-repairs/`:
`full-replay-regression-wave15/report.json`, `sl-conditional-order-replays/report.json`,
`sl-release-json-bloom.json`, `sl-family-native-wave15.log`,
`sl-nostructure-wave11-baseline.json`, and
`h2l-component-order-wave15/direct-oc-red.json`.


## OptimizeCasts call order and the native SimplifyLocals gate

The pin advances to `a9a69767b`. It includes `b54efdac1`, which closes the four
stale SimplifyLocals test contracts. All 282 tests in that native family now
pass (79.443 s including build). The typed-reference checks compare the actual
conditional and null arm, retain positive local-carrier removal requirements,
and keep validation checks. The sparse-effects unit builds the intended tree
without assuming which root the lifter emits first. No test is disabled.

OptimizeCasts now forwards a proven redundant cast's operand with its original
source order. Other replacements keep their existing order rule. This fixes a
GC pair shape with two differently trapping calls: the first call was delayed
until after the second call and its local write. The native regression was red
with call order [1, 0]; it now requires [0, 1] and removal of three redundant
casts. Shared IR and OptimizeCasts native tests pass 459/459 in 83.714 s.

Full wave 16 passes 937/1000 saved fixture/order pairs and fails 63 in 172.401 s.
It fixes the O4z component-trap case and regresses none of the prior 936 passes.
The release CLI also passes the exact O4z case in Node and Wago. Release build
is 308.205 s, an open performance bug; binary SHA-256 is
`8d4fe3609c6b128f30dcefef6a05ca688b51565ecd365baa43b082c26ad35fe2`.

The real-Node generated CodeFolding gates completed with the frozen `009ad983b`
binary. Regular: 10,000 canonical matches, 5,019 completed runtime matches,
4,981 blocked originals, zero runtime mismatches. Aggregate: 6,624 canonical
matches and 3,376 output-shape differences; all 10,000 runtime observations
match. Aggregate Starshine output is 668,374 canonical bytes versus Binaryen's
671,750. Both lanes have zero generator, validation, command, determinism, or
codec failures. They take 2,191.280 s and 622.840 s. Output-shape classification
still needs retained-diff review; these are not whole-pipeline speed results.
The queue now tests CoalesceLocals, followed by SSANoMerge.

Next reduced owners: Vacuum moves a write when removing a dropped `local.tee`
result in the i8x8 population-count case (3 per byte instead of 4), and
OptimizeInstructions changes a known null trap to unreachable in the nullable
reference fixture. Those fixes and the remaining gates are still open.

Evidence: `full-replay-regression-wave16/report.json`,
`oc-pending-order-native-red.log`, `oc-and-ir-native-wave16.log`,
`oc-release-component-trap.json`, `sl-family-native-wave16.log`,
`genvalid-wave14-code-folding-regular/result.json`,
`genvalid-wave14-code-folding-aggregate/result.json`,
`i8x8-popcnt-wave16/`, and `nested-nullable-trap-wave16/` under
`.tmp/starshine-pass-repairs/`.


## Vacuum dropped-write order and wave 17

Starshine `dd692ff43` keeps the source position when replacing a dropped
`local.tee` with `local.set`. The old fresh root let lowering run later reads
before that write. The reduced packed-byte population-count kernel returned
three bits per byte instead of four. Its new native execution regression uses
an independent scalar reference and requires the drop to be removed.

The four Dewdrop Vacuum regressions and all 122 bounded native Vacuum tests in
`optimize_test.mbt` pass. The release CLI passes the exact O4z i8x8 population
count and saturation fixtures in Node and Wago and external validation. Full
wave 17 passes 939/1000 saved fixture/order pairs and fails 61 (157.418 s), with
no regression from wave 16. Native regression build/run takes 71.597 s;
isolated native execution 0.188 s; debug build 21.382 s; scoped interfaces
5.031 s; release build 263.593 s. Work over 30 s remains a performance bug.
Release SHA-256: `de9733f09782aae699f1f1d77b1119ddb07fc5a5f34a959a2376070d74b828be`.

Review of all 20 retained CodeFolding aggregate differences is now complete.
Each removes one final bare return, retains nested returns, and saves one
canonical byte. Together with the 10,000 real-Node runtime matches and no size
losses, this supports an agent classification of a size-winning final-return
cleanup. This is not a runtime speed win. Generated renewal for the latest
repairs and the complete native/source-fixture gates remain open.

The next confirmed owner is PrecomputePropagation: a nested loop copies its
changing counter into a local, but propagation folds the later condition using
an older constant. The original exits with 9; the optimized module loops.
The reduced reproducer is `precompute-loop-copy-reduced.wat`.

Evidence under `.tmp/starshine-pass-repairs/`:
`vacuum-release-fixtures.json`, `vacuum-wave17-native-isolated.json`,
`full-replay-regression-wave17/report.json`,
`code-folding-aggregate-return-diff-review.json`, and
`precompute-loop-copy-reduced.json`.
