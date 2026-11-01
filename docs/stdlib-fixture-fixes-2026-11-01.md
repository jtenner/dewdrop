# Wave 1 Mission A: WAT fixture fixes

Date: 2026-11-01 UTC. Branch: `worker/wave1-fixtures`. Base: `b9fcc8ea`.
Owner status: **G0 PASS WITH KNOWN RED**. The accepted cold build of 67.88
seconds is outside this work. No SDK setting, compiler source, Dew source,
JSON expectation, B-tree file, or Starshine gitlink is changed here.

All eight verdicts are **CORRECT NEW OUTPUT**. Each expected WAT is changed
on its own, with its evidence in the same commit. There are no escalations.
This report does not claim that MoonBit core caused the old differences.

## Review method

The full baseline diffs are in
`docs/research/data/stdlib-modern-moonbit/snapshots.log.gz`.
Each full diff, including the entire `compiler.facts` record, is also kept in
`docs/research/data/stdlib-fixture-fixes/<fixture>.diff.gz`.
No snapshot update command was used. Each reviewed candidate was built in
scratch space by applying only its own old/new diff, with every old line and
hunk count checked. A fresh full run then checked current compiler output.

`research/data/stdlib-fixture-fixes/review.py` replays these full diffs in
memory from `b9fcc8ea`. It records hashes for all custom-fact lines and full
candidates. For the four large cases it checks every retained function body
with an explicit index map; it also checks that each removed body matches its
retained target. This is an exact body check, not a text-similarity test.
The function signature and full type/section diffs were checked separately.

Compiler evidence shared by these cases:

- `src/semantic/program_specialization_plan.mbt:1051` builds the full
  specialization key; line 1071 reuses a matching instance and checks its
  shapes before reuse.
- `src/semantic/program_physical_link.mbt:1506` selects the exact source-site
  target. Lines 1572-1646 choose any required adapter and its singleton.
  Lines 1653-1686 handle targets inside generic bodies.
- `src/backend/starshine_code.mbt:5301` uses the selected target and singleton;
  line 5358 emits `global.get` when that singleton exists.
- `src/backend/starshine_program_assembly.mbt:938` builds singleton values at
  startup from the selected physical function.
- `src/backend/starshine_compiler_facts.mbt:1420` attaches facts after final
  body/index layout. Lines 1490-1575 scan the final bodies, direct callees,
  address-taken functions, and boundary facts. Thus removed functions and
  changed `ref.func` targets also require changed custom facts; these bytes
  are part of each reviewed WAT, not discarded noise.

Both old and new WAT were parsed, validated, and run on **Node and Wago**.
All 16 modules validate. All 32 runtime runs match the unchanged JSON output,
including Debug's exact text under `write_limit: 3`. The log is
`research/data/stdlib-fixture-fixes/wat-runtime.log`.

## Per-fixture evidence

### `collections/binary-heap-runtime.wat`

**CORRECT NEW OUTPUT. The new output removes one unused-receiver natural-compare instance and uses the retained compare body. The heap code and its results stay the same.**

Full review: **60 hunks**, 2,894 → 2,872 lines. Old function 34 is removed; its instruction body equals function 33 and does not read the receiver. Old functions 35–68 move down by one; all **68 retained bodies**, including `main`, match exactly under that map. Type 66 is removed and later type references move down by one. The compare caller now uses function 33.

Source: `std/ordering.dew:39` compares values and does not read `self`; `std/collections/binary_heap.dew:59`, `:74`, and `:95` implement compare, sift-up, and sift-down. `tests/module-snapshots/collections/binary-heap-runtime.dew:66` starts checks for empty state, min/max order, duplicate keys, alias writes, Floyd heapify, custom comparators, reference values, iteration, and clear. Both old and new pass these checks on both runtimes.

### `generics/bounded-function-reference-runtime-evidence.wat`

**CORRECT NEW OUTPUT. Concrete callbacks use the four existing singletons for their exact selected targets. The generic paths that must capture runtime evidence remain in the module.**

Full review: **5 hunks**, 399 → 375 lines. Specialized readers 11–14 now load globals 0–3 instead of allocating closures with wrappers 24–27. Startup already binds those globals to targets 17–20; the four removed wrappers only forwarded their value argument to those same targets. Four closure subtypes and their declared elements are removed. Capturing readers 9–10 and evidence wrappers 22–23 remain intact.

Source: `tests/module-snapshots/generics/bounded-function-reference-runtime-evidence.dew:41` defines `read`; line 45 returns it from `reader`; line 71 checks results 42, 84, 42, and 1 for single-bound, ordered multi-bound, nominal, and Bool callbacks. The full-key/singleton rules above select the right evidence instance, while `src/backend/starshine_program_adapters.mbt:700` plans escaping evidence references. Both versions pass all four assertions on both runtimes.
