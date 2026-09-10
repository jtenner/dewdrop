# Starshine runtime and pass-order experiments

Date: 2026-09-10. Goal: preserve Dew execution, reduce module size where possible,
and prefer runtime speed over size. Validation alone is not proof of correct
execution.

## Starting state

- Dewdrop HEAD: `286e881b` at the start. The workspace has existing compiler and
  self-host edits. These are used for the build but are not part of this work's
  commits. Reports record a hash of the workspace diff and the compiler binary.
- Pinned Starshine: `8d82581f51627a452062d8965e40601c106de1f3`.
- Node: `v26.8.1`. Moon: `0.1.20260827`.
- 460 module snapshot fixtures: 405 executable fixtures and 55 expected compiler
  failures. Discovery includes multi-file, imported-module, and test-mode cases.
- Stock `O4s` means optimize level 4 and shrink level 1. The CLI requires the
  explicit level flags. In `starshine-mb/src/passes/optimize.mbt`, the current
  fast preset expands to duplicate-function-elimination, vacuum, reorder-locals,
  strip-debug. The full compatibility scheduler is reserved for `O4z`.

## Method

`tools/starshine-experiments/runner.py` compiles each fixture, validates it, and
checks output and trap expectations with the existing Node and Wago consumers.
It then optimizes the same input for each selected pass list, validates the
result with wasm-tools, and repeats the execution checks. Expected diagnostics
are checked too. The runner retains commands and full failure messages and
continues through the corpus. No snapshot is rewritten. Failed execution cannot
count as a passing size or speed result.

`pipelines.json` keeps explicit pass order. Candidate names are experiment
labels, not compiler defaults or claims of correctness. Implicit traps remain
enabled. No closed-world or trusted compiler-fact assumptions are added.

## Initial checks

The three runner unit tests first failed because the runner did not exist, then
passed after implementation. They cover changed output, changed output before a
trap, command error diagnostics, and timeouts.

The first release native snapshot compiler build took **100.993 seconds**. This
exceeds the repository's 30 second limit and is a build performance bug. It is
separate from individual Dew fixture compile time.

## Corpus baseline and first pass sweep

The current workspace source run finished with 371 passing runtime fixtures,
one matching compiler-error fixture, and 88 baseline failures. A separate
checkout at `f3e8fa9e` produced 371 passing runtime fixtures, 43 matching
compiler-error fixtures, and 46 baseline failures. These include stale
diagnostics, compiler assertions, and one baseline runtime error. Neither source
run had a Starshine failure among the modules admitted to optimization. Source
failures must stay visible; the experiment does not update those snapshots.

The committed compiler was built in native debug mode in 13.244 seconds. Its
test-module compiler built in 8.840 seconds. The release Starshine CLI build took
187.591 seconds, another build performance bug.

To check every optimizer input despite those compiler failures, the next run
assembled the checked-in WAT snapshots. All 405 baseline modules passed Node and
Wago. Stock O4s passed all 405. The 55 compiler-error fixtures have no WAT and
are explicitly counted as such; this lane does not test their diagnostics.

The first ordered candidates passed 308/405 (`cleanup`), 309/405 (`speed`), and
321/405 (`gc-speed`). The failures include invalid output, optimizer crashes,
30-second optimizer limits, and valid modules that loop forever at runtime.
`control-flow/short-circuit-runtime` is one runtime-loop case for `cleanup`.
These candidates cannot be selected on size or speed grounds.

The library run compiled each of the 25 standard test files and all 43 operation
probe modules. This found a missing `open dew.std.fixed_array` in the SHA-256
test, hidden by imports in the aggregate test module. Adding that import makes
the isolated SHA-256 corpus test pass before and after O4s. Builtin trap probes
use an all-export trap checker; their intentional failing assertion is not an
ordinary test that should return normally.

The constructor operation probe found a separate O4s failure: the CLI final size
cleanup removes a `return` that discards values below the result on the operand
stack. Falling through the function leaves those values on the stack and creates
invalid Wasm. A two-parameter, one-result function reproduces the failure. The
regression is in the CLI final cleanup, not the public `vacuum` pass alone.

## Terminal return fix

Starshine commit `f56444542` fixes both unconditional removal sites: the final
size candidate in `src/passes/pass_manager.mbt` and the final encoder cleanup in
`src/cmd/cmd.mbt`. Each collects changed functions and validates the candidate
fallthroughs with one shared module environment. Functions that need to discard
extra stack values retain their return. Ordinary redundant returns still go.
The CLI regression uses a raw instruction array because WAT parsing can
normalize away the failing shape before the test reaches the encoder.

Both regressions failed before their respective fixes. The pinned native suite
then passed **10,985/10,985 tests**, in **334.775 seconds**. A large existing DAE
threshold test spent minutes repeating type lookups; its saved stack is in
`data/starshine-2026-09-10/slow-native-test.txt`. The fixed release build took
173.200 seconds. These exceed the 30 second compiler activity target.
`moon info starshine-mb/src/cmd starshine-mb/src/passes` passed in 3.346 seconds,
with no public API change. The native debug generator build took 26.675 seconds.

The dedicated aggregate Vacuum GenValid profile compared 10,000 cases at seed
`0x5eed` against Binaryen 131 in 43.566 seconds. It used the explicit release
Starshine binary and eight subprocess workers. There were 7,830 normalized
matches and no validation, generator, or command failures. The other 2,170
cases belong to two already documented smaller-output families: 1,080 hazard
cases at -2 bytes and 1,090 local-set prefix cases at -1 byte. All 20 saved
differences replay byte-identically with the original CLI. This classifies them
as pre-existing differences; this generated lane does not prove execution.
Total canonical bytes: Starshine 509,081; Binaryen 512,331.

The fixed release passed all 405 saved modules in Node and Wago and all 68
library modules in Node for O4s, prune, inline-prune, cse-prune,
precompute-prune, inline-cse, inline-fold, and fold-inline. This is 3,240
optimized fixture modules and 544 optimized library modules, each checked
against the same baseline assertions. The source compiler failures above stay
separate and visible.
