# Wave 1 wildcard compiler regression

Base: `0b877965`. Worktree: `/data/workspace/wave1-wildcard-fix`.

## Test checkpoint

The unchanged wildcard fixture crashes in the final campaign snapshot log.
Role 53 is the external nominal storage lookup. Signature certification also
uses this lookup after converting a signature value to storage, so role 53
alone does not prove that a struct or closure field owns the bad reference.

The new ordinary-module test has a generic callback record, a callback result
from a separate generic enum module, and an unrelated scalar main. It uses no
standard module names. It checks diagnostics and the full physical invariant.
Implementation is unchanged at this checkpoint. Test results follow below.

The second ordinary-module case places the generic producer in
`callbacks_test.dew`. Production excludes this source's declarations. Its
record captures a generic trait-bound function reference. This separates an
unused source reference from live nominal layout demand. No expected error
or snapshot is changed.

Resource incident: canceling the first lock wait sent SIGTERM to `flock`.
The initial script did not stop on that failure and briefly started a native
build without the lock. The process tree was killed before a test completed.
This is not gate evidence. The script now uses `flock -x 9 || exit $?`.
The restarted gate waits for the same exclusive lock and cleans local build
output on exit. No other worktree output or SDK setting was used.

## Failing ordinary-module proof

The first draft had source syntax errors (23 pass, 2 fail, 27.49 s).
After fixing syntax, a control with the trait in the live enum module passed
25/25 (26.80 s): its trait signature kept the enum live. Moving the trait into
`callbacks_test.dew` isolates the defect. The native test now aborts in
`assert_program_physical_type_fragments`, through the same role-53 external
nominal lookup as the wildcard case. The exact panic and active test are in
`data/stdlib-wave1-wildcard-fix/red-focused.log` (to be compressed at handoff).
The failing lane took 31.33 s, a visible performance bug above 30 s.

The initial filtered run selected zero tests (13.22 s); it is not a pass gate.
All subsequent runs select the owning file through the focused integration
runner, with no name filter. Compiler code is still unchanged here.

## Root cause and fix

`program_reachable_callable_roots` computes the callable and nominal demand
closure. The later collection of `program_function_value_roots` used
`compile_time_demand_expressions` without that closure in the usual pipeline.
It scanned unused bodies, including excluded test sources and unused library
producers. A generic function reference retained a physical callback signature
with an external nominal result. The enum's owner correctly had no live demand,
so no physical enum existed. Signature certification converts its result to
storage and reports code 503, role 53, slot 1, declaration 0.

The fix supplies `Some(program_roots)` for function-reference collection in
all modes. The same demand closure now controls nominal registration and
callback reference registration. No generic layout or erasure rule changes.
No invariant, diagnostic, library path, declaration ordinal, or source name is
special-cased. Live callbacks keep their nominal result; unused producers keep
neither their signature nor their nominal result. The two tests check both.

## Final gate results

SDK: `/data/home/.moon`, Moon `0.1.20261023`, moonc/core
`0.10.17+d971670cd`. Process-local `MOON_CC` is the tracked
`docs/research/data/stdlib-wave1/native-tools/cc` (Clang, trailing
`-fbracket-depth=4096 -g0 -O0`, adjacent `ar`). The evidence-local `moon`
wrapper forces `-j 1` for nested scripts too. Both PATH entries are prepended
to the inherited PATH. There is no SDK or global configuration change.

All final gates run under exclusive `flock` on
`/data/workspace/wave1-control/build.lock`. Each script removes its own
`_build`, `.mooncakes`, `.dew/cache`, and scratch Wasm before lock release.
No other worktree build output was used. No B-tree source or snapshot was
changed. The pinned Starshine gitlink is unchanged. No push occurred.

From `/data/workspace/wave1-wildcard-fix`:

```sh
bash docs/research/data/stdlib-wave1-wildcard-fix/red.sh
bash docs/research/data/stdlib-wave1-wildcard-fix/green.sh
bash docs/research/data/stdlib-wave1-wildcard-fix/review-gate.sh
git diff --check
```

These scripts preserve the exact commands, process environment, lock, cleanup,
and `/usr/bin/time -p` calls. `red.sh` now runs the whole preflight owning file;
it reproduces the panic at test checkpoint `667e2e7a` and passes with the fix.
The earlier checkpoints are `c2d37788` and `18deab3a`; neither is claimed as a
successful regression proof. The minimal three source files are also saved
under `data/stdlib-wave1-wildcard-fix/repro/`, identical to the failing test.

| Final gate | Pass / fail | Wall seconds |
| --- | --- | ---: |
| Callback preflight (23 old + 2 new) | 25 / 0 | 28.967 |
| Program link integration | 46 / 0 | 19.036 |
| Module physical planning | 13 / 0 | 0.100 |
| Physical reference invariants | 6 / 0 | 2.559 |
| Physical type invariants | 23 / 0 | 9.808 |
| All five focused native files | **113 / 0** | 60.48 aggregate |
| Existing adapter compile | pass | 16.82 |
| Existing adapter runtime tests | **9 / 0** | 0.03 |
| Existing production cross-module callbacks | **15 / 0**, imports=0 | 21.28 compile + 0.24 runtime/checks |
| Full stdlib public tests | **445 / 0** | part of full std gate |
| Full stdlib private tests | **41 / 0** | part of full std gate |
| Operation checks (43 summaries) | **4,191 / 0** | part of full std gate |
| Full `tools/dew-test/run.sh` | **exit 0**, repeat bytes equal | 169.38 aggregate |
| Wildcard repeat, validation, Node, Wago | **all pass**, output `wildcard` | 2.998 / 2.483 compiles |
| Wildcard expected JSON/WAT gate | **0 / 1**, new warnings only | 31.52 review aggregate |

The first wildcard gate took 33.34 s (generator 24.733 s; compiles
3.033 / 2.375 s). The review generator took 25.508 s. Both checks preserve
normal repeat compilation, diagnostics, and both runtimes; neither uses an
update flag or bypass. The failed snapshot comparison is kept visible.
`status` records that failure; `snapshot-result.json` records both compile
results and both runtime outputs.

Activities above 30 s remain visible: red proof lane 31.33 s; focused gate
aggregate 60.48 s; first wildcard gate aggregate 33.34 s; review aggregate
31.52 s; std gate aggregate 169.38 s. Individual std compiler performance
bugs: public test module 34.398 s and private test module 63.392 s (the latter
is also reported by the private-lane timer). Public repeat compile is 6.390 s.
No performance work or change to the accepted G0 cold baseline is claimed.

## Wildcard per-item output verdict

**COMPILER DEFECT FIXED. WAT UNCHANGED. CORRECT NEW WARNINGS.**

The fixed compiler emits exactly the old expected WAT, including the entire
`compiler.facts` record. Both old and new WAT SHA-256 are:
`c41eed6ecdd333d5a209b175347767a14c17717b0234ee0217bd4959f8dfabd5`.
The preserved full WAT diff is empty. Explicit `wasm-tools validate`, normal
Node/Wago execution, and repeat byte checks all pass.

The old JSON SHA-256 remains
`61f7a06392e4cbfde18ebfe43329edc173ac593b071d14172c02b2cd93d35f83`.
It expects only the existing UTF-8 derive warning. Two newly landed source
warnings also appear, in stable order, on both compiles:

- `std/encoding/hex.dew:46:7`: `UnreachableBlockItem(14, 1, 871)`.
  Line 45 calls `unreachable()`; line 46's `0u32` cannot execute.
- `std/encoding/binary.dew:6:10`: `RedundantPatternArm(1, 107)`.
  `BinaryError` has exactly one variant at lines 4–6. Its derived equality
  match has a redundant fallback, as does the existing single-variant UTF-8
  error derive. This warning is unrelated to callback type registration.

These are source warnings from the new modules, visible after the panic is
fixed. Errors remain empty, and runtime output stays exactly `["wildcard"]`.
**No JSON or WAT expectation is edited by this worker.** The root worker can
apply the two reviewed warning additions when it resolves all final snapshots.
The four snapshots owned by the fixture worker were not edited.

## Changed files and hashes

Implementation is limited to
`src/semantic/program_specialization_plan.mbt` (one demand-filter change).
Its SHA-256 is
`cac9dd8f69cb717ac5d56efd19ada15113a2e921247dc05802fa5b5c49845434`.
Tests are limited to
`src/semantic/program_function_type_preflight_wbtest.mbt` (two added tests).
Its SHA-256 is
`fccbb80e40481e95b44222e6430c6c85bfe4a9e3c9d8e8c854c58517eec4a47c`.

Other changes are this note and the exact evidence files listed in
`data/stdlib-wave1-wildcard-fix/files.txt`. `SHA256SUMS` lists their hashes.
Logs are compressed in full, including all warnings and timing lines.
No generated Wasm, native binary, cache, or build output remains. Final
`git diff --check` passes. The complete fix commit hash is in the handoff.
