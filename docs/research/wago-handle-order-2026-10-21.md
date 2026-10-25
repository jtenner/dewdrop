# Nursery handle order diagnostic

The private diagnostic uses the installed numeric-inline stack. It adds a
bounded collector trace, with no changes to generated native allocation
instructions. It is not installed or included in a public performance patch.
The [data directory](data/wago-handle-order-2026-10-21/) contains the patch,
raw trace, checks, build record and summary.

The same two-transform compiler job passes, returns 42 and produces identical
Wasm/cache output hashes. Its 47.077 second instrumented run is not a speed
comparison. The compiler and request hashes are the same as the
[previous full-job measurement](wago-gc-followup-2026-10-21.md).

The trace records 317,075,456 allocations, 146 minor collections and no major
collection. Cleanup uses the sparse path 140 times and the general path six
times. It does not use the all-dead path. Of 1,334,860 native handle batches,
93,053 (6.97%) qualify for the contiguous HandleBase path.

Each collection samples at most 4,096 adjacent handle pairs, spread across
the original and recycled cohorts. A 256-row ring retains all 146 cycles.
The trace records actual allocation-table entry addresses, absolute ID gaps,
ascending/descending order and 64-byte line/4-KiB page boundaries. The fixed
per-collector trace uses 26,680 bytes. Output is written once at close.

| Recycled pairs | First five cycles | Middle five | Last five |
| --- | ---: | ---: | ---: |
| Adjacent IDs, either direction | 98.71% | 48.04% | 40.09% |
| Cross 64-byte table line | 26.15% | 63.10% | 69.47% |
| Cross 4-KiB table page | 1.58% | 47.61% | 56.83% |

These are address-locality counts, not hardware cache-miss measurements.
They show growing fragmentation in this real workload. They do not prove
that cleanup order causes all of it or that stable cleanup makes the full job
faster. A separate branch now tests a stable forward pass for sparse cleanup.
It retains the allocator's LIFO free-list contract, existing free prefix,
survivor order and ownership/card cleanup. It adds no sort or index table.
The all-dead cleanup remains unchanged because this trace did not use it.

The new order regression fails on the old loop: one live middle handle causes
a later dead handle to move into its slot in the recycled list. The failure
is visible in the retained red-test log. Next checks compare general/sparse
cleanup semantics, repeated cycles, ownership, cold cleanup cost and full-job
speed before publication.

## Stable-loop trace and adverse small benchmark

The separate stable-loop diagnostic keeps the same317,075,456 allocations,
146 minor collections,140 sparse paths and6 general paths. It changes only
sparse cleanup ordering, plus its existing diagnostic hooks. Last-five-cycle
recycled pairs cross4-KiB table pages6.59% of the time, versus56.83% for the
old loop. Unit absolute ID gaps rise40.09% to57.04%;64-byte line crossings
fall69.47% to51.72%. Contiguous HandleBase batch admission rises6.97% to8.86%.
[Raw stable trace](data/wago-handle-order-stable-2026-10-21/) is retained.
These address counts do not measure hardware cache misses or establish speed.

Five alternating exact-base/candidate small benchmark pairs contradict a
universal gain. With2,097,152 identities and50 warm cycles, warm-cycle median
increases7.539ms to31.595ms (+319.07%). The original ordered row included fixture setup and is invalid for isolated
cleanup cost or allocation claims. Corrected ordered-only medians are
3.077ms to3.830ms (+24.47%), both0B/op. Warm samples remain valid at0B/op.
These results are retained in the candidate's research note.

The synthetic fixture retains every64th position as young, selects positions
again after each reorder and does not promote objects by age. Its stable
permutation repeatedly interleaves retained IDs with the reversed dead cohort.
A4,096-ID simulation after50 cycles has19.27% adjacent IDs and35.12% simulated
page crossings on the stable path, versus92.36% and5.20% with tail swapping.
The real collector promotes objects by age and has changing live positions.
The adverse case remains useful: better order in one job is not proof that
stable cleanup always preserves locality. Full-job A/B medians are42.019 seconds control,39.443 seconds stable candidate
(6.13% less) and4.013 seconds V8. All9samples, output hashes and exact-root
checks pass in [the full-job data](data/wago-stable-recycling-2026-10-21/).
The stable experiment is held unpublished and uninstalled because of its
adverse synthetic result. A separately bounded bitmap candidate will test
canonical dead-ID order instead. The private production source is restored
to the installed PR1008 baseline; the stable experimental host is retained.

## Canonical suffix experiment

A separate candidate keeps the original sparse cleanup, then groups only its
newly freed suffix by ID with a reusable bounded bitmap. It keeps the old
free prefix, membership, survivor order and allocator LIFO agreement. It caps
scratch at2MiB and scans at most one bitmap word per8new dead identities.
Descending free IDs produce ascending allocation IDs for native HandleBase.

Its first unpaired full-job sample passes in36.924seconds with identical
output and exact roots. This is preliminary qualification, not a speed claim.
[The record](data/wago-canonical-recycling-2026-10-21/preliminary/) preserves
the exact helper and binary hashes. Matched full-job samples remain required.

The first helper still regresses valid warm-cycle micros7.412ms to12.732ms
(+71.79%). Corrected ordered-only medians are3.205ms to9.703ms (+202.78%).
The canonical ordered row includes one bitmap allocation amortized over ten
iterations,27,033B/op; allocs/op rounds to zero and must not be read as no
allocation. Warm cycles report0B/op. Original ordered rows are retained but
marked invalid because their fixture allocation/timing boundary was wrong.
A bounded fast admission for already-dense handle tables is under test.
