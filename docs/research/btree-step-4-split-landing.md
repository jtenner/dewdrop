# B-tree step 4 split landing

Base master: `20f902acb6caa56a49712df832aeb0c46ec520b8`.
Source branch: `fix/burn-dewdrop-r1` at `aa5de4c7b2770697245e21259cbd7df9bc0abb61`.
Step 4 source commit: `d23570464feaef37be7876e4d210516865d118e5`.

## Files to carry

- `docs/research/btree-build-status.md`
- `docs/research/btree-step-4-plain-splits.md`
- `docs/research/data/btree-step-4/measurements.json`
- `docs/research/data/btree-step-4/reviews.json`
- `docs/research/data/btree-step-4/tuning.json`
- `src/standard_sources/standard_btree_sources.mbt`
- `std/README.md`
- `std/collections/btree.dew`
- `std/tests/btree_plain_fit_test.dew`
- `std/tests/btree_plain_splits_test.dew`
- `std/tests/btree_split_transition_test.dew`
- `tools/btree-fit/diagnostics.mjs`
- `tools/btree-fit/record.py`
- `tools/btree-splits/carriers.dew`
- `tools/btree-splits/check-arithmetic.py`
- `tools/btree-splits/control-instructions.mjs`
- `tools/btree-splits/diagnostics.mjs`
- `tools/btree-splits/physical.dew`
- `tools/btree-splits/run.mjs`
- `tools/dew-test/assemble.py`
- `tools/test-btree-plain-fit.py`
- `tools/test-btree-plain-splits.py`

## Commits to leave behind

- `e32732813a1372cbefd93cd1577ac67a111498a8`: fix(std): reject empty semantic version suffixes
  - `docs/burn-fix-dewdrop-r1.md`
  - `src/standard_sources/standard_package_sources.mbt`
  - `std/semver.dew`
  - `std/tests/semver_suffix_test.dew`
- `75b47bda072364dbcc4c3821516d74984139478f`: fix(std): accept module manifests within documented limits
  - `docs/burn-fix-dewdrop-r1.md`
  - `docs/research/package-formats-and-semver-2026-08-17.md`
  - `src/standard_sources/standard_package_sources.mbt`
  - `std/package.dew`
  - `std/tests/module_manifest_limits_test.dew`
- `4223aad88d9971f9fc6e03051d707fad03377a41`: fix(std): validate constructed Git dependencies
  - `docs/burn-fix-dewdrop-r1.md`
  - `docs/research/package-formats-and-semver-2026-08-17.md`
  - `src/standard_sources/standard_package_sources.mbt`
  - `std/package.dew`
  - `std/package/artifact.dew`
  - `std/tests/package_requirement_validation_test.dew`
- `51704ea0e77fa4380f227e31aa50d22543a546fb`: fix(std): report the invalid semantic version identifier byte
  - `docs/burn-fix-dewdrop-r1.md`
  - `src/standard_sources/standard_package_sources.mbt`
  - `std/semver.dew`
  - `std/tests/semver_identifier_error_test.dew`
- `aa5de4c7b2770697245e21259cbd7df9bc0abb61`: docs: close Dewdrop burn fix R1 search record
  - `docs/burn-fix-dewdrop-r1.md`

## Shared log

`docs/burn-fix-dewdrop-r1.md` is the only shared file. It was added by the empty-suffix fix. Step 4 adds a separate section plus search-log edits. Leave the complete file behind. This note records the B-tree split without the other fixes. The step 4 note links to this split note in place of the excluded burn log. All code and tests are copied without edits.

## Acceptance

B-tree work has a performance-measurement exemption from Joshua on 2026-10-26. This landing uses correctness tests only. No runtime benchmark is needed. The semantic-version fixes keep their measurement hold.

## Stage 2 test-count repair

Joshua approved this test-only scope change on 2026-10-26. It is a separate commit from step 4. Change only the wildcard module count from 79 to 80 and its dependency count from 76 to 77 in `src/semantic/module_system_wbtest.mbt`. No compiler or runtime code changes.

Stage 2 commit `4e5fa46fa9e208c47407a0abff07bdef684d1fab` added `dew.std.collections.btree` to wildcard imports but did not update these counts. It is an ancestor of master `20f902acb6caa56a49712df832aeb0c46ec520b8`. The full unchanged-master native suite passes 1,925/1,925 tests. Its integration lane passes 274/275 tests; the original wildcard test fails at `80 != 79`.

The original test stops at its first failed check. Two independent probes repeat its exact manifest setup and each old count. Run them on unchanged master with Moon's in-memory white-box test overlay, selecting the semantic package. Both fail: module count `80 != 79`, dependency count `77 != 76` (2 tests, 0 passed, 2 failed; exit 2; 8.974 seconds). Master's tracked files and worktree remain unchanged. This proves both count failures predate step 4. The probe source, command, stdout, stderr, source hash and exit status are in `/tmp/dewdrop-btree-step4-landing/probes/`.

The repair changes test expectations only. It has no production runtime path, allocation, or memory change.

## Saved validation and approved snapshot exclusion

Tested source: `fd5ae682dae55b0cdf93e05ff418fad7961bfc50`. Binaries were rebuilt from that source; binary hashes are in [the validation record](data/btree-step-4/landing-validation.json). The later report commit changes documentation only.

| Lane | Landing | Unmodified master |
|---|---:|---:|
| Native | 1,925/1,925 | 1,925/1,925 |
| Integration | 275/275 | 274/275; old wildcard count |
| Stress | 15/15 | 15/15 |
| Standard library | 355/355 | 355/355 |
| Private B-tree | 41/41 raw; 41/41 O4s | 24/24 raw |
| Public B-tree providers | 8/8 | Included in standard library suite |
| Module snapshots | 453/461 | 453/461 |
| Pinned Starshine, matching SDK | 15,236/15,236 | Newer SDK build issue reproduced before tests |

The step 4 transition test is part of both 41-test private runs. Exact diagnostics, raw/O4s validation, reference cleanup checks, and all four expected negative controls pass. Generated B-tree source and split arithmetic checks pass. There are 42 further runtime probe groups with 4,121 checks; SWAR, UTF, and WASI parity pass 61,000, 17,471, and 196 checks. All 85 architecture WAT cases pass.

The eight WAT mismatches are identical on master and the landing branch. Both runs check all 461 fixtures. The expected diagnostics and Node/Wago output match before each failing WAT comparison. The saved diff hashes match for every affected file:

- `tests/module-snapshots/collections/binary-heap-runtime.wat`
- `tests/module-snapshots/generics/bounded-function-reference-runtime-evidence.wat`
- `tests/module-snapshots/generics/generic-enum-adapter-runtime.wat`
- `tests/module-snapshots/generics/generic-erased-scalar-adapter-runtime.wat`
- `tests/module-snapshots/modules/imported-bounded-function-reference-runtime-evidence.wat`
- `tests/module-snapshots/text/show-collections-runtime.wat`
- `tests/module-snapshots/text/show-derived-runtime.wat`
- `tests/module-snapshots/types/derive-debug-runtime.wat`

These failures predate step 4. Joshua ruled on 2026-10-26 that this landing must exclude all eight WAT fixture files. Their identical drift on master is accepted for this step 4 landing. The fixture refresh will be a separate small change after this landing. No fixture was changed. The proposed future patch is `/tmp/dewdrop-btree-step4-landing/preexisting-wat-snapshots.patch`; it is not part of this landing.

The full pinned Starshine suite passes all 15,236 tests with the matching Moon SDK after the local fixture setup described below. All measurement quiet holds were closed or released before this final correctness rerun.

The B-tree tool build took 398.889 seconds, above the 30-second compiler activity limit. One unchanged native test file, `src/compiler_driver/transforms_methods_wbtest.mbt`, also exceeded that limit. Raw elapsed logs are preserved. These runs are correctness checks; no runtime benchmark or allocation sampling ran. The B-tree measurement exemption applies.

The landing base is master `20f902acb6caa56a49712df832aeb0c46ec520b8`. The excluded semver/package files still match that base. `fix/burn-dewdrop-r1` remains unchanged at `aa5de4c7b2770697245e21259cbd7df9bc0abb61`. Final publication and head verification are recorded in the task handoff and `/tmp/dewdrop-btree-step4-landing/push-verification.json`.

## Final scope ruling (Joshua, 2026-10-26)

Land step 4 plus the approved stage 2 two-count repair, with that repair in its own commit. Do not include the eight WAT fixture files. The proven pre-existing snapshot drift does not block this scoped landing. Keep the semver fix and all other package fixes on `fix/burn-dewdrop-r1`.

The comparison `WINDOW CLOSED` and V20 `RELEASE` messages closed the quiet holds. The existing owner authorization permits this scoped landing and push. No performance measurement lease was used.

## Final SDK and fixture setup (2026-10-28)

The shared Moon SDK had changed from `0.1.20261012` to `0.1.20261023` during the holds. With the newer SDK, the unchanged Starshine pin fails to compile on both master and the landing branch: `Result.is_ok`, `Result.is_err`, and `Int.reinterpret_as_float` are missing. Both commands stop before running tests.

A cached complete SDK archive at `/tmp/moon-tc.tar.gz` has SHA-256 `6edefa7e433ef4d598c16de3ef9ebad4f35b6116aca45f36d07bf238a9b915c3`. It provides Moon `0.1.20261012`, moonc `v0.10.15+943464bfa`, and the matching core. It was verified and extracted to `/tmp/dewdrop-btree-step4-landing/moon-sdk-20261012`. Per-command `MOON_HOME` and `PATH` select it. The shared SDK and repository source were not changed for this setup repair.

The first compatible-SDK full run passed 15,235/15,236 tests. The single failure required the local parent directory `starshine-mb/.tmp`. Creating that parent made the same focused case pass (1/1). The test still creates its own unique output child and checks that it contains generated files. A final full run with this setup passes 15,236/15,236 tests, exit 0.

The final command is `bash tools/test-starshine-native.sh -j 4` with the isolated SDK selected. Logs, command, source pin, SDK hashes, exit status, and elapsed time are in `/tmp/dewdrop-btree-step4-landing/starshine-rerun/` and the committed validation record. No runtime source or WAT fixture change was needed.
