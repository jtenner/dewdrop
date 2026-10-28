# Phase 1 validation after the V20 release

Source branch: `coordinate/dewdrop-pkg-phase1`.
Validation started at `d86ffde55b4800481c83cf88d268a1bb949922fd`.
All five worker areas are integrated. No landing or push has occurred.

The V20 hold was released. Before local validation, the shared ledger at
`/home/dev/Projects/starshine-goose-campaign-20261023/performance-lock.json`
had generation 20, no owner, no reservation, and no active lease. Correctness
checks held the existing `build.lock` mutex. No measurement lease was requested
or taken. Compiler elapsed records are diagnostics, not performance comparisons.

## Setup and native results

The first bootstrap test stopped before compilation because the pinned
`starshine-mb` workspace member was absent. Its stderr and exit 1 were saved.
An independent local dependency checkout was restored from existing Git objects
at the exact pinned commit `1b237952167f582abd492aec27adf10c5a6c9e60`.
This changed no tracked source, remote, or main-checkout files.

The repeated `DEW_NATIVE_TEST_PACKAGES=dew_bootstrap tools/test-native.sh`
passed. `DEW_NATIVE_TEST_PACKAGES=standard_sources tools/test-native.sh` also
exited 0, but reported no test entry. The latter is compile-only evidence.

The full routine `tools/test-native.sh` completed with exit 1. Its completed
test reports total 1,364 passed and zero failed. Some targets did not reach test
execution: they failed compilation. This is not a passing full lane.

Installed tools report `moon 0.1.20261023` and
`moonc v0.10.17+d971670cd (2026-10-23)`.
The distinct compile errors are:

- `src/transforms/floats.mbt:169`: `UInt64` has no `to_float` method.
- `src/transforms/floats.mbt:171`: `Int64` has no `to_float` method.
- `src/transforms/floats.mbt:174`: `UInt` has no `to_float` method.
- `src/transforms/floats.mbt:176`: `Int` has no `to_float` method.
- Pinned `starshine-mb/src/wast/lower_to_lib.mbt:814`: `Int` has no
  `reinterpret_as_float` method.

The transform source and Starshine pin are unchanged from master `20f902acb6`.
Tool resolution and SDK/core compatibility need repair or a compatible local
install before these errors can be classified further. No compiler-lowering or
dependency-source workaround has been folded into the package-contract branch.

Raw stdout/stderr and exit records are retained under
`tests/package-contract-v1/evidence/post-release/`. Large warning streams are
stored as deterministic gzip files. All processes from these runs have exited.

## Remaining work

Resolve local SDK compatibility. Then finish routine/integration and affected
platform checks, run real offline pack with the branch compiler, and update the
consolidated report. Performance comparisons still need a separate lease.
The earlier narrow checks remain valid within their recorded limits.

## Further qualification and offline preparation regression

An isolated source fixture from exact master `20f902acb6`, with its pinned
Starshine and standard sources, reproduces the four transform conversion-method
errors. The real pack check also stops on those errors, then removes its private
snapshot and creates no output set. A separate integration check reports
`program.modules.length(): 80 != 79`; the same test fails on exact master, so
that count failure is not introduced by Phase 1. The baseline fixture initially
lacked its integration script; that setup error was repaired before the check.

LLVM first stopped for missing `prelude.mi`. A complete official nightly SDK
was then installed in `/tmp/pkg-phase1-post-release/sdk-nightly`, without changes
to the shared SDK or its credentials. The downloaded binary checksum was
verified. It reports `moon 0.1.20261028` and
`moonc v0.10.17+5802d87ac-nightly`. Its native, JS, WasmGC and LLVM core bundles
all build. The first project checks with that SDK stopped because its private
registry index was empty, before project compilation. Cached dependency metadata
must be copied locally; this is a setup issue, not a package-contract result.

New `tools/test_dew_pack_offline.mjs` checks a remaining pack requirement:
compiler dependency synchronization must be disabled during package preparation.
It uses the real shell launchers with a fake Moon executable and captures the
actual argument vector. It covers bootstrap, JS and WasmGC launches, ordinary
build controls, and the prepared compiler environment. Before the fix, three
ordinary-build controls pass and four offline-policy checks fail, exit 1.
Raw evidence is `/tmp/pkg-phase1-post-release/offline-red.*`.
These tests prove forwarding and environment policy, not an observed HTTP leak.

The fix sets a private package-preparation environment flag and forwards
`--frozen` through both compiler launchers. This disables Moon dependency sync
for bootstrap, JS, and WasmGC compiler calls during pack/publish preparation.
Ordinary build behavior is unchanged. No Dew source or codec bytes change.
The extra branch/argument work is constant per compiler launch, with no added
source or graph copy. It must be included in the queued preparation measurement.

The identical seven offline checks now pass, exit 0. All 34 existing pack checks
also pass. Their raw streams are `offline-green.*` and `pack-after-offline.*`
in `/tmp/pkg-phase1-post-release/`. This is a script/environment policy fix; no
compiler-lowering or dependency source changed.
