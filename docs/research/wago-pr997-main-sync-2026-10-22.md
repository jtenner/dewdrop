# PR 997: resolve the live main conflict

[PR #997](https://github.com/wago-org/wago/pull/997) is maintained in the isolated
checkout `/tmp/wago-pr997-main-sync-20261022`, branch
`dewdrop/pr997-main-sync-20261022`. The merge starts at the exact PR head
`dba9d9670bc2fe1710bd4b83f7c9f70bbbfb1e46` and uses live main
`688303ebfa75384e89773e3fc865b8bccb2e6a71`. The PR API's older base SHA is not
used as the current main ref.

Seven files conflicted. Keep main's RV64 admission, typed native roots, state-only
modules, saved artifact checks, compact extern roots, and same-domain suspended
root traversal. Restore the PR's AMD64/ARM64 extern root plans, bounded fallback,
foreign identity checks, checked table mirrors, saved entry landing slots, and
bounded native caller records. Suspended activations use their supplied owner.
RV64 keeps its own adapter boundary and bridge format; it does not read the
AMD64/ARM64 saved context records. Its transient table publication roots are
unchanged. The strict AMD64 public state footprint is 23,440 bytes, including
34 new pointer words over main's 23,168-byte state.

PR 997 remains a draft with changes required. The existing unused local funcref
table and A-to-B-to-A scalar relay failures remain unresolved. A scalar edge is
not proof that no older same-domain frame exists. This merge does not include
the separate scalar adapter metadata prototype or grant new foreign-frame
traversal authority. Green ordinary tests do not establish the missing proof.
Do not merge or auto-merge the draft based on this maintenance update.

Merge commit `26d272e49f7f36d66034a7afa20b6c472ad06f5c` has both exact refs as
parents. The fast-forward push to `fix/gc-extern-local-roots` was accepted.
No force push or PR merge was made. The worktree is clean. GitHub confirms
the new head, the current main base, no merge conflict, and draft status.

All local checks pass on Go 1.27.1, GOMAXPROCS=2:

| Check | Wall seconds | Peak RSS KiB |
| --- | ---: | ---: |
| AMD64 focused GC/extern/root suite | 27.438 | 3,557,456 |
| Complete ordinary root suite | 160.230 | 2,156,456 |
| Final complete Wago suite | 48.774 | 3,555,676 |
| Complete register-check root suite | 164.779 | 3,589,696 |
| Register-check benchmark module | 30.660 | 778,736 |
| ARM64 focused GC/extern/frame QEMU suite | 26.640 | 2,708,972 |
| Final RV64 GC frame and extern source/artifact QEMU suite | 34.272 | 4,876,032 |
| Final documentation check (85 Markdown files) | 0.058 | 27,412 |

Times include building and linking. The final Wago execution phase is
23.532 seconds; the RV64 execution phase is below one second. The large
cross-target Wago test binaries dominate linking RSS. The long activities
exceed the 30-second target. This maintenance update makes no speed claim.
The checked benchmark module runs correctness tests, not speed comparisons.

The ordinary root run preceded a final RV64-only narrowing of the table
mirror guard. The complete ordinary Wago suite, complete register-check root
suite, and RV64 checks pass after that final change. ARM64 behavior is unchanged
by the added constant architecture guard. Existing tests cover typed roots,
foreign caller records, saved landing slots, null table admission, and RV64
adapter boundaries. No new test or timeout limit was added or weakened.

The pinned Release 3 corpus uses a temporary shared local Git clone, removed
after the root suites. GOWORK is unset; direct tool paths avoid untrusted mise
workspace tasks. All commands, output, CPU time, RSS, faults, and context
switch counts are retained in
[data](data/wago-pr997-main-sync-2026-10-22/identity.json).
The [resolution diff](data/wago-pr997-main-sync-2026-10-22/merge-resolutions.patch)
retains the actual conflict choices. Existing dirty Wago and Dewdrop host
checkouts are untouched. T3 will watch the pushed draft for host check results.


## Required green check: draft profile, 2026-10-22

The exact PR head remains `26d272e49f7f36d66034a7afa20b6c472ad06f5c`, open,
draft, and without a merge conflict. Required CI run `39734486860` completes
successfully. Its executed qualification is **Draft smoke / Linux amd64**;
the full platform, lint, race, corpus, documentation, and conformance matrix is
skipped by draft policy. This is not a full native CI qualification.
Regression stress run `39734486862` also reports success. Separate native RISE
run `39734486778` has completed fixture preparation and is still running
`JIT / native Linux RISC-V64` (job `119677151197`) at this snapshot.

The PR body still says changes required and forbids merging or auto-merging.
The known unused-table and A-to-B-to-A scalar relay root failures remain.
Keep draft status and leave the PR unmerged. T3 continues watching because the
native RISC-V64 result is pending; no source or CI retry is justified by a
successful smoke check. The service state is saved in
[data](data/wago-pr997-main-sync-2026-10-22/required-green-draft-snapshot.json).


## Cancelled native RISC-V job: split the serial workload

The [native job](https://github.com/wago-org/wago/actions/runs/39734486778/job/119677151197)
starts at 06:33:40 UTC and is cancelled at 08:04:01 UTC, approximately the
configured 90-minute job limit. Smoke, CLI/standalone, compiler/runtime, and
public ownership/compiler-free steps pass. In the final guard step, ordinary
Wago thread checks and the next runtime guard checks pass; cancellation then
kills an active Go compiler. No assertion failure or Go test timeout is shown.
The elapsed job budget explains the cancellation; this is not evidence that
the known GC root faults are repaired or a new runtime fault is reproduced.

Commit `d329e9df9f09488f8906dfa3cee7f396574851d0` splits the native workflow into two
matrix jobs: `runtime` runs smoke, CLI/standalone, compiler/runtime, and
guards/threads; `ownership` runs the full public/artifact matrix. Every original
command appears exactly once. Artifact preparation and loading remain in one
job with their original temporary directory. Both jobs retain the 90-minute
limit, RISE label, pinned setup/fixtures, GOMAXPROCS=2, compiler serialization,
and fork permissions. Matrix fail-fast is disabled so a failing group cannot
cancel its companion. No source tests, test timeouts, or runtime code change.

Actionlint 1.7.7 passes in 1.937 seconds including build, peak RSS 200,952 KiB.
A 0.004-second coverage check confirms all five commands, group selection,
unchanged setup/environment/fixture bindings and the unchanged job budget.
Documentation passes for 85 Markdown files in 0.061 seconds, peak RSS 27,316 KiB.
The two groups add separate runner setup/cold builds. Actual native duration
and total cost remain unmeasured; the next hosted runs must qualify the split.
No old 90-minute run is retried unchanged and no job budget is raised.

The fast-forward push is accepted; the head is open, draft, and mergeable.
The unused-table and A-to-B-to-A scalar relay root defects remain unresolved.
Keep draft status and leave the PR unmerged. T3 watches the new native groups.
[Identity](data/wago-pr997-rise-split-2026-10-22/identity.json),
[hosted stages](data/wago-pr997-rise-split-2026-10-22/hosted-stage-excerpt.log),
[workflow diff](data/wago-pr997-rise-split-2026-10-22/fix.patch),
[workflow validation](data/wago-pr997-rise-split-2026-10-22/actionlint.json), and
[coverage check](data/wago-pr997-rise-split-2026-10-22/stage-coverage.json)
retain output, commands, resource use, and validation limits.
