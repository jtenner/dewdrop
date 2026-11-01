# Wave 1 final fixture review

Base: `1caf8f48`. Branch: `worker/wave1-final-fixtures`. Date: 2026-11-01.
Mission A at `8c3b047f` stays intact. Only four new expected WAT files change.
No library, compiler, SDK, global tool, B-tree, or Starshine gitlink changes.
No push. The consolidated campaign report is unchanged.

## Verdicts

All four verdicts are **CORRECT NEW OUTPUT**.

| Fixture under `tests/module-snapshots/` | Full review | Reason |
| --- | --- | --- |
| `collections/iter-combinators-runtime.wat` | 24 hunks; 1,408 → 1,411 lines; 47 function bodies checked exactly | Three ordinary callback types are added. All old bodies and all other sections match under the checked type map. |
| `text/code-points-exhausted.wat` | One hunk; 679 lines; all 3,014 custom payload bytes decoded | Only 18 source record fields change. All code, types, calls, exports, globals, and data stay the same. |
| `text/code-points-invalid-view-trap.wat` | One hunk; 789 lines; all 3,649 custom payload bytes decoded | Only 18 source record fields change. All other bytes stay the same. |
| `text/code-points-runtime.wat` | One hunk; 1,224 lines; all 7,219 custom payload bytes decoded | Only 36 source record fields change. All other bytes stay the same. |

The iterator map is old 0–71 unchanged, 72–74 +2, and 75 onward +3.
New types 72, 73, and 77 are `(eqref) -> (ref 8)`, `(eqref) -> eqref`,
and `(eqref, eqref) -> (ref 8)`. Type 8 is the erased Option carrier.
`std/iter.dew:81` adds ordinary `iter_next`; `:85–117` add wrappers with
`pull`, `callback`, and `predicate` function fields. `:125` and `:137` add
map and filter constructors. These are item 08 additions, before the existing
fixture's function signatures. `src/semantic/program_physical_link.mbt:999–1073`
interns source function types and function signatures. The type schedule at
`src/semantic/program_physical_type_schedule.mbt:143–180` emits their slots.

All 47 old function indexes and bodies match the new ones exactly after the
map, including each `call_ref`, `ref.func`, direct call, function header,
local type, heap type, and struct operand. Every old top-level type is also
checked. The non-type sections are checked as a whole under the same map.
The full 5,887-byte facts payload has exactly 46 changed fields: six signature
indexes and 40 heap/allocation type indexes, each +3. No function targets,
effects, source records, constants, or instruction offsets change.
`src/backend/starshine_compiler_facts.mbt:1580–1625` keys signature facts by
final signature index; body scans attach the final heap/allocation types.
The fixture at `tests/module-snapshots/collections/iter-combinators-runtime.dew:32`
checks for-each order, fold sum, any/all, and find, then writes the exact
`collections:iter-combinators` output.

For all three text files, each changed declaration ID and body ID increases
by five. Each source byte offset increases by 2,214. Item 01 inserts exactly
five functions at `std/text.dew:88–167`: the wide magnitude parser, U64 and
I64 parsers, and two conversion helpers. Existing code-point declarations
move down 82 lines. The checked old/new source byte offsets are:

| Function | Old offset | New offset | New source line |
| --- | ---: | ---: | ---: |
| `string_code_points` | 4,649 | 6,863 | `std/text.dew:256` |
| `string_view_code_points` | 4,788 | 7,002 | `std/text.dew:263` |
| `StringCodePoints.next` | 7,762 | 9,976 | `std/text.dew:359` |
| `StringViewCodePoints.next` | 7,975 | 10,189 | `std/text.dew:369` |

Exhausted uses the first and third rows; invalid-view uses the second and
fourth; runtime uses all four. The constructors have two records each;
`next` has four each. `src/backend/starshine_compiler_facts.mbt:209–229`
sets provenance from the module, declaration, defined body, and source offset.
`starshine-mb/src/binary/compiler_facts_encode.mbt:204` writes these source
fields. Thus the new values point to the same functions in the new source.
No diagnostic or runtime instruction is changed.

## Evidence and replay

All evidence is in `docs/research/data/stdlib-wave1-final-fixtures/`.
`review.py` extracts each unified diff by its strict old/new hunk counts,
checks every old context/removal line against `1caf8f48`, and replays it.
Interleaved timing lines are excluded by name only while reading hunks.
It checks the full bodies and sections; it does not run Mission A's old loop.
`review.json` records full old/new/diff SHA-256 hashes and every changed
custom payload byte. Each `<fixture>.diff.gz` preserves the full diff.
Each `<fixture>.new.wat.gz` preserves the independently replayed candidate.

`facts.py` decodes the full v1 payload using the pinned encoder's field order
and declared field types. Unknown forms fail with their type, path, and offset.
It requires exact end of input. `facts.json` lists every changed leaf field;
the old/new decoded full records are saved as `*.facts.json.gz`.
`source-changes.diff.gz` preserves item 01/08 source evidence.
`before.log.gz` preserves the completed owner run, including its full failure.
No snapshot update flag was used. Candidates were written one at a time only
after their full diff and source review.

## Gates

The old/new WAT gate passed: eight modules parse and validate, and all
16 Node/Wago runs match the unchanged JSON exactly. Wall time: 0.91 seconds;
Wago runner build: 0.512 seconds. The iterator writes
`["collections:iter-combinators"]`; exhausted and runtime return `[]`;
invalid-view returns `{"trap":"unreachable","stdout":[]}` on both runtimes
for both versions. `wat-runtime.log` records each call and time.
Review replay took 2.62 seconds; complete facts decode took 0.10 seconds.

**READY for fixture merge, with one named compiler escalation.** The full
unfiltered worker run checked all 461 fixtures: **460 pass, one fail**, exit 1,
288.25 seconds. There are no WAT mismatches. The only failure is the same
`modules/std-wildcard-runtime` assertion, saved with worker paths in
`after-escalation.txt`. There were 917 logged fixture compiler calls; the cold
generator build took 23.454 seconds; the longest fixture compile took
2.775 seconds. No worker compiler activity exceeded 30 seconds.
`after-summary.json` and `after.log.gz` preserve the counts and full run.

The completed owner baseline is 456 pass, five
fail, exit 1, 294.28 seconds. It checked 461 fixtures, logged 917 compiler
calls, built the generator in 20.710 seconds, and its longest fixture compile
was 2.645 seconds. `before-summary.json` holds these counts. Four failures are these expected WAT changes.
The fifth is a real compiler assertion, preserved in `escalation.txt`:
`tests/module-snapshots/modules/std-wildcard-runtime.dew:1` reaches
`src/semantic/program_physical_type_invariants.mbt:636`, error code 503,
phase 5, module 4294901807, detail 227633266689. This is outside this
fixture-only review. Its expected output stays intact and the gate stays red.

Commands run from this worktree:

```sh
python3 docs/research/data/stdlib-wave1-final-fixtures/review.py
python3 docs/research/data/stdlib-wave1-final-fixtures/facts.py
flock /data/workspace/wave1-control/build.lock bash docs/research/data/stdlib-wave1-final-fixtures/gates.sh
```

The gate script uses its own `_build`, the current pinned SDK, the required
clang wrapper with flags after arguments, adjacent `ar`, and a local `moon`
launcher that sets build jobs to one. The full unfiltered snapshot run uses
`--jobs 2`, normal Node and Wago, and normal repeat-byte checks. No library
or compiler source change means no std repeat is required. Cleanup runs on
EXIT before the exclusive build lock is released.

## Final state

The four fixture changes and this evidence form one bounded commit. No source
fix was needed. The one compiler assertion requires a separate compiler fix;
its failure was neither caught as success nor replaced with expected output.
The normal snapshot command returned exit 1.

`mission-a-preserved.json` checks all eight Mission A WAT files byte for byte
against `8c3b047f`. `git diff --check` passes. The gate EXIT hook removed this
worker's `_build`, `.mooncakes`, `.dew/cache`, temporary runtime Wasm, and
snapshot Python cache before releasing the lock. Starshine remains clean at
`29dde5c78291a976abd5f739da920915f04fdc36`. The global SDK remains unchanged.

### Full expected-file hashes

`tests/module-snapshots/collections/iter-combinators-runtime.wat`

- Old SHA-256: `736550654925699f88754d7e5602e2fbab38de6a6ade9412af549a2c823a0fea`
- New SHA-256: `a4e653a28d1ca1822bf6fbe6bc95f7205f00b5e7e9f98800775f702680a0e096`

`tests/module-snapshots/text/code-points-exhausted.wat`

- Old SHA-256: `5998ec1e6fde40b8fe69f541a1dcc9226eb61f9388a37a8aabb874a0683461d1`
- New SHA-256: `6cde403c309ab103f8b7e1443e59282e5091dad7c34508b196bb4543c1a09508`

`tests/module-snapshots/text/code-points-invalid-view-trap.wat`

- Old SHA-256: `30617eb4c30c3f86bbdd82c7a2f39256620d0f44adaebbd07b89f6fd4e645fbc`
- New SHA-256: `f6457d5e0d6c388c8ac1ee5fc08dc0f3ec70554ec80682d0551e4ceb907a4abe`

`tests/module-snapshots/text/code-points-runtime.wat`

- Old SHA-256: `17c5dd62cb831162bbd1b7e328af3796a01850f48257b22dca18ff31a273c681`
- New SHA-256: `3116484d7281b17d76698cecb857cfc7d1da7739bb27f1ae7e45932912837c6e`

