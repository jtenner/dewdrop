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

## Darwin AMD64 corpus follow-up

The same run also fails
[Corpus correctness / Darwin amd64 / shard 3 of 4](https://github.com/wago-org/wago/actions/runs/39606585738/job/119252800452).
Its only reported failure is `TestCorpus/clang-cpp-kernels/CompileFull`:
the child reaches the 15-second limit (15.06 s reported). There is no
wrong-result or compiler error in the job log. The runner is macOS 15.7.9,
AMD64, Go 1.27.1, testing merge `32d0071`.

The job sets `WAGO_CORPUS_TIMEOUT=20s`, but `runCorpusChild` in
`bench/suite/corpus_runner_test.go` uses a fixed 15-second limit. This
observation does not justify raising the limit or hiding a slow compile.

On the unchanged PR head, three focused Linux AMD64 runs pass in 2.67,
2.71 and 2.68 s. The command is:

```sh
GOCACHE=/tmp/wago-pr980-go-cache GOWORK=off GOMAXPROCS=2 go test -v -count=3 -timeout=2m -run='^TestCorpus$/^clang-cpp-kernels$/^CompileFull$' ./suite -args -wago.corpus=clang-cpp-kernels
```

It runs from `/tmp/wago-pr980-ci-fix/bench`. Total elapsed time, including
the Go test build, is 15.785 s; the test package reports 8.092 s. Linux
success does not prove native Darwin behavior. No source was changed.

A single attempt to rerun failed jobs is again rejected with HTTP 403:
`This workflow is already running`. The workflow status remains `queued`
while the returned completed jobs include both known failures. Keep the PR
watch active and retry after the workflow ends. Do not cancel other jobs.
Failure excerpts, local output and retry rejection are saved beside the
earlier evidence with the `darwin-amd64-corpus` and `linux-compile-full`
prefixes.

## Final CI result and accepted retry: 2026-10-22

The completed workflow's final [CI job](https://github.com/wago-org/wago/actions/runs/39606585738/job/119577547741)
fails because `app-corpus-verify` was skipped. Its inputs also show failures in
`platform-test` and `corpus-correctness`. The detailed logs confirm the same two
Darwin failures described above; the aggregate adds no new compiler failure.

The workflow now reports `completed/failure`, so the earlier running-workflow
restriction no longer applies. One request to rerun only failed jobs succeeds.
The request/result and exact job IDs are saved in
`data/wago-pr980-darwin-host-gc-ci-2026-10-21/final-ci-rerun-2026-10-22.json`.
No source or timeout limit changed. Native Darwin results remain pending.
T3 Code continues to watch PR #980 and will wake this thread when results change.


## Retry fails again; ARM64 live-loop scheduling fix: 2026-10-22

The [new Darwin ARM64 job](https://github.com/wago-org/wago/actions/runs/39606585738/job/119665056637)
hits the same three-second GC-progress limit for the typed and Caller variants.
The prior HostCall failure is therefore not cleared by retry. The
[aggregate](https://github.com/wago-org/wago/actions/runs/39606585738/job/119666141355)
reports platform-test failure. The Darwin AMD64 corpus retry passes.

A raw ARM64 regression reproduces GC starvation in all eight live callback
owners with async preemption disabled: a second goroutine cannot finish
collection before 65,536 tiny callbacks return. The bridge's NOSPLIT assembly
loop has no explicit scheduling point, and tiny callbacks need not supply a
stack-growth check. Commit `ed3783423aa090a39967847e3d9d1044a5abd975` now yields to
Go after 1,024 callbacks, with results already stored and native state parked.
It reloads the correct owner-specific trap/control arguments and checks for
cancellation before resuming. The private countdown uses existing spare Go
frame space. No native frame, public ABI, root map, or artifact format changes.
No new heap state is added. AMD64 code is unchanged.

The before/after regression and cancellation cases pass under ARM64 QEMU.
Ten checked repeats cover all eight owners, FP preservation, recursive Go stack
growth, bounded helpers, and public host/array-length paths. Darwin ARM64 test
binaries build and the Mach-O owner disassembly verifies offsets and branches.
The full normal root gate passes in 151.407 s; the full register-check root gate
passes in 135.766 s; the checked benchmark module passes in 30.188 s.
These long activities remain above the 30-second target. Documentation passes.
The original three-second test limit is unchanged.

A broad emulated runtime run still fails the signal-ownership test and a
repeated pool-cache expectation. Unchanged PR head has the same failures under
the same QEMU flags. Both outputs are retained; the broad emulated suite is not
reported green. Early invalid raw-fixture/argument-offset attempts are also
retained. The valid before-fix failure is `leaf-callback-arm64-red-r2`.

The fast-forward push to `perf/native-array-len` was accepted. No force push or
PR merge was made. Native Darwin is not available locally; the hosted result
for the new head is still required. T3 continues to watch the new CI attempt.
[Identity and source](data/wago-pr980-arm64-host-yield-2026-10-22/identity.json),
[reproducible failure](data/wago-pr980-arm64-host-yield-2026-10-22/leaf-callback-arm64-red-r2.log),
[checked ARM64 result](data/wago-pr980-arm64-host-yield-2026-10-22/arm64-runtime-focused-checked.json),
and [baseline emulator comparison](data/wago-pr980-arm64-host-yield-2026-10-22/qemu-baseline-comparison.json)
include the commands, raw logs, resource use, and validation limits.
