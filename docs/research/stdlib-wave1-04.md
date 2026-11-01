# Wave 1 item 04: relative path parts

Base: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Branch: `worker/wave1-item-04`. Sole worker. No B-tree edits.

Test checkpoint `7662bf3f`: seven new tests in `std/tests/path_parts_test.dew` define
filename, optional validated parent, stem, and optional extension. Last dot
wins except at filename byte zero. Trailing dots give an empty extension.
A single component has no parent. See `std/README.md` for the API and example.
Cases cover UTF-8, repeated dots, dotfiles, exact 4096 bytes, overflow and
escape checks. Existing host escape tests are unchanged.

That checkpoint was red by inspection: the four methods did not yet exist in
`std/path.dew`. No compiler command ran at that checkpoint.

Baseline: owner G0 PASS WITH KNOWN RED; 355 public std tests, 41 separate
private B-tree tests, 42 traps and 4121 operation probes. Eight public provider
tests are not counted again. Mission A reviewed the eight snapshot differences
at this dependency checkpoint. No snapshots will change. SDK remains
`/data/home/.moon`, Moon 0.1.20261023, core 0.10.17+d971670cd.

## Implementation and resource bound

The implementation scans backward for the final slash. A second backward
scan finds the final dot strictly after filename byte zero. It does not build
a segment array, normalize a path, add a builtin, or change import rules.
The parent wraps a nonempty validated prefix; it cannot create the workspace
root. Slash and dot bytes cannot occur inside a UTF-8 multibyte sequence.

Each query uses O(n) time, O(1) scan state, and at most n result text bytes
(n <= 4096). Absent parent/extension does not copy text. Present strings use
the existing `String.slice` copy rules. The bound excludes fixed builder,
string and option headers. No whole path split or segment array is allocated.
Existing validation and join code are unchanged.

The production probes use 64, 512 and 4096 byte dot-free single-component
paths. Each call validates the input and calls all four queries; the scans
therefore take their full path. The expected result is the input for filename
and stem, and None for parent and extension. Timing includes validation and
result copies; it is not a claim of query-only cost or speedup. The Node
runner checks every call, records seven batches of 10,000 calls after 2,000
warmups, and records heap and RSS before/after explicit GC. These process
memory values are observations, not a bound on Wasm GC allocation.

An eighth test added with the implementation checks a 4096-byte UTF-8
single-component path (2048 two-byte characters) and byte overflow. It also
checks absent parent/extension at the maximum length.

## First gate attempt (setup failure)

The first locked gate did not compile Dew. Moon derives the native archiver
path from the `MOON_CC` wrapper name and could not find `.tmp/moon-ar`.
Focused compile exited 255 in 0.10 s (69976 KiB peak RSS). Native tests
exited 1 in 0.05 s. Consumer and the three benchmark compiles each exited
255 in 0.04 s. Generator check passed in 0.04 s. Full diagnostics are in
`data/stdlib-wave1-04/attempt-1.log`. Build files were removed by the exit trap.
A local `.tmp/moon-ar` symlink to `/usr/bin/ar` fixes this setup error; no SDK
file changes are needed. This was not a Dew compiler or source failure.

The second locked attempt reached C compilation but Clang's default
256-level bracket limit rejected the existing generated compiler body at
`src/backend/starshine_v128_builtins.mbt:533`. Focused cold build: 20.61 s,
866736 KiB peak RSS, exit 1. Consumer cold build: 7.11 s, 1312100 KiB, exit 1.
Benchmark builds: 1.85 / 1.84 / 1.84 s, exit 1. Generator check passed in
0.03 s; native standard_sources compile check passed in 1.94 s (0 tests).
Full output is saved in `data/stdlib-wave1-04/attempt-2.log.gz`.
The local wrapper now adds `-fbracket-depth=4096`. No source or global SDK
change is needed. Neither failed attempt exceeded 30 seconds per command.

The third locked attempt built the compiler. Focused test parsing then failed
at `std/tests/path_parts_test.dew:62` and `:89`: a unit loop must use
`break ()`, not a bare `break`. Production consumer and probes also lacked
`open dew.std.string` for String methods. These fixture errors were fixed;
no semantic/emission rule was changed. Full output is in
`data/stdlib-wave1-04/attempt-3.log.gz`.

**PERFORMANCE BUG:** the cold focused build plus diagnostics took **32.60 s**,
1076852 KiB peak RSS. This is above 30 s and is separate from the accepted
67.88 s G0 cold build. Native standard_sources checked in 1.937 s (0 tests),
and standard_loader passed **31/31** in 14.335 s. Consumer build took 16.45 s,
1312152 KiB, exit 1. Probe compiles took 0.85 / 0.85 / 0.84 s, exit 1.
Generator check passed. No Dew tests ran in this attempt.


## Final gates: READY candidate

All final gate commands exited zero. No functional blocker remains. This is
a review candidate, not a landed item. The orchestrator owns the combined
full std run; this worker did not run or recount the B-tree suite, provider
tests, operation probes, or snapshots.

| Gate | Wall seconds | Peak RSS KiB | Passed / failed |
| --- | ---: | ---: | --- |
| Focused Dew compile, cold | 27.92 | 1076604 | compile passed |
| Focused Dew run | 0.03 | 49784 | 16 / 0 |
| Host generator --check | 0.03 | 13040 | 1 / 0 |
| Native source/loader lane | 15.25 | 682248 | 31 / 0 |
| Production consumer compile | 15.90 | 1312376 | compile passed |
| Production consumer run | 0.02 | 45060 | 1 / 0 |
| 64-byte probe compile | 0.93 | 70100 | compile passed |
| 512-byte probe compile | 0.94 | 70084 | compile passed |
| 4096-byte probe compile | 0.91 | 70024 | compile passed |
| Runtime/memory probe run | 4.53 | 58008 | 216000 calls / 0 failures |

The 16 focused tests are **8 new path-parts tests + 8 unchanged host tests**.
They include the existing escape and join-limit checks. These eight host tests
are not the eight B-tree provider tests. Native standard_sources has no tests
and passed its compile check in 1.864 s. Native standard_loader passed 31 tests
in 13.383 s, through `tools/test-native.sh`. No compiler/backend source changed,
so full native/integration lanes are left to combined integration. No new
module exists, so there is no module identity or shared registration change.
The test generator uses the bootstrap source; the ordinary CLI consumer uses
the on-disk source. Both compiled successfully under the existing rules.

No final compiler command exceeded 30 seconds. The earlier 32.60-second cold
diagnostic run remains a recorded performance bug; it is not hidden by the
final timing. All three failed attempts and the final run keep full diagnostic
logs. Large warning logs are gzip text, not generated runtime binaries.

| Input bytes | Median microseconds per call | Retained heap delta bytes | RSS delta bytes |
| --- | ---: | ---: | ---: |
| 64 | 1.0143 | -2968 | 524288 |
| 512 | 5.7831 | 8456 | 266240 |
| 4096 | 58.5491 | -336 | 0 |

There are 210000 measured calls and 6000 checked warmup calls. The production
consumer and all three probes have **zero host imports**. At 4096 bytes,
post-GC process RSS is 58376192 bytes and does not grow across the timed
batches. GC heap deltas are small and may be negative. These results support
the source-level bounded-memory design; they do not prove zero allocation.
No old API changed, so there is no before/after speedup claim.

## Exact reproduction

Run from `/data/workspace/wave1-item-04`. The saved gate script records each
command with `/usr/bin/time -v`, preserves failures, and removes `_build`,
`.mooncakes`, `.dew/cache`, and generated Wasm/harness files in an EXIT trap
before it releases the lock. All compiler/test work is inside that one lock.
The setup commands below only copy or generate text and make a local link.

```sh
mkdir -p .tmp
cp docs/research/data/stdlib-wave1-04/consumer.dew .tmp/consumer.dew
python3 docs/research/data/stdlib-wave1-04/bench.py
cp docs/research/data/stdlib-wave1-04/moon-cc.sh .tmp/moon-cc
chmod +x .tmp/moon-cc
ln -s /usr/bin/ar .tmp/moon-ar
cp docs/research/data/stdlib-wave1-04/gate.sh .tmp/gate.sh
flock /data/workspace/wave1-control/build.lock bash .tmp/gate.sh
```

The gate exports this exact PATH:
`/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin`.
It sets process-local `MOON_CC=$PWD/.tmp/moon-cc`, which runs
`clang "$@" -g0 -O0 -fbracket-depth=4096`. Moon commands use `-j 1`.
No SDK setting changes. The scoped generator check is
`python3 tools/generate_host_std.py --check`; no full check-generated or
new-module gate is needed for this existing module. The complete command
arguments and timings are also in `data/stdlib-wave1-04/final.log.gz` and
`data/stdlib-wave1-04/results.json`.

Pure generation before the gate was `python3 tools/generate_host_std.py`.
Final source hygiene check: `git diff --check` passed. The exit trap removed
all owned build directories and Wasm files. No snapshot or B-tree file changed.
No push occurred. The test checkpoint is `7662bf3f`; the implementation
checkpoint is the commit that adds this final evidence and the four queries.

Changed files are exactly:

- `std/path.dew`
- `std/tests/path_parts_test.dew`
- `src/standard_sources/standard_host_sources.mbt`
- `std/README.md`
- `docs/research/stdlib-wave1-04.md`
- `docs/research/data/stdlib-wave1-04/attempt-1.log`
- `docs/research/data/stdlib-wave1-04/attempt-2.log.gz`
- `docs/research/data/stdlib-wave1-04/attempt-3.log.gz`
- `docs/research/data/stdlib-wave1-04/final.log.gz`
- `docs/research/data/stdlib-wave1-04/results.json`
- `docs/research/data/stdlib-wave1-04/bench.py`
- `docs/research/data/stdlib-wave1-04/bench.mjs`
- `docs/research/data/stdlib-wave1-04/consumer.dew`
- `docs/research/data/stdlib-wave1-04/gate.sh`
- `docs/research/data/stdlib-wave1-04/moon-cc.sh`

## Combined landing gate

Item 04 on hex integration head `8dc8bdf4`: full `bash tools/dew-test/run.sh`
exited 0 in 157.07 s. Public tests: 387 passed (379 prior + 8 path tests),
private tests: 41 passed. Builtin traps, repeat-byte check and all 42 operation
check scripts passed. Native standard_loader lane passed 31 tests. Local
Clang -g0 -O0 uses the pinned SDK; long compiler calls remain visible.
Full logs: `data/stdlib-wave1/landing-04-{std,native}.log.gz`. Build output removed.
