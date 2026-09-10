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
