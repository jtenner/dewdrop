# Phase 1 bootstrap input contract

Scope: bootstrap only. Base master is
`20f902acb6caa56a49712df832aeb0c46ec520b8`. Branch:
`t3/bootstrap-manifest-contract`. The full approved plan at `c812b052` and
`AGENTS.md` were read. No server, registry CLI, standard source, network write,
PR, push, or merge is in scope. All format numbers stay at 1.

## Failure checkpoint

Production source is unchanged from base. New checks copy bootstrap sources to
an isolated temporary Moon module, replace only `fn main`, and call real package,
lock, source, integrity, store, and restore code. No Dew compiler is built.

Command:

```
python3 src/dew_bootstrap/package_contract_check.py --evidence /tmp/pkg-phase1-bootstrap-evidence/red > /tmp/pkg-phase1-bootstrap-evidence/red.stdout 2> /tmp/pkg-phase1-bootstrap-evidence/red.stderr
```

Exit 1. There are 80 named checks and 69 failed expectations, including restore
side-effect assertions. Full commands, stdout, stderr, exit status, check names,
source hashes, and executable hash are in
`/tmp/pkg-phase1-bootstrap-evidence/red/results.json`. The outer stdout and
stderr paths are above. Narrow `moon build --target native src`: exit 0,
0.988935 seconds wall time. This is a functional build duration, not a benchmark.

Examples: `manifest unknown field` returned exit 0 and
`ok @fixture/root@1.0.0 dependencies=0`, instead of exit 2 with an unknown-field
error. `store identity` returned exit 0 and `ok stored`, instead of exit 2 with
an identity error. Invalid dependency records and oversized sources reached
restore writes before failing integrity. The harness records those writes as
separate failures. Existing path-conflict rejection checks pass on base.

Two harness setup attempts were corrected before this run: executable naming
and a test link that recursed into its own workspace. They are not code defects.

## Changed paths and later measurements

Planned shared checks cover manifest load, lock load and traversal, compile
source selection, integrity, artifact store, and artifact restore. Preserve
materialized Git sources. Match Dew's U32 SemVer and request rules. Reject
links and unsafe paths before source reads or restoration. Keep 16 MiB source,
256 MiB local artifact, and 64 MiB public transport bounds distinct. Public
transport belongs to the CLI owner.

Hold: no full native lanes, broad compiler builds, benchmarks, performance runs,
or cross-platform builds. After the coordinator grants a quiet-host lease,
compare base and final frozen source on tiny packages, 256 dependency manifests,
4,096 lock entries, diamonds and chains, 65,536 source files, long nested paths,
16 MiB sources, near-256 MiB local artifacts, cache hits, store and restore.
Record native time, peak RSS, allocations, metadata calls, bytes read and copied,
and executable size. Inspect all shared callers. Avoid pairwise path scans and
whole-file reads for size checks.

Native and LLVM share `platform_native.mbt` plus `platform.c`. Other bootstrap
platform implementations are absent at base. Their execution and the full
native compiler lanes remain held. No performance or platform pass is claimed.

## Wider failure checkpoint

The test driver can now read production files from an exact Git revision. This
keeps baseline checks independent of pending source edits. The production input
was again `20f902acb6caa56a49712df832aeb0c46ec520b8`:

```
python3 src/dew_bootstrap/package_contract_check.py --revision 20f902acb6caa56a49712df832aeb0c46ec520b8 --evidence /tmp/pkg-phase1-bootstrap-evidence/red-expanded > /tmp/pkg-phase1-bootstrap-evidence/red-expanded.stdout 2> /tmp/pkg-phase1-bootstrap-evidence/red-expanded.stderr
```

The expanded checks cover exact source order and inventory, valid and invalid
caret/tilde/exact/Git requests, build metadata and prerelease rules, cache-backed
graph restoration, nested source directories, conventional source inventory,
pre-write integrity, and the exact manifest byte limit. The script normalizes
only leading slashes in source output before an exact inventory comparison; base
`bootstrap_dirname` can print two leading slashes. No path-normalization fix is
in scope. Raw output remains in the evidence.

The first test checkpoint is `9e2d120ed`. The second checkpoint records only
expanded tests and this note; production edits remain uncommitted until the
same checks pass. A native test build timeout now kills the full process group.

## Final failure coverage

The wider failure command was run again with evidence directory
`/tmp/pkg-phase1-bootstrap-evidence/red-final` (and matching `.stdout` and
`.stderr` files). It adds lowercase hash syntax, escaped duplicate lock-entry
keys, the exact direct-dependency limit, dependency byte order in integrity,
Unicode source byte order, and artifact field bounds before copies. These use
the same base revision. The test checkpoint before these additions is
`0a76aa9b1`. Counts and wall duration are in the raw JSON and will be copied to
the final validation record.

The source-order fix also applies to dependency order. Moon's `Compare for
String` is length-first. It must not select the canonical byte order of package
sources or dependencies. This can change old source-integrity hashes for
packages with different-length source paths or dependency names. No v2 is added;
this aligns unreleased v1 with the contract. Recreate affected local locks and
artifacts using the aligned contract.

## Path agreement checkpoint

Read the JS contract at
`/home/dev/.t3/worktrees/dewdrop/t3-e477a636/tools/dew-package-contract.mjs`,
reported head `588cf363c2f9970ca698d44639c57d7a23bce731`, without edits.
Source/dependency byte order, lowercase hashes, and all size constants agree.
Windows drive-absolute paths match `^[A-Za-z]:/`; a colon in a relative filename
is allowed. Direct native helper checks cover that distinction, NUL, dot and
empty segments, backslashes, manifest prefixes, and the exact 4,096-byte path
bound without requiring host files at that length.

Run the same failure command with `--evidence
/tmp/pkg-phase1-bootstrap-evidence/red-paths`. Base source is unchanged. The
previous test checkpoint is `0fc3e2cc4`. Full evidence remains in that folder.

## Strict text checkpoint

The first direct-path run could not pass NUL in a process argument. The driver
now receives path text as JSON, so it can check NUL without changing the input
rule. That incomplete setup run is not a baseline pass. The complete replacement
run used `--revision 20f902acb6caa56a49712df832aeb0c46ec520b8 --evidence
/tmp/pkg-phase1-bootstrap-evidence/red-utf8`: exit 1, 149 named checks, 100
failed expectations including pre-write checks. Narrow build: exit 0,
1.007082 seconds. The test checkpoint before this repair is `77692bbcf`.

The installed `moonbitlang/x@0.5.5` source was read from its local registry ZIP.
It exposes `is_file` and `is_dir`, but no lstat/size API. Native reads use
fopen/fseek/ftell and full-file allocation. String reads then use
`@unicode.to_utf8_string`, which can replace invalid bytes. This justifies the
small lstat helper and a strict `@utf8.decode` in bootstrap JSON reads.

`manifest invalid UTF-8` returns exit 0 on base with
`ok @fixture/root@1.0.0 dependencies=1`. The invalid lock byte fixture already
returns exit 2, but with a JSON character error rather than a UTF-8 error. The
lock check specifically pins that diagnostic; it does not claim the base accepts
that lock. No remote dependency or software install was needed.
