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
The corrected run has 49 matching results and 72 differences. These counts
are in the saved stdout summary and are not a full-reader coverage claim.

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


## Checkpoint 3: batch bridge and passing harness

Red test checkpoint: `1f1084e0cd3837c787a390cc6c30376b68ad77ad`.
The red command is `node --test tests/package-contract-v1/harness.test.mjs`.
It returned exit 1: 8 bridge tests failed with `ERR_MODULE_NOT_FOUND` for the
not-yet-added bridge, and 3 existing helper tests passed. This is evidence for a
new harness feature, not evidence of a production parser bug.

The SAME command and test file now return exit 0: all 11 checks pass. The bridge
starts one process with an argv array, passes only requests, checks result IDs
and diagnostics, and exposes child stderr/status. Output is bounded to 8 MiB,
and the child has a 30-second deadline. The main runner calls optional adapter
`prepare(cases)` once before per-case comparison. A separate `emit.mjs` exports
expanded cases, WITH answers, for language-specific test generation. It never
feeds answers to a reader under test.

`evidence/harness-green.json` records the exact command, prior head, exit status,
full stream paths, and SHA-256 of every tested code/data file. No test source
changed after this run. This source map verifies the interpreted test code; no
compiled Dew executable was involved. The matching stdout reports 11 pass and
0 fail. `evidence/functional.json` records six further narrow checks with exact
argv, environment overrides, stdout, stderr, and expected/actual exit status:

1. Generator output is byte-identical on a repeat run.
2. An explicit unsupported artifact-path request exits 2.
3. The JSONL CLI adapter accepts a negative protocol-fixture result, exit 0.
4. It exposes a wrong protocol-fixture result, exit 1, with the exact case ID.
5. Expanded generator output keeps the escaped duplicate-key input unchanged.
6. The SAME full baseline command still returns 1, with stdout and stderr
   byte-identical to checkpoint 1: 49 match, 72 differ, 58 unsupported.

At checkpoint 3 there is no production green claim. Other workers own the
fixes and real reader adapters. The later JS coordination result is below. The generic runner enforces acceptance, expected output fields, and a
nonempty rejection diagnostic. It does not itself prove that a rejection came
from the intended parser error. Each production adapter must check its reader's
specific error when that distinction is available. Static byte/budget fixtures
are not a replacement for real binary codec and restoration checks.

The first commit attempt returned exit 128 with `Author identity unknown` and
`fatal: unable to auto-detect email address`. The local environment had no Git
author. Commits use command-scoped `-c user.name=Codex` and
`-c user.email=codex@openai.com`; no stored Git configuration changed.

## Handoff points

Use fixture checkpoint `7bcb9edd0377e3c0f0b914fd72f22ff2d9caf785` first if other
workers need the data before the bridge commits. Preserve stable case IDs and
schema version 1. The whole branch also adds the checked batch bridge.
No production file or other worker's note/test is changed.

Rule points for the coordinator: preserve the Dew Git grammar and narrow
prerelease predicate; confirm all hash/capsule paths use full logical path sort;
prove trailing `-`/`+` behavior in the real Dew parser; check Windows absolute
paths without inventing a broader filename policy. These points are explained
in `package-contract-v1.md`. This area cannot close the native, platform, source
race, lock graph, restore, binary cap, or performance gates.

## Checkpoint 4: coordinated JS reader agreement

Prior harness head: `0714abd2c81b9c230579458d8074c6e1e0f3eec5`.
The coordinator supplied the completed JS module at
`/home/dev/.t3/worktrees/dewdrop/t3-e477a636/tools/dew-package-contract.mjs`,
head `588cf363c2f9970ca698d44639c57d7a23bce731`.
That worktree was clean. It was read only. No peer file changed here.
The coordinator also confirmed that drive-prefixed `C:/x.dew` paths are unsafe;
the existing shared vector already has this rule.

`adapters/javascript.mjs` calls that module's real parse/read/collect/encode API.
The fixture and baseline regression checkpoints existed before this adapter.
This runs the SAME contract cases that were red on the old publisher. The
adapter sets valid surrounding fields for individual name/version/request cases;
manifest JSON is passed raw. It writes bounded fixture files for the file-reader
mode and source inventory. Path cases call the real encoder with one-byte source
buffers. It checks the intended rejection diagnostic for every negative case,
with OS/setup faults left visible. Ten exported MAX_* constants also agree with
the shared limits file; this does not prove large-input cap enforcement.

Both `DEW_CONTRACT_JS_ENTRY=parse` and `DEW_CONTRACT_JS_ENTRY=read` return exit 0:
149 pass, 0 fail, 30 unsupported. The 121 cases run on the old reader now all
pass; another 28 artifact path cases pass through the real encoder, including
duplicate/prefix conflicts in both orders and the Windows drive-root case.
The old baseline was 49 match and 72 differences for its 121 cases. There is no
claim of a baseline artifact-path check, because that baseline adapter did not
support artifact-path records.

`evidence/javascript.json` records the exact commands, environment overrides,
production head, production module hash, adapter hash, and full stream paths.
Each subprocess had a 30-second timeout. No compiler or network was invoked.
The production module hash was unchanged before and after the run. These are
narrow functional results, not performance measurements. All changes in this
worktree are still within the assigned test/docs area.

The remaining 30 cases are 18 requirement matches and 12 numeric budget inputs.
The JS module has no version-match API and these checks did not allocate large
sources or capsules. Native/bootstrap/Dew and affected-platform checks, real
large source/file-count/encoded-cap checks, source-race checks, lock traversal,
restoration, and the quiet-host performance gate remain with the coordinator.
No rule or API adjustment is needed for the JS functions tested here. The
previous static Dew parser and shared hash-order points still need owning-worker
checks. Use the earlier workload proposal after the timing hold is lifted.

## Complete changed file list

- `docs/research/package-contract-v1.md`
- `docs/research/pkg-phase1-contract.md`
- `tests/package-contract-v1/README.md`
- `tests/package-contract-v1/adapters/baseline-registry.mjs`
- `tests/package-contract-v1/adapters/javascript.mjs`
- `tests/package-contract-v1/adapters/jsonl-reader.mjs`
- `tests/package-contract-v1/artifact-budgets.json`
- `tests/package-contract-v1/artifact-paths.json`
- `tests/package-contract-v1/emit.mjs`
- `tests/package-contract-v1/evidence/baseline.json`
- `tests/package-contract-v1/evidence/baseline.stderr`
- `tests/package-contract-v1/evidence/baseline.stdout`
- `tests/package-contract-v1/evidence/functional.json`
- `tests/package-contract-v1/evidence/harness-green.json`
- `tests/package-contract-v1/evidence/harness-green.stderr`
- `tests/package-contract-v1/evidence/harness-green.stdout`
- `tests/package-contract-v1/evidence/harness-red.json`
- `tests/package-contract-v1/evidence/harness-red.stderr`
- `tests/package-contract-v1/evidence/harness-red.stdout`
- `tests/package-contract-v1/evidence/javascript-parse.stderr`
- `tests/package-contract-v1/evidence/javascript-parse.stdout`
- `tests/package-contract-v1/evidence/javascript-read.stderr`
- `tests/package-contract-v1/evidence/javascript-read.stdout`
- `tests/package-contract-v1/evidence/javascript.json`
- `tests/package-contract-v1/generate.py`
- `tests/package-contract-v1/harness.test.mjs`
- `tests/package-contract-v1/jsonl.mjs`
- `tests/package-contract-v1/limits.json`
- `tests/package-contract-v1/manifests.json`
- `tests/package-contract-v1/names.json`
- `tests/package-contract-v1/requirement-matches.json`
- `tests/package-contract-v1/requirements.json`
- `tests/package-contract-v1/run.mjs`
- `tests/package-contract-v1/semver.json`
- `tests/package-contract-v1/source-selection.json`
- `tests/package-contract-v1/support/jsonl-reader.mjs`
- `tests/package-contract-v1/vectors.mjs`
