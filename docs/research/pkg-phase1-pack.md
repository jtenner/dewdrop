# Phase 1: local pack and captured inputs

Scope: `tools/dew`, `tools/dew-registry.mjs`, new snapshot helpers, and
`tools/test_dew_pack.mjs`. Base: `20f902acb6caa56a49712df832aeb0c46ec520b8`.
Approved plan read in full from `c812b052:docs/package-manager-migration-plan.md`.
Owner permits only the Phase 1 local contract. No server, auth change, network
publication, push, PR, or merge. No Claude or child agents. Laptop timing HOLD.

## Checks first

The narrow test runs the real registry source in Bun. Its compiler subprocesses
and HTTP endpoint are mocks. The shell route check replaces both Bun and Moon
with small scripts. No compiler build or network request is permitted.

Command: `node --test tools/test_dew_pack.mjs`.
Baseline run: exit 1, 14 failed, 0 passed, 0 skipped. Exact output files:
`/tmp/dew-pack-evidence/baseline.stdout`, `baseline.stderr`, `baseline.status`.
Runner stderr is empty; the runner embeds each child's stderr in stdout.
Specific diagnostics from unchanged production source:

- `publish keeps capsule sources fixed after build`:
  `AssertionError: integrity sources differ from build inputs`.
- `publish keeps capsule sources fixed after integrity`:
  `AssertionError: capsule sources differ from build inputs`.
- `snapshot fixes dependency graph and rewrites lock paths`: the same integrity
  byte mismatch after changing root, dependency, and lock inputs.
- `compiler failure keeps stderr and removes private files`:
  `mock compiler failed: fixture build error`, then
  `build failure leaked a temporary directory` (`dew-publish-*`).
- `src regular file uses root sources`:
  `dew publish: package has no conventional .dew sources`.
- `pack retains capsule and local INPUTS without credentials or network`:
  `dew pack: unsupported registry command` (exit 2).
- Pack collision, build failure, and help checks fail on that absent route.
  Their detailed new-path assertions need green coverage; the absent route
  alone does not prove the old code had each detailed failure.
- `publish dry-run uses local preparation with no auth or upload`:
  `dew publish: credentials file is invalid`.
- `publish rejects unknown, duplicate, missing and positional options`: the
  first unknown option is ignored and the mock publish succeeds (exit 0).
- `reject source files above 16 MiB before build`: old code accepts the sparse
  16 MiB + 1 file and mock publishes it (exit 0).
- `reject source and directory symlinks`: the first source symlink is silently
  ignored and mock publish succeeds (exit 0).
- `shell routes pack to the script without a native build`:
  `unexpected native pack route` (mock Moon exit 91).

Each changed behavior has a named check.
Source mutation checks compare actual capsule bytes and canonical v1 integrity
against bytes observed by the build mock. The graph case captures a materialized
dependency and then mutates both its source and the root lock.

Test checkpoint: `e1d5eb3acccbea8a5a89a684122b5ff5c730eebb`.
The first commit attempt failed because Git had no author identity. It made no
commit. Later local commits use the base commit's `Codex <codex@openai.com>`
identity by command options, without changing Git configuration.

Wider checks were added before the code checkpoint. They separate each option
and symlink case. The graph mutation now changes the dependency and lock only.
The exact old file was saved with:
`git show 20f902acb6caa56a49712df832aeb0c46ec520b8:tools/dew-registry.mjs > /tmp/dew-pack-evidence/baseline-registry.mjs`.
No baseline source was edited. Run:
`DEW_TEST_REGISTRY_MODULE=/tmp/dew-pack-evidence/baseline-registry.mjs node --test --test-name-pattern='snapshot fixes|manifest changes|default manifest|publish rejects|reject .* symlinks' tools/test_dew_pack.mjs`.
Exit 1, 12 failed, 0 passed. Output: `wider-baseline.stdout`,
`wider-baseline.stderr` (empty), `wider-baseline.status`, in the evidence folder.
The graph-only diagnostic is `dependency graph differs from build inputs`.
The changed manifest leads to a capsule/integrity mismatch. Absent dependencies
give `dew.json does not contain a package manifest`. Every option is separately
shown to be ignored. Every symlink case is separately shown to be accepted or
silently omitted by the old publisher. These use a mocked compiler, so they do
not establish a bug in a real compiler's own checks.

Additional coverage: a diamond graph with one captured shared node; unsafe lock
paths; missing, cyclic, wrong-identity and wrong-integrity graph inputs; source
size preflight; 64 MiB encoded-size preflight; output parent removal; and visible
cleanup errors with and without a primary compiler error. Pack-specific detailed
checks extend the new route's coverage; missing pack on master is the red case.

A strict-UTF-8 check failed on the first snapshot candidate, before its fix:
`DEW_TEST_CONTRACT_MODULE=/home/dev/.t3/worktrees/dewdrop/t3-e477a636/tools/dew-package-contract.mjs node --test --test-name-pattern='invalid UTF-8' tools/test_dew_pack.mjs`.
Exit 1. Actual error: `dependency @test/dep is missing from dew.lock`, instead of
the required UTF-8 error, because permissive decoding changed invalid bytes into
text. Exact output: `utf8-red.stdout`, `utf8-red.stderr` (empty),
`utf8-red.status`. Candidate source is saved as `candidate-before-utf8.mjs` and
`candidate-before-utf8.patch` in the evidence folder. This is a candidate defect,
not a separate claim about compiler behavior on master.

First green run against the other worker's real contract source:
`DEW_TEST_CONTRACT_MODULE=/home/dev/.t3/worktrees/dewdrop/t3-e477a636/tools/dew-package-contract.mjs node --test tools/test_dew_pack.mjs`.
At that point: 16 passed, 0 failed, 0 skipped, exit 0. Exact files:
`real-contract.stdout`, `real-contract.stderr` (empty), `real-contract.status`.
An earlier attempt ran before that module appeared on disk: 3 passed, 11 failed
with `Cannot find module`, exit 1 (`first-green.*`). This was a missing test
dependency, not a code-defect result. The final wider run is still required.

## Design and limits

Build, ABI extraction, integrity, and encoding must consume one private source
snapshot. Only manifests, selected sources, the reachable graph and rewritten
v1 lock, and the selected standard sources are copied. No whole workspace or
cache copy. Preserve test sources in integrity/capsules and compiler selection.
Use the parallel worker's `dew-package-contract.mjs` API without editing it.
Until that branch is present, any temporary test contract must be outside source
and explicitly selected by `DEW_TEST_CONTRACT_MODULE`. It is not final evidence.

Local `pack` and `publish --dry-run` retain `package.dpa` plus `INPUTS.json` in
a new output directory. Existing paths must not be replaced. INPUTS is local
evidence only, with absent future release fields. No remote tag check or full
release descriptor is added. Existing publish auth and HTTP remain as before.
Gaps 5 (server persistence/listing) and 7 (token expiry/revocation) stay deferred.

## Performance handoff

Changed shared callers: pack, publish, and publish dry-run. Sensitive work:
source traversal, graph traversal, bounded file reads/copies, standard-source
capture, SHA-256, JSON, and capsule buffers. Snapshotting adds disk I/O and hash
work proportional to selected bytes. It must not copy unrelated workspace data.
No performance result is claimed during HOLD.

After an exclusive lease: compare frozen master and head for tiny/root/src
packages, a 16 MiB source, near-64 MiB capsules, 65,536 tiny files, graph chains
and diamonds, and large unrelated workspaces/caches. Record raw wall time, peak
RSS, allocations if available, staging bytes, bytes read/written and artifact
size. Include warm/cold compiler cache and fixed standard/compiler identity.
Native lanes, real compiler validation and performance runs remain held.
