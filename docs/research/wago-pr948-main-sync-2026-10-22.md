# PR 948: resolve the live main conflict

[PR #948](https://github.com/wago-org/wago/pull/948) is updated from `58cbd04c9`
to merge commit `72e684df38cef599be936dbed3229a5a5b85999e`. It contains live
main `688303ebfa75384e89773e3fc865b8bccb2e6a71` and preserves the PR history.
The fast-forward push was accepted. No force push or PR merge was made.

The earlier clean check used the PR API's historical base `83c51e61f`, rather
than the live main ref. That did not establish compatibility with current main.
Reading the live Git ref exposed one textual conflict in `src/wago/hostcall.go`.

The resolution keeps main's early callback scope and one deferred scope end.
It also keeps the PR's conditional result scratch, so scalar host calls retain
their allocation bound. Reference results and separate host-reference type
contexts retain dispatch-owned scratch and cleanup.

The normal suite then exposed a semantic merge overlap in `codec.go`: the old
unconditional start fields survived beside main's gated start extension. Keep
main's encoder/decoder and exact artifact-size goldens. The existing inactive-
start regression fails before the correction. No new format version is added.

Validation on Go 1.27.1, GOMAXPROCS=2, package concurrency 2:

- Focused host/reference/allocation/cached-start tests pass: 27.366 s including build.
- All ordinary root packages pass in the full run except stale codec-size goldens. After restoring main's strict goldens, the complete Wago rerun passes: 45.838 s including build, 22.136 s tests. No other production source changes after that full run.
- The complete register-check root suite passes: 146.509 s including builds.
- The register-check benchmark module passes: 30.838 s including builds.
- Documentation check passes: 98 Markdown files, 0.138 s including build.
- Both old PR head and live main are ancestors of the merge; no unresolved index entries remain.

Earlier invalid local runs are retained. `-p2` was a command error, corrected to
`-p 2`. GOWORK=off breaks the new installer test; forcing an absolute workspace
breaks standalone temporary modules. Final runs leave GOWORK unset, use direct
Go/PowerShell paths, and use an independent clone of the pinned Release 3 corpus.
The original corpus symlink caused Git VCS stamping errors. The final temporary
clone was removed after the tests. No tests or timeout limits were weakened.

These activities exceed the 30-second compiler activity target. This maintenance
update makes no new speed claim. Hosted CI for the new merge is pending.

[Identity and source resolution](data/wago-pr948-main-sync-2026-10-22/identity.json),
[manual merge diff](data/wago-pr948-main-sync-2026-10-22/merge-resolutions.patch),
[full checked result](data/wago-pr948-main-sync-2026-10-22/checked-root.json), and
[checked benchmark result](data/wago-pr948-main-sync-2026-10-22/checked-bench.json)
are saved with commands, raw failures, final output, CPU time and peak RSS.
The isolated Wago branch is `dewdrop/pr948-main-sync-20261022`, at
`/tmp/wago-pr948-main-sync-20261022`. Existing dirty checkouts are untouched.


## Tagged lint follow-up: 2026-10-22

The hosted [lint job](https://github.com/wago-org/wago/actions/runs/39732958160/job/119672128373)
exposes four old root-planner calls in the numeric-leaf and trapping-guard stats
fixtures. These files are excluded from ordinary/register-check builds and
included by the diagnostics lint profile. The error is a compile failure,
wrapped in the baseline runner's incomplete-diagnostic message.

Commit `1d9fbd472` supplies the new exact-roots and generic-execution inputs in
all four calls. The source/native callsite, root, trap, pin, import, selection,
and counter assertions remain intact. Runtime lowering and the lint baseline
are unchanged. The focused combined stats/register-check command reproduces
all four errors before the fix and passes afterward: 25.450 s including build,
0.009 s package execution, peak RSS 3,664,760 KiB.

The full `just lint` gate passes with verified Staticcheck 2026.2.1 built by
Go 1.27.1: formatting, generated-file sync, both vet profiles, all four
Staticcheck profiles, and four script test commands. The lint gate takes
172.806 s and peaks at 3,649,928 KiB RSS. Existing baseline findings remain
visible; all profiles report zero new findings. Documentation passes for 99
Markdown files. The long activities remain above the 30-second target and
make no new compiler speed claim.

The fast-forward push to the existing PR branch is accepted. No force push or
PR merge was made. Hosted CI for the new head is pending; T3 keeps watching.
[Identity](data/wago-pr948-lint-2026-10-22/identity.json),
[red build](data/wago-pr948-lint-2026-10-22/stats-fixtures-red.log),
[green tagged tests](data/wago-pr948-lint-2026-10-22/stats-fixtures-green.json), and
[full lint](data/wago-pr948-lint-2026-10-22/full-lint.json)
retain exact commands, output, verified tool provenance, and resource use.


The later [Linux AMD64 failure](https://github.com/wago-org/wago/actions/runs/39732958160/job/119672128633)
also tests old head `72e684d` and reports the same four stale fixture calls.
The current PR head is already `1d9fbd47205e4d1686f868074a1fcd5aebbee01d`.
No additional source change or retry of the old run is needed. Existing green
combined stats/register-check and complete lint results validate the fix.
The Linux failure excerpt and classification are retained in the same evidence
folder. T3 remains assigned to the new head's CI.


The later [aggregate CI job](https://github.com/wago-org/wago/actions/runs/39732958160/job/119680353445)
fails on the same old `72e684d` run because lint did not succeed. Its input also
reports the known platform-test failure. It reports no new compiler error.
Both detailed failures were the four stale stats fixture calls already fixed
by current head `1d9fbd47205e4d1686f868074a1fcd5aebbee01d`. Keep monitoring the
new head; do not retry or change source for the superseded aggregate result.
The aggregate failure excerpt and classification are saved beside the lint
and Linux evidence.
