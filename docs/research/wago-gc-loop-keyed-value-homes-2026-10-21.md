# Bounded frame cache for loop reference checks

Research-only experiment. This is not installed or published. The four-second
Dew compilation target remains unmet. Full-job results and the acceptance
decision are recorded below when the experiment ends.

The source pass chooses at most eight fixed final struct type/exact extent
pairs from cast/read sites inside loops. Only selected functions get homes.
Each entry uses 16 private frame bytes: a full 64-bit reference word and a
successful raw address. The maximum is 128 bytes before frame alignment.
Address zero disables the entry. Both slots are excluded from GC roots.

A lookup retains the original pop/flush/materialize/release order. It tests the
saved address and compares all reference bits. A hit supplies an address, then
executes the field load. A changed operand, foreign high bits, null, i31, type
mismatch, or insufficient extent still takes the original full resolver. The
keys never widen an earlier access to a later field's extent. The miss key is
stored before resolving; only successful resolution stores an address. Failure
unwinds the entire call tree. EH and custom-instruction modules are excluded.

Every wrapper and register entry clears all address bytes before local-zeroing
early returns. Unknown native calls, reference/indirect calls, dynamic/import
context changes, and Go helpers clear owner-frame addresses before entry.
`callHostSync` is the common GC-helper boundary, including allocation shortcuts.
A caller clears before entering an unknown callee so suspended ancestor frames
are protected too. Inline bodies clear absolute owner offsets through
`localOff`. MOV-to-memory clears preserve registers and flags. Only the actual
existing proven read-only call target preserves the frame entries.

The new cache does not publish old per-value address/extent facts, register
certificates, or child identities. Trapping guards and GC read regions use the
original resolver path explicitly. Native payload writes still reload fields;
they do not move or release existing objects. A Go boundary invalidates entries
before object movement, freeing, or handle reuse can occur.

Astra found no need for immutable parameters or rooted keys under these limits.
Daybreak Blue found no safety fault, but found duplicate clearing at the GC
helper wrapper and `callHostSync`. The redundant wrapper clear is removed.
It also requested direct cross-instance and read-only-call tests; both are added.

The red emitted-site test reports no cache site on the unchanged compiler. The
first implementation passes focused combined register/stats checks. Tests cover
same and alternating references, native field writes, forced collection, nested
host reentry, direct/transitive/indirect/reference calls, both entry ABIs, codec
reload, null zero-trip loops, entry after traps, parameter-only frames, all-eight-
byte clearing, non-root homes, the eight-entry budget, and disabled inline use.
Metadata corruption after filling an entry makes missing invalidation visible
without relying on old evacuated bytes changing. Cross-instance tests include
A -> native B -> Go collects A -> native A and handle corruption in the callback.

The pinned real compiler gets 11,080 cache lookup sites in 1,018 functions.
Old static per-value reuse falls from 4,766 to 3,583. Counts describe emitted
sites, not measured dynamic cache hits. No dynamic hit/miss counters were added.
Do not infer profitability from the emitted-site count.

After removing duplicate clears, diagnostic compilation takes 0.548 seconds.
Native bytes rise from 25,972,587 to 28,655,643 (+10.33%). Exact GC roots stay at
25,794 safepoints, 50,438 callsites, 77 maximum roots and 1,803,076 metadata bytes.
The candidate native SHA is
c0b0ba13296d0f5798c7ad33f663e939a9a8eb8b14054590a6124dc357871b60.

The first three pairs still contain duplicate clears. Their control median is
36.450609 seconds; their candidate median is 38.472647 seconds. System load
rises sharply during the last pair. These preliminary data show no large gain
and cannot establish a precise regression. They are retained separately from
the corrected final screening pair.

Raw evidence is in `/tmp/wago-four-seconds/loop-keyed`. The prior SIMD/read-call
source is the control. Both variants use the same pinned compiler/request,
CPUs 12/14, GOMAXPROCS=2, 512 MiB heap and 64 MiB nursery. No task-owned tests
or builds overlap any full-job timing. All accepted full jobs must keep the
same output/cache hashes and validate main=42.

## Final screen and decision

The corrected pair is 36.158612 -> 34.675842 seconds (4.10% lower in this one
pair), with peak RSS 1,139,016 -> 1,139,712 KiB (+696 KiB). Both outputs retain
Wasm SHA 89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb
and cache SHA c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240,
and validate main=42. One pair cannot establish a reliable speed gain. The
native code growth is substantial, and actual cache hit/miss counts are unknown.
Hold this prototype; do not install or publish it as a performance win. The
four-second target remains unmet.

Full AMD64 backend, collector, runtime, and Wago tests pass normally and with
wago_regalloccheck. Lanes take 55.57 and 55.45 seconds including build; Wago test
execution takes 28.37 and 28.96 seconds. Focused statistics tests pass in 24.15
seconds including build. The original installed compiler and ARM64 edit remain
unchanged. The next requested work is a read-only assessment of Wago issues
308, 309, 313, and 321.

Private research commit: `399f7721bf72ea2c9b8c4d9864e43167770b2d2c`. Raw small reports and a source patch are
in `docs/research/data/gc-loop-keyed-value-homes-2026-10-21`.
