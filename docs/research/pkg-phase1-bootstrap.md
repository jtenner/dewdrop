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

## Shared vector adapter checkpoint

The driver and Python harness now consume `emit.mjs` output from the shared
vector folder, without editing it. `--vectors PATH` selects a peer folder; the
merged repo defaults to `tests/package-contract-v1` when present. It calls real
bootstrap load, source selection, path validation and graph traversal functions.
No expected answers are sent to the Moon reader. Range-match vectors build a
small valid local lock graph and distinguish a request mismatch from any other
failure. Manifest vectors use raw JSON text and inspect the normalized dependency
map returned by the actual loader. Artifact path vectors call the real shared
validator without making long host paths.

Command:

```
python3 src/dew_bootstrap/package_contract_check.py --vectors /home/dev/.t3/worktrees/dewdrop/coordinate-dewdrop-pkg-phase1/tests/package-contract-v1 --evidence /tmp/pkg-phase1-bootstrap-evidence/green-shared2 > /tmp/pkg-phase1-bootstrap-evidence/green-shared2.stdout 2> /tmp/pkg-phase1-bootstrap-evidence/green-shared2.stderr
```

Exit 0: 157 bootstrap checks and 181 shared checks pass. Exactly 12 artifact
budget cases are listed as unsupported. All 18 request-match cases run through
the local graph loader. Narrow build: exit 0, 0.887067 seconds. The emitted
vector bytes have a SHA-256 in the evidence. Source-selection cases execute the
native collector for both include-tests modes. They do not execute the Dew
compiler. Bounds checked only by inspecting constants are not codec tests.

The final own-suite baseline command used `--revision
20f902acb6caa56a49712df832aeb0c46ec520b8 --evidence
/tmp/pkg-phase1-bootstrap-evidence/red-freeze`. It includes exact/caret/tilde
trailing `-` and `+` requests and lock versions. Earlier trailing-marker manifest
checks also fail on base and pass with the fix. A test-driver JSON expression
was corrected before the successful shared run; that build failure is retained
in `green-shared/results.json` and is not a production-code defect.

Only the five owned Moon input files were formatted, using `moonfmt -` with
explicit input and output. Total wall duration: 0.050981 seconds. Per-file
commands, stderr, exit status and wall duration: `/tmp/pkg-phase1-bootstrap-evidence/format.json`.

## Implementation checkpoint

Final base run: exit 1, 157 named checks, 108 failed expectations including
pre-write state assertions, narrow build exit 0 in 1.079560 seconds. The test
checkpoint before the implementation is `411fed668`.

The implementation now:

- Rejects duplicate JSON keys before map collapse, including escaped keys.
  Uses strict UTF-8, known fields, byte limits and bounded nesting. Missing
  dependencies still means an empty map.
- Checks ASCII package names, bounded U32 SemVer, all five request forms,
  direct-dependency counts, strict v1 lock schema and counts, provenance strings,
  lowercase hashes and safe relative lock paths.
- Checks each request before loading or restoring its dependency, including exact
  Git source equality. Checks loaded/stored name and version against the lock.
  The native lstat helper rejects links, special files and oversized selected
  files. It checks every existing parent before a missing lock path is restored.
- Selects globally UTF-8-byte-sorted conventional regular `.dew` sources, with
  tests excluded for compile input and included for integrity/cache artifacts.
  It ignores root directories with a `.dew` suffix. Source reads have the
  16 MiB bound. Full-file reads are not used just to obtain size.
- Checks local artifact dependencies, identities, provenance, path conflicts,
  field lengths, file lengths, count bounds, checksum and complete source
  integrity before restore writes. Restore directories are parent-first. Cache
  storage validates identity even on a cache hit. A new artifact hashes source
  bytes during encoding instead of reading once for integrity and again to
  store. Local encoded size is bounded before appending each source.

The local codec remains 256 MiB. The JS public publish policy remains 64 MiB.
There is no new codec version, network installer or Git fetch operation.

Costs and limits:

- Metadata checks are bounded scans. SemVer parse allocates bounded component
  arrays; dependency and file checks use hash sets. Paths are not compared
  pairwise. The UTF-8-order comparator scans UTF-16 units without allocating
  encoded strings on each sort comparison. Sorting remains O(n log n).
- The lstat helper adds metadata calls, including one per existing parent for
  checked reads and restoration. These calls need quiet-host measurements on
  deep paths and shared dependency graphs. No speed or RSS gain is claimed.
- Artifact store and restore still use the existing whole-payload buffers and
  checksum copies, up to the 256 MiB local bound. This patch does not claim
  streaming or low peak memory for near-limit artifacts.
- Checks inspect filesystem state at each step. They do not freeze source or
  lock files against concurrent mutation. End-to-end release snapshots belong
  to the separate snapshot area. Full openat-based race hardening is not proven.
- The parent-link check also rejects links in package path ancestors. Check this
  policy on platforms with linked temporary-directory ancestors before claiming
  native portability. Only the Linux native narrow driver has run. LLVM shares
  the edited binding but its compile and execution remain held. Bootstrap had
  no JS/Wasm platform implementation at base, and none is added here.
- Existing lock hashes from length-first Moon sorting can need regeneration.
  The full native/integration/cache lanes and large-cap workloads remain held.

Files are confined to `manifest.mbt`, `package_artifact.mbt`, new bootstrap
contract/helper/test inputs, `platform.c`, `platform_native.mbt`, and this note.
