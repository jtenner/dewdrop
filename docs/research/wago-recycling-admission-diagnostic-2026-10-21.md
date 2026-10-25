# Nursery recycling admission diagnostic

Keep canonical recycling held. A uniform 64-pair sample is unsound as a
performance estimator for the known periodic survivor pattern. A stratified
sample fixes that case, but the real guest that regressed 12.21% is also
highly scattered. The current evidence does not justify a default threshold.
No production gate, install, push or public commit was made.

## Uniform sample counterexample

A read-only simulation retains each 64th allocation position, applies the
exact old sparse tail-swap cleanup, and follows allocator LIFO reuse. At
65,536 handles its first cohort has only 3.514% exact ID-block crossings,
but 64 uniformly spaced pairs report 64 crossings. Sampling aligns with the
periodic removal pattern. With canonicalization on admission, thresholds
4/64 through 32/64 sort all 60 simulated cycles; later cohorts have only
3.9% true crossings but the grid still reports 32/64.

Dividing the adjacent-pair space into 64 strata and choosing one fixed mixed
offset per stratum avoids this particular alias. Across 60 unsorted cycles,
the 65,536-handle sample has 0–5 crossings, and the 4,096-handle sample has
0–2. Thresholds 8/64 through 32/64 admit none. This is a deterministic
heuristic, not a confidence guarantee for arbitrary input.

The simulation and full per-cycle results are retained in the separate
`/home/dev/Projects/wago-gc-recycling-admission-probe` worktree, under
`docs/research/data/recycling-admission-probe-2026-10-21/`. The canonical-v2
checkpoint `97ff148a4` is unchanged.

## Private diagnostic

The private source and host are at
`.tmp/wago-recycling-admission-diagnostic/{source,host-source}`. They were
copied from the existing handle-order diagnostic, including its worker patch.
The sparse cleanup function was restored byte-for-byte from
`.tmp/wago-next-gc-perf/before-stable-diagnostic-collect.go`, by function
boundaries. It does not sort. The stable-only unused slices import was removed
from this private copy after a build failure; that failure remains in the logs.

The existing 256-row ring now also records:

- Exact adjacent ID-block and actual handle-table 4 KiB page transitions.
- 64-stratum sampled counts and bit masks of individual outcomes.
- Suffix/table lengths, low/high IDs, whole-table and offset word budgets.
- Invalid-ID and adjacent-equal counts. These are not a duplicate-set check.

The ring occupies 63,544 bytes per observed collector. Entry size is asserted
to be 16 bytes. The extra exact scan reads each suffix once and retains no
per-object record. JSON is written at Close. All recorded cohorts fit within
the ring, so neither run lost early rows. A synthetic summary test checks
exact counts and a deliberately shifted base address where ID-block and page
counts differ. In these two actual runs, the block/page aggregate counts
happened to agree; the code keeps both measures separate.

## Observations

The guest uses the existing real Wasm fixture: 131,072 struct allocations per
call, two field reads per iteration, a global ring retaining each 64th object,
and automatic collections. It ran 26 calls, matching the benchmark's 16
warmup and ten measured calls, with exact-root and checksum assertions. Its
3,407,873 allocations, 78 minor collections and positive live tracing counts
passed the diagnostic test.

The compiler used the same compiler.wasm and request semantics as the full-job
comparison, with separate output paths and home. Both output hashes and main=42
passed. It made 317,075,456 allocations and 146 minor collections: 140 sparse
and six general. Its detailed tracing/promotion counts differ from the older
aggregate trace, so the fresh data is not described as an exact replay of the
old heap trajectory.

| Measure | Guest | Compiler |
| --- | ---: | ---: |
| Sparse cohorts | 78 | 140 |
| Median recycled IDs per cohort | 43,349 | 2,082,453 |
| Handle-table entries, min–max | 43,607–70,755 | 839,214–6,559,018 |
| Approximate table bytes, min–max | 0.70–1.13 MB | 13.43–104.94 MB |
| Median absolute sample error | 4.09 percentage points | 3.41 percentage points |
| Maximum absolute sample error | 16.89 percentage points | 14.08 percentage points |
| Cohorts meeting existing global word/scratch budget | 78 | 140 |

The guest's exact crossing rate grows from 3.52% to 60.45%; its last five
cohorts range from 57.69% to 60.45%. The compiler's last five range from
51.35% to 58.52%. Thus locality alone does not separate the regressing guest
from the target compiler workload.

These counts apply thresholds to the old unsorted trace; they are not actual
admission counts after a sorting gate changes subsequent allocations:

| Required sampled crossings | Guest cohorts meeting rule | Compiler cohorts meeting rule |
| ---: | ---: | ---: |
| 8 / 64 | 73 / 78 | 129 / 140 |
| 16 / 64 | 70 / 78 | 121 / 140 |
| 24 / 64 | 65 / 78 | 95 / 140 |
| 32 / 64 | 57 / 78 | 55 / 140 |

## Decision and limits

Reject the uniform grid and do not select a production threshold from these
traces. The table-footprint difference is a plausible reason that equal
crossing rates have different costs, but these runs do not establish a cache
capacity or break-even cutoff. Do not encode the job name or choose an
unexplained size threshold.

A stratified gate could still amortize sorting by waiting for fragmentation
to return after an admitted sort. The old trace cannot establish that benefit;
it requires a private counterfactual trace and matched timing, including the
negative guest and cleanup cases. The independent ABI and compiler fixes can
proceed while this collector experiment remains held.

A skipped sort makes no membership or ownership changes, but sampling does
not validate every identity. Collector.Verify does not scan freeHandles for
duplicates. Current v2 rejects duplicates in its budget-admitted bitmap path;
a new early return would lose that diagnostic for otherwise admitted inputs.
A future gate should retain validation-only bitmap checks under
VerifyAfterCollect for those inputs, clear scratch without emitting a new
order, and test both sides of the gate. Existing small/budget-rejected fallback
still has its old no-rewrite contract. The private diagnostic merely observes
that untouched path; zero adjacent duplicates is not proof of global uniqueness.

## Files and elapsed checks

All raw data is under `.tmp/wago-recycling-admission-diagnostic/data/`:
`compiler-order.jsonl`, `guest-order.jsonl`, `summary.json`, `identity.json`,
build/test logs and compiler output-validation metadata. `summarize.py` and
`run-compiler.py` beside that directory reproduce the report and job setup.
The identity file hashes the restored sparse function, diagnostic sources,
host binary and request.

Host build: 5.335 s. Summary test: 1.254 s. Guest diagnostic test: 13.774 s
including build (test execution 0.073 s). Compiler diagnostic: 46.025 s.
These are instrumented correctness/observation runs, not performance samples.
No installed source or public candidate worktree was changed by the diagnostic.
