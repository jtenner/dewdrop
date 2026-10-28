# Phase 1 package contract report

Status: **READY TO MEASURE, on HOLD**.

Branch: `coordinate/dewdrop-pkg-phase1`.
Base master: `20f902acb6caa56a49712df832aeb0c46ec520b8`.
Plan: `c812b052:docs/package-manager-migration-plan.md`.
Frozen production source: `3ac2506d9b13a033979470e0a344a8977a0f0190`.
Final test repair and validation head:
`788cf198b9397e29833ae317df220be2e78f6a95`.
The final branch head, including this report, is in the handback. Only the
harness and reports changed after the production source freeze.

The owner then reserved the laptop for V20. All owned build, test, guest-run,
and timing processes exited. No new build, test, guest run, or timing started
after receipt of that hold message. This report and its evidence archive use saved results and
static file operations. Wait for `RELEASE`, then obtain the designated
coordinator's current exclusive lease before any timing. READY TO MEASURE is a
work handoff, not a lease or a claim that the full validation gates have passed.

No server, box, WorkOS, dewdrop-pm, registry data, or production host changed.
No package was published. No branch was pushed, PR made, or master merge done.
Muse must review this integrated branch before landing work starts.

## Result

The local readers use the v1 name, bounded SemVer, dependency, schema, duplicate
key, source-selection, path, and size rules covered by the shared cases. Missing
`dependencies` means an empty object. Strict checks cover direct decode and
public encode/validate paths. The bootstrap also checks existing materialized
locks, requests, identity, Git source, containment, integrity, store, and restore.

`dew pack` and `dew publish --dry-run` prepare `package.dpa` and `INPUTS.json`
without credential reads or network calls. Build, interface, source integrity,
and capsule bytes use one captured package, dependency, and standard-source
snapshot. Original manifest and lock bytes are checked before canonicalization.
Normal publish uses the same preparation path.

The source-file cap is 16 MiB. The complete publish capsule cap is 64 MiB,
including framing and checksum. Local artifacts retain their separate 256 MiB
cap. Manifests keep 1 MiB; locks keep 8 MiB. Direct dependencies have a 256-record
cap, local locks 4,096 records, and source inventories 65,536 files.

The local input record is not a public release descriptor. It marks the missing
compiler build identity and future release data as absent. Public GitHub source,
an existing remote tag, release metadata, and server acceptance belong to later
publish work. The owner's six program decisions remain in force. This phase
does not add organization scopes, a device-code service, or a new server repo.

## All seven gaps and failing-first evidence

“Master” below means the exact pinned source, not the current moving branch.
Bootstrap checks build a small driver from those real source functions. Dew
codec checks compile the exact source files with a saved test compiler whose
source commit is unknown. That limit applies to all Dew codec results.

| Gap | Check name and master result | Integrated result and scope |
| --- | --- | --- |
| 1. Missing dependencies | JS `manifest: absent dependencies means own empty object`: the old capsule rejects the valid minimal manifest. | Pass. JS, native, and Dew readers accept absence as `{}`. The local pack path also has an absent-dependencies check. |
| 2. Split validation | Native `manifest unknown field`: master exits 0 and prints a loaded package. Dew `contract v1 manifest decode rejects invalid package name`: master accepts it. JS unknown/duplicate/name/version/request cases also fail on master. | Pass. Unknown fields, decoded duplicate keys, names, bounded SemVer, requests, paths and bounds have common cases. The same final 187 Dew shared cases give 139 pass/48 fail on master, then 187 pass on branch source. |
| 3. Missing commands | `pack retains capsule and local INPUTS without credentials or network`: master exits 2 with `unsupported registry command`. `shell routes pack to the script without a native build`: the old route enters mock Moon and exits 91. | Pass for local `pack` and publish dry-run. Network add/install/search/resolve/update/remove/info remain Phase 5. They are not claimed fixed. |
| 4. Separate source reads | `publish keeps capsule sources fixed after build` and `publish keeps capsule sources fixed after integrity`: master reports changed build/integrity/capsule inputs. `snapshot fixes dependency graph and rewrites lock paths` also exposes a changed graph. | Pass. Source, manifest, lock and dependency mutations do not change the captured inputs. Failure and cleanup checks also pass. These are local mock-compiler checks, not a real publish or full compiler integration run. |
| 5. Unproved persistence/listing | No local check can establish server persistence, public listing, or immutable download. | Not fixed in Phase 1. Phase 4 needs server work and an end-to-end release check. No false failing-first or server-success claim is made. |
| 6. Weak lock checks | Native `graph identity`: master exits 0 with `ok modules=2`. `lock entry escaped duplicate` exits 0. `store identity` exits 0 with `ok stored`. Range, Git-source, path and early-restore-write checks also expose master failures. | Pass in the narrow driver. It rejects invalid requests/records before unsafe reads or restore writes, and checks actual identity/integrity. Dew lock decode and public value checks now agree with encode. Original snapshot locks retain duplicate/unknown/UTF-8 errors instead of losing them during rewrite. Full compiler-observed interface execution remains queued. |
| 7. Expiry/revoke status | Auth changes are expressly outside this phase. No new auth check is claimed. | Not fixed in Phase 1. Phase 3 owns native WorkOS auth, expiry, refresh and visible revocation results. Pack does not fix or exercise remote auth. |

Per-area red/green records and exact commands are in `pkg-phase1-javascript.md`,
`pkg-phase1-bootstrap.md`, `pkg-phase1-std.md`, `pkg-phase1-pack.md`, and
`pkg-phase1-contract.md`. Integration findings, setup errors, fixes, and limits
are in `pkg-phase1-integration.md`. Setup errors are excluded from defect counts.

Additional integration checks were added before their fixes:

- Empty SemVer suffixes: 16 shared failures disappeared after two checks in the
  owning `std/semver.dew` parser. Coverage includes requests, manifests, locks,
  and artifacts. Fixing each package caller separately would leave drift.
- Dew lock decode: ten shared failures disappeared. Two public-value failures
  also disappeared. A name set replaces pairwise duplicate comparisons.
- Original snapshot lock: ten missing rejections became passing checks. Valid
  framing and a valid-lock control keep the test on the intended cause.
- Linked path ancestors: two JavaScript missing rejections became passing checks.
  Native, snapshot, and standalone JS readers now reject linked ancestors.
- Lock version text: two JavaScript missing rejections became passing checks.
  All three readers require literal JSON `1`, not `1.0` or `1e0`.

## Workers and merge order

Five separate worker branches used Sol, high reasoning, and standard speed.
No Claude or extra review agent ran. Each area has test checkpoints before its
code checkpoint. All worker branches and worktrees are retained.

| Order | Branch | Checkpoint commits |
| --- | --- | --- |
| 1 | `t3/package-contract-vectors` | `7bcb9edd0`, `1f1084e0c`, `0714abd2c`, `6fae21cd6` |
| 2 | `t3/javascript-package-contract` | red `158dd8340`; fix `588cf363c` |
| 3 | `t3/bootstrap-manifest-contract` | tests `9e2d120ed`, `0a76aa9b1`, `0fc3e2cc4`, `77692bbcf`, `b62a405bc`, `411fed668`; code `97678a88f`; final note `fcf8e28f7` |
| 4 | `t3/std-package-contract` | red/fix pairs `fe82ffe50`/`bbda0fa70`, `94e159f5f`/`d73cc9855`, `ed5d01382`/`075e9a00c` |
| 5 | `t3/package-pack-snapshot` | tests `e1d5eb3ac`, `29a391a77`; code `2012c41ee` |

The first four areas merged in that order. Only the generated standard mirror
conflicted; it was regenerated from merged sources. The pack worker's three own
commits were then picked as `150f6d7c2`, `aca17e7ea`, and `e01b99892`. Its inherited
copies of JS commits were not picked again. Root integration test/fix checkpoints
are on the branch first-parent log and are described in the integration record.

## Final narrow checks

| Check | Result |
| --- | --- |
| Native contract driver | 157 area checks and 199 shared cases pass; 12 numeric budget cases are explicitly unsupported |
| Shared Dew codecs | 187 pass; filesystem selection and numeric budget recipes are not part of that codec runner |
| Dew area regressions | 27 pass |
| Dew public lock regressions | 3 pass |
| Existing Dew package round trips | 3 selected from 10 pass; the large file-count case was not run |
| JavaScript area, Node and Bun | 108 pass in each runtime |
| Shared JavaScript, parse and manifest-file modes | 181 pass in each mode; 18 range-match and 12 budget cases are explicitly unsupported |
| Pack/snapshot CLI | 34 pass, with mock compiler children and HTTP |
| Original snapshot lock | 11 pass |
| Strict JS lock parser | 24 pass |
| Shared harness | 11 pass after replacing an obsolete inventory-count assertion with named regression controls |
| Existing registry smoke | 1 pass |
| Generated source mirror | Current |

Saved records are in `tests/package-contract-v1/evidence/final/`. They include
raw streams, commands, exit status, source hashes, compiler/driver hashes, and
functional compile durations. The first harness failure is retained. Its later
repair changed no production source. Static hash checks show all current `src/`,
`std/`, and `tools/` inputs match the frozen production check inputs.

The native driver was built from frozen source. Its build warnings are retained,
not hidden. Dew test Wasm was made fresh with standard-source overrides and caches
off. The saved test compiler hash is
`73a57efc6454d0ef7b4755f3c9979561c146a1cad182778d044c32890658b626`;
its source commit is unknown. A fresh full compiler and real `pack` run are still
required. Mock subprocess checks do not replace that gate.

## READY TO MEASURE: queued work

These changes affect runtime and memory. No claim of no performance effect, a
speed gain, or a memory gain is made. Full native, integration, stress, Starshine,
LLVM/platform, large-cap and performance runs remain held. After `RELEASE`, use
the required lanes, including `tools/test-native.sh`,
`tools/test-integration-native.sh`, `tools/test-stress-native.sh`, and
`tools/test-starshine-native.sh`, as appropriate. Add fresh real compiler/pack,
cache restore, and affected native/LLVM checks. Compile-only evidence is not
native execution evidence.

Before timing, the designated coordinator must grant an exclusive quiet-host
lease and pause competing work. Compare frozen master with the integrated head,
using exact compiler binaries and hashes. For preparation work, use equivalent
local build/hash/capsule inputs and suppress upload; master has no pack command.
Record raw samples, native host/architecture, tool versions, source and binary
identity, time, peak RSS, allocations where available, bytes copied, and disk I/O.

| Workload | Inputs and cost to inspect |
| --- | --- |
| Package preparation | Tiny single-source package, 1 MiB package, and a capsule just below/exactly at/above 64 MiB. Keep every source within 16 MiB. Include root fallback, recursive src, and test sources. Measure capture, build, integrity, ABI and encoding separately and end to end. |
| Large inventories | Few large files and many small files, up to 65,536; shallow and deep paths up to logical limits. Check sort cost, metadata calls and path-prefix work. |
| Manifests and locks | 0/1/256 direct dependencies, 0/1/256/4,096 lock records, valid and invalid raw JSON, duplicate and unknown fields, exact/range/Git requests. Include strict decode and public encode. |
| Materialized graphs | Chains, diamonds, shared nodes, identity/request/source mismatch, and a large graph. Check one capture per package, repeated parent checks, source reads, disk footprint and descriptor-input memory. |
| Local artifacts | Encode/decode/store/restore, cache hit and miss, missing-source restore, 16 MiB source edges, over-64-MiB local artifacts and 256 MiB local edges. Check complete v1 bytes and pre-write failures. |
| Shared compiler callers | Local check/build/test/run, source integrity, legacy explicit module manifests, local graph/cache paths, standard codecs and linked-path policy. Rebuild from frozen source. Check interfaces on real programs. |

Source capture copies the chosen root, materialized graph and standard sources.
Its disk and metadata cost grows with those inputs. Per-file reads are bounded;
the transport is still an in-memory capsule, not a streaming upload. Native local
artifact store/restore retain whole-payload and checksum buffers. SemVer and
strict JSON parsing allocate bounded metadata; path/name sets add temporary
storage. Parent checks add metadata calls proportional to depth. The lock name
set removes a pairwise scan, but that is not a measured speed claim.

Reject a clear measured regression until the narrow design is improved. Treat
compiler activity over 30 seconds as a bug. Stop owned timings before returning
a lease. Do not label cross-compilation or emulation as native measurements.

Old local locks/artifacts made with length-first Moon ordering can need new
integrities. The format remains unreleased version 1. Linked ancestor paths are
rejected; aliases used by temporary directories on other hosts need platform
checks. Complete concurrent filesystem replacement hardening is not proven.
No network release, persistence, auth, or install end-to-end pass is claimed.

## Files by area

The exact inventory below includes source, tests, docs, and retained evidence.

### JavaScript contract and lock input

```text
docs/research/pkg-phase1-javascript.md
tools/dew-package-contract.mjs
tools/dew-package-lock.mjs
tools/test_dew_package_contract.mjs
```

### Bootstrap input and cache

```text
docs/research/pkg-phase1-bootstrap.md
src/dew_bootstrap/manifest.mbt
src/dew_bootstrap/package_artifact.mbt
src/dew_bootstrap/package_contract.mbt
src/dew_bootstrap/package_contract_check.py
src/dew_bootstrap/package_contract_driver.mbt.fixture
src/dew_bootstrap/platform.c
src/dew_bootstrap/platform_native.mbt
```

### Dew codecs

```text
docs/research/pkg-phase1-std.md
src/standard_sources/standard_package_sources.mbt
std/package.dew
std/package/artifact.dew
std/semver.dew
std/tests/package_contract_v1_test.dew
std/tests/package_lock_contract_v1_test.dew
```

### Snapshot and pack

```text
docs/research/pkg-phase1-pack.md
tools/dew
tools/dew-package-snapshot.mjs
tools/dew-registry.mjs
tools/test_dew_pack.mjs
```

### Shared checks, report, and evidence

```text
docs/research/package-contract-v1.md
docs/research/package-manifest.md
docs/research/pkg-phase1-contract.md
docs/research/pkg-phase1-integration.md
docs/research/pkg-phase1-report.md
tests/package-contract-v1/README.md
tests/package-contract-v1/adapters/baseline-registry.mjs
tests/package-contract-v1/adapters/javascript.mjs
tests/package-contract-v1/adapters/jsonl-reader.mjs
tests/package-contract-v1/artifact-budgets.json
tests/package-contract-v1/artifact-paths.json
tests/package-contract-v1/emit.mjs
tests/package-contract-v1/evidence/baseline.json
tests/package-contract-v1/evidence/baseline.stderr
tests/package-contract-v1/evidence/baseline.stdout
tests/package-contract-v1/evidence/final/bootstrap-branch.json
tests/package-contract-v1/evidence/final/bootstrap-master.json
tests/package-contract-v1/evidence/final/checks.json
tests/package-contract-v1/evidence/final/std-branch.json
tests/package-contract-v1/evidence/final/std-master.json
tests/package-contract-v1/evidence/final/std-supplement.json
tests/package-contract-v1/evidence/final/streams.json
tests/package-contract-v1/evidence/functional.json
tests/package-contract-v1/evidence/harness-green.json
tests/package-contract-v1/evidence/harness-green.stderr
tests/package-contract-v1/evidence/harness-green.stdout
tests/package-contract-v1/evidence/harness-red.json
tests/package-contract-v1/evidence/harness-red.stderr
tests/package-contract-v1/evidence/harness-red.stdout
tests/package-contract-v1/evidence/javascript-parse.stderr
tests/package-contract-v1/evidence/javascript-parse.stdout
tests/package-contract-v1/evidence/javascript-read.stderr
tests/package-contract-v1/evidence/javascript-read.stdout
tests/package-contract-v1/evidence/javascript.json
tests/package-contract-v1/evidence/std-shared-red.json
tests/package-contract-v1/evidence/std-shared-red.stderr
tests/package-contract-v1/evidence/std-shared-red.stdout
tests/package-contract-v1/generate.py
tests/package-contract-v1/harness.test.mjs
tests/package-contract-v1/jsonl.mjs
tests/package-contract-v1/limits.json
tests/package-contract-v1/lock.test.mjs
tests/package-contract-v1/locks.json
tests/package-contract-v1/manifests.json
tests/package-contract-v1/names.json
tests/package-contract-v1/requirement-matches.json
tests/package-contract-v1/requirements.json
tests/package-contract-v1/run-std.py
tests/package-contract-v1/run.mjs
tests/package-contract-v1/semver.json
tests/package-contract-v1/snapshot-inputs.test.mjs
tests/package-contract-v1/source-selection.json
tests/package-contract-v1/support/jsonl-reader.mjs
tests/package-contract-v1/vectors.mjs
```
