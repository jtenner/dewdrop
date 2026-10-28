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
