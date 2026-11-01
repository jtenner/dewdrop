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

### `generics/generic-enum-adapter-runtime.wat`

**CORRECT NEW OUTPUT. The singleton now refers to the exact enum adapter selected for this source site. Its argument/result conversion preserves the source enum values.**

Full review: **3 hunks**, 773 → 773 lines. Only `compiler.facts`, the declared element, and startup `ref.func` change; the target is 5 → 7. All function bodies remain unchanged. Function 7 converts compact scalar payloads through the erased fallback and back; function 5 is the direct specialized implementation. Facts must mark the new address-taken target and startup reference target.

Source: `tests/module-snapshots/generics/generic-enum-adapter-runtime.dew:18` defines `echo_maybe`, line 39 returns it as a function value, and line 43 checks tuple, named, boxed, and nested enum payloads (42–45). `src/semantic/program_physical_link.mbt:1572` checks signature compatibility before selecting an adapter; emission uses that selected singleton. Both versions pass every assertion on both runtimes.

### `generics/generic-erased-scalar-adapter-runtime.wat`

**CORRECT NEW OUTPUT. Each singleton uses its exact typed export adapter, which boxes the argument, calls erased `identity`, and unboxes the result. The value and carrier type are preserved.**

Full review: **3 hunks**, 276 → 276 lines. Only facts, declared elements, and startup references change: 9–13 → 14–18. All other code, types, globals, and exports remain unchanged. The five new targets have signatures I32, I64, F32, F64, and V128 respectively, with matching box fields on each side of erased function 7.

Source: `tests/module-snapshots/generics/generic-erased-scalar-adapter-runtime.dew:1` defines identity; lines 13–30 return the five typed references. Main at line 33 creates all five and invokes I32, I64, and F64 with assertions. Both versions pass on both runtimes. F32 and V128 are constructed but not invoked by this existing fixture; their exact adapter bodies and matching carrier types were checked in the full WAT (no extra runtime coverage is claimed).

### `modules/imported-bounded-function-reference-runtime-evidence.wat`

**CORRECT NEW OUTPUT. The concrete imported reader uses its existing singleton for target 3. The generic imported reader still has the closure that captures runtime evidence.**

Full review: **4 hunks**, 144 → 138 lines. Specialized reader 7 loads global 0 instead of making subtype 34 with wrapper 10. Startup already sets global 0 to target 3; removed wrapper 10 only forwarded argument 1 to function 3. Its subtype and declared element are removed. Generic reader 6 and capturing wrapper 9 remain unchanged.

Source: `tests/module-snapshots/modules/imported-bounded-function-reference-runtime-evidence.dew:1` imports `fixture.callback_provider`; line 3 returns imported `read`, and line 11 checks callback result 42. The provider is in the adjacent `.modules/fixture.callback_provider/` directory. Exact-site target selection uses the module and specialization key, not a spelling rule. Both versions pass on both runtimes.

### `text/show-collections-runtime.wat`

**CORRECT NEW OUTPUT. The nested collection Show path reuses the existing equivalent append function. It keeps the depth check, formatter depth increment, and selected value formatter.**

Full review: **24 hunks**, 2,325 → 2,302 lines. Old function 92 is removed and its caller uses function 79. Its body equals retained function 79 after index mapping; all **98 retained bodies** match exactly. Old functions 93–98 move down one, type 137 is removed, and the later types/exports move with them.

Source: `std/show.dew:50` checks depth and increments it before `append_show`. `tests/module-snapshots/text/show-collections-runtime.dew:26` checks Array, FixedArray, Option Some/None, Result Ok/Err, and nested Option<Array<I32>> strings. Every exact-string assertion passes for both versions on both runtimes.

### `text/show-derived-runtime.wat`

**CORRECT NEW OUTPUT. Derived Show calls reuse equivalent I32 and Point append functions. The required depth checks, field values, and text writes remain the same.**

Full review: **22 hunks**, 1,891 → 1,846 lines. Old function 64 redirects to 54 and old 65 to 61; their bodies equal those retained targets under the type/index map. Types 82–83 are removed. All **71 retained bodies**, including the enum arms and nested Wrapper formatter, match exactly after mapping; later functions and types move down two.

Source: `src/parser/derive.mbt:729` makes derived field calls to `show_append`; `std/show.dew:50` supplies the depth check. `tests/module-snapshots/text/show-derived-runtime.dew:33` checks empty structs, Point, unit/tuple/empty-struct/named enum variants, and nested generic Wrapper text. Both versions pass every string assertion on both runtimes.

### `types/derive-debug-runtime.wat`

**CORRECT NEW OUTPUT. Wrapper<I32> Debug reuses the existing equivalent I32 forwarding function. All output bytes and partial-write behavior stay the same.**

Full review: **33 hunks**, 1,976 → 1,971 lines. Old function 68 is removed; old Wrapper body 81 (new 80) calls retained function 46. Both forwarding bodies load argument 0 and call function 32. Type 87 is removed, later types and functions move down one, and all **79 retained bodies** match exactly after this map.

Source: `src/parser/derive.mbt:572` makes ordinary `debug` field calls; line 586 builds struct output. `tests/module-snapshots/types/derive-debug-runtime.dew:34` covers derived structs/enums, nested values, integer limits, float bit patterns including negative zero, Unit, escaped text/bytes, SWAR, and V128. Its unchanged JSON sets `write_limit: 3`. Both old and new produce the exact expected text on Node and Wago.

## Commands and gate results

The exact selected PATH for both full runs and the WAT runtime checks was
`/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin`.
All commands ran from `/data/workspace/wave1-fixtures`.

```sh
git -c protocol.file.allow=always submodule update --init --reference /data/workspace/dewdrop/starshine-mb starshine-mb

env PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin /usr/bin/time -p bash tools/module-snapshots/run.sh --jobs 1 --target-dir .tmp/fixture-build > docs/research/data/stdlib-fixture-fixes/before.log 2>&1

env PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin /usr/bin/time -p bash tools/module-snapshots/run.sh --jobs 2 --target-dir .tmp/fixture-build > docs/research/data/stdlib-fixture-fixes/after.log 2>&1

python3 docs/research/data/stdlib-fixture-fixes/review.py > docs/research/data/stdlib-fixture-fixes/review-after.jsonl

env PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin /usr/bin/time -p python3 docs/research/data/stdlib-fixture-fixes/check-wat.py > docs/research/data/stdlib-fixture-fixes/wat-runtime-replay.log 2>&1

git diff --check b9fcc8ea..HEAD
```

Both full runs used the pinned SDK, the default two runtimes, repeat-byte
checks, diagnostics checks, and all fixtures. There were no filters, update
flags, or reproduction bypasses. The first run used one slot, including its
cold generator build. The second used at most two warm fixture slots.

| Full run | Passed | Failed | Compiler calls | Wall seconds | Generator build seconds | Longest fixture compile seconds |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| before | 453 | 8 | 922 | 423.22 | 26.708 | 1.868 |
| after | 461 | 0 | 922 | 198.09 | 0.063 | 1.880 |

Before exit: **1**, with exactly the eight named WAT mismatches. Their fresh
full diffs equal the historical baseline bytes. After exit: **0**, with
**461/461 green and no escalations**. No compiler activity in these runs
exceeded 30 seconds. These results do not change the owner's accepted cold
build result from G0.

The first old/candidate WAT parse/validate/runtime check took **1.05 seconds**;
the saved script replay took **1.17 seconds**. Each log records every
parse/validate pair, runtime call, and Wago runner build time. All 16 WAT
modules validate and all 32 runtime checks pass in each run.

### Times for the eight affected fixtures

Each pair below is the first and repeat Dew compile, in seconds.

| Fixture | Before | After |
| --- | --- | --- |
| `collections/binary-heap-runtime` | 0.526 / 0.428 | 0.545 / 0.428 |
| `generics/bounded-function-reference-runtime-evidence` | 0.391 / 0.319 | 0.408 / 0.317 |
| `generics/generic-enum-adapter-runtime` | 0.397 / 0.317 | 0.414 / 0.312 |
| `generics/generic-erased-scalar-adapter-runtime` | 0.402 / 0.319 | 0.379 / 0.310 |
| `modules/imported-bounded-function-reference-runtime-evidence` | 0.411 / 0.320 | 0.394 / 0.327 |
| `text/show-collections-runtime` | 0.519 / 0.441 | 0.514 / 0.423 |
| `text/show-derived-runtime` | 0.492 / 0.430 | 0.518 / 0.420 |
| `types/derive-debug-runtime` | 0.538 / 0.444 | 0.516 / 0.423 |

No compiler source changed, so no native unit or compiler integration lane
was needed. Full logs are gzip files in `research/data/stdlib-fixture-fixes/`;
`results.json` gives the gate counts and timing summary. No failure was hidden.

## Atomic fixture commits

| Fixture | Commit |
| --- | --- |
| `collections/binary-heap-runtime` | `3a5b5105` |
| `generics/bounded-function-reference-runtime-evidence` | `4f0766da` |
| `generics/generic-enum-adapter-runtime` | `abeb8b2b` |
| `generics/generic-erased-scalar-adapter-runtime` | `6c792266` |
| `modules/imported-bounded-function-reference-runtime-evidence` | `89f221e9` |
| `text/show-collections-runtime` | `d4e938aa` |
| `text/show-derived-runtime` | `c5cfa1af` |
| `types/derive-debug-runtime` | `109882b4` |

## Handoff cleanup

Removed this worker's `.tmp/fixture-build`, `.tmp/fixture-review`,
`.mooncakes`, and generated `tools/module-snapshots/__pycache__`. Source and
compact evidence remain. The patched Starshine gitlink is still
`29dde5c78291a976abd5f739da920915f04fdc36`; its working tree is clean.
The global SDK is unchanged. No push occurred. Build slots are released.
