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
