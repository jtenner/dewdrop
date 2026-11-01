# Wave 1 item 12: bounded directory pages

Status: **READY for review**, not landed. No functional blocker remains.
Base: `8dc8bdf406733f8a29662f28c68528276870b0de`.
Branch: `worker/wave1-item-12`. Test checkpoint: `e012b490`.
No B-tree file, SDK setting, or snapshot changed. No push.

## API and bounds

`dew.std.fs.directory` provides a separate `DirectoryReader` trait;
`FileSystem` is unchanged. `read_directory(reader, path, cookie, count, bytes)`
returns `Result<DirectoryPage, DirectoryError>`. A page has `entries`, `cookie`,
and `end`. Start at cookie zero; use the returned cookie until `end` is true.
`std/README.md` has a complete first-page example.

Limits: 1–2048 encoded records, including dot entries; 24–49152 encoded bytes.
A short complete buffer means end. A full buffer needs another read. Count
stops and incomplete tails return prior complete progress with `end=false`.
An incomplete first record returns `PartialRecord`; retry with a larger byte
limit, or stop if already at the maximum. No partial name is exposed.

Names are valid UTF-8 single path parts relative to the requested directory.
Empty names, slash, backslash, NUL, bad UTF-8 and unknown type codes are rejected.
`.` and `..` are skipped, but consume record budget and advance the cookie.
Lengths are checked before access and before addition; oversized host replies
are errors. Cookies are opaque, not ordered. A bounded hash set rejects any
cookie repeated within the page, including the input cookie. The API makes no
snapshot guarantee. Callers must bound total calls or track cookies if they
need to detect cycles across distinct pages during directory mutation.

`WasiDirectoryReader` checks each path part with no-follow `path_filestat_get`,
then opens it with DIRECTORY and lookup flags zero. A link in the requested
path returns `Symlink`; entry links are data. Metadata and open use ordinary
WASI foreign declarations. A forged invalid `RelativePath` is rejected before
host access. The caller owns the root handle. Each opened child receives one
close attempt, including intermediate open/stat failures and read/decode errors.
The primary read/decode error wins over a close error; otherwise close errors
are returned. No recursive walk or deletion was added.

Reserved source bits: directory 1024 and WASI directory 2048. Identity slots:
84 and 85. Wildcard facts on this branch are 94 source paths, 83 modules and
80 direct wildcard dependencies. Other reserved slots/bits remain unused.

## Final gates

All build, compiler and test commands ran under the exclusive build lock.
The final script exited **0**. Exact timed commands are in
`stdlib-wave1-12-gates.sh`. Full logs for all three attempts are preserved in
`data/stdlib-wave1-12/gates.log.xz`; compact final results are in
`stdlib-wave1-12-final.log`. The two failed attempts remain named below.

| Gate | Seconds | Peak RSS KiB | Result |
| --- | ---: | ---: | --- |
| Directory generator `--check` | 0.02 | 12192 | pass |
| Identity generator `--check` | 0.02 | 12032 | pass |
| Focused cold compile | 30.97 | 1080136 | pass; performance bug >30s |
| Focused Dew runtime | 0.03 | 46636 | 10 passed, 0 failed; all 10 new |
| WASI probe compile | 1.17 | 70952 | pass |
| Mock host + real WASI + scaling | 0.17 | 73936 | 70 passed, 0 failed; all new |
| Production consumer compile | 22.80 | 925828 | pass |
| Production consumer runtime | 0.03 | 46920 | 1 passed; result 42, no WASI imports/test metadata |
| Bootstrap/on-disk source equality | 10.74 | 680720 | 1 passed, 0 failed |
| Native source registry | 0.91 | 80852 | 2 passed, 0 failed; 1 new |
| Native module/source-selection integration | 29.09 | 1133016 | 51 passed, 0 failed; 1 new |
| Generated Moon interface | 0.21 | 35020 | pass |
| Complete `check-generated.sh` | 59.70 | 836952 | pass; aggregate performance bug >30s |

The 51 integration tests comprise 27 module tests (26.279s) and 24 preamble
checks (2.804s). They cover imports, dependency closure, wildcard facts and
stable module identities. The generated gate also passed 14 bootstrap tests,
3 CLI fixtures, and its normal policy, generator and JavaScript checks.
There are 12 new named tests (10 Dew + 1 registry + 1 integration), 70 new host
checks, and one production consumer check. Existing checks are not new tests.
No full std-runner total is claimed here; the owner runs that lane at landing.
The eight public provider tests were not counted again.

The real temporary tree contains a file, UTF-8 name, subdirectory, and symlink.
It verifies empty enumeration, exact relative name/type checksums, bounded
pagination and rejection of final/intermediate links. It used four pages and
**12 opens / 12 closes**. Its temporary tree was removed in `finally`.
Mock cases cover every 1–24 byte truncated first record, partial tails,
opaque/repeated cookies, count/byte limits, bad names/types/UTF-8, over-reported
host lengths, open/stat/read permission errors, nested failures, close errors
and primary-error precedence. Every acquired mock handle has one close call.

## Runtime and memory

New API: no prior-path speedup is claimed. The reproducible host probe checks
100 iterations for each size, against exact entry count and end-state oracles.
Its hash-set decoder has expected linear work in records plus name bytes.
Input, returned entries, cookie set and scratch are bounded by the page limits;
no persistent traversal state or unbounded retry loop exists.

| Records/call | Encoded bytes | 100 calls, ms | Process RSS bytes | Heap delta bytes |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 25 | 0.604 | 53186560 | 420968 |
| 16 | 400 | 2.882 | 54919168 | 205432 |
| 256 | 6400 | 10.746 | 61214720 | 1356024 |
| 1024 | 25600 | 22.023 | 65933312 | 2802672 |
| 1966 | 49150 | 61.275 | 75710464 | 4299832 |

Linear memory remains exactly **65536 bytes** at every size. These RSS/heap
numbers include Node, Wasm GC, mock host buffers and tracing; heap deltas cover
100 calls after a pre-run GC and include temporary garbage. They are not exact
per-call allocation counts. Each call copies at most 49152 host bytes, retains
at most the requested count of records/cookies, and scans only the bounded
buffer. The largest fixture is just below the maximum byte limit.

## Exact commands and cleanup

SDK: `/data/home/.moon`, moon 0.1.20261023, moonc/core
0.10.17+d971670cd. Existing Bun: `/tmp/burn-starshine-fix-tools/bun`.
Process-local Clang flags: `-fbracket-depth=4096 -g0 -O0`, adjacent private
archiver symlink, and `-j 1` for focused/native commands. Repository check
scripts retain their own flags. No global SDK changes.

```sh
mkdir -p .tmp
cp docs/research/stdlib-wave1-12-cc.sh .tmp/directory-cc
chmod +x .tmp/directory-cc
ln -sf /usr/bin/ar .tmp/directory-ar
cp docs/research/stdlib-wave1-12-gates.sh .tmp/directory-gates.sh
flock /data/workspace/wave1-control/build.lock bash .tmp/directory-gates.sh
```

The EXIT trap removes `_build`, `.mooncakes`, `.dew/cache`, generated Wasm and
harness files before releasing the lock, including failed attempts. Logs are
preserved in the archive. Scratch logs/wrappers are removed at handoff. Remaining
functional blockers: none. Known performance bugs: final cold focused compile
30.97s, full generated check 59.70s (earlier 55.96s). The accepted 67.88s cold
baseline is separate and unchanged. Compiler performance fixes are outside this
library item.

## Failed attempts, preserved

1. `stdlib-wave1-12-attempt1.log`: U64 shifts rejected U32 shift counts
   (`std/fs/directory.dew:75`, test line 49 at that checkpoint). A typed
   conversion fixed both. Focused 28.82s, probe 1.02s, production 20.40s failed.
   Native source equality 1/1, registry 2/2, integration 51/51 passed.
   Generated check stopped at missing Bun on PATH in 3.17s; the retry used the
   existing Bun path.
2. `stdlib-wave1-12-attempt2.log`: 10/10 Dew tests passed. The probe compiled in
   1.12s. Mock checks passed, but real Node WASI followed a final symlink despite
   lookup flags zero. The explicit no-follow metadata check fixed this; the
   failing assertion was preserved. Production, native, source equality and
   full generated checks passed. Full generated check took 55.96s.

## Exact changed files

```text
docs/research/data/stdlib-wave1-12/gates.log.xz
docs/research/stdlib-wave1-12-attempt1.log
docs/research/stdlib-wave1-12-attempt2.log
docs/research/stdlib-wave1-12-cc.sh
docs/research/stdlib-wave1-12-consumer.dew
docs/research/stdlib-wave1-12-final.log
docs/research/stdlib-wave1-12-gates.sh
docs/research/stdlib-wave1-12.md
self_host/compiler/semantic_standard_module_ids.dew
src/semantic/module_system.mbt
src/semantic/module_system_wbtest.mbt
src/semantic/standard_module_identity.mbt
src/semantic/standard_preamble.mbt
src/semantic/standard_preamble_wbtest.mbt
src/standard_sources/directory_wbtest.mbt
src/standard_sources/pkg.generated.mbti
src/standard_sources/registry.mbt
src/standard_sources/standard_directory_sources.mbt
std/README.md
std/fs/directory.dew
std/fs/wasi_directory.dew
std/tests/directory_test.dew
tools/check-directory-consumer.mjs
tools/check-directory-operations.mjs
tools/check-generated.sh
tools/dew-test/assemble.py
tools/dew-test/directory_operations.dew
tools/dew-test/run.sh
tools/generate_directory_std.py
tools/standard-module-identities.json
```

## Combined landing gate

Full `bash tools/dew-test/run.sh` exited 0 in 170.94 s:
445 public tests (435 prior + 10 permanent new tests), 41 private
tests, builtin traps, repeat-byte check, and all 43 operation check scripts
passed. `DEW_NATIVE_TEST_PACKAGES=standard_loader bash tools/test-native.sh`
passed 31/31 tests in 14.01 s. Process-local Clang uses trailing
-g0 -O0 and bracket-depth 4096; the pinned SDK is unchanged. Compiler calls
over 30 s remain visible in the full logs. Build output was removed.
Logs: `data/stdlib-wave1/landing-12-{std,native}.log.gz`.

## Combined registration and host gate

The final wildcard selects 85 modules, 96 source paths and 82 direct root
dependencies. Source bits 128/256/512/1024/2048 and slots 81–85 remain
distinct. Both directory sources and all prior module checks are retained.
Scoped native source-interface generation passed; the exported interface
was current. Preamble and module-system integration files passed 53 tests
in 24.65 s. Logs: `data/stdlib-wave1/landing-12-{modules,info}.log.gz`.
The full standard runner now has 43 operation scripts: 4,121 baseline checks
plus 70 directory host checks. Its real WASI and mock-host checks passed.
