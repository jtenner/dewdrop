# PR 1009: resolve the live main conflict

[PR #1009](https://github.com/wago-org/wago/pull/1009) uses isolated checkout
`/tmp/wago-pr1009-main-sync-20261022`, branch
`dewdrop/pr1009-main-sync-20261022`. Its original head is
`ec8e26decce5904b4d9875f3c1bdab1243d32548`. Live main is
`688303ebfa75384e89773e3fc865b8bccb2e6a71`; both refs were fetched.
The historical base from the PR API is not used as the current main ref.

The catalog had one text conflict. Keep main's three-target `reg-abi`
registration and the PR's AMD64-only `direct-reference-abi` option. Existing
catalog ownership tests require the three-target registration. The CLI
manifest and schema retain the private reference-call option.

A tagged stats test then failed to build because main added a generic-GC
argument to `newGCFrameRootPlan`. Update the PR's test call to request exact
roots and generic execution. Keep all its register-call, wrapper-entry, hidden
reference, and root metadata assertions. Retain the original failed build as
evidence. The corrected stats plus register-check fixture passes.

The production merge preserves the PR's private direct-call restrictions,
wrapper reachability and retained adapters, exact roots, one-result bound,
register limits, tail/EH exclusions, and global-cache retirement on return.
It does not add the AMD64 reference optimization to another architecture.
The strict code and artifact size goldens pass without new edits.

The 8,192-call microbenchmarks pass all output and exact-root checks. Three
200-ms samples per mode give medians of 32,303 to 27,758 ns for scalar results
(14.07% less) and 31,062 to 26,292 ns for reference results (15.36% less).
Other local tests ran at the same time. These are isolated call-loop results,
not a new full compiler result or a memory comparison. The old full Dewdrop
and V8 samples remain historical. The four-second compiler target is not
claimed by this merge.

Merge commit `877363283b2564fff3b07de5a26520de2066fae3` contains both exact
parents. The fast-forward push to `perf/direct-reference-register-abi` was
accepted. GitHub confirms the new head, live main base, and no merge conflict.
No force push or PR merge was made. The isolated worktree is clean.

All required local gates pass on Go 1.27.1, GOMAXPROCS=2. Timings include builds:

| Check | Wall seconds | Peak RSS KiB |
| --- | ---: | ---: |
| Catalog and CLI manifest | 4.927 | 105,140 |
| Reference ABI and strict product sizes | 27.018 | 3,614,040 |
| Complete ordinary root suite | 156.718 | 2,154,600 |
| Complete register-check root suite | 146.959 | 3,595,192 |
| Register-check benchmark module | 31.708 | 956,660 |
| Reference ABI with stats and register checks | 26.405 | 3,609,916 |
| Direct-call microbenchmarks | 3.525 | 291,512 |
| Documentation (86 Markdown files) | 0.061 | 27,260 |

The wider AMD64 backend suite with both stats and register checks has 24
failing top-level tests, and the exact same 24 tests fail on unchanged main.
The [baseline comparison](data/wago-pr1009-main-sync-2026-10-22/backend-stats-baseline-comparison.json)
and both raw logs retain these counter-assertion failures. This optional suite
is not green. The changed private-reference stats fixtures pass. No assertion
or test is removed or weakened.

The complete root gates use a temporary shared clone of pinned Release 3 spec
sources, removed afterward. Direct tool paths avoid untrusted mise workspace
tasks. GOWORK stays unset for standalone temporary modules. Large test binaries
and standalone TinyGo builds dominate the long activities. They exceed the
30-second target and remain measured, not hidden or redefined as fast.

[Identity](data/wago-pr1009-main-sync-2026-10-22/identity.json),
[conflict and test repair](data/wago-pr1009-main-sync-2026-10-22/merge-resolutions.patch),
[full checked gate](data/wago-pr1009-main-sync-2026-10-22/checked-root.json), and
[microbenchmark samples](data/wago-pr1009-main-sync-2026-10-22/microbenchmark-summary.json)
are saved with full output, commands, CPU time, peak RSS and other resource
measurements. Existing dirty compiler/host checkouts are untouched.
T3 will watch the pushed branch for hosted CI results.


## Required CI green; separate native RISC-V hang

Head `877363283b2564fff3b07de5a26520de2066fae3` remains open,
non-draft, and mergeable. The [required CI workflow](https://github.com/wago-org/wago/actions/runs/39735491072)
is complete and successful. This is full CI, not draft smoke. The returned
first page confirms green lint, race, Core v2/v3, documentation, platform and
corpus jobs; the draft-smoke job is skipped. The regression-stress workflow is
skipped. The job-list API returns only its first page, so the saved job list is
not presented as an exhaustive inventory of the full matrix.

The separate [native RISC-V job](https://github.com/wago-org/wago/actions/runs/39735491061/job/119680322680)
fails in public ownership checks. Smoke, CLI/standalone qualification, and
compiler/runtime correctness pass first. The public test process is killed
after 16 minutes 30 seconds. Its last subtest is
`TestRV64PublicReferenceFunctionImportedStartGo/artifacttrue-vectortrue-widefalse-ownedfalse-success`.
The callback is inside `runtime.GC`, yielding in its sweep-completion loop;
goroutine zero is waiting on a runtime scheduler lock/futex. The log does not
establish a source cause. Do not classify the hang as transient or as a known
baseline failure without further evidence.

The same imported-start test passes ten full QEMU repetitions in each ordinary
and register-check mode (Go 1.27.1, RVA20 baseline, GOMAXPROCS=2). Each run covers
source/saved code, scalar/vector signatures, wide mode, owned host bindings,
success/trap/panic/exit, cancellation, and instance close. All GC calls and
lifetime/refund assertions remain active. Ordinary execution takes 14.149
seconds for the package, 51.877 seconds including build, with peak RSS
4,748,020 KiB. The checked command takes 51.476 seconds including build,
with peak RSS 4,753,280 KiB. Long compiler/build work remains above the
30-second target. QEMU passes do not establish native RISC-V safety or explain
the hosted hang.

There is no diff from live main in the runtime, RISC-V backend, or failed test;
the shared optimization catalog adds only the AMD64 option. This limits the
likely connection to the private-reference change but is not baseline proof.
No source, timeout, or test assertion is changed on this evidence. One retry
of only the failed native job is accepted. Successful jobs are not rerun.
Native retry is pending, the PR stays unmerged, and T3 continues watching.

[Hosted state](data/wago-pr1009-green-rise-2026-10-22/hosted-snapshot.json),
[timeout trace](data/wago-pr1009-green-rise-2026-10-22/rise-timeout-trace.log),
[classification and retry](data/wago-pr1009-green-rise-2026-10-22/classification.json),
[ordinary repeats](data/wago-pr1009-green-rise-2026-10-22/imported-start-default.json),
and [checked repeats](data/wago-pr1009-green-rise-2026-10-22/imported-start-checked.json)
retain commands, raw output, resources, and the remaining native validation gap.


The later failure notice names old job `119680322680`, already inspected above.
The latest run attempt has [native retry job 119699190118](https://github.com/wago-org/wago/actions/runs/39735491061/job/119699190118)
in progress, with pinned fixture preparation successful. The head is unchanged
at `8773632`, open and mergeable. This is a delayed notice, not a second native
failure. [The retry snapshot](data/wago-pr1009-green-rise-2026-10-22/late-failure-retry-snapshot.json)
records the distinct job IDs. No duplicate retry, source patch, or timeout
change is made. T3 remains assigned to the existing retry.
