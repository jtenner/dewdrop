# Deferred GC evidence

Start with [the result](../../wago-gc-deferred-implementation-2026-10-22.md).

- `series.json` records the exact base, final branch and numbered patch hashes.
- `patches/` contains the implementation commits in order. `patch-replay-check.json` proves that replay yields the branch tree, using a separate index.
- `qualification-summary.json` holds all six final matched compiler samples and medians. Each sample checks output hashes, Wasm validation and main=42.
- `validation-summary.json` names the 24 selected passing final checks. Other raw logs include earlier red tests, fixes and rejected experiments; those are historical evidence, not current failures.
- `qualification-host/` is the frozen comparison host. `qualification-managed-fork.patch` is its three-file delta against the base Wago source. The private fork is for the matched host experiment; it is separate from the implementation series. The host go.mod contains local replace paths that must be set for another checkout.
- `qualification-identity.json`, source/host manifests and `control-production-audit.json` identify the builds. The replay check also proves that every compiled candidate production file matches the implementation plus the frozen private fork.
- The Python scripts record exact commands and timing. The final matrix uses an external pinned corpus and interpreter. It removes its temporary corpus link in a finally block.
- `perf-probe.c` records the hardware-counter request rejected by the kernel. No hardware cache count is claimed.

No binaries, mapped heaps, native caches or copied source trees are stored here.
The source branch is `/tmp/wago-gc-deferred-20261022`; measured host binaries are
in `/tmp/wago-gc-deferred-evidence`. The numbered patch series preserves the code
if those temporary directories are removed.

Raw logs and mail patches retain their original whitespace. Local attributes
exclude these evidence formats from source whitespace checks.
