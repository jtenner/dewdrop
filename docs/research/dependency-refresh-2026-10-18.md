# Dependency refresh, 2026-10-18

## Scope

- Starshine: `2368260c6a3f798c8d50089faccb409880d125e5` to
  `9ae3871659343e1f4d58f13d9cdf622d753ea135` (package version `0.3.0`). This includes
  upstream `a4237ca03` and two local compatibility/limit-repair commits.
- MoonBit `moonbitlang/x`: `0.5.1` to `0.5.5` in Dewdrop and Starshine.
- Snapshot `wasm-tools` pin: `1.251.0` to `1.262.0` (current release).
- Go tools: pin Wago `v0.1.0-beta.13` and `golang.org/x/sys v0.49.0`.
  The latter requires Go 1.26. The three modules now use the released Wago
  module instead of a sibling checkout. Existing local Wago edits are intact.
- Website: Astro `7.4.0`, Shiki `4.5.0`, TypeScript `6.0.3`, Astro check
  `0.9.10`, and both font packages `5.3.0`. Refresh the full npm lock file.
- Editor: VSCE `4.0.0`; refresh the full npm lock file. The other direct
  packages are already current.
- Facet plugin: `v0.1.0` is still the latest release. Keep its existing lock.

TypeScript `7.0.2` is the latest release. Astro check `0.9.10` accepts only
TypeScript 5 and 6. Keep the latest supported TypeScript 6 release and retain
normal peer-dependency checks.

## Validation evidence

Local raw logs and time/memory records are under
`.tmp/starshine-refresh-2026-10-18/`. The measurement helper records wall time,
exit status, CPU time, and the largest child-process RSS. That RSS value is
not the total memory of all concurrent processes. Test times are not
pass-local runtime benchmarks.

The website build, all 11 editor tests, the VSIX package build, and all three
Go module build/test commands pass. Both npm audits report zero known issues.
The first website audit found one issue; `npm audit fix` updated its transitive
package before the successful build.

## Compatibility changes

MoonBit x `0.5.5` returns an `ArrayView[String]` from `read_dir`. The three
bootstrap directory scans and Starshine's recursive scan copy the view with
`to_owned()` before sorting. Each scan makes one owned copy; iteration-only
callers keep using the view. The Starshine pin includes the committed source
repairs above its upstream base.

The FFI provider now has a `_start` runtime export outside its API metadata.
The consumer generator accepts this exact name only with no parameters or
results, then excludes it before API comparison and binding generation. A
provider with no API exports is rejected. It still reports all other extra or missing API exports.
The new positive entry-point test failed before the fix. All 22 consumer unit
tests pass after it, including checks that invalid metadata stays diagnostic.
All 473 selected bindings and 63 carrier probes pass against 4,375 API exports.
All five added test functions fail against the unchanged root baseline generator
with the expected export-mismatch errors (0.069 seconds); the fixed generator
passes all 22 tests.

A workspace-wide build mixes unsupported targets. The foreign library in
`src/starshine_guest` is for WasmGC. The bootstrap platform functions are for
native/LLVM. Build the native packages without the guest, and build WasmGC
packages without the bootstrap. Do not add unused platform stubs or remove tests.

The final Starshine WasmGC full gate passes all 15,201 tests and every CI fuzz
suite in 270.901 seconds (1,578,880 KiB maximum child RSS). The resolved seed and
each fuzz suite counter are in `starshine-full-complete.log`. This run includes
all 24 validator boundary cases. Earlier 15,193-test logs predate the new tests.

## Current toolchain source changes

The installed MoonBit formatter changes legacy `Int`/`UInt` spelling to
`Int32`/`UInt32`, default optional parameters to `~`, and current range syntax.
The official `moonfmt -w` changed 306 of 614 source files in 7.551 seconds.
Two package manifests also needed the current format. The new Starshine
validator and regression test files also use the official formatter. The standard built-in
registry generator now emits the current integer spelling. These are mechanical
source changes required by the current formatter gate. The separate format
commit verifies 299 files against official formatting of their baseline; the
seven files with cache/bootstrap behavior changes stay with their fixes. See
[the format record](moonbit-source-format-2026-10-18.md).

## Review and focused checks

Claude Code completed a read-only review after its usage reset. It read the
manifest and compatibility diff, plus portions of the large formatter diff.
It listed unread files and did not claim complete formatter coverage. Its
report is outside production source at
`/tmp/dewdrop-dependency-review-2026-10-18/claude-current.stdout`.
Some test evidence in its input packet was from earlier failed attempts;
final validation below supersedes that evidence.

The strict CLI fixtures also found an existing duplicate UTF-8 import in
`src/semantic/moon.pkg`. Each Moon invocation printed the warning into compiler
output. The second identical import is removed; the three exact-output CLI
fixtures pass. A scan of all 45 package manifests finds no other duplicate.

The review found the self-host freshness check still looked for `moon.mod.json`.
It now checks both current Starshine `moon.mod` files. An isolated fake-tree
harness fails on the old script and passes seven cases on the fix: unchanged
provider, each manifest, source, package, generator, and missing provider.
No live timestamps were changed. The current Starshine version in the fragment
research note is also corrected.

The native binary round-trip fuzz test found a width error. I32 limit values
were widened to U64 before encoding. For an optional maximum at or above
`0x80000000`, the native backend sign-extended the value and emitted a ten-byte
LEB instead of the required five-byte unsigned32 form. Nine I32 limit calls now
use the U32 encoder directly; I64 limit paths are unchanged. Four regression
tests cover 18 exact-byte and decode-consumption cases at `0x7fffffff`,
`0x80000000`, and `0xffffffff`, including both memory-sharing flags. The native
red result shows the two optional-maximum tests fail before the fix. All four
pass after it (93.683-second native rebuild, 2,021,884 KiB peak child RSS).

A targeted Claude review flagged the same optional-UInt widening pattern in
`ValidateMax`. Independent inspection confirmed signed extraction in generated
native C, and new public-API tests reproduced it: three of four tests failed
before the fix. The I32 optional maximum now masks the widened value to 32 bits
before the unchanged min/max/bound comparisons. The I64 branch is unchanged.
Four tests initially cover 22 valid and invalid cases, including high min and max together,
the public table validator, reversed limits, and bounds below/at/above U32.
All four pass on native (140.686 seconds, 2,473,864 KiB child RSS) and WasmGC
(4.574 seconds, 427,620 KiB). Generated C contains the mask and no added allocation.
The final read-only Claude review read the whole validator file and found no
confirmed defect. Following its test suggestion, two more reversed-range cases
with a maximum UInt64 bound were added for the full run, for 24 cases total.
These cases check the old false-accept path as well as the false rejection.
A bounded scan of three generated native C files found no additional instance
of the signed-widening defect outside these two fixes.

The native carried-guard test failed because the `wasm-opt` mise shim had no
active tool. The same test passes with real Binaryen 133 in 0.021 seconds.
The tools are activated only for this run; no fake executable or test skip is used.

All three released-Wago Go tools also pass explicit `go build` commands.
The sibling Wago checkout, including its local changes, is unchanged.

The first full four-target run also exposed two existing portable-cache tests.
An explicit enabled memory pack was blocked by the file-platform check. The
cache availability helper now accepts that pack for interface, body/family,
layout and fragment lookup/store. Environment opt-ins and persistent file-pack
opening are unchanged. The public policy constructor retains its signature;
a private constructor accepts the actual pack. Both failing tests keep all
assertions and run on every target. The five changed source files use the
current formatter.

Claude read all five source files, both unchanged test files, the contract doc,
and the raw WasmGC failures. It found no confirmed defect. Its missing-coverage
notes and file-commit limit are explicit: this is internal memory lookup/store,
not a new public memory-pack constructor or portable file commit. No runtime
or code-size gain is claimed. Final four-target results are recorded below.

The rich self-host smoke test then found a default-import gap. Native Dew
opens `dew.std.option` and `dew.std.result` with the default preamble; the
self-host compiler opened only the preamble. A new focused test reproduces
unresolved Option/Result signatures in the unchanged self-host code (one
failed test, 0.061 seconds). It also checks the disabled setting, standard-module
self-import exclusions, original file identity, and input immutability.
The fixed helper checks module availability once and selects static import
text. It preserves preamble-only and partially supplied manifests. Partial
manifest tests also check that absent types retain visible signature errors.
All 77 tests in the two owning files pass, including the unchanged original
preamble-only test (0.191 seconds execution; 5.717-second build/link harness).

Independent native compilation found three separate smoke-fixture errors:
missing explicit opens for `dew.std.fixed_array` and `dew.std.bytes`, plus an
unconstrained `.into()` result. These are source errors before Starshine emission.
The fixture adds the two opens, an I32-typed assignment for the conversion,
and constructor probes for the two enum layouts its existing shape checks
require. All original operations and checks remain. The call-count check now
accepts named or numeric direct calls and excludes tail calls, `call_ref`,
comments and unrelated names. The exact fixed source compiles natively in
1.453 seconds. The full final smoke passes in 22.701 seconds, including Wasm
validation, every shape/count assertion, and fingerprint/count rejection.
Peak child RSS is 1,040,636 KiB. Its emitted output SHA-256 is
`8520786158a806df22043d7cacd2a664b5117a75fc485d31cbddd1d0973a65d5`.
Claude read the final five changed files and the red/green evidence. It found
no code defect. Two documentation gaps are corrected. Its listed limits include
partial reads of related native/import code and no independent test execution
or artifact hashing. The parent checks the measured results and source hashes.
The original native failure logs establish the fixture source errors. Current
emitted constructors and all 33 output checks establish the tested layouts;
the extra constructor functions are compile/emission probes.

The full language suites pass 332 standard-library tests, the operation checks,
61,000 SWAR checks, 17,471 UTF checks, and 196 WASI checks. The first snapshot
run then reports 159 text mismatches out of 461 fixtures. Both Node and Wago
execution, expected diagnostics/output/traps, and repeated-byte checks pass
before each WAT comparison. All 222 changed lines are imported-function lines:
wasm-tools 1.262.0 now prints explicit parameters and results beside type indices.

The snapshot migration parses all 411 existing WAT files, prints them with the
runner's exact flags, and parses the new text again. All old/new parsed binaries
are byte-identical. It finishes every check before writing any file. Exactly
159 WAT files change (222 lines); no JSON expectations change. The measured
migration takes 3.423 seconds and 24,000 KiB maximum child RSS. Raw per-file hashes
and the runtime failure classification are in `snapshot-printer-migration.json`
and `snapshot-runtime-triage.json`. The fresh check passes all 461 fixtures on
Node and Wago in 23.909 seconds (179,320 KiB child RSS). Architecture WAT checks
also pass in 0.224 seconds. An independent agent verifies every changed line,
the unchanged JSON oracles, and the migration's check-before-write order.
Claude reads all 159 changed-file hunks and finds no defect in the goldens or
runner. It notes that the one-time migration helper lacks its own version guard
and captured-error display. The pinned final runner independently enforces the
tool version and validates the resulting goldens. A parent check confirms the
original helper equals the reviewed copy and that all 159 changed snapshot files
are WAT, with no JSON changes. The report lists partial related-source reads and
the denied original `/tmp` helper read; the reviewed copy's SHA-256 is
`db7b061337fd3ff7b00a5806232fa87981f9bc328b1c998a17d30f5475da02ac`.
A separate follow-up verifier enforces the live printer version, reports tool
stderr with each file path, and checks all 411 baseline/final text hashes and
parsed binary hashes against the migration record. It passes in 4.254 seconds
(19,220 KiB child RSS); `snapshot-baseline-verification.json` also records the
version, exact baseline and verifier hash.

## Compiler cost

The first full native Starshine run took 1007.650 seconds and reached
7,864,864 KiB in one child process. It ran 15,227 tests, with the branch-tool and binary-round-trip failures
listed above. This exceeds the project's 30-second compiler budget and is a build
performance defect. It is not evidence of a runtime slowdown.

A compile-only Clang 23 probe used the same 273,295,583-byte generated passes
C source, `-O2`, and mimalloc configuration. It reached the 180-second timeout
and 4,581,368 KiB RSS. It did not complete, so it proves no speed gain.
No compiler, allocator, or optimization setting was changed on that evidence.
Earlier repository measurements also show that changing the allocator can
harm runtime performance; retain the production allocator and optimization.
The final full native Starshine lane passes all 15,235 tests in 1,070.745 seconds,
with 7,867,504 KiB maximum child RSS. The sampled remaining pass black-box test
input is 352,259,237 bytes of generated C. Native cold compilation remains above
the budget. These two full runs are not a controlled dependency performance
comparison; test counts, source changes and cache state differ.

`build-environment.json` records the AMD Ryzen 7 8845HS host, GCC 14.2.0,
Node 24.21.0, Moon/Moonc versions, and memory-metric limits. The pre-commit source
record includes 3,275 files across root/Starshine MoonBit, self-host Dew, standard
Dew, manifests, FFI inputs and the provider. Its SHA-256 is
`4656e5cf22270065574628b9f61d4fd5d28f5a2ae56cd7ebc2a4a370ff6a0e0a`;
per-file hashes are in `final-source-identity.json`. Snapshot printer hashes are
recorded separately. Validation preceded the later request to commit all changes.
The compiler logic remains unchanged by the local commits. The commit-pinned
FFI fingerprint is refreshed and checked separately below.

## Final validation

The final four-target Dewdrop tests pass with the portable-cache fix:

| Target | Passed | Failed |
| --- | ---: | ---: |
| Native | 1,375 | 0 |
| WasmGC | 1,366 | 0 |
| JavaScript | 1,366 | 0 |
| Wasm | 1,366 | 0 |

The same root gate passes formatting, nine proof goals, generated-source and
source-policy checks, the FFI checks, strict CLI diagnostics, and compile-request
checks. It initially stopped at the rich self-host smoke fixture, now fixed and
passed as recorded above. All remaining full-gate stages pass in resumed runs:

| Stage | Wall seconds | Maximum child RSS, KiB |
| --- | ---: | ---: |
| Final format check | 0.051 | 20,588 |
| Final generated/source-policy checks | 8.838 | 381,632 |
| Native integration | 90.258 | 1,089,692 |
| Native stress, 15 tests | 0.337 | 15,480 |
| CLI cache, ABI and size budgets | 135.685 | 1,398,792 |
| Final snapshots, 461 fixtures, two runtimes | 23.909 | 179,320 |
| Final architecture WAT checks | 0.224 | 14,968 |

The standard-library and parity stages pass in `root-final-suites.log`; that
original command stopped on the printer-only snapshot mismatch. The refreshed
snapshot and final architecture commands then pass separately. The original
`tools/check.sh` failure remains in the evidence; no single exit-zero run of that
whole script is claimed.

Its measured 402.688 seconds includes four concurrent target
lanes, each with a separate build directory and lock. This is not a comparison
with the earlier serial run.

Complete release package builds pass on native (341.006 seconds,
3,963,200 KiB maximum child RSS) and WasmGC (14.358 seconds,
1,105,824 KiB). These scopes include all Starshine packages, including command,
fuzz and trace packages. The target-specific exclusions are described above.
The guest Wasm validates, and the refreshed FFI build, metadata check,
generation and consumer checks all pass.

Final native Starshine tests pass all 15,235 cases with zero failures. The final
self-host fixed-point check passes in 61.706 seconds (1,046,636 KiB child RSS),
including compiler B semantic probes. B and C core, raw linked and final modules
compare byte-for-byte; both final modules have SHA-256
`a7d15d9ae710ed9ac606f4edc46ea3938cf2238bfef9858d49e65d1a25190d6b`.
Each measured compiler source-build/execution phase is below 30 seconds.
All 36 CLI command checks pass, including expected failures, cache identity,
metadata and artifact-publication checks. The lane takes 211.574 seconds and
3,097,852 KiB maximum child RSS. It checks both the explicit Starshine executable
and the default optimizer fallback. Per-command times and output are saved in
`.tmp/cli-optimization-yxbrk0xj/report.json`; the native fallback rebuild exceeds
30 seconds.

The final current-source rebuilds pass across every package in the target scopes
described above, including all 21 Starshine packages: native takes 93.279 seconds
(1,941,188 KiB child RSS), and WasmGC takes 4.374 seconds (924,096 KiB). All 3,275
recorded source hashes matched that identity before the commits. The temporary child
workspace is removed. All requested build and test stages pass in the final
component runs. Cold native compilation remains above the 30-second budget.

## Commit-pinned FFI refresh

The Starshine commits change the revision field in the generated fingerprint.
Regeneration updates that field for `9ae3871659343e1f4d58f13d9cdf622d753ea135`. Of the original
3,275 recorded source inputs, only `self_host/starshine/fingerprint.dew` and
`self_host/starshine/fingerprint-prefix.bin` change. Compiler algorithms, binding declarations
and provider Wasm remain unchanged. The manifest records the new revision.

Generated/source-policy checks pass in 8.815 seconds, FFI checks in 5.370 seconds,
and the full smoke test in 22.675 seconds. The repeated fixed-point check passes
in 61.642 seconds. B and C are byte-identical with SHA-256
`1b40919b3db9221a9452e1aa8426f6da4fa554af0ce874e406201a5829ce3d0f`.
The pre-commit timings and hashes above retain their original inputs.

`commit-source-identity.json` records the current 3,276 inputs, adding the FFI
binding manifest. Its source SHA-256 is
`4254ccfa002e145f1f72326059c3380ca8d1dd0c8a29e324f43912d8f3bfd634`. The two Starshine commits and four Dewdrop commits
are local. Commit preparation changes source format documentation and generated
revision data; it preserves all tested compiler logic.
