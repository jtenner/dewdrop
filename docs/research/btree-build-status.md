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
| 2 | Plans and providers | `feat/btree-step-2-plans-providers` | — | in flight |
| 3 | Plain fit writes | `feat/btree-step-3-plain-fit-writes` | — | queued |
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
- State: running; no report or test result yet.
- Parent told the worker to continue from its original base. After the report,
  transplant only its step-2 commits onto current integration before merging;
  do not replay the old integration history. No active worker edits were moved.

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
