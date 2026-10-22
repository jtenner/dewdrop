# GC scalar screen and large promotion sorting

The four-second Dew compiler target remains unmet. This is a small local GC
improvement above deferred-GC commit `7f748b9ed0cb2822a69af4913871ccb0a1aa193f`.
It is not installed or published.

## Scope and discarded approaches

A fresh diagnostic run of the frozen deferred-GC host records 29.95 sampled CPU
seconds: 23.02 seconds in generated code, 1.60 cumulative seconds in dead nursery
handle cleanup, and 0.62 cumulative seconds in promotion sorting. Diagnostic
elapsed time and RSS are not production comparisons.

The first bounded scalar-replacement screen finds 2,948 nonempty scalar-only
constructors, 201 immediately assigned to locals, and two adjacent local reads.
Neither adjacent read is a qualifying scalar projection. This does not rule out
wider escape analysis. Returned wrappers, reference payloads, and analysis across
calls need a broader proof. No scalar-replacement optimization was added.

A four-handle cleanup prototype retains every check and passes mixed-object and
exceptional-ledger tests. Its isolated dense and scattered cases regress, so its
production change was removed. The patch and tests remain research evidence.

A diagnostic size census finds 79 promotion sorts, 70 above the old 65,536-plan
limit; the largest has 500,664 plans. A temporary large workspace improves the
isolated sort, but gives an overlapping 28.7163-to-28.4683-second full-job median
and about 9.6 MiB higher median RSS. That version is superseded.

## Final change

Increase the lazily grown stable counting-sort workspace limit from 65,536 to
1,048,576 plans: 20 MiB per collector at its maximum, versus 1.25 MiB before.
Small collections allocate only their existing needed capacity. Larger batches
keep the in-place comparison sort. Close releases the workspace.

Use the allocation-size key already filled by `promotionPlansSorted` instead of
reading the handle table again in both bucket passes. All production sorting
calls fill these keys first. The stable kind/size order, equal-key order,
allocation groups, failure points, roots, handles, and native ABI remain intact.
The existing reference sort remains the independent order oracle.

Large-buffer reuse avoids a new temporary allocation on every collection. Tests
check both sides of the bound, exact stable ordering, mixed plan kinds, cleared
workspace entries, and zero warm allocations. The raw microbenchmark includes
amortized initial workspace bytes; zero bytes/op is not claimed.

## Matched full jobs

Use the same pinned compiler, request, frozen private managed-instance host,
512 MiB heap, 64 MiB nursery, CPUs 12/14, GOMAXPROCS=2, no transform workers,
and fresh native/result caches. No task-owned builds or tests overlap timing.
The control and final candidate differ only in `promotion_sort.go`.

Three serial pairs, with order control/candidate, candidate/control,
control/candidate, give these elapsed seconds:

- 28.973310 / 28.845930: saves 0.127380 seconds.
- 28.661564 / 28.533480: saves 0.128084 seconds.
- 28.933298 / 28.581888: saves 0.351410 seconds.

All three pairs improve. Independent medians are 28.933298 and 28.581888 seconds
(1.215% lower); the median paired saving is 0.128084 seconds. The overlapping
ranges and three-pair sample limit the strength of the result. This is a small
measured gain, not a general speed claim or a route established to four seconds.

Median CPU is 29.305909 versus 28.927885 seconds. Median RSS is 648,956 versus
649,232 KiB (+276 KiB); ranges overlap, so no memory gain is claimed. Retained
workspace can still grow more on other workloads. Isolated large-sort cases
improve 12.4–14.1 times. These factors do not apply to the full job.

All six output Wasm/cache hashes match the pinned expected values. Wasm validation
passes, and output `main` returns 42. V8 was not rerun.

## Validation and limits

Full collector, runtime, and Wago suites pass. Collector fault-injection,
padded-header, workers/concurrent-product, race-focused sort, and checked Wago GC
lanes pass. The final memory-bound assertion also passes. No assertion, root map,
trap check, failure point, or product gate was relaxed.

The initial full suite failed because this new checkout lacked the pinned
Release 3 corpus. Restoring the existing pinned files and interpreter made the
rerun pass. The failure remains in the raw record. Early setup failures and a
no-match cleanup test command are excluded from measurements. Full Wago test
execution still takes about 40 seconds, and some build/test processes exceed
30 seconds and 3 GiB RSS; these remain test/build budget problems, not production
memory results.

Source and timed hosts remain under `/tmp/wago-gc-scalar-replacement-20261022`
and `/tmp/wago-gc-scalar-evidence`. Small logs, scripts, discarded patches, output
hashes, and large-artifact hashes are saved in Dewdrop at
`docs/research/data/wago-gc-scalar-replacement-2026-10-22/`.

[Small evidence files and reproduction scripts](data/wago-gc-scalar-replacement-2026-10-22).

Final private source commit: `44bb8e1bc3b2b175b20600f9870d58d4a1219fef`, branch `dewdrop/gc-large-promotion-sort-20261022`. Source worktree is clean. No runtime was installed and no PR was opened.
