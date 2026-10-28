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

## Implementation and final narrow evidence

Owner approved inheriting the two JavaScript commits after the red runs:

| Original worker commit | Local inherited commit |
| --- | --- |
| `158dd834088f598e9a629cb8f89dcb2d28c9f90a` | `deac06c7e11599acf2425454a1fcd419570618ef` |
| `588cf363c2f9970ca698d44639c57d7a23bce731` | `24d1946bbd55f20779318a3bcec752ee9b9cd2f8` |

Root integration must skip these duplicate changes when it picks the snapshot
checkpoints. This work does not edit the inherited contract implementation.
Second own test checkpoint: `29a391a7744eed1b2995facc1288c94e986ae794`.
The code checkpoint follows local head `24d1946bbd55f20779318a3bcec752ee9b9cd2f8`.
Its tested source hashes are below; final handoff gives its exact commit ID.

`preparePackage` captures validated manifests, selected root/dependency sources,
the reachable graph, and selected standard `.dew` files. It checks regular files,
all parent directories, no-follow open, fstat identity, bounded reads, growth and
replacement, and strict manifest UTF-8. Selected file inventory is not treated as
captured bytes. The rewritten lock uses confined `.dew-snapshot/N/dew.json` paths.
The capture hashes each package with the existing v1 source-integrity field order
and checks dependency integrity and identity before build. Compiler graph checks
still apply; this helper does not implement a new version resolver.

Captured files have mode 0400; captured directories have mode 0500 while building.
Build uses the captured manifest, captured standard root, and an isolated private
cache. No live package or materialized dependency file is read after freeze.
Compiler scripts and installed toolchain files remain trusted installed tools.
Integrity from the compiler must equal the captured source integrity. Capsule
encoding takes only the captured root bytes. The compiler still owns compile
selection and excludes `_test.dew`; capture/integrity/capsules include tests.
No real compiler selection check is claimed in this mock-only run.

The primary compiler error and a cleanup error both remain visible. Package
errors throw; only the outer CLI sets `process.exitCode`. Outputs are retained
after snapshot cleanup, in a new directory created exclusively. A build failure
cannot leave a local output set or cause upload. Existing output directories,
capsules, descriptors and package inputs are not replaced.

Local commands:

```sh
tools/dew pack --manifest ./dew.json --output ./new-pack-directory
tools/dew publish --dry-run --manifest ./dew.json --output ./new-dry-run-directory
tools/dew pack --help
tools/dew publish --help
```

The output directory's parent must exist. The default directory is
`SCOPE-NAME-VERSION.pack` in the working directory. The capsule remains v1 with
the existing `registry:ORIGIN` source field. `INPUTS.json` records original and
canonical manifest hashes, files and hashes, original/rewritten lock hashes,
the exact captured graph, source integrity, ABI/interface, build-file digest,
captured standard identity, and capsule digest/size/paths. It records compiler
build identity as null because current ABI metadata does not expose it. Future
release data is null. This is local build evidence, not a public release.

Bounds: source 16 MiB, manifest 1 MiB, publish capsule 64 MiB including overhead,
local dependency artifact capture 256 MiB, 65,536 files/package, 4,096 graph nodes.
Lock input uses the approved plan's 1 MiB metadata bound. Coordinator note:
large 4,096-node graphs can reach this lock-byte bound before the node bound;
confirm this local lock policy when integrating. No contract API change is needed.
No version or codec number changes. Standard source capture also limits individual
files to 16 MiB and count to 65,536. This is not a whole-workspace/cache copy.

Additional baseline preflight run:
`DEW_TEST_REGISTRY_MODULE=/tmp/dew-pack-evidence/baseline-registry.mjs node --test --test-name-pattern='64 MiB publish|snapshot rejects .* graph' tools/test_dew_pack.mjs`.
Exit 1, 6 failed. Exact files: `preflight-baseline.stdout`,
`preflight-baseline.stderr` (empty), `preflight-baseline.status`. Old code reaches
the build before rejecting the capsule cap. The graph cases test snapshot-local
preflight with a mock compiler, not missing real-compiler rejection.

Final normal-import command, after the real contract commits were inherited:
`node --test tools/test_dew_pack.mjs`.
Result: exit 0, 34 passed, 0 failed, 0 skipped. Exact stdout, empty stderr, and
exit status are in `/tmp/dew-pack-evidence/integrated-green.stdout`,
`integrated-green.stderr`, `integrated-green.status`.
All 14 original named checks are covered, with option/symlink cases split and
the wider checks above. The same mutation checks are green. No fixture skipped
an unavailable module. A previous wider run using an exact external contract
copy also passed 34 checks: `wider-green.*`. That contract copy's SHA-256 equals
the inherited file: `c914ceac8f601d1f41f05ba47319a8dd225dd6e0f04551a4c5451d5946440fae`.

Impact smoke command: `python3 -m unittest tools/test_dew_registry_cli.py`.
Exit 0, one passed; stdout empty; stderr says `Ran 1 test` and `OK`.
Exact files: `auth-smoke.stdout`, `auth-smoke.stderr`, `auth-smoke.status`.
This checks the existing IPv6 no-login error without an HTTP call. It is not
auth expiry, revocation, server, or live-publish coverage.

Static commands: `git diff --check`, `node --check tools/dew-registry.mjs`,
`node --check tools/dew-package-snapshot.mjs`, `bash -n tools/dew`: all exit 0,
no stdout/stderr. No production source changed after the final normal-import run.
Tested implementation SHA-256 values:

| File | SHA-256 |
| --- | --- |
| `tools/dew` | `abfe52397e36b39ee012a467de1a3e1d5e16df897c68c7bdbb51f9e03431b133` |
| `tools/dew-registry.mjs` | `ec16833f266c7f20a7bd13879aeae4b821c293fedeba74cd727711abb900f57f` |
| `tools/dew-package-snapshot.mjs` | `bc2b404acf64dc6393a8dc6a8e40112fde298254edb1e1931db42cf9cc8034cb` |
| `tools/test_dew_pack.mjs` | `84d13a0554a5cfe639cf5dbabb86903817855552ec04b063dfd91b78d382d27d` |

Own changed files: those four files and this note. Inherited files:
`tools/dew-package-contract.mjs`, `tools/test_dew_package_contract.mjs`,
`docs/research/pkg-phase1-javascript.md`. Native integration after the bootstrap
and standard changes is still required. No full native lane, stress lane,
Starshine lane, broad build, timing or benchmark ran. No real compiler subprocess
ran, so no compiler wall-time sample is reported. Test-runner durations are
incidental functional-check output, not performance evidence.

## Performance handoff

Changed shared callers: pack, publish, and publish dry-run. Sensitive work:
source traversal, graph traversal, bounded file reads/copies, standard-source
capture, SHA-256, JSON, and capsule buffers. Snapshotting adds disk I/O and hash
work proportional to selected bytes. It must not copy unrelated workspace data.
No performance result is claimed during HOLD.

Capture reads/writes one bounded source at a time and stores file metadata.
Encoding later retains root file buffers plus one encoded capsule buffer, so its
live source/capsule data can approach twice the publish size before runtime/GC
overhead. SHA-256 rechecks and no-follow/parent checks add per-file work. The
compiled build file is hashed in chunks. The private cache deliberately cannot
reuse or restore live package-cache inputs. No lower memory or runtime cost is
claimed without measurement. An unavailable compiler build identity is not
invented from a Git commit or package version.

After an exclusive lease: compare frozen master and head for tiny/root/src
packages, a 16 MiB source, near-64 MiB capsules, 65,536 tiny files, graph chains
and diamonds, and large unrelated workspaces/caches. Record raw wall time, peak
RSS, allocations if available, staging bytes, bytes read/written and artifact
size. Include warm/cold compiler cache and fixed standard/compiler identity.
Native lanes, real compiler validation and performance runs remain held.
