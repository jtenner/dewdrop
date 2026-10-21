# PR #992 Core 3 documentation baseline repair

The Linux/arm64 job for head `3f6212934d1f3d6c4ee2527b00df3e5bfdbf3d34`
passes the earlier signal-log test repair and Wago runtime tests. It fails
`TestRelease3DocumentationMatchesCommittedBaseline` because main's rewritten
feature page removed the recorded Core 3 totals.

Failed job: https://github.com/wago-org/wago/actions/runs/39660906917/job/119446788561

CI tested merge `0d028a53aa35e31cfc8a317e90abc825226d9f26`, with main
`f91caadd3ccdc3bd0ab431412088d34d1f9e90a2`. The PR head alone retained
the old page and passed. Reproducing the exact merge exposed the failure.

Restore six lines to the new phase-based feature page: 258 files, 2,226
modules, and 58,038 assertions passed, with zero failures, skips, or gaps.
Link the committed report and refer to `SupportedFeatures()` for the active
build. Keep the baseline and test expectations unchanged.

The exact merge fails before the fix (0.183 s). The fixed spectest package
passes on that merge (0.172 s) and the original PR head (0.215 s). Docs checks
pass on both (0.135 s and 0.146 s). The Linux/arm64 binary builds (0.220 s)
and both documentation tests pass under QEMU (0.089 s). Daybreak Blue found
no issue in the six-line fix or saved evidence.

The final merge-tree check found a feature-page conflict. The first docs
commit `7ed6da087` was pushed before that failure stopped the command sequence.
Merge main and resolve the only conflict with the reviewed page. The final
merged spectest package passes (0.179 s), and docs-check passes on 86 files
(0.144 s). The resulting tree merges cleanly with the tested main commit.

Published merge commit `30a46b6bf5e5b325168be3313a77f9ebc1957890` to
[PR #992](https://github.com/wago-org/wago/pull/992). GitHub reports it as
mergeable. No checks were yet reported for the new head at handoff. The
hosted ARM64 result remains pending; QEMU is emulated execution.

Raw results and review metadata are in
`docs/research/data/wago-pr992-core3-doc-baseline-2026-10-21/`.
