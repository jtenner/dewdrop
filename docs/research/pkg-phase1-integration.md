# Phase 1 integration record

Base: `20f902acb6caa56a49712df832aeb0c46ec520b8`.
Branch: `coordinate/dewdrop-pkg-phase1`.
Plan: `c812b052:docs/package-manager-migration-plan.md`.

The merge order is shared vectors, JavaScript contract, bootstrap contract,
standard codecs, then snapshot/pack. Full native lanes and performance runs
remain on hold. No server, box, WorkOS, or dewdrop-pm changes are in scope.
No PR, push, or master merge has occurred.

## Shared standard-codec regression checkpoint

The narrow `tests/package-contract-v1/run-std.py` runner uses the shared vectors
directly. It generates one Dew test per case ID. It checks name, SemVer,
requirements and matching, raw manifests and normalized dependencies, plus
artifact decode/validate/encode with correct framing and SHA-256 checksums.
SemVer cases also enter manifest, lock, and artifact decoders.

The first generator run had setup errors: missing block newlines and a missing
test-file suffix. Those errors ran no contract tests and are not bug evidence.
The corrected runner reached 155 cases: 132 pass and 23 fail on unchanged master
standard sources. Two failures showed a new mismatch: `semver_parse` accepted
`1.0.0-` and `1.0.0+`. The standard codec worker did not change `std/semver.dew`.

Coverage was widened before the fix. Shared manifests and exact/caret/tilde
requirements now include both empty suffixes. The same generated suite has
169 cases: **132 pass and 37 fail**, exit 1. Sixteen failures concern empty
suffixes. The other 21 failures concern the separate codec worker's fixes.
The baseline standard files still match master. The command is:

```sh
python3 tests/package-contract-v1/run-std.py --compiler /home/dev/Projects/dewdrop/_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe --evidence /tmp/pkg-phase1-shared-std-red
```

The compiler executable hash is
`73a57efc6454d0ef7b4755f3c9979561c146a1cad182778d044c32890658b626`.
Its source commit is unknown. This is evidence for the exact source inputs
listed in the result file, not evidence of a fresh compiler build. Caches are
disabled. Each compile/run has a 30-second timeout. The result includes commands,
wall times, exit codes, compiler hash, all standard-source hashes, generated
test hash, and case IDs. Streams and result are retained under
`tests/package-contract-v1/evidence/std-shared-red.*`.

Source selection and numeric artifact-budget recipes do not run in this codec
runner. Filesystem callers own selection. Large allocation and complete native
validation remain separate checks. The added SemVer fix must stay in the shared
parser, since manifest, lock, artifact, and requirement readers all call it.
It must reject an empty identifier before parsing or allocation. Its added
constant work and all existing standard parser callers need measurement after
the quiet-host lease.

## Integrated JavaScript checks

After the first two merges, Node checks pass: 106 area checks, 149 shared cases
in each of parse/read modes, and 11 harness tests. The shared runner lists 30
unsupported range-match/budget cases. All three JavaScript check stderr files
are empty. These are functional checks, not performance results.

## Empty SemVer suffix fix

Regression checkpoint: `d61a75c37`. The parser now checks that a dash has a
following prerelease identifier before the build separator, and that a plus
has a following build identifier. It returns `EmptyIdentifier` at the missing
identifier. The source change is in `std/semver.dew`, the narrow shared owner of
this bug. Fixing each package caller separately would leave the other readers
with different SemVer rules. No scan, allocation, or source copy was added.
The existing scans get two constant-time checks.

The identical 169-case test suite now reports **148 pass and 21 fail**, exit 1.
All sixteen empty-suffix failures are gone. The 21 remaining failures are the
separate standard codec changes that have not been merged yet. The result is
`/tmp/pkg-phase1-shared-std-semver-fixed/result.json`; stdout/stderr are in that
directory. This is a partial green result for the parser fix, not a claim that
the complete contract suite passes. The generated package sources are current.
The wider JavaScript vector suite now passes 163 cases, with the same 30
unsupported range-match/budget cases. No full native lane or timing run ran.

## Original lock input regression checkpoint

The completed snapshot branch is `2012c41ee577fbd104cf49e423b7db2077235896`.
Static inspection found that `captureGraph` used `JSON.parse` and then wrote a
canonical lock. This hid original duplicate/unknown fields from the compiler's
strict lock reader. The new `snapshot-inputs.test.mjs` calls the real snapshot
module with a mock compiler and tiny standard sources. It checks duplicate
decoded keys, unknown fields, invalid unused locked records, and invalid UTF-8.
Every rejection must happen before a build call. The valid-lock control checks
the original lock digest and the checked source integrity.

Command before the fix:

```sh
DEW_TEST_SNAPSHOT_MODULE=/home/dev/.t3/worktrees/dewdrop/t3-5d0c8bc9/tools/dew-package-snapshot.mjs node --test tests/package-contract-v1/snapshot-inputs.test.mjs
```

Result: 10 failures, 1 pass, exit 1. Each failure reports a missing expected
rejection. Raw output is `/tmp/pkg-phase1-snapshot-lock-red.stdout`; stderr is
`/tmp/pkg-phase1-snapshot-lock-red.stderr`. This error is in newly added snapshot
code, not a claim that master had the `pack` command. The fix must validate the
original lock, including unused records, before snapshot path rewriting.

## Dew lock codec regression checkpoint

Shared vectors now include 16 raw lock cases. With the empty-suffix parser fix
but before lock or worker codec fixes, the 185-case suite reports **154 pass,
31 fail**, exit 1. Ten new failures have `lock/` IDs: invalid name, empty source,
absolute/drive/parent/empty/dot paths, invalid integrity/interface, and duplicate
records. Six valid or already-rejected lock controls pass. The raw result and
streams are in `/tmp/pkg-phase1-shared-std-lock-red/`.

The standard lock decoder returned records before applying its validator.
The fix must make decode obey the same rules as public encode, check public
SemVer text and drive-root paths, and use a name set instead of a pairwise scan.
The added public-constructor tests are
`std/tests/package_lock_contract_v1_test.dew`. No change to module-manifest path
semantics is needed. Network resolution and install remain outside Phase 1.

The public-constructor regression ran before the fix: one valid control passed,
two tests failed with `invalid public lock version validated` and `drive-root
lock path validated`, exit 1. Compile exit was 0 with empty stderr. The compile
and run streams are `/tmp/pkg-phase1-public-lock-red*`.

After the fix, the same 185 shared cases show **164 pass and 21 fail**, exit 1.
Every `lock/` case passes. The 21 remaining failures belong to the unmerged
manifest/artifact codec worker. All three identical public-lock tests pass,
exit 0, with empty compile stderr. The generated source mirror is current.
Shared results are in `/tmp/pkg-phase1-shared-std-lock-fixed/result.json`.

Successful lock decode now performs validation. Validation parses each bounded
version text and checks each path/provenance once. A name set replaces the old
pairwise name scan for both decode and encode. This adds temporary set storage
proportional to record count and avoids quadratic duplicate comparisons. No
source bytes are copied. Measure 0, 1, 256, and 4,096 records, including invalid
and duplicate records, after the quiet-host lease. No performance claim is made.

## Strict JavaScript lock parser

`tools/dew-package-lock.mjs` preserves decoded duplicate keys and validates all
original v1 records before any path rewriting. It shares the manifest name and
SemVer functions, keeps 8 MiB for a local lock (1 MiB remains the manifest cap),
and caps the local graph at 4,096 records. A 16-level JSON limit, 65,536-value
limit, and 4,096-byte JSON string limit match the existing standard lock reader.
The parser returns only schema-checked data and uses no network or filesystem.

The new parser passes 22 focused checks, including raw syntax, duplicate decoded
fields, invalid records, exact 8 MiB bytes, and 4,096/4,097 records. The shared
JavaScript adapter now calls it for the 16 lock cases. The ten original-snapshot
rejections remain a pending integration check until the snapshot commit merges
and calls this parser. No pack-fix claim is made at this checkpoint.

This parser adds one bounded metadata parse and a package-name set to local
pack/publish preparation. It does not parse each lock twice or copy source
contents. Measure lock parse/capture with large materialized graphs after the
hold. File I/O, UTF-8 rejection, and snapshot cleanup still need the caller checks.

## Linked ancestor agreement checkpoint

The JavaScript reader initially followed a link in a package path ancestor,
while the bootstrap and snapshot readers rejected it. Two new real-filesystem
checks cover manifest reads and source collection through a linked parent.
Before the fix, the area suite reports **106 pass, 2 fail**, exit 1. Both failures
are missing expected symlink rejections. Streams are
`/tmp/pkg-phase1-ancestor-red.stdout` and `.stderr`. These checks do not claim
complete hardening against concurrent directory replacement.

The native shared adapter now also runs the 16 raw lock cases. The integrated
narrow native run passes **157 area checks and 197 shared cases**, exit 0;
12 numeric artifact-budget cases remain explicitly unsupported. Its stderr is
empty. Evidence is `/tmp/pkg-phase1-bootstrap-integrated/results.json`.

The same JavaScript area suite now passes **108 checks**, exit 0, with empty
stderr. The added checks inspect ancestors before and after a manifest read,
and before source collection. This aligns the input rule with native and pack
readers. It adds metadata calls proportional to path depth. It does not add
source copies, and it does not claim full race protection. Use physical paths
without linked ancestors; linked temporary-directory aliases on other hosts
still need platform checks. Evidence is `/tmp/pkg-phase1-ancestor-green.*`.

## Lock version literal agreement

Native and Dew lock readers already require the literal JSON number `1`.
The JavaScript lock parser initially admitted `1.0` and `1e0` after numeric
conversion. Two new shared and focused cases require rejection of those forms.
This is a representation check for the existing codec number, not a new version.

Before the fix, the focused lock suite reports 22 pass and 2 fail, exit 1.
Both failures are missing expected rejections. The parser now checks the original
root version number before conversion. This adds no scan or metadata copy.
The same focused suite now passes 24 checks, exit 0. Raw streams are
`/tmp/pkg-phase1-lock-literal-red.*` and `/tmp/pkg-phase1-lock-literal-green.*`.

## Ordered integration and original lock fix

Bootstrap merged, then the standard codecs. Only the generated package source
mirror conflicted. It was regenerated from the merged source files. Pack's three
own checkpoints were then cherry-picked in order, without its inherited copies
of the already-merged JavaScript changes. All worker checkpoints remain reachable
from their retained branches; no worktree was removed.

Pack now reads original lock bytes with strict UTF-8, then calls
`parsePackageLock` before canonicalization or source capture. It uses the existing
8 MiB local lock cap. The exact 11-case original-lock test now passes, exit 0.
The original 34-case pack suite had one diagnostic-only mismatch: an escaping
path now fails earlier with `unsafe locked package path: ../outside`. The test
now requires that specific cause, and each other graph check requires its own
identity, integrity, cycle, or missing-lock cause. No valid behavior was changed
to satisfy the test. Streams are `/tmp/pkg-phase1-snapshot-lock-green.*` and
`/tmp/pkg-phase1-pack-integrated.*`.

## Fixed-source final checks

Production code was frozen at `3ac2506d9b13a033979470e0a344a8977a0f0190`.
The final narrow run is `/tmp/pkg-phase1-final/results.json`. It records each
command, stdout/stderr path, exit status, functional wall time, and changed-file
hash. The small native driver was rebuilt from that source. Dew tests compiled
fresh Wasm from the on-disk standard sources with caches disabled; the saved
test compiler's source commit remains unknown.

The first final run passed native, Dew shared, JavaScript Node/Bun, shared JS
parse/read, pack, strict lock, and original-lock snapshot checks. The harness
failed only because its old fixed count expected 179 vectors instead of 211.
The count assertion was replaced with named controls for the new actual
regressions. No production code changed after the freeze for that test repair.
The failed harness stdout remains in `/tmp/pkg-phase1-final/harness.stdout`.
Full native lanes, LLVM/platform compilation, real compiler pack validation,
large cap workloads, and performance measurements remain held.
