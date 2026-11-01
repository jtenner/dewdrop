# Dewdrop standard library wave 1 — final report

Date: 2026-11-01 UTC. Branch: `campaign/stdlib-wave1`.
Integration base: `b9fcc8ea`. **All 12 items LANDED. No item is BLOCKED.**
All workers finished. No open functional escalation remains. No push occurred.

The owner's G0 PASS WITH KNOWN RED ruling supersedes the old report's blocked
status. Mission A cleared all eight known WAT mismatches before item work began.
The accepted 67.88-second cold baseline was not chased. The global SDK is unchanged:
Moon `0.1.20261023`, moonc/core `0.10.17+d971670cd`, `/data/home/.moon`.
The Starshine gitlink stays `29dde5c78291a976abd5f739da920915f04fdc36`.

## Mission A: eight fixture verdicts

All eight verdicts are **CORRECT NEW OUTPUT**. Each fixture had its own commit
and source/body/type evidence. No blanket snapshot update was used.

| Fixture under `tests/module-snapshots/` | Reason | Commit |
| --- | --- | --- |
| `collections/binary-heap-runtime.wat` | Reuses the equivalent natural-compare body; heap behavior stays the same. | `3a5b5105` |
| `generics/bounded-function-reference-runtime-evidence.wat` | Concrete callbacks use existing exact-target singletons; capturing generic paths remain. | `4f0766da` |
| `generics/generic-enum-adapter-runtime.wat` | The singleton selects the exact enum adapter and preserves payload conversions. | `abeb8b2b` |
| `generics/generic-erased-scalar-adapter-runtime.wat` | Typed adapters box, call erased identity, and unbox the same carrier. | `6c792266` |
| `modules/imported-bounded-function-reference-runtime-evidence.wat` | The concrete imported callback uses its singleton; the evidence-capturing path remains. | `89f221e9` |
| `text/show-collections-runtime.wat` | Reuses an equivalent append body, with the same depth checks and text. | `d4e938aa` |
| `text/show-derived-runtime.wat` | Reuses equivalent I32 and Point append bodies. | `c5cfa1af` |
| `types/derive-debug-runtime.wat` | Reuses an equivalent I32 forwarding body; exact output and partial writes remain. | `109882b4` |

Mission A landed at `8c3b047f`: **461/461 snapshots passed**, Node and Wago,
198.09 seconds. All 16 old/new WAT modules validated; all 32 runtime checks passed.
Full verdicts, line evidence, hashes and diffs:
[fixture report](stdlib-fixture-fixes-2026-11-01.md).

## Mission B: item landings

Every row is **LANDED**, with zero final focused failures. “Focused” is the
worker's Dew test count; it can include existing tests or a temporary oracle.
“New” counts only permanent new public tests. Combined counts are the actual
full standard runner at that landing; every row also passed **41 private tests**.
Worker heads retain test, implementation and evidence checkpoints.

| Item | Status | Worker head | Integration head | Focused / new | Combined public |
| --- | --- | --- | --- | ---: | ---: |
| [01 — Wide decimal parsing](research/stdlib-wave1-01.md) | LANDED | `4cca698a` | `5bfc21a0` | 8 / 4 | 365 |
| [02 — ASCII trim views](research/stdlib-wave1-02.md) | LANDED | `2a8c12bf` | `1d970ba3` | 6 / 6 | 361 |
| [03 — Text split and lines](research/stdlib-wave1-03.md) | LANDED | `3c02fe7c` | `f79a9405` | 8 / 8 | 403 |
| [04 — Relative path parts](research/stdlib-wave1-04.md) | LANDED | `69c5c904` | `8aad3967` | 16 / 8 | 387 |
| [05 — Hex bytes](research/stdlib-wave1-05.md) | LANDED | `55727848` | `8dc8bdf4` | 5 / 5 | 379 |
| [06 — Binary cursor](research/stdlib-wave1-06.md) | LANDED | `1183df23` | `6cf258ea` | 8 / 8 | 411 |
| [07 — Incremental SHA-256](research/stdlib-wave1-07.md) | LANDED | `dd7360c0` | `50074aa0` | 5 / 4 | 391 |
| [08 — Iterator adapters](research/stdlib-wave1-08.md) | LANDED | `4be367c9` | `4a35c1d7` | 9 / 9 | 374 |
| [09 — Sorted-array bounds](research/stdlib-wave1-09.md) | LANDED | `b02d3d35` | `5859c325` | 4 / 4 | 395 |
| [10 — Buffered delimiter reads](research/stdlib-wave1-10.md) | LANDED | `f193efc0` | `bba34a83` | 23 / 14 | 425 |
| [11 — Process writers](research/stdlib-wave1-11.md) | LANDED | `25197246` | `c4f71d18` | 10 / 10 | 435 |
| [12 — Directory pages](research/stdlib-wave1-12.md) | LANDED | `9c88a983` | `1f0b7059` | 10 / 10 | 445 |

The final count is **355 + 90 = 445 public tests**. The eight existing public
B-tree provider tests stay inside that count; the 41 private tests are separate.
The U64/I64 worker also ran 528 Node integer checks. Hex ran 64 Node-oracle cases.
SHA tests cover the CAVS messages, chunk splits and long streams. Iterator tests
cover callback order, live scalar/reference callbacks, no intermediate arrays
and zero host imports. Sorted search uses a linear oracle and comparison bounds.
Process tests cover partial/invalid writes and exact stdout/stderr bytes on WASI.
Directory tests include 70 host checks and a real tree: **12 opens, 12 closes**.
Each linked item note contains its exact files, commands, times and memory data.

The new modules have canonical slots 81–85 and source-selection bits
128/256/512/1024/2048. The final wildcard has **85 modules, 96 source paths,
and 82 root dependencies**. Import closure, wildcard facts, generated exports
and bootstrap/on-disk equality checks pass. Identity mirrors come from the
version-1 identity registry. All formats and codecs stay at version 1.
No standard-module path, declaration ordinal or source spelling selects a
runtime algorithm. New algorithms are Dew functions; host operations use foreign
declarations. No B-tree source or test file changed.

## Issues found and fixed during combined checks

- Hex and UTF-8 tests opened two `decode` functions in the shared test module.
  Hex tests now use `@hex`. The stream SHA tests also gained distinct helper
  names. Neither fix changes test values or library behavior.
- Sorted search appends six functions and six natural-order methods. The
  Array callable-count fact changed from 146 to 158 in `0b877965`; all old
  identity assertions remain.
- A reduced test PATH hid `rg`. The old native runner returned zero while
  omitting file groups. That run is **excluded**. `1caf8f48` adds a required-tool
  check, checks the search exit status, and rejects an empty file list. The full
  native rerun below covers all 304 groups.
- A real wildcard compiler assertion exposed unused function references whose
  named result types had been excluded by demand planning. `daaf2fe1` (worker
  `f4a63e6d`) makes callback collection use the same reachable declarations.
  Two ordinary user-module tests prove the cause and fix. Assertions remain
  enabled; no standard-module special case was added. The worker passed 113
  focused checks and the complete standard runner.
- The library additions changed three code-point source records and temporarily
  added three unused iterator callback types. Those four WAT files had individual
  reviews at `07f19daf`. After the compiler fix, `a1eb11ed` restores only the
  iterator fixture: its full WAT is byte-for-byte equal to the pre-wave file,
  including all 47 bodies and facts. `8313a6aa` records two correct new wildcard
  warnings from hex's dead trap fallback and the binary error's one-case Eq
  derive; wildcard WAT and runtime output are unchanged.

Details: [final fixture review](stdlib-wave1-final-fixtures-2026-11-01.md),
[compiler fix](research/stdlib-wave1-wildcard-fix.md),
[native runner correction](research/stdlib-wave1-native-runner.md).
The earlier wildcard escalation is resolved.

## Final full gates

Compiler/library code tested: `8313a6aa`. Final expected WAT: `a1eb11ed`.
Later changes are documentation and evidence only. Final gates use the pinned
SDK's default C settings (`MOON_CC` and `CC` unset) and preserve the inherited
PATH. No filter or reproduction bypass was used in the final snapshot run.

| Command | Result | Wall seconds |
| --- | --- | ---: |
| `bash tools/test-native.sh` | 1,931 passed, 0 failed; 304 groups | 654.60 |
| `bash tools/test-integration-native.sh` | 278 passed, 0 failed; all 19 files | 85.53 |
| `bash tools/dew-test/run.sh` | 445 public + 41 private passed; 4,191 operation checks in 43 scripts; repeat bytes identical | 144.69 |
| `bash tools/test-stress-native.sh` | 15 passed, 0 failed | 0.36 |
| `bash tools/check-generated.sh` | Passed, including native bootstrap tests and CLI fixtures | 59.24 |
| `bash tools/module-snapshots/run.sh --jobs 2 --target-dir _build` | 461/461 passed on Node and Wago | 235.53 |

The final snapshot lane measured **922 compiler calls**, maximum 2.150 seconds;
none exceeded 30 seconds. Stress was run because the compiler reachability code
changed. The pinned Starshine source and passes were unchanged, so its full
separate suite was not rerun.

Full final and failed-attempt logs plus machine-readable results:
[final evidence](research/data/stdlib-wave1/final/results.json).
The invalid native setup run, the one-count native failure and the intermediate
snapshot failures are kept as separate compressed logs. They are not counted as
passing gates. Concurrent snapshot timing lines are parsed without line anchors
so all 922 calls are counted.

## Remaining performance issue

The cold standard-test compiler invocation took **79.634 seconds**, including
native C build, above the repository's 30-second activity limit. The runner
reports it as a performance issue. The 59.24-second generated-check aggregate
is also retained plainly. The owner-accepted G0 cold time was 67.88 seconds.
No time limit was bypassed or global SDK setting changed. Earlier item builds
used process-local low-memory Clang flags; their times and failed attempts stay
in the item notes. There is **no open functional blocker**.

## Worker control and cleanup

Group A was dispatched first; Group B reused free slots. Item 03 started only
after 01 landed. Every worker used a private branch/worktree and
`codex exec -s danger-full-access`. Eight active sessions caused memory pressure
during the first C build; workers were queued and resumed with their commits
and drafts intact. Build admission used one cold build and at most two warm
jobs. A canceled worker lock wait briefly started a build without the lock;
its processes were stopped before a test completed, excluded from evidence,
and the lock-failure guard was fixed.

All 12 item workers and both fixture/compiler follow-ups finished. All commits
are local. Completed worker worktrees, native output, Dew caches, temporary
Wasm/host probes and generated Python caches were removed after validation.
Compact source fixtures, scripts, hashes and logs remain. The integration
working tree is clean after this report commit. Nothing was pushed to origin.
