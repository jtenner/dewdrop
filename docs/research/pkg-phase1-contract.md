# Phase 1 contract vector work record

Area: contract-vectors. Date: 2026-10-28.
Branch: `t3/package-contract-vectors`.
Worktree: `/home/dev/.t3/worktrees/dewdrop/t3-21590465`.
Base: `20f902acb6caa56a49712df832aeb0c46ec520b8`.
Approved plan read in full: `c812b052:docs/package-manager-migration-plan.md`.
`AGENTS.md` read. No children or Claude used.

## Checkpoint 1: regression data and baseline probe

This area adds shared test data, test adapters, and documentation only. It owns
no production fix. The canonical local rules and all seven scope gaps are in
`package-contract-v1.md`. Data is in `tests/package-contract-v1/*.json`.
The generator preserves raw manifest text and compact boundary recipes. A small
Node runner compares expected fields and keeps setup errors visible.

The baseline adapter loads exactly the old registry source through `git show`.
It executes capsule/source selection, not source-pattern assertions. It supplies
only test bindings, blocks compiler/network/process calls, and uses disposable
source files. It does not load credentials. Frozen evidence is under
`tests/package-contract-v1/evidence/baseline.*`.

The recorded JSON contains the exact command, production reader commit, test
source base, Node version, stdout path, stderr path, and exit status. The `.stdout`
and `.stderr` files contain the complete captured streams. The capture subprocess
had a 30-second timeout. No compiler was invoked, so there is no compiler wall
time to record. The tool's functional check elapsed time is not a benchmark.

Initial fixture review found a boundary case combined with absent dependencies.
It was corrected BEFORE this checkpoint: byte-boundary manifests have explicit
empty dependencies. Escaped valid keys also have explicit empty dependencies.
This avoids counting an unrelated missing-dependencies rejection as byte-cap or
JSON escape coverage. The saved baseline evidence is from the corrected data.

The baseline run is intentionally red. It is not a completed production fix.
The probe covers 121 checks against the old capsule/source functions. It leaves
58 artifact-path, budget, and range-match checks unsupported and lists every ID.
The final pass/failure counts are in the saved stdout summary.

Specific red checks include `manifest/dependencies-absent`,
`manifest/unknown-field`, `manifest/duplicate-name-escaped`,
`manifest/duplicate-dependency-escaped`, `manifest/dependencies-257`,
`manifest/bytes-1048577`, `name/upper-scope`, `semver/core-overflow`,
`requirement/comparator`, `source-selection/src-regular-file`,
`source-selection/global-logical-sort`, and the symlink source/tree cases.
Each malformed field has nearby valid controls with all other fields valid.
The baseline keeps its own rejection diagnostic. The shared runner requires a
nonempty diagnostic on rejections but cannot map all languages' error codes;
production adapters must check the intended reason as well as acceptance.

## Wider coverage and performance-sensitive callers

The cases cover absence, empty objects, unknown fields, literal/escaped duplicate
keys, data types, name/version/request syntax and byte bounds, U32 limits,
prerelease/build distinctions, existing local match rules, direct dependency
counts, source precedence/order/fallback, test inclusion, symlink refusal,
logical path rules, both prefix record orders, and distinct local/publish caps.
Budget descriptors are preflight inputs, not large encoded artifact evidence.
No source race, checksum, lock graph, cache restore, or platform execution claim
is made from these fixtures.

No production call path changes in this area, so production time and allocation
costs do not change. Test recipe expansion grows with fixture bytes and allocates
one expanded string per recipe. It is bounded to 1,048,577 bytes per expansion.
Cases run sequentially; baseline probe makes a fresh small package for each.
Do not run large artifact construction during the timing hold.

After the coordinator grants a quiet-host lease, measure owning-worker changes
against the frozen base. Cover manifest parsing and duplicate checks at 0, 1,
256 dependencies and 1 MiB; source inventory/hash/capsule preparation for tiny,
65,536-file, deep-tree, and near-16-MiB-file inputs; total encoded capsule limits
at 64 MiB and local artifact limits at 256 MiB. Include compiler source loading,
integrity queries, pack, offline build/check/test/run, artifact decode and source
restoration, and lock graph shared callers. Record exact source and binary
identities, raw native samples, elapsed time, peak RSS, allocations where
available, and I/O bytes. Do not infer speed or memory gains from this check.

## Held checks and phase limits

Full native, integration, stress, Starshine, compiler build, affected-platform,
performance, and memory checks remain HELD by the owner. No server, box, WorkOS,
dewdrop-pm, push, PR, remote publication, or master merge action is authorized.
Gap 3 is local pack only in Phase 1; network install/discovery is Phase 5. Gap 5
persistence/listing is Phase 4. Gap 7 expiry/revoke is Phase 3 and untouched.
Other workers must supply real reader red-to-green evidence after this fixture
commit integrates. This area cannot honestly report that production green yet.

## Checkpoint 2: JSONL bridge checks, before implementation

Fixture checkpoint: `7bcb9edd0377e3c0f0b914fd72f22ff2d9caf785`.
The next test-only feature is a batch JSONL bridge for a separately built reader.
One process receives expanded inputs with IDs, without expected answers. It must
return one result for each ID. This avoids a compiler process per vector and
lets other workers keep their own reader APIs.

`harness.test.mjs` first checks raw escaped-key preservation, positive/negative
results, missing/duplicate/unknown replies, malformed JSON, subprocess stderr
and exit status, and missing executables. `support/jsonl-reader.mjs` is only a
protocol fixture, not a contract parser. Existing helper checks also cover
path-order mismatch detection, rejection diagnostics, compact recipe bounds,
exact manifest byte boundaries, and fixture inventory.

The new bridge is absent at this checkpoint. The recorded red test therefore
shows missing bridge support, not a production reader defect. The SAME test file
will run after the bridge is added. The record under `evidence/harness-red.*`
contains the exact command, source head, stdout, stderr, and exit status.
No compiler or timing workload runs.
