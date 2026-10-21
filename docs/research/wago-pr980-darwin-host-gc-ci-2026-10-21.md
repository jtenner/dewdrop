# PR #980 Darwin ARM64 host GC timeout

[PR #980](https://github.com/wago-org/wago/pull/980) head
`a8b72ce7a0775c5d3d4a642357aec9dfbbb72d57` fails its Darwin ARM64 job:
https://github.com/wago-org/wago/actions/runs/39606585738/job/119252800446

The sole reported test failure is
`TestBoundedHostYieldAllowsGCAndCancellationWithOneP/HostCall`:
`host_segments_test.go:158: bounded host segments prevented GC progress`.
It occurs in the `wago_codegenstats` package run. Earlier normal and register
allocation check runs succeeded. The failing test allows three seconds for
`runtime.GC()` to finish while a guest repeatedly calls Go with one P.
This is separate from PR #992's repaired documentation check.

The hosted job tests merge `32d0071` of this head with main
`83c51e61fad72f3c258c2be8275977704ce681d3`, using Go 1.27.1.
The unmodified PR head passes 20 focused repeats on Linux AMD64 with
`wago_codegenstats`: 6.310 s of tests, 35.415 s including a cold Go build.
That does not establish native Darwin behavior or prove a test-only fault.
No source change is justified by the current evidence.

Attempted a single failed-job rerun. GitHub rejects it with HTTP 403:
`The workflow run containing this job is already running`.
Run 39606585738 still has queued Darwin corpus jobs. Keep native PR watching
active, then retry the failed job once after the run completes. Do not cancel
unrelated queued jobs or treat the Linux result as a Darwin pass.

The failed worktree creation under the nearly full projects volume made no
source change. The clean diagnostic worktree is `/tmp/wago-pr980-ci-fix`, with
its Go cache at `/tmp/wago-pr980-go-cache`. Saved job log, local test results,
and the rerun rejection are in
`docs/research/data/wago-pr980-darwin-host-gc-ci-2026-10-21/`.
