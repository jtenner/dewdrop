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
