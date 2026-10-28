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
