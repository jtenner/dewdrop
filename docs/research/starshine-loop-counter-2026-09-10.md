# Starshine loop-counter repair, 2026-09-10

The offending pass is `simplify-locals-nostructure`. The local repair is
Starshine `b92bf0767`. The compiler used for the source-fixture checks is the
committed Dewdrop compiler at `928eef9a`; unrelated working-tree edits are not
part of these results.

## Cause and repair

The JSON benchmark first fails after this prefix:

```
duplicate-function-elimination
precompute
inlining
local-cse
simplify-locals-nostructure
```

The first four passes execute correctly. Applying the fifth pass alone to the
saved four-pass output also hangs. Replacing transformed functions one at a
time isolates function 52. The reduced shape is a loop that reads a counter
through `local.tee`, tests the copy, then increments that copy and writes it
back to the counter before branching to the loop head.

There is one counter-read instruction, but it executes many times. A helper
incorrectly walked into the loop as if it were an ordinary expression. It
replaced the repeated read with the initial zero. Dead-write removal then
erased the increment. The result passed WebAssembly validation but never
finished running.

All three following-expression walkers now visit only expression inputs.
Control-region bodies use the existing region scanner and its local state.
The pass still removes unrelated local copies. No whole-function skip was
added. The shared fix also protects the other SimplifyLocals variants.

The small, permanent input is
`starshine-mb/tests/fixtures/simplify-locals/aliased-loop-counter.wat`.
Run its CLI regression with a freshly built native binary:

```sh
moon build --target native --release starshine-mb/src/cmd
bun starshine-mb/scripts/test/simplify-locals-loop-runtime.ts \
  "$PWD/_build/native/release/build/jtenner/starshine/cmd/cmd.exe"
```

The regression tests baseline execution, optimized execution, and validation.
It checks four counter start/step choices, seven limits, and four pass variants.
A five-second child-process timeout catches the old hang and retains artifacts.

## Evidence and limits

- The original test fails before the fix: the counter increment disappears.
  The old native CLI's output validates, but execution times out.
- 112 optimized runtime checks pass after the fix. Both original JSON exports,
  `legacy(1)` and `canonical(1)`, return 86.
- 354 focused pass-family tests and all 10,990 Starshine native tests pass.
- 10,000 regular GenValid comparisons match Binaryen 131 canonically.
- The 10,000-case dedicated aggregate has zero tool/validation failures but
  10,000 output differences: 8,338 smaller and 1,662 larger canonical outputs.
  All 20 retained examples are byte-identical on the old Starshine binary.
  These remain parity gaps; validation and size do not prove correct execution.
- All 461 source fixtures compile as expected: 410 runtime cases and 51 source
  errors. O4s and fold-coalesce pass every runtime case in both Node and Wago.
  The repaired fold-flat-locals candidate passes 406 and fails four older cases.

The four remaining SLNS failures are `collections/fixed-array-set-oob-trap`
(lost bounds trap), `control-flow/float-literal-match-runtime`,
`types/derive-eq-generic-runtime`, and `types/derive-hash-runtime` (wrong values).
Old-binary prefix replay reproduces all four at this same pass. Separate small
inputs expose a branch-join result changing from 10 to 20 and a stack-carried
sum changing from 3 to 4. Keep SLNS out of the production speed schedule until
these faults are repaired.

Other candidates also have visible failures. `code-folding` first introduces
an array-bounds trap in `collections/fixed-array-runtime`. `remove-unused-brs`
after a DCE prefix first triggers `unreachable` in Wago only for
`modules/imported-generic-callback-adapter-runtime`; Node passes. The latter
needs runtime-versus-transform attribution, so it is not yet a proven pass bug.
`tools/starshine-experiments/isolate.py` now accepts `--input-wasm` for exact
compiler output and `--runtime node --runtime wago --wago PATH` for both engines.

## Measurements

The direct JSON prefix transform took 8.75 ms in one measured run. Focused
family tests took 1.966 s; `moon info` took 5.082 s. The first native regression
build took 50.882 s, the cold release build 214.617 s, and the full native suite
553.849 s. Those three activities exceed the 30-second budget and remain
performance bugs. The full three-schedule source-fixture run took 151.891 s
in aggregate; individual compiler and optimizer commands stayed below 30 s.

Detailed local records remain in `.tmp/cli-optimization-logs/`: the
`simplify-locals-repro`, `corpus-fixed`, `fuzz-slns-regular`, and
`fuzz-slns-dedicated` directories plus build/test logs. The pass dossier in
Starshine records exact seeds, oracle version, profile counts, cache counts,
and the outstanding faults. This repair is not full pass-family signoff.
