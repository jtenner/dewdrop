# Phase 1 standard package contract

## Scope and identities

- Assigned branch: `t3/std-package-contract`.
- Worktree: `/home/dev/.t3/worktrees/dewdrop/t3-21223c02`.
- Baseline: `20f902acb6caa56a49712df832aeb0c46ec520b8`.
- Approved plan read in full: `git show c812b052:docs/package-manager-migration-plan.md`.
- Only the standard manifest and artifact codecs, their tests, this note, and the
  generated package source mirror are in scope. All codecs stay version 1.
- The owner holds full native lanes, broad compiler builds, and performance work.
  No child agent or Claude is used. No remote state changes are in scope.

## Red checkpoint

The implementation files remain byte-identical to the baseline. The new file is
`std/tests/package_contract_v1_test.dew`. Each rejected artifact has valid framing
and a correct SHA-256 trailer, so checksum rejection cannot hide a semantic gap.
The test runner executes all tests even after an assertion trap.

A saved compiler is used without rebuilding it. Its source commit is not known;
this is a narrow functional probe of the exact on-disk Dew sources, not evidence
of a fresh native build of the baseline. The executable is:
`/home/dev/Projects/dewdrop/_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe`.
SHA-256: `73a57efc6454d0ef7b4755f3c9979561c146a1cad182778d044c32890658b626`.
The loader uses `DEW_STD_ROOT` below and interface/program caches are disabled.

The first test compile exposed a missing `dew.std.fixed_array` import. It exited 1
with `NoMatchingMethod` at the digest access. The import was added before the
behavior run. This setup failure is not counted as bug evidence.

The local harness is `/tmp/pkg-phase1-std-evidence/run.py`; command:
`python3 /tmp/pkg-phase1-std-evidence/run.py red`.
It uses subprocess timeouts of 30 seconds and records separate stdout, stderr,
exit status, wall time, and source hashes. This wall time records a functional
check, not a performance measurement.

Environment overrides:
```json
{
  "DEW_STD_ROOT": "/home/dev/.t3/worktrees/dewdrop/t3-21223c02",
  "DEW_INTERFACE_CACHE": "0",
  "DEW_PROGRAM_CACHE": "0",
  "DEW_CACHE_PACK": "0",
  "DEW_CACHE_DIR": "/tmp/pkg-phase1-std-evidence/cache"
}
```

Compile command:
```json
[
  "/home/dev/Projects/dewdrop/_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe",
  "/tmp/pkg-phase1-std-evidence/red.wasm",
  "main",
  "main",
  "std/tests/package_contract_v1_test.dew",
  "/home/dev/.t3/worktrees/dewdrop/t3-21223c02/std/tests/package_contract_v1_test.dew"
]
```
Compile exit: 0; wall seconds: 0.7757585410145111.
Compile stdout:
```text
wrote self-describing Dew test module
```
Compile stderr: empty.

Execution command:
```json
[
  "node",
  "--no-liftoff",
  "/home/dev/.t3/worktrees/dewdrop/t3-21223c02/tools/dew-test/run.mjs",
  "--wasm",
  "/tmp/pkg-phase1-std-evidence/red.wasm",
  "--label",
  "package contract v1"
]
```
Execution exit: 1; wall seconds: 0.19162290001986548.
Execution stdout: empty.
Execution stderr (all check names and failure reasons):
```text
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 manifest decode rejects invalid package name: unexpected trap unreachable: assertion failed: manifest decoder accepted invalid package name
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 manifest decode rejects invalid dependency name: unexpected trap unreachable: assertion failed: manifest decoder accepted invalid dependency name
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 public manifest rejects invalid Git enum strings: unexpected trap unreachable: assertion failed: invalid Git requirement validated
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 public artifact rejects invalid Git enum strings: unexpected trap unreachable: assertion failed: artifact invalid Git requirement validated
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects invalid package name: unexpected trap unreachable: assertion failed: artifact decoder accepted invalid package name
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects invalid dependency name: unexpected trap unreachable: assertion failed: artifact decoder accepted invalid dependency name
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects duplicate dependencies: unexpected trap unreachable: assertion failed: artifact decoder accepted duplicate dependencies
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects duplicate sources: unexpected trap unreachable: assertion failed: artifact decoder accepted duplicate sources
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact requires Dew sources: unexpected trap unreachable: assertion failed: non-Dew source accepted
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact rejects reserved manifest directory: unexpected trap unreachable: assertion failed: manifest directory source accepted
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact rejects forward path prefix conflicts: unexpected trap unreachable: assertion failed: forward path prefix conflict accepted
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact rejects reverse path prefix conflicts: unexpected trap unreachable: assertion failed: reverse path prefix conflict accepted
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode checks unsafe paths: unexpected trap unreachable: assertion failed: unsafe source path decoded
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects empty source set: unexpected trap unreachable: assertion failed: empty source set decoded
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 Git enum must retain its variant: unexpected trap unreachable: assertion failed: Git enum accepted exact version text
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decoder checks provenance: unexpected trap unreachable: assertion failed: artifact decoder accepted empty source
package contract v1: 2 passed, 16 failed
```

Input SHA-256 values:
```json
{
  "/home/dev/Projects/dewdrop/_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe": "73a57efc6454d0ef7b4755f3c9979561c146a1cad182778d044c32890658b626",
  "std/package.dew": "0a44c7c928a5acf1e9c484d0022d5d3d5204d2b868e72248e30b687ad222db8b",
  "std/package/artifact.dew": "68e50bd71324cb00f9417ab56679a8cb3083c1b58024c530c973df31ae4ce324",
  "std/tests/package_contract_v1_test.dew": "7d2b346e29c9eb58f25a16cb0ca245702b9a98b8970c85a2ec0238b9244d5272"
}
```

## Fix and widened coverage

Test checkpoint: `fe82ffe500236bc93a1e217aa0950758414e06be`.
The code fix applies these narrow changes:

- Apply manifest validation before decode returns a value.
- Validate the public Git requirement variant before encoding. Preserve the
  existing bounded `git+source#ref` grammar; do not add npm URL rules.
- Apply artifact validation before decode returns a value.
- Require `.dew` source paths, reserve the root `dew.json/` prefix, and reject
  file/directory prefix conflicts in either input order without all-pairs scans.
- Keep source, dependency, file-count, encoded-byte, and checksum bounds.

The new checks also protect strict unknown-key/escaped-duplicate handling,
missing dependencies, malformed versions/requirements, test-file inclusion,
shared directories, and the distinct 256 MiB local codec cap. The 64 MiB public
publish cap is a caller policy, not a replacement local codec cap. Symlink and
source-selection checks belong to filesystem callers outside this area.

## Shared callers and held validation

These changes affect `PackageManifest` Decode/Validate/Encode and
`PackageArtifact` Decode/Validate/Encode, including direct public constructors.
Lock and module manifest path semantics must keep their existing relative-path
helper; source-only restrictions belong to the artifact path helper.
Existing strict JSON parsing handles duplicate decoded keys, including escapes.
SemVer parsing already bounds text to 255 bytes and numeric identifiers to U32.

Full native, integration, stress, and Starshine lanes are held. Full standard
library execution, cross-platform builds, and shared-vector integration are also
held pending coordinator input. This report makes no performance claim.

After a quiet-host lease, compare frozen master and branch builds with exact
binary hashes. Measure manifest decode/validate/encode at 0, 1, and 256 direct
dependencies, exact/caret/tilde/Git requirements, valid and rejected input, plus
artifact decode/validate/encode for 1 and 65,536 files, shared/deep directories,
prefix conflicts in both orders, 16 MiB source bounds, and 64/256 MiB encoded
boundaries. Record raw runtime, peak RSS, allocations, bytes copied, and native
host details. Check added validation scans and avoid full-source copies and
O(file-count squared) prefix scans. Keep compiler work below 30 seconds.

## Green checkpoint

The exact same 18 checks now pass. Test source SHA-256 stayed unchanged from the
red run. Implementation input hashes and commands are recorded below. The tested
source is the code delta from `fe82ffe500236bc93a1e217aa0950758414e06be` in the code
checkpoint that contains this section. The compiler executable hash is unchanged.
The test Wasm was built fresh from these on-disk sources, with caches disabled.

Command: `python3 /tmp/pkg-phase1-std-evidence/run.py green`.
Compile exit: 0; wall seconds: 0.9816947809886187.
Compile command is the red command with output `green.wasm`.
Compile stdout:
```text
wrote self-describing Dew test module
```
Compile stderr: empty.
Execution exit: 0; wall seconds: 0.22823493502801284.
Execution command is the red command with input `green.wasm`.
Execution stdout:
```text
package contract v1 passed: 18
```
Execution stderr: empty.

Input SHA-256 values:
```json
{
  "/home/dev/Projects/dewdrop/_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe": "73a57efc6454d0ef7b4755f3c9979561c146a1cad182778d044c32890658b626",
  "std/package.dew": "df0383bb0ce2727b31e7769c4af441caa79b380a27085bda9efe5e2d3e60957b",
  "std/package/artifact.dew": "9b87705c23c2f579bc3b39b02b73832bc3de9235cf0677ae993ddf5cdec83245",
  "std/tests/package_contract_v1_test.dew": "7d2b346e29c9eb58f25a16cb0ca245702b9a98b8970c85a2ec0238b9244d5272"
}
```

`python3 tools/generate_package_std.py` exits 0 and prints
`generated src/standard_sources/standard_package_sources.mbt`.
`python3 tools/generate_package_std.py --check` exits 0 and prints
`checked src/standard_sources/standard_package_sources.mbt`.
`git diff --check` exits 0 with no output.

Artifact decoding now performs the same validation pass used by public encode.
This adds dependency-name/duplicate and source-path/duplicate/prefix set work to
successful decode. Manifest decode adds its bounded dependency validation pass.
Git validation parses only the public Git string variant; exact/caret/tilde/any
values do not incur string rendering or another SemVer parse. The existing Git
syntax is unchanged. The file-prefix check uses one set of full-path StringViews
and probes a view at each slash. It adds no copied path strings and no persistent
directory set. Each path view can still require a runtime value; allocation cost
must be measured after the hold. Work grows with file count, path byte count,
and the sum of prefix lengths hashed at separators, not with all file pairs.
The path length remains bounded at 4,096 bytes. No file-content copy was added.
The artifact encoder's existing payload/trailer copy remains unchanged.

Module and lock path rules did not change. The local 256 MiB cap, 16 MiB source
cap, 256 dependencies, and 65,536 source-file cap did not change. No public
publish helper was added: 64 MiB is a transport policy owned by the publisher.

## Public SemVer red checkpoint

Code checkpoint for the first green set:
`bbda0fa703f95c8a92951aa582784da020fbaf14`.
Static follow-up found that SemVer fields are public, not parser-only.
`docs/spec.md` states that fields without `private` are public. A caller can
construct `SemVer::{ ... text: "01.0.0" }`, and each requirement variant can hold
this unchecked value. The first fix therefore left a real encode/validate gap.
The next five checks cover public manifest/artifact versions and exact, caret,
and tilde variants, including leading zeros, malformed identifiers, and U32
core/prerelease overflow. All five fail on the first fix, while its original 18
checks pass (compile exit 0, 1.268208222 seconds; run exit 1, 0.275136998 seconds).

The first baseline fixture setup failed because its parent `std` directory was
missing. It ran no baseline check. The fixture was repaired, then both package
files were compared byte-for-byte with `git show 20f902ac:<path>` before use.
Other standard files are symlinks to unchanged worktree source. No production
source was reverted or overwritten. No broad compiler build ran.

Baseline command:
`CONTRACT_STD_ROOT=/tmp/pkg-phase1-std-evidence/baseline python3 /tmp/pkg-phase1-std-evidence/run.py red-semver-baseline`.
The harness sets `DEW_STD_ROOT` to that fixture; other overrides stay as above.
The compiler and test runner commands are as above with
`red-semver-baseline.wasm`. All 23 checks run against the original baseline
package implementation. The five new failures are thus reproduced on untouched
baseline source as well as the current code checkpoint.

Compile exit: 0; wall seconds: 1.0124049119767733.
Compile stdout:
```text
wrote self-describing Dew test module
```
Compile stderr: empty.
Run exit: 1; wall seconds: 0.3951608630013652.
Run stdout: empty.
Run stderr:
```text
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 manifest decode rejects invalid package name: unexpected trap unreachable: assertion failed: manifest decoder accepted invalid package name
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 manifest decode rejects invalid dependency name: unexpected trap unreachable: assertion failed: manifest decoder accepted invalid dependency name
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 public manifest rejects invalid Git enum strings: unexpected trap unreachable: assertion failed: invalid Git requirement validated
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 public artifact rejects invalid Git enum strings: unexpected trap unreachable: assertion failed: artifact invalid Git requirement validated
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects invalid package name: unexpected trap unreachable: assertion failed: artifact decoder accepted invalid package name
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects invalid dependency name: unexpected trap unreachable: assertion failed: artifact decoder accepted invalid dependency name
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects duplicate dependencies: unexpected trap unreachable: assertion failed: artifact decoder accepted duplicate dependencies
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects duplicate sources: unexpected trap unreachable: assertion failed: artifact decoder accepted duplicate sources
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact requires Dew sources: unexpected trap unreachable: assertion failed: non-Dew source accepted
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact rejects reserved manifest directory: unexpected trap unreachable: assertion failed: manifest directory source accepted
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact rejects forward path prefix conflicts: unexpected trap unreachable: assertion failed: forward path prefix conflict accepted
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact rejects reverse path prefix conflicts: unexpected trap unreachable: assertion failed: reverse path prefix conflict accepted
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode checks unsafe paths: unexpected trap unreachable: assertion failed: unsafe source path decoded
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decode rejects empty source set: unexpected trap unreachable: assertion failed: empty source set decoded
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 Git enum must retain its variant: unexpected trap unreachable: assertion failed: Git enum accepted exact version text
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 artifact decoder checks provenance: unexpected trap unreachable: assertion failed: artifact decoder accepted empty source
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 public manifest checks SemVer text: unexpected trap unreachable: assertion failed: invalid public manifest version validated
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 public artifact checks SemVer text: unexpected trap unreachable: assertion failed: invalid public artifact version validated
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 public exact checks SemVer text: unexpected trap unreachable: assertion failed: invalid public SemVer requirement validated
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 public caret checks SemVer text: unexpected trap unreachable: assertion failed: invalid public SemVer requirement validated
FAIL main::std/tests/package_contract_v1_test.dew::contract v1 public tilde checks SemVer text: unexpected trap unreachable: assertion failed: invalid public SemVer requirement validated
package contract v1: 2 passed, 21 failed
```
Input SHA-256 values:
```json
{
  "/home/dev/Projects/dewdrop/_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe": "73a57efc6454d0ef7b4755f3c9979561c146a1cad182778d044c32890658b626",
  "/tmp/pkg-phase1-std-evidence/baseline/std/package.dew": "0a44c7c928a5acf1e9c484d0022d5d3d5204d2b868e72248e30b687ad222db8b",
  "/tmp/pkg-phase1-std-evidence/baseline/std/package/artifact.dew": "68e50bd71324cb00f9417ab56679a8cb3083c1b58024c530c973df31ae4ce324",
  "std/tests/package_contract_v1_test.dew": "d6ef4ddcb5f5ec3d10448e65d091fe2039b334535247904de9569a4add17e5f1"
}
```

The required fix is to validate rendered SemVer text through the existing strict
parser for public version and requirement values. This adds bounded parser work
and allocations to encode/validate callers. A type-privacy change could remove
that need, but it changes an API outside this assignment. No such API change is
proposed in this patch. Measurements remain held and must include this new work.

## Public SemVer green checkpoint

Test checkpoint: `94e159f5f116da8eff9b1f0fa365d1b25f9bac9a`.
The same 23 checks pass with unchanged test source. The version and requirement
validators reuse `semver_parse` on the wire text. No new SemVer grammar, version
codec, or Git grammar is introduced. This checks encoded text, not a claim that
all public SemVer internal fields are consistent with that text for unrelated
SemVer arithmetic APIs.

Command: `python3 /tmp/pkg-phase1-std-evidence/run.py green-semver`.
Compile exit: 0; wall seconds: 0.9932756000198424.
Compile stdout:
```text
wrote self-describing Dew test module
```
Compile stderr: empty.
Execution exit: 0; wall seconds: 0.21480105601949617.
Execution stdout:
```text
package contract v1 passed: 23
```
Execution stderr: empty.
Commands match the first red commands with output/input `green-semver.wasm`.
Input SHA-256 values:
```json
{
  "/home/dev/Projects/dewdrop/_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe": "73a57efc6454d0ef7b4755f3c9979561c146a1cad182778d044c32890658b626",
  "std/package.dew": "68a596acd1d9ed4a04a2c87c8bcfb8732f82b31bf50b5fcceaa32c912bb0a1a1",
  "std/package/artifact.dew": "35966ea77aba5f2eecc52dbcc413ba15f0c6db677804a223fe356655ed3656a1",
  "std/tests/package_contract_v1_test.dew": "d6ef4ddcb5f5ec3d10448e65d091fe2039b334535247904de9569a4add17e5f1"
}
```

The embedded source mirror was regenerated and its `--check` passed, exit 0.
`git diff --check` also passed, exit 0, with no output.

Performance addendum: this final fix supersedes the first checkpoint's statement
that only Git requirements parse during validation. Public exact/caret/tilde
requirements and package version text now also parse, because public SemVer fields
can bypass both checked factories. Successful decode currently repeats that
bounded parse during final validation. This allocates the parser's result state;
it does not render/copy exact version text or file contents. Reuse of the current
strict parser keeps all codecs on the same grammar. A quiet-host lease is needed
to measure this cost and the added path views. Include no-dependency manifests,
256 SemVer dependencies, prerelease/build strings at 255 bytes, and early/late
rejections in that comparison. No runtime or memory improvement is claimed.
