# B-tree build status

Design authority: [btree-design.md](btree-design.md), selected at
`5922ea1a12ede3913f97b9b7bdac1f90343240f1`.
Upstream authority: bbtree `8adae97a0ed97e5c98fa2790312eb0aec9719846`.
Integration branch: `feat/btree-integration`.
Initial local master: `2698dff678cda71f8ef505e3a53d768af0bda73e`.
Initial remote master: `b54e394e82d0320bbb56c1466c0dfc8144ec99ad`.

## Build rules

- Each step uses one Sol worker with high reasoning in its own worktree.
- Section 14 requires each step to start from the prior committed step.
  No independent steps are marked. Run one step worker at a time.
- Merge worker branches in step order. A step is integrated only after its
  focused tests pass on the integration branch.
- Section 13.3 calls the 16 rows ordered stages. No other stage groups are
  defined. Use a full native test gate after each row unless the owner supplies
  other stage boundaries. Never land a failing stage.
- Do not change the six selected departures. A worker must stop with evidence
  if it finds a wrong or missing design fact.
- Keep all implementation, test and build work in worktrees. The owner now
  permits stage merges into the clean main checkout's local `master`.
- Before each stage landing, rebase integration onto current local `master`,
  then pass the full native gate on that combined head. Merge into local
  `master`, then run `git push origin master`. If a push is rejected because
  the remote moved, stop and report it. Never force-push.
- Record each worker report and landing here, then commit the checkpoint.

## Steps

| Step | Scope | Worker branch | Worker head | State |
| --- | --- | --- | --- | --- |
| 1 | Storage probes | `feat/btree-step-1-storage-primitives` | `341e653bd4be5a042bd9d1f80370c07e555d7fc9` | stage-landed on master `6582b71b927ceb8e56207306edc05e00a1baa8eb`; pushed |
| 2 | Plans and providers | `feat/btree-step-2-plans-providers` | `8ac0ef46259275a9dd2d3ce468d7fdbee9647129` | stage-landed on master `484cfba12aa3664e1c06dcdcda706f0ec63272d6`; pushed |
| 3 | Plain fit writes | `feat/btree-step-3-plain-fit-writes` | `8beddc761964613ec915a9f67d749c5826ecf3cf` | integrated; full stage gate pending |
| 4 | Plain splits | `feat/btree-step-4-plain-splits` | — | queued |
| 5 | Plain deletion | `feat/btree-step-5-plain-deletion` | — | queued |
| 6 | Inline search | `feat/btree-step-6-inline-search` | — | queued |
| 7 | Prefix insertion | `feat/btree-step-7-prefix-insert` | — | queued |
| 8 | Prefix deletion | `feat/btree-step-8-prefix-delete` | — | queued |
| 9 | Cursors and bounds | `feat/btree-step-9-cursors-bounds` | — | queued |
| 10 | Map facade | `feat/btree-step-10-map-facade` | — | queued |
| 11 | Read batches | `feat/btree-step-11-read-batches` | — | queued |
| 12 | Write batches | `feat/btree-step-12-write-batches` | — | queued |
| 13 | Builder and append | `feat/btree-step-13-builder-append` | — | queued |
| 14 | Split and retain | `feat/btree-step-14-split-retain` | — | queued |
| 15 | Set facade | `feat/btree-step-15-set-facade` | — | queued |
| 16 | Delivery evidence | `feat/btree-step-16-delivery-evidence` | — | queued |

## Workers and reports

### Step 1

- Base: `274ea5873deb4b239914ac76e89b6679ba34ac84`.
- Provider/model/options checked: `codex`, `gpt-6.1-sol`,
  `reasoningEffort=high`.
- Task ID:
  `node:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Adelegate-task%3Abtree-step-1-storage-primitives-r1`.
- Child thread ID:
  `thread:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Adelegate-task%3Abtree-step-1-storage-primitives-r1`.
- Report received: worker head `341e653bd4be5a042bd9d1f80370c07e555d7fc9`,
  clean worktree, 13 changed files, no compiler changes.
- Worker checks: privacy 9 passed (9.574 s); type query 1 passed (8.526 s);
  raw casts 3 passed (1.509 s); carrier integration 8 cases passed (10.341 s);
  four probe compiles 0.153–0.197 s; ordinary Dew 2 passed (0.030 s);
  SIMD 1,450 masks passed.
- Physical evidence: paired backing arrays have no entry boxes; Unit has no
  value array; reference clears leave null slots; SIMD has no allocations.
  These are emitted-code checks, not dynamic heap-byte measurements.
- Cold CLI build: 40.114 s, open tool-build performance issue. Warm: 0.030 s.
  Investigation: 42 cold tasks and an 80,984,071-byte generated C file;
  no measured phase cause. No self-host/heap-pause/throughput claim.
- Worker evidence: [step-1 note](btree-step-1-storage-primitives.md).
  Raw artifacts: `/home/dev/.t3/worktrees/dewdrop/t3-de40f005/.tmp/btree-step-1/`.
- Worker reports no design-fact blocker. Parent reviewed all changed probes,
  tests and runner code. No source change was needed.
- Integration merge: `03b9a148dfc168d48ed011f9070faab6f33c0b4f`.
- Parent focused tests on that merge: privacy 9 passed (11.285 s), type-query
  1 passed (0.032 s), raw casts 3 passed (13.920 s), carrier integration
  1 test / 8 cases passed (2.432 s). Probe compiles 0.205–0.259 s;
  all 1,450 SIMD masks and 2 ordinary Dew tests passed.
- Parent probe run used the worker's native compiler/generator, whose compiler
  source is unchanged in the merge. Parent logs and emission are in
  `.tmp/btree-integration/step-1/`. Each command is timed. No parent focused
  compiler command exceeded 30 seconds.
- Parent read both saved Claude reports and exit/stderr files. The follow-up
  withdrew the design findings; its remaining source/test gaps are fixed in
  the worker head and passed parent checks. Claude did not read binary Wasm
  or run tests; physical/runtime checks are separate evidence.
- Step 1 is integrated and stage-landed on local and remote master at
  `6582b71b927ceb8e56207306edc05e00a1baa8eb`. Both the original and fresh
  post-rebase full native gates passed. The merge and push each returned 0.

### Step 2 launch

- Base: `5f8bfb43e034ecbfd7cf6c11542c9a46239b63eb`.
- Dependency: step 1 integrated with parent focused checks green.
- Provider/model/options checked: `codex`, `gpt-6.1-sol`,
  `reasoningEffort=high`.
- Task ID:
  `node:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Adelegate-task%3Abtree-step-2-plans-providers-r1`.
- Child thread ID:
  `thread:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Adelegate-task%3Abtree-step-2-plans-providers-r1`.
- Report received: `59aab429906362eb62ace42989f65316ced9e6d9`, clean worktree,
  26 changed files. Transplant only this commit from the original base.
- Worker checks: 20 Dew tests; 3 native tests (9.141 s); 26 integration tests
  (8.131 s + 1.860 s); four optional-evidence misuse diagnostics; physical
  probe compile (0.610 s). All passed.
- Worker physical evidence: keyless inline branches, Unit with no value array,
  and no allocations in clear/window/paired-access/rank paths. Actual heap
  bytes were not measured. Full raw samples and limits are in the
  [step-2 note](btree-step-2-plans-providers.md) and
  `/home/dev/.t3/worktrees/dewdrop/t3-78c50516/.tmp/btree-step-2/final/`.
- Four open tool-build costs above 30 seconds: cold CLI 38.906 s, registry CLI
  32.375 s, final CLI 34.487 s, final generator 30.517 s. No proven phase cause.
- The guarded-return compiler reproducer has a tested valid source form used
  by storage. No design-fact blocker is reported.
- Parent independent source reviews and focused checks are pending.
- Parent import-only probe passed in 0.326 s using the exact worker compiler
  and worker std sources. Importing `dew.std.collections.btree` alone loads
  its dependencies. Evidence: `.tmp/btree-integration/step-2-pre-review/`.
- Independent Sol/high read-only review completed. Task ID:
  `node:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Adelegate-task%3Abtree-step-2-review-sol-r1`.
  The parent separately reviews registry, module IDs, generated mirrors and
  std test integration.
- Independent Claude Code Opus/high read-only review is running with normal
  auth and Read/Glob/Grep only. Packet, full diff, prompt, stdout, stderr and
  eventual exit status: `/tmp/dewdrop-btree-step2-review-59aab429/`.
  Scope is all 26 changed files plus relevant source and raw performance
  evidence. Neither review result is claimed yet. The reviewed worker checkout
  stays at its reported head until the reviews finish.
- Sol review returned one confirmed P2 harness bug: `cost-*.json` includes the
  previous `cost-summary.json`, which has no `samples` field. A repeated run
  fails before the four negative-evidence checks. Parent reproduced the saved
  file selection. Fix by reading numbered sample files, then run twice in the
  same output folder. No storage/provider or design conflict was found.
- Sol also noted that the allocation recorder omits `array.new_fixed`.
  Parent added counters to all 44 such instruction sites in a copy of the
  exact emitted module and ran the allocation checks. No fixed-array
  allocation occurred on measured success paths, and all reported counts
  stayed the same. Parse/validate/runtime times were 0.034/0.017/0.064 s.
  Evidence: `.tmp/btree-integration/step-2-allocation-check/`.
  Include this opcode in the committed recorder with the rerun fix.
  Source hashes and reported performance limits were independently checked
  by Sol. Claude's full review remains pending; step 2 is not integrated.
- Claude review completed (exit 0). All changed source/diff files were in
  scope; binary Wasm, hashes, Git HEAD and parts of raw evidence were outside
  its verified coverage. The Git HEAD read was denied; there was no auth
  failure. Parent/Sol identity and runtime checks are separate evidence.
- Parent confirmed and fixed two further tooling gaps: `check-generated.sh`
  now checks the B-tree source mirror, and the Starshine library experiment
  shares the private test list and one combined private-source case with the
  stdlib runner. The standard-sources interface was regenerated (0.375 s).
- Parent also fixed numbered sample-file selection and extended allocation
  counting to fixed/data/element arrays and default struct allocation.
  Cost samples now use longer loops. The note labels the original mixed-JIT
  short samples as smoke checks, counts the inline-width enum, and records
  independent source evidence for C bytes and `-Og` without claiming a cause.
- Inactive tag fill values need not match: live masks exclude them. No storage
  change or new design departure is needed. Wrapper, move/clear and consumed
  comparator costs remain explicit later-step measurements; no warm-lookup
  allocation claim is made by the foundation.
- Original worker head is preserved at `refs/btree-build/step-2-original`.
  Only its single commit was rebased onto current integration. Replayed worker
  head: `4e5fa46fa9e208c47407a0abff07bdef684d1fab`; provisional integration
  merge: `b4410a710263c5d3a612bf203a8c0a4f34b2e18b`. Focused parent checks
  and the same-folder rerun regression are pending. Step 2 is not integrated.
- Parent fixes are committed at `91a88912d6d0101d38e178857542f000339baa6a`.
  Focused checks on that integration head passed: identity 3 tests (11.774 s),
  B-tree backend 2 tests (10.550 s), preamble/wildcard 24 tests (2.190 s).
  Public 8 and private 12 Dew tests passed. The complete probe ran twice in
  the same output folder; both reached all four expected negative-evidence
  checks and passed. The second physical compile took 0.883 s.
- The shared private Starshine case passed in raw and O4s forms (12 tests).
  Its source compile took 3.689 s; optimization 0.076 s. Fresh allocation
  instrumentation includes `array.new_fixed`; measured success-path counts
  are unchanged. Long cost samples are at least 10.500 ms. Full raw ranges
  retain visible outliers; no production-map speedup is claimed.
- Fresh artifacts: `.tmp/btree-integration/step-2/`, with numbered cost JSON,
  unedited identity files, both rerun logs and `starshine-private/report.json`.
- Parent's cold Starshine CLI build took 269.899 s (26 tasks), another open
  tool-build performance bug. Warm no-work control: 0.028 s. Its generated C
  file is 124,819,868 bytes. `build-starshine-evidence.json` records these
  facts; no measured phase cause is claimed. Other focused compiles stayed
  below 30 seconds.
- The broad generated-source gate exposed a pre-existing scalar conversion
  policy test: 34 native branches versus an expected 23. Parent confirmed
  all relevant files match master. The existing step-2 worker is repairing
  this bounded test issue on its branch, without compiler or runtime changes.
  Follow-up task ID:
  `node:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Athread-send%3Abtree-step-2-scalar-policy-gate-fix-r1`.
- Step 2 meets the integration definition: merged, with focused B-tree tests
  green. Stage 2 is not landed on master. The policy repair and full native
  stage gate must pass before that landing.
- Scalar-policy follow-up report: base `91a88912d6d0101d38e178857542f000339baa6a`,
  head `6b902057c4679414d43c1031320b4623e5250d44`, clean worktree. Two files:
  the policy test and [evidence](scalar-builtin-policy-gate-2026-10-25.md).
  The inventory now checks 34 native branches and the exact 23 library targets,
  retaining one-instruction and unique-name checks. Production source is
  unchanged. Worker focused check: 2 passed (0.043 s). Read-only Claude found
  no confirmed defect; its scope/limits are in the evidence note.
- Parent reviewed that patch, merged it at
  `47eb644b31737fdc46f060c1a3bc81cd5127808f`, and independently passed the
  two focused policy tests. The full generated gate still fails (worker
  0.669 s; direct failure 0.049 s) in `test_debug_float_policy.py`: the
  intrinsic generator reports 28 missing declarations. Exact names and
  diagnostics are preserved in the note. The generator/test/intrinsic source
  files are unchanged from master. No generated-gate success is claimed.
- Parent is assigning the missing-intrinsic declaration coverage repair to
  the same step-2 worker. Stage 2 stays off master until this gate and the
  full native gate pass. Step 3 owns the plain engine, not this tooling issue.
- Intrinsic-coverage follow-up is running on the same worker branch. Task ID:
  `node:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Athread-send%3Abtree-step-2-intrinsic-coverage-gate-fix-r1`.
  Scope is ordinary source/declaration generation, directly related mirrors
  and policy evidence, with read-only Claude review. No tree layout change or
  compiler dispatch exception is permitted. No result is claimed yet.
- Parent told the worker to continue from its original base. After the report,
  transplant only its step-2 commits onto current integration before merging;
  do not replay the old integration history. No active worker edits were moved.

### Step 3 launch

- Base: `bee17cd481a4d48f2ed02d895119ee05192defee`.
- Dependency: step 2 merged, with parent focused B-tree tests green. The old
  scalar policy repair is separate tooling work; no engine dependency is
  missing. No stage-2 master landing is claimed.
- Provider/model/options checked: `codex`, `gpt-6.1-sol`,
  `reasoningEffort=high`.
- Task ID:
  `node:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Adelegate-task%3Abtree-step-3-plain-fit-writes-r1`.
- Child thread ID:
  `thread:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Adelegate-task%3Abtree-step-3-plain-fit-writes-r1`.
- State: running. Scope is plain root-leaf lookup/fit writes, result policies,
  counts and inspector. No split, deletion or multi-level claim is permitted.
  The worker must measure actual hot-path allocation, including consumed
  comparator results, and carry the known cold tool-build costs forward.
- Worker asked which exact production pass list to use: at this pin O4s has
  no inlining/heap2local, and its probe retains consumed Ordering/Option
  objects. Parent answered through the pending-request tool. The selected
  design names no exact production pass list; the parent's earlier wording
  was imprecise. Raw native output and unchanged O4s remain controls; no
  experimental pass list is promoted to production.
- Allocation scope remains section 13.2: no private tree/path/search
  temporaries, and no discarded Options on Bool/Unit forms. Requested public
  get/put Option results and comparator/provider results must be counted
  separately, not hidden or confused with private scratch. No whole-call
  object-free claim is permitted when provider/API costs remain. Continue
  source policy specialization; isolate ordinary compiler issues under
  section 14. A genuine new design departure still requires stopping with
  exact evidence. No allocation rule or selected departure was waived.

## Stage landings

Stage 1 has landed on local and remote master at
`6582b71b927ceb8e56207306edc05e00a1baa8eb`.

Stage 1 gate: `tools/test-native.sh` with no package override or filter,
tested head `5f8bfb43e034ecbfd7cf6c11542c9a46239b63eb`, passed (exit 0).
All 1,925 tests passed across 303 owning-file/package commands. The suite took
541.639 seconds. Every command stayed below 30 seconds; no performance flag
was emitted. The default native lane reports 25 groups with zero active tests
(integration/stress skips); step 1's new integration case was separately run
with skipped tests enabled and passed as recorded above. This is a full
routine native result, not a full integration or pinned Starshine result.
Logs: `.tmp/btree-integration/stage-1/full-native.log`, `.head`, `.status`,
and `.resources.json`. The first wrapper attempt could not start because
`/usr/bin/time` was absent (exit 127); no native test ran in that attempt.
The completed run used Python timing plus the script's per-command measurements.

| Stage | Tested integration head | Full native result | Master head | Landing state |
| --- | --- | --- | --- | --- |
| 1, before master rebase | `5f8bfb43e034ecbfd7cf6c11542c9a46239b63eb` | 1,925 passed, 0 failed; 541.639 s | — | new gate required after rebase |
| 1, after master rebase | `6582b71b927ceb8e56207306edc05e00a1baa8eb` | 1,925 passed, 0 failed; 523.325 s | `6582b71b927ceb8e56207306edc05e00a1baa8eb` | stage-landed; pushed to origin/master |
| 2 | `484cfba12aa3664e1c06dcdcda706f0ec63272d6` | 1,925 passed, 0 failed; 567.337 s | `484cfba12aa3664e1c06dcdcda706f0ec63272d6` | stage-landed; pushed to origin/master |

### Owner landing updates and stage-1 rebase

The owner committed the former main-checkout edits. Local `master` is clean at
`0744aea0c697fdfaa62688eabcecead6ee8a5ef0`, after tools commit `c57d355f99`
and research-docs commit `0744aea0c6`. The landing-destination question is
resolved. The latest instruction requires a normal push after each local
stage merge; it replaces the preceding no-push instruction.

Integration was rebased with merges preserved onto that local-master head.
Pre-rebase integration is retained at
`refs/btree-build/stage-1-before-master-rebase`
(`53331ad848e4d043266a0a6d65484b212947437d`). Post-rebase head before this
status update: `23ba5742cbd025a8f6e2028534018a7bbdc327df`.
The original worker branch/head remains unchanged. Its integration replay is
`b5c6029c78`, under integration merge `f04ab406de`.
All 13 step-1 files have identical content before and after the rebase.
The two owner commits do not change compiler/std/submodule source.

The fresh full native gate passed on the rebased integration branch:
1,925 tests, 0 failures, 303 measured commands, 523.325 seconds total.
Every command stayed below 30 seconds. Evidence is in
`.tmp/btree-integration/stage-1-after-master-rebase/`.

Before landing, both worktrees were clean and local master still matched the
tested base `0744aea0c697fdfaa62688eabcecead6ee8a5ef0`. The main checkout's
`git merge --ff-only feat/btree-integration` returned 0 and advanced master
to the exact tested head `6582b71b927ceb8e56207306edc05e00a1baa8eb`.
`git push origin master` returned 0, advancing remote master from
`b54e394e82d0320bbb56c1466c0dfc8144ec99ad` to that same head. The main
checkout remained clean. Logs and exit codes are in `merge.*`, `push.*`,
and `landing.json` under the evidence directory above. No force-push was used.

## Design-fact blockers

None reported.

## Latest reports and gate preparation

- Step-2 intrinsic-coverage follow-up reported clean head
  `27580d200afd32fb4fa380bd6d7e7313a9fc8c01` on base
  `dce4fd0e36f6e0643e88f554e435af2617dc4e3c`. Eight files add all 28
  missing public declarations from the independent scalar catalog and generic
  reference signature. Existing public signatures and private boundaries stay
  intact. Parent read the source, tests and evidence note. No compiler or
  B-tree implementation changed.
- Worker checks: 13 owning policy tests, four generator checks, five public
  Dew tests, 28 exact single-opcode wrappers and expected scalar-ref rejection
  passed. Full generated gate passed cold (39.690 s) and warm (10.568 s).
  The cold cost remains open. The separate pre-existing imported generic
  returned-callback MissingFunction limit is documented, not fixed or hidden.
- Claude reached its session usage limit before reading any repair files.
  The saved report claims no Claude coverage. Parent source review and fresh
  gates are separate evidence; no successful Claude review is claimed.
- Step 3 reported clean head `441cf6cc1c23053919203461b3e623e6bb2fe9f3`.
  Worker reports 8 public and 24 private raw/O4s tests, 3 native identity and
  2 backend tests, exact diagnostics and mirrors green. Allocation counts
  distinguish private scratch from requested Options and comparator results.
  O4s medians: lookup 15.817 ns, replacement 14.997 ns, fit including clear
  35.603 ns. CLI 53.872 s and test-tool 30.596 s remain open build-cost bugs.
  No design-fact blocker is reported. Parent acceptance is pending.
- Independent read-only Sol/high step-3 review started. Exact base/head and
  all 18 changed files, raw data, harness and allocation limits are in scope.
  Task ID:
  `node:delegated-task:command%3Amcp%3A11f906aa-2fa4-4041-b2b6-3ead904ef2e8%3Adelegate-task%3Abtree-step-3-review-sol-r1`.
  No result is claimed yet. Claude remains unavailable due to the usage limit.

### Stage 2 landing and step 3 review

- Intrinsic repair original head is pinned at
  `refs/btree-build/step-2-intrinsic-original`. Only its one commit was
  transplanted to current integration. Replayed worker head:
  `8ac0ef46259275a9dd2d3ce468d7fdbee9647129`. Integration was rebased with
  merges preserved onto current local master `6582b71b927ceb8e56207306edc05e00a1baa8eb`.
- Fresh generated-source gate passed on integration
  `484cfba12aa3664e1c06dcdcda706f0ec63272d6` (36.960 s). The outer cost is
  above 30 seconds and remains open; it does not establish a slow phase.
- Full routine native gate passed on that exact head: 1,925 passed, zero
  failed, 304 measured commands, 26 zero-test groups, 567.337 s. Each native
  command stayed below 30 seconds. Integration skips remain separate from
  focused backend tests. Evidence: `.tmp/btree-integration/stage-2/`.
- Parent confirmed clean integration and main checkouts and unchanged tested
  master base. Main-checkout fast-forward merge returned 0. Normal
  `git push origin master` returned 0. Both local and remote master are now
  `484cfba12aa3664e1c06dcdcda706f0ec63272d6`; the main checkout is clean.
  `landing.json`, `merge.*` and `push.*` record this landing. No force push.
- Independent step-3 Sol/high review completed with no confirmed defect and
  no actionable unverified risk. All three commits and all 18 changed files
  were read. Source/tool/module hashes and generated mirror match. Saved
  public 8/private raw 24/private O4s 24 tests passed. Independent searches
  (261 per control), fit writes, comparator counts and inactive slots passed.
  Every constructor form is recorded; checked private warm scratch is zero.
- Review limits: historical scratch/review packets and WAT outside checked
  paths were not fully read; no exact heap/GC/large-tree/other-CPU claim.
  Known build costs and ordinary generic-Option compiler defect remain open.
  No files changed or builds/large benchmarks ran in that review.
- Parent will transplant only the three step-3 commits, run focused checks
  on integration, then record acceptance before starting step 4.

### Step 3 integration acceptance

- Original three-commit worker head is pinned at
  `refs/btree-build/step-3-original`. Only those three commits were replayed
  onto current integration. Replayed worker head:
  `8beddc761964613ec915a9f67d749c5826ecf3cf`.
- Integration merge: `24b62868f29c9862f81b6721740652bcff0df65d`.
  Parent focused checks on this merge passed: native identity 3 tests
  (10.037 s), backend 2 tests (9.604 s), B-tree and identity mirrors
  (0.025/0.019 s), public 8 and private raw/O4s 24 tests, exact diagnostic
  assertions, physical shapes, every carrier allocation check and loop costs.
- Complete measured runner took 33.609 s including all tests, instrumentation
  and benchmarks. Its compiler/optimizer commands are separately timed;
  none exceeded 30 seconds. Raw evidence is in
  `.tmp/btree-integration/step-3/` and `probes/`, with current integration
  source hashes and worker-native tool hashes. No heap-byte claim is made.
- Step 3 meets the integration definition. Stage 3 remains off master until
  a fresh full native gate passes after the current-master rebase.
- Step 4 may now start from this committed, accepted integration point.
