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
