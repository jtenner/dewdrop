# Wave 1 item 11: Process Writer

Base: `8dc8bdf406733f8a29662f28c68528276870b0de`.
Test checkpoint: ten new tests; not run yet. The module is absent, so these
are expected to fail until implementation. No baseline changes.

Contract: `process_stdout(p)` and `process_stderr(p)` return a Writer that
keeps the given Process and channel. A direct write forwards once. Use
`io_write_all` for complete writes. Empty complete writes make no Process call.
`LimitExceeded` maps to `IoError::LimitExceeded`. All other Process error kinds
map to `IoError::Backend(code)`, preserving the numeric code. Process operation
is discarded; channel identity stays in the writer. No host imports are needed
for a mock Process. No global Process is created.

## Implementation and checks

Test/doc checkpoint: `306a3fbc`. Implementation uses ordinary generic Process
functions captured at construction, following `std/iter.dew`. Writer execution
needs only that typed callback. No runtime builtin, compiler dispatch, global
Process, or removed Facet adapter was added. Registration uses reserved module
slot 83 and text mask bit 512. Hex stays at slot 81/bit 128. Wildcard counts
include only the modules on this branch: 93 source paths, 82 modules including
the application, and 79 application wildcard dependencies.

The ten Dew tests cover partial limits 1 through 9, both channels, byte values
00/80/ff, exact counts/call counts, channel state, empty complete writes without
calls, one-shot partial writes, zero and excessive progress, all five Process
error kinds, and errors after successful progress. An intentionally mismatched
Process operation in the mock confirms that mapping uses kind/code while the
adapter keeps its own channel. Written prefixes survive an error; there is no
retry after an error. Complete writes use the existing `io_write_all` loop.

The first integration run passed 50 tests and failed one existing wildcard
fact: `src/semantic/module_system_wbtest.mbt:174`, `79 != 78`. This was a stale
expected dependency count for the added module. The test now expects 79. The
full failed log is retained; no test was suppressed.

## Reproduce

Run in `/data/workspace/wave1-item-11` on `worker/wave1-item-11`:

```sh
mkdir -p .tmp
cp docs/research/stdlib-wave1-11/process-cc.sh .tmp/process-cc
chmod +x .tmp/process-cc
ln -sf /usr/bin/ar .tmp/process-ar
cp docs/research/stdlib-wave1-11/gates.sh .tmp/gates.sh
flock /data/workspace/wave1-control/build.lock bash .tmp/gates.sh
cp docs/research/stdlib-wave1-11/retry.sh .tmp/retry.sh
flock /data/workspace/wave1-control/build.lock bash .tmp/retry.sh
```

The saved scripts give exact commands and PATH. Each compiler, build and test
command ran within one exclusive build lock. Their EXIT traps delete `_build`,
`.mooncakes`, `.dew/cache`, and generated Wasm/WAT files before lock release,
including on failure. No shared build outputs. The process-local Clang wrapper
adds `-fbracket-depth=4096 -g0 -O0`, with its adjacent `process-ar` symlink.
Focused builds use `-j 1`. SDK: `/data/home/.moon`, moon 0.1.20261023,
moonc/core 0.10.17+d971670cd. The global SDK was not changed.

First gate results (seconds; peak resident memory in KiB):

| Gate | Seconds | Peak KiB | Result |
| --- | ---: | ---: | --- |
| adapter generator --check | 0.02 | 12044 | pass |
| identity generator --check | 0.02 | 12112 | pass |
| focused test compile, cold | 28.30 | 1079048 | pass |
| focused runtime | 0.02 | 46428 | 10 passed, 0 failed |
| production mock compile | 20.31 | 925752 | pass |
| production large mock compile | 0.59 | 71044 | pass |
| production WASI compile | 0.74 | 71028 | pass |
| production runtimes and measurements | 0.14 | 57016 | pass |
| bootstrap/on-disk equivalence | 9.26 | 680720 | 1 passed, 0 failed |
| native source registry | 0.82 | 80432 | 2 passed, 0 failed |
| first focused integration | 24.05 | 1132688 | 50 passed, 1 failed |
| source interface generation | 0.19 | 36980 | pass |
| complete check-generated.sh | 53.47 | 836976 | pass |

The **53.47-second generated-check aggregate exceeds 30 seconds**. It includes
policy checks, builds, native bootstrap tests and CLI fixtures. It remains
visible as a performance issue; no scope was added to fix the shared runner.
The two timed integration compiler calls were 16.881 and 7.165 seconds.
The accepted historical 67.88-second cold baseline is unchanged.

## Runtime and memory evidence

The production mock module has **zero imports** and no `dew.tests` section.
Its main returns four after two writes per channel and exact byte checks.
The large mock main returns 128 after 64 writes per channel and exact 4096-byte
checks. The production WASI module runs with Node's real WASI `fd_write`;
separate descriptors receive exactly `out 00 80 ff 0a` and `err 00 80 ff 0a`
(with no space byte). All three production modules execute successfully.

`runtime.mjs` warms the small module, times repeated calls, forces GC before
and after each measurement, and prints `process.memoryUsage()` snapshots:

| Work | Process writes | Bytes checked | Runtime ms | Retained heap delta bytes | RSS delta bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| 10,000 small calls | 40,000 | 100,000 | 5.733 | -2624 | 4399104 |
| 100,000 small calls | 400,000 | 1,000,000 | 21.801 | -152 | 262144 |
| 100 large calls | 12,800 | 819,200 | 6.412 | 1856 | 57344 |
| 1,000 large calls | 128,000 | 8,192,000 | 43.855 | 344 | -114688 |

These are whole-process measurements, including the mock's BytesBuilders,
byte checks, Wasm allocations and JS calls. They do not measure an exact Wasm
GC heap or prove a speedup. Larger repeats retain no proportional buffer.
The adapter has three fixed fields: Process, channel, typed callback. It
allocates no byte buffer and forwards the original Bytes value. The existing
`Bytes.view` shares backing bytes, so `io_write_all` adds suffix views without
copying payloads. Work is one callback per successful chunk: O(ceil(n/limit));
adapter live state is O(1), excluding the supplied Process. The mock stores
O(n) bytes to provide an exact byte oracle. This is a new API, so there is no
replaced runtime path or before/after speed claim.

The baseline standard/private-B-tree/probe suites were not recounted here.
The orchestrator owns the complete standard run. No snapshot was refreshed,
no B-tree file was edited, no held fix was imported, and no push occurred.

## Final retry and handoff

**READY for review; not landed. No item blocker remains.**

Final focused acceptance: **64 passed, 0 failed, 12 new**. This includes
10 new Dew tests, 2 registry tests (1 new), 1 source-equivalence test, and
51 integration tests (1 new). Repeated runs are not added. Existing auxiliary
policy/Node/native/CLI tests in check-generated also pass; they are not added
to the 64. Baseline provider and private B-tree tests are not recounted.

| Final retry gate | Seconds | Peak KiB | Result |
| --- | ---: | ---: | --- |
| focused integration | 30.28 | 1132688 | 51 passed, 0 failed |
| pure production compile | 22.40 | 925756 | pass |
| large production compile | 0.63 | 70932 | pass |
| WASI production compile | 0.72 | 70924 | pass |
| strict zero-import assertion, runtimes, benchmark | 0.14 | 57148 | pass |

The **30.28-second integration aggregate exceeds 30 seconds**. Its individual
compiler calls took 20.823 and 9.450 seconds. No single separately timed
compiler call exceeded 30 seconds. The complete generated-check gate was timed
as an aggregate; no finer timing claim is made for that gate.

The final runtime script requires the pure module import list to equal `[]`.
This assertion passes. Repeat measurements: 100,000 small calls took 21.731 ms
with retained heap delta -152 bytes; 1,000 large calls took 45.313 ms with
retained heap delta +344 bytes. Array buffers stayed at 10,475 bytes. Separate
WASI byte checks pass again. Full snapshots are in the compressed logs.

The first retry script's display-only log-summary command could not find `rg`
on its bounded PATH. Test status was preserved. The saved retry script now
uses `awk` from that PATH for this display step. Raw native logs and all
production statuses are saved.

All logs, including the failed wildcard assertion, are in
`stdlib-wave1-11/logs/*.log.gz`. `stdlib-wave1-11/changed-files.txt` lists every
changed file against the dependency checkpoint. The implementation/evidence
commit follows `306a3fbc`; its hash is in the handoff.

Both locked scripts completed their EXIT cleanup. `_build`, `.mooncakes`,
`.dew/cache`, generated Wasm/WAT and harness files are absent. Scratch files
were removed after log preservation. The pinned submodule is unchanged.
`git diff --check` passes. The tree is clean after the item commit. The
orchestrator must review and run its combined standard gate before landing.

## Combined landing gate

Full `bash tools/dew-test/run.sh` exited 0 in 161.96 s:
435 public tests (425 prior + 10 permanent new tests), 41 private
tests, builtin traps, repeat-byte check, and all 42 operation check scripts
passed. `DEW_NATIVE_TEST_PACKAGES=standard_loader bash tools/test-native.sh`
passed 31/31 tests in 13.45 s. Process-local Clang uses trailing
-g0 -O0 and bracket-depth 4096; the pinned SDK is unchanged. Compiler calls
over 30 s remain visible in the full logs. Build output was removed.
Logs: `data/stdlib-wave1/landing-11-{std,native}.log.gz`.

Combined registration check: canonical slots 81/82/83 remain distinct. The
wildcard has 83 modules, 94 source paths and 80 root dependencies. Both binary
and process import-closure tests are retained. Scoped `moon info --target native
src/standard_sources` passed and the exported interface stayed current. The
two focused integration files passed 52 tests in 23.89 s. Logs:
`data/stdlib-wave1/landing-11-{modules,info}.log.gz`.
