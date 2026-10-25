# Wago safety follow-ups and integer helper inlining

## Completed work

The local GC stack includes incoming spill-extent, runtime type-growth and
shared-stub switch repairs from PR1002, PR1003 and PR980. Each new regression
failed before its repair. The public/local commit map and check records are
in [the data folder](data/wago-gc-followup-2026-10-21/).

[PR1006](https://github.com/wago-org/wago/pull/1006) restores saved registers
before a final struct cast/get failure enters global writeback. Before the
repair, wrong-type casts replaced dirty globals with native addresses.
The fix changes cold failures only and preserves the successful instructions.
It is a ready follow-up above PR948. Full normal, checked and bench checks pass.

[PR1007](https://github.com/wago-org/wago/pull/1007) permits bounded integer
leaf inlining under exact GC roots. It consumes the original source call mask
once per removed call. It retains GC caller frame/pin policy. No runtime type
or heap checks are removed. Tests preserve exact root offsets through later
allocations and check signed divide traps, dirty globals, Tiny collection and
saved-code reload. The real compiler removes 11,886 native calls in 1,798
callers, with 25,794 safepoints and exact coverage preserved.

## Full compiler timing

All engines use compiler SHA256
`c64fcf044b72cb7356ad598a35670045931337cfa7a6bb9d5916cd304b23fba6`,
request SHA256
`077b0ff0271706cc3034f3e06c7a228f227c49aeec7786d21373b2072af89c72`,
CPU affinity 12,14 and GOMAXPROCS=2. Wago uses fresh native caches; every
transform result cache misses. No task-owned test or build overlaps the runs.
This is the same two-transform compiler job, not a complete self-host build.

| Engine | All wall times (s) | Median (s) |
| --- | --- | --- |
| Wago safety stack control | 55.089, 47.117, 47.499 | 47.499 |
| Wago plus integer leaf inlining | 46.017, 45.916, 45.687 | 45.916 |
| V8 | 4.017, 4.025, 3.993 | 4.017 |

The new change reduces the median by 3.33%. Wago remains 11.43 times slower
than V8. First run order was control/candidate/candidate/control, then three
V8 samples. The first control varied, so one additional control/candidate
pair was added. All nine samples remain; none is discarded. This is a shared
host with changing background load, so the percentage is not a precise bound.
Earlier unrestricted-host timing runs are not directly comparable.

Every run produces identical Wasm and cache bytes. Wasm validation passes and
main returns 42. Offline native artifact probes confirm Exact=true on all six
Wago runs. Native callsites fall from 68,809 to 56,923. The focused 8,192-step
integer loop improves 9,396 to 3,818 ns (2.46x), with zero warm allocations.

Inlining grows combined-stack native code from 26,901,064 to 27,059,224 bytes
(0.588%). Metadata falls from 3,642,299 to 3,311,043 bytes; the total artifact
shrinks by 173,096 bytes. Peak RSS is about 1.08 GiB for Wago and 0.46 GiB for
V8. No RSS improvement is claimed for inlining.

## Review record and remaining work

[Claude's independent review](wago-claude-bottlenecks-2026-10-21.md) found the
module-wide inline gate and several other proposed bottlenecks. Astra checked
its safety assumptions. Retained type proofs must not bypass extent checks.
Sparse collection already preserves survivor order; only recycled free IDs
change order. A [bounded locality trace](wago-handle-order-2026-10-21.md) now shows
growing allocation-table fragmentation over 146 minor collections. This is
address evidence, not a hardware cache-miss or full-job gain claim. A separate
stable sparse-cleanup candidate is under test. No collector rewrite is
included in this install.

The earlier getter-inlining experiment is not published or installed; its
full-job gain was unproven. Its saved artifacts retain exact GC roots, so
lost root admission does not explain its slower sample.

The extra full stats+register-check instrumentation run reports unrelated
legacy peephole-count failures. The isolated count failure also occurs on
unchanged origin/main cd029409b. Required normal/register-check suites and
focused GC diagnostics pass; original failures remain in the data/logs.

Public commits are pushed before local picks. The combined source was checked
against the exact measured production patch. The user's ARM64 call.go edit
is retained with its original SHA256. Combined normal/checked packages pass in 40.436/41.948 seconds; focused
checked GC diagnostics pass in 13.814 seconds.


The last upstream audit also caught PR1003 test commit `4bfc46b92`.
It rejects casts, reads and writes between unrelated numeric/reference struct
types after joining a shared runtime domain through an imported global. Default,
forced-GC and Tiny cases pass. Its checked run with the numeric/root regressions
passes in 11.333 seconds. Local pick `d476f70ab` changes tests only; measured
production code is unchanged. The final install uses that exact local HEAD.

The array-length pin-spill experiment in
`/home/dev/Projects/wago-gc-array-length-pins-pr` remains unpublished local
work. Its focused tests pass, but its speed is unmeasured; it is not installed.


## Final local install

Installed and selected `local-gc-d476f70ab` from combined branch
`dewdrop/local-gc-perf-20261020`, HEAD
`d476f70abd475a2d33a186aae8a1723d99d44913`.
Manager: `/home/dev/.local/bin/wago`.
Runtime: `/home/dev/.local/share/wago/versions/local-gc-d476f70ab/standard/normal/wago-runtime`.
All 30 CLI/build/smoke checks pass, including numeric inlining roots and loops,
abstract arrays, mixed constructors, vector/scalar fields, dynamic array sizes,
and older native code. Version selection and the login-shell PATH are verified.
Final binary hashes and every check are stored in the data folder. All six
worked PR heads match the final live upstream audit. The watcher remains a
read-only process that polls once per minute and logs later head changes.
