# Wave 1 item 03: text split and lines

Base: `4a35c1d75d434056c5efee34aec4ea4e9d171e29`.
Test checkpoint: six new tests; not run at this checkpoint. The API is absent.

Contract: `StringView.split(delimiter)` returns a lazy `Iter<StringView>`.
Matches do not overlap. Leading, repeated and trailing delimiters yield empty
fields. Empty source yields one empty field. Empty delimiter yields the source
once (also for empty source). `lines()` splits on LF and removes a CR only
immediately before that LF. Lone CR stays. Final LF yields a final empty line.
Both return views of the source; `compact()` makes an explicit independent copy.
Exhausted iterators keep returning None. Iterator aliases share progress.

Plan: KMP prefix table, O(delimiter bytes) state, no source scan on construction,
one source byte read per scan step, at most twice as many search comparisons as
source bytes. Source scan and comparison counters give test evidence.
No compiler changes, new builtins, module slots, or B-tree edits are needed.

## Baseline and first attempt

Owner G0 is PASS WITH KNOWN RED; SDK is `/data/home/.moon` (moon
0.1.20261023, core/moonc 0.10.17+d971670cd). The given baseline is 355 public
std tests, 41 separate private B-tree tests, 42 builtin traps and 4121 operation
probes. This item does not recount the eight provider tests. Mission A reviewed
the eight historical snapshots at the dependency checkpoint; none are changed.
The accepted 67.88 s cold baseline is outside this item.

`flock /data/workspace/wave1-control/build.lock bash .tmp/gate.sh` attempt 1:
focused compile exited 1 in **218.95 s**, peak RSS **4,171,532 KiB**.
This is a visible >30 s performance bug. The initial local Clang wrapper put
`-g0` before Moon's `-g`, so debug data stayed enabled. Later runs put
`-fbracket-depth=4096 -g0 -O0` last and set process-local `MOON_CC`.
The SDK is unchanged. Compiler diagnostics rejected numeric range loop syntax
at `std/tests/text_split_test.dew:16`, `:85`, and `std/text.dew:392`, with
follow-on unknown helper errors. No tests ran (0 passed, 0 runtime failures;
compile gate failed). All numeric ranges are now supported functional loops.
The full first log is `data/stdlib-wave1-03/attempt-1.log.gz`.

Attempt 2 used the corrected flags: compile exited 1 in **28.33 s**, peak
RSS **1,080,348 KiB**. It found one more syntax error: the prefix fallback used
a Boolean `while` body at `std/text.dew:396`; Dew requires pattern arms.
That loop now uses pattern arms too. Again no tests ran. Full diagnostics:
`data/stdlib-wave1-03/attempt-2.log.gz`. No gate failure is suppressed.

## Implementation checkpoint

The API and generated mirror are now present. Eight focused tests cover the
contract above, late prefix fallback, a multiscalar delimiter, alias progress,
and a scan bound. `iter()` returns the same iterator for ordinary `for` loops.
The implementation uses existing StringView, FixedArray and Iter rules only.
Each `next()` moves forward or ends; prefix fallback strictly reduces the
matched width. A matched delimiter is consumed in full, so matches do not overlap.
Counters are stored once per returned field. `source_scans()` counts forward
search bytes, excluding the CR check in lines and delimiter table setup.

Production consumer and six production benchmark cases are in
`data/stdlib-wave1-03/`. They use no test module or host imports. The benchmark
checks exact total field bytes against a simple prefix/dense input oracle.
At this checkpoint, the third gate was queued. It was not yet a passing handoff.

## Final gate: READY candidate

Test checkpoint: `6aad3f70`. Implementation checkpoint: `646a588c`.
The final gate exited **0**. New focused tests: **8 passed, 0 failed**.
Generator check: **1 passed, 0 failed**. Production consumer compile and run:
**1 passed, 0 failed**, no host imports, no output and no trap. Production
benchmark cases: **6 passed, 0 failed**, with 3,120 checked main calls.
No unresolved blocker. This is a review candidate, not a landed item.

Reproduce from this worktree with the same SDK:

```sh
mkdir -p .tmp
cp docs/research/data/stdlib-wave1-03/gate.sh .tmp/gate.sh
flock /data/workspace/wave1-control/build.lock bash .tmp/gate.sh
```

The saved script contains the exact timed compiler/runtime commands, local
Clang setup, generator `--check`, and cleanup trap. It sets `MOON_CC` and uses
`-j1`; the adjacent `llvm-ar` symlink points to `/usr/bin/ar`. Full final log:
`data/stdlib-wave1-03/gate.log.gz`. Machine-readable results:
`data/stdlib-wave1-03/results.json`. Lock wait is outside the command timings.

| Final command | Wall seconds | Peak RSS KiB |
| --- | ---: | ---: |
| Focused `moon run --target native -j1 src/dew_test_gen` | 27.87 | 1,078,828 |
| Focused Node tests | 0.03 | 50,640 |
| `python3 tools/generate_text_iteration_std.py --check` | 0.02 | 12,096 |
| Production `moon run --target native -j1 src/module_snapshot_gen` | 20.45 | 929,060 |
| Production Node consumer | 0.02 | 46,280 |
| Python compile/runtime benchmark gate | 4.28 | 73,648 |

Each of the six benchmark compiles took 0.529–0.578 s. No final compiler
activity exceeded 30 s. Attempt 1's 218.95 s activity remains a recorded
performance bug; it is not relabeled as the accepted 67.88 s baseline.

### Runtime and memory

Inputs use either repeated `a` bytes with missing delimiter `aaaaab` (prefix
fallback), or repeated `a,` with delimiter `,` (many returned fields). Each
production case checks exact total field bytes against the simple input oracle,
exact source scans equal to N, and search comparisons at most 2N. The focused
suite also checks exact individual fields and late successful prefix fallback.
There is no source scan at construction or `iter()`. Calls after exhaustion
perform no scan. The benchmark uses 100 warmups and 21 samples of 20 calls.

| Input bytes N | Prefix median microseconds | Dense median microseconds | Source scans in each case | Comparison bound |
| --- | ---: | ---: | ---: | ---: |
| 1,024 | 5.431 | 15.822 | 1,024 | 2,048 |
| 8,192 | 36.924 | 114.876 | 8,192 | 16,384 |
| 65,536 | 276.213 | 836.996 | 65,536 | 131,072 |

The counters reject repeated source scans and quadratic prefix search. Times
support linear scaling. These are new APIs; no previous API speedup is claimed.

Iterator array payload is `4 * delimiter.byte_length() + 16` bytes: one KMP
prefix table plus four U32 state slots, independent of source length and field
count. That is 40 bytes for prefix cases and 20 for dense cases, excluding
object headers, retained source/delimiter views, and temporary result views.
The iterator does not retain prior fields or copy source bytes. Each result
calls the existing `StringView.view`; `compact()` is the explicit copy path.
Line iteration uses a one-byte LF delimiter and the same bounded state.

With explicit GC before and after 420 measured calls, V8 heap change was
11,624–12,392 bytes across all sizes. Absolute post-GC heap was
4,171,408–4,172,112 bytes. This is process heap evidence, not an exact WasmGC
object-size measurement. Peak benchmark process RSS was 73,648 KiB; individual
RSS samples and Wasm sizes are in `results.json`. V8 RSS includes retained
arenas and is not the live iterator payload bound.

### Scope and cleanup

No compiler semantic/emission rules, runtime builtins, module identities,
registries, SDK files, B-tree files, or historical snapshots changed. No held
fixes were imported. No push occurred. No native compiler test lane was needed:
this item changes Dew library algorithms and their generated source mirror.
The orchestrator owns the complete std and native/integration landing gates;
this worker ran the focused item gates above and did not claim a fresh full
baseline. Build outputs are private to this tree.

The trap removed `_build`, `.mooncakes`, `.dew/cache`, all generated Wasm/WAT,
and benchmark source harnesses before releasing the build lock. Only small
reproducible source fixtures, scripts, results and compressed logs remain.

Exact changed files relative to the dependency checkpoint:

- `std/text.dew`
- `std/tests/text_split_test.dew`
- `std/README.md`
- `src/standard_sources/standard_text_iteration_sources.mbt`
- `docs/research/stdlib-wave1-03.md`
- `docs/research/data/stdlib-wave1-03/attempt-1.log.gz`
- `docs/research/data/stdlib-wave1-03/attempt-2.log.gz`
- `docs/research/data/stdlib-wave1-03/gate.log.gz`
- `docs/research/data/stdlib-wave1-03/gate.sh`
- `docs/research/data/stdlib-wave1-03/consumer.dew`
- `docs/research/data/stdlib-wave1-03/benchmark.py`
- `docs/research/data/stdlib-wave1-03/benchmark.mjs`
- `docs/research/data/stdlib-wave1-03/results.json`

## Combined landing gate

Full `bash tools/dew-test/run.sh` exited 0 in 170.30 s:
403 public tests (395 prior + 8 permanent new tests), 41 private
tests, builtin traps, repeat-byte check, and all 42 operation check scripts
passed. `DEW_NATIVE_TEST_PACKAGES=standard_loader bash tools/test-native.sh`
passed 31/31 tests in 14.57 s. Process-local Clang uses trailing
-g0 -O0 and bracket-depth 4096; the pinned SDK is unchanged. Compiler calls
over 30 s remain visible in the full logs. Build output was removed.
Logs: `data/stdlib-wave1/landing-03-{std,native}.log.gz`.
