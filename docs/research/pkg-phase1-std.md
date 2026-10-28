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

Pending after this test-only checkpoint. The intended narrow fixes are:

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
