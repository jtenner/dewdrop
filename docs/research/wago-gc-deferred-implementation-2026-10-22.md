# Four deferred Wago GC issues: implementation and checks

All four requested issues have local code and commits: [308](https://github.com/wago-org/wago/issues/308), [309](https://github.com/wago-org/wago/issues/309), [313](https://github.com/wago-org/wago/issues/313), and [321](https://github.com/wago-org/wago/issues/321).

The Wago branch is `dewdrop/gc-deferred-20261022`, at `/tmp/wago-gc-deferred-20261022`. It starts from `9d84600f1580a3a68ba46f1e262695d85a661d7c`. The [patch series](data/wago-gc-deferred-2026-10-22/patches/) and [commit/hash manifest](data/wago-gc-deferred-2026-10-22/series.json) preserve the changes in this repository.

## What is implemented

| Issue | Change | Admission |
| --- | --- | --- |
| 308 | Stable virtual heap/handle ranges, lazy page access, portable fallback, direct native handle bindings, checked teardown | Native 64-bit mapped products; bounded portable/Tiny fallback |
| 309 | 16-byte hot handles, cold card links, header-free structs, eight-byte array prefix, aligned vectors, 16-byte old class | Default; padded-header A/B build retained |
| 313 | 32-KiB regions, 128-byte lines, packed tracing, lazy sweep, transactional sparse evacuation, page return, `CompactGC` | Explicit `GCAllocatorImmix`; paged default retained |
| 321 | Bounded telemetry, background metadata sweep, stealing mark workers, private copy chunks, concurrent graph marking and insertion barriers, paced optional automatic controller | Build/config/size gates; no default worker threshold |

The [implementation record](data/wago-gc-deferred-2026-10-22/deferred-gc-implementation-2026-10-22.md) explains each commit. The [concurrent-mark proof](data/wago-gc-deferred-2026-10-22/concurrent-marking-design-2026-10-22.md) states its roots, barriers, memory/work bounds and cancellation rules. Concurrent relocation is not enabled.

## Compiler result

Three matched cold-cache pairs use the same pinned compiler/request, frozen host, CPUs 12/14, GOMAXPROCS=2, 512-MiB heap, 64-MiB nursery and no transform workers. The order is control/final, final/control, control/final. No other builds or tests ran during these samples. The final product uses the default paged allocator and nil execution options.

| Median | Control | Final |
| --- | ---: | ---: |
| Wall time | 33.622 s | 28.985 s |
| Process CPU | 34.050 s | 29.372 s |
| Peak RSS | 1,138,168 KiB | 620,524 KiB |
| Minor page faults | 11,026 | 88,074 |
| Voluntary context switches | 112,706 | 90,601 |
| Involuntary context switches | 24,660 | 18,495 |

This is 13.8% less wall time and 45.5% less peak RSS on this pinned job. Every output Wasm/cache hash matches; Wasm validation passes and the generated main returns 42. [Raw samples and medians](data/wago-gc-deferred-2026-10-22/qualification-summary.json) include CPU, RSS, faults, context switches and output hashes. **The four-second target is not met.** These results do not establish a speed gain for other inputs.

The host executable grows from 17,278,827 to 17,358,095 bytes (+79,268, 0.46%). Worker and concurrent products are 17,420,239 and 17,473,291 bytes. These are matched unstripped Go host builds, not per-function JIT byte counts. [Build sizes/hashes](data/wago-gc-deferred-2026-10-22/linked-host-sizes.json) and [source identity](data/wago-gc-deferred-2026-10-22/qualification-identity.json) are saved.

The comparison uses a frozen private managed-instance host. Its three private source changes are audited against the baseline. The current Dewdrop Facet host and its build script have separate user edits and are left intact. The existing ARM64 call.go change is also intact (hash in series.json). The qualified binary is `/tmp/wago-gc-deferred-evidence/final-host`; no active runtime or public PR was changed.

## Optional collector measurements

Immix remains opt-in: its current serial full-mark screens are slower than the paged collector. Sparse evacuation packs four regions into one with stable identities and bounded scratch. Parallel marking and large copy screens do not justify automatic defaults. Background overlap does not show a clear gain. Concurrent marking improves the large Go-graph screen by about 8%, but the small graph is slightly slower; snapshot memory is about 6.42 MB. These screens are separate from the compiler result above. Full raw data and the decision to retain disabled defaults are in the implementation record.

`GCConfig{Allocator: GCAllocatorImmix}` selects the region collector. Worker options also require `-tags wago_gc_workers`. Concurrent marking requires `-tags 'wago_gc_workers wago_gc_concurrent'`, AMD64, a moving nursery, `ConcurrentMark: true` and explicit `MinConcurrentBytes`/object thresholds. `AutoConcurrent` optionally advances cycles at exact allocation/minor safepoints. Zero mark/copy/concurrent byte thresholds disable their work. Snapshot/remark budget declines stay visible and never publish partial sweep. Explicit full GC cancels a snapshot before exact tracing, so floating snapshot garbage cannot cause false exhaustion.

## Checks and limits

The [24 final checks](data/wago-gc-deferred-2026-10-22/validation-summary.json) pass: native collector/runtime, full Wago, AMD64 backend, both physical layouts, fault injection, race checks, native concurrent roots/barriers/reentry/artifacts, register checks, guard-page build, worker and Tiny exclusion, ARM64 GC/physical guards under QEMU, and Darwin/Windows/386 cross-builds. The test corpus link was removed after the run.

QEMU excludes only `TestGCReducedBatchHonorsDeadline`, which has a known emulated timer EINVAL. Darwin/Windows were built, not run. Hardware cache counters are unavailable: Linux perf_event_open returned EPERM. Reported worker nanoseconds are elapsed time, not OS CPU. Accessible/reserved mapping bytes are not RSS or OS commit charge. No unavailable measurement is called zero.

All compiler activities were timed. The full Wago test executable takes 40.026 seconds in this run, above the 30-second activity target; the complete compiler job also remains far above four seconds. No claim is made that these latency bugs are resolved.

To inspect the complete implementation, use the local Wago branch. To replay the series, start a clean Wago branch at the exact base above and run `git am` on the numbered patches in order. The patches are checked against a separate index; the final tree must match the Wago branch. Avoid applying them over the dirty active host checkout.
