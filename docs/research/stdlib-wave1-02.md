# Wave 1 item 02: ASCII trim views

Dependency: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Test checkpoint: five new tests for six exact ASCII whitespace bytes,
all 128 ASCII byte values, empty/all-whitespace text, interior whitespace,
NUL, non-ASCII spaces, UTF-8 boundaries, and nonzero view starts.
The API contract and example are in `std/README.md`.
The tests precede implementation; the trim methods do not yet exist.
No compiler command has run at this checkpoint. Gates and timings follow.

## Implementation checkpoint

Six new tests now include empty nonzero-start and all-whitespace views.
The six methods use ordinary Dew byte scans. `trim_ascii` composes the
start and end scans. String entry points first make a full shared view.
No builtin, compiler rule, module identity, or B-tree file changes.

For a valid UTF-8 view, every removed byte is below 128 and is therefore
a complete one-byte scalar. A lead byte or continuation byte is at least
128, so scanning stops before it. The end scan checks `index > 0` before
subtracting one. The start scan checks `index < length` before reading.
The existing `string_view_range` checks the resulting scalar boundaries.

The scan uses a fixed number of U32 locals. Existing `bytes_view` stores
`source.chunks` with new start/length fields; it does not copy payload.
Each one-sided view trim creates one range record; both-sided trim creates
two. String convenience adds one full-view record. Payload allocation is
zero; range-record use is O(1). A small result retains its source buffer.
Runtime heap measurements include GC/JIT noise and are not allocation counts.

First locked gate: generator check passed (0.02 s, 12,312 KiB peak RSS).
Native test-generator build failed before Dew tests ran: C compiler `cc1`
was killed. Elapsed 92.83 s, peak RSS 2,490,244 KiB. This exceeds 30 s
and is a visible compiler performance failure, beyond the accepted 67.88 s
cold baseline. Retry uses process-local `MOON_CC=/usr/bin/clang` and `-j 1`;
there is no SDK change. Full initial log is retained locally in `.tmp/gates.log`.
Gates are pending at this implementation checkpoint.

## Final gates: PASS

Checkpoints: tests/docs `968caab0`; implementation/mirror `9af13d8f`.
The final evidence commit fixes the two inline `break` statements to use
Dew's required newlines. The prior parser failure is retained in
`stdlib-wave1-02/build-attempts.log`. Its build took 27.93 s and
1,076,656 KiB peak RSS; no tests ran in that attempt. The earlier direct
Clang attempt took 21.63 s and 866,528 KiB and failed on its default
256-bracket limit in generated C (`starshine_v128_builtins.mbt:533`).
These build setup failures are resolved by the local wrapper in `gates.sh`.

Run from `/data/workspace/wave1-item-02`:

```sh
flock /data/workspace/wave1-control/build.lock bash docs/research/stdlib-wave1-02/gates.sh > .tmp/final-gates.log 2>&1
git diff --check
```

The script records each exact command with `/usr/bin/time -v`. It sets
`MOON_CC` to a private Clang wrapper with `-fbracket-depth=4096 -g0 -O0`
and uses `moon run -j 1 --target native`. This changes only the compiler
process environment. It preserves full logs in `.tmp`; compact result
lines are saved in `stdlib-wave1-02/results.log`.

| Gate | Wall seconds | Peak RSS KiB | Result |
| --- | ---: | ---: | --- |
| `python3 tools/generate_string_std.py --check` | 0.03 | 12,128 | pass |
| focused `src/dew_test_gen` compile, including cold native build | 27.92 | 1,077,276 | pass |
| focused Node test run | 0.03 | 46,188 | 6 passed, 0 failed, 6 new |
| `src/module_snapshot_gen` production consumer compile | 19.57 | 930,852 | pass |
| Node consumer checks and scan benchmark | 0.77 | 58,728 | 5 exports passed |

The production consumer uses ordinary `app.trim` imports and all three
String entry points, plus both-sided nonzero-start views at three sizes.
It needs no host imports. All six focused tests have 164 assertions.
There are no unresolved source or compiler blockers. The 92.83 s initial
GCC build remains a recorded performance failure; final compiler commands
are below 30 s. No baseline snapshot was changed.

Owner G0 remains the accepted baseline: 355 public tests, 41 separate
private B-tree tests, 42 builtin traps, and 4,121 operation probes.
This worker ran six focused tests only; it does not count private/provider
cases again or claim a fresh full-suite result. No compiler source changed,
so native compiler unit/integration lanes are left to combined landing.

## Runtime and memory

`bench.py` generates the production source. `bench.mjs` loads and warms it
before timing. Seven batches of 10,000 calls measure scan plus view-header
creation, with compilation and Wasm initialization outside the timed loop.
Each result is checked against the expected six UTF-8 bytes (`λ🌍`).
This is a new API; no before/after speedup is claimed.

| Removed ASCII bytes | Median ns/call | Post-GC heap delta bytes | RSS delta bytes |
| ---: | ---: | ---: | ---: |
| 32 | 78.609 | -3,144 | 0 |
| 512 | 622.824 | 9,560 | 561,152 |
| 8,192 | 8,293.008 | 16 | 0 |

The scan visits each removed byte once, plus at most one stopping byte per
side. This gives linear worst-case work and constant scan state. Measurements
agree with linear growth after fixed call/view cost. Heap/RSS deltas include
runtime noise, not exact object sizes. Source inspection of
`std/text_runtime.dew` (`bytes_view` and `string_view_range`) proves shared
payload and bounded range-record allocation as described above.

The EXIT trap removed `_build`, `.mooncakes`, `.dew/cache`, generated Wasm,
and the generated consumer source before releasing the lock. No push,
SDK change, B-tree edit, new module, or shared registry change occurred.
Status: READY for review; not landed.

## Combined landing gate

Integration tree: item 02 on Mission A head `8c3b047f`. Full
`bash tools/dew-test/run.sh` exited 0 in 161.14 s: public 361 passed
(355 baseline + 6), private B-tree 41 passed, builtin traps and all
42 operation check scripts passed. Repeat-compilation bytes match.
The first compile took 31.344 s and the private B-tree compile took
63.239 s; both are visible compiler performance issues. Other compiler
calls stayed below 30 s. Process-local MOON_CC used Clang with -g0 -O0
and bracket-depth 4096; no SDK file changed. Initial local wrapper setup
failed to find adjacent ar before any tests; adding a local ar symlink fixed it.
`DEW_NATIVE_TEST_PACKAGES=standard_sources bash tools/test-native.sh`
exited 0 in 0.70 s but contains zero tests; no test coverage is claimed for it.
Final campaign native lanes cover compiler loading rules. Full compressed
logs: `data/stdlib-wave1/landing-02-{std,native}.log.gz`. Build output removed.
