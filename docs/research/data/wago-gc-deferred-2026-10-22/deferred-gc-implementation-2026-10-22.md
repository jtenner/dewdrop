# Deferred GC implementation series

Requested issues: 308 (stable backing), 309 (compact headers), 313 (Immix old
space), and 321 (parallel/concurrent collection). This series starts from
9d84600f1, the reviewed private GC stack with native SIMD reader summaries.
The rejected global cache and unproven loop frame cache are excluded. All four
requested implementations are present. Immix and worker modes remain opt-in after
measurement. The sections below record the bounded stages and their evidence.
No public PR, installed runtime, or unrelated checkout is changed.

## Stable backing: memory owner

Supported native 64-bit Linux, Darwin and Windows builds reserve bounded virtual
ranges for Throughput old/large space, nursery/survivors, and handles. Pages are
made accessible before publishing logical extents. Old growth commits geometric
prefixes instead of allocating/copying Go slices. Nursery growth can move objects
within its reservation, but never changes the reservation base. Stable addresses
do not authorize retaining raw object addresses across collection.

The shared `internal/virtualmem` owner supports checked range arithmetic,
idempotent explicit Close, lazy commit, and zero-filled whole-page discard.
Unix discard replaces unused pages with anonymous PROT_NONE pages. Windows uses
reserve/commit/decommit separately. Portable and TinyGo builds retain Go backing;
`Config.DisableVirtualBacking` supplies an explicit comparison control.

Handle reservations include the invalid zero identity, worst-case object count,
and bounded native batches. Production allocation preflights missing identity
capacity before object allocation. Errors preserve live objects. Checked-handle
generation retirement is accounted for. Native view addresses are revoked before
mapped owners are released. MemoryStats reports virtual reservation and committed
page bytes separately from OS RSS/commit charge. This chapter does not yet alter
generated loads or claim a whole-compiler win.

The owner adds 16 bytes to throughputHeap and 8 bytes at the collector tail.
The comparison flag grows Config from 64 to 68 bytes and adds 8 bytes due to
Collector pointer alignment, so Collector grows by 32 bytes. Exact footprint
assertions track the new cost. The native object/handle ABI remains version 9.

Tests pass: owner/range/discard/Close, repeated stable handle/old growth, bounded
identity exhaustion with retained data, portable fallback, complete native GC,
wagodebug fault injection, and race tests. The race lane takes 26.69 s including
build (collector 16.37 s). Complete AMD64 backend/runtime/Wago integration takes
55.19 s including build; tests take 5.26/0.41/28.22 s. The >30 s build lane remains
above the user's compiler activity target; it is not described as a fast compile.

Owner tests cross-compile for Linux ARM64, Darwin AMD64/ARM64 and Windows
AMD64/ARM64 (4.89–5.15 s each). These are build checks, not native OS execution.
Darwin/Windows execution and OS RSS/page-fault observations remain unmeasured.

An initial one-page commit experiment was slightly slower than Go growth and
is not retained. Geometric commit is retained. A five-sample screening benchmark
allocates/touches 256 4 KiB objects while growing to 1 MiB, then closes its owner:
stable median 309,957 ns vs portable 596,172 ns. Stable performs zero backing-copy
bytes vs 2,547,712 copied bytes; Go allocations are 128 B/2 allocations vs about
3,908,096 B/14 allocations. This is a backing-growth microbenchmark with variable
portable timings, not application throughput, retained memory, or whole-job RSS.

Raw logs and command/timing JSON are in `/tmp/wago-gc-deferred-evidence` and are
mirrored into Dewdrop research evidence when the series is finalized. The
subsequent native binding, compact layout, region collector and worker stages
are recorded below.

## Stable backing: native handle bindings

Native ABI 10 adds the handle base to the instance view at offset 32 (native
prefix 40 bytes). The common AMD64 checked resolver, final-cast resolver, and
ARM64 checked-object leaf load it directly. Instruction counts and guarded
handle/type/extent checks stay the same; one collector-pointer dependency is
removed. Space backing/counts remain dynamically checked. The preceding ABI 9
artifact is rejected rather than read with a different instance layout.

Mapped handles never move. The portable comparison path updates every live
instance binding when Go growth moves its table. A collector-local binding list
is released on physical instance teardown (after retained importers are gone),
not logical Close. Failed instantiation also releases its binding. A separate
small mutex protects physical release against another instance's Go allocation.
No mutex or new branch is emitted into native reads. Collector Close revokes all
bindings before unmapping. This adds a lazy binding-list owner, one pointer to
Collector (+8 bytes), and 24 bytes per native instance view. Binding storage is
bounded by the peak number of live instances and is not a reference cache.

Red/green tests cover portable relocation with multiple instances, idempotent
release, no retained binding accumulation, and concurrent physical release while
portable growth occurs. Race checks pass (4.19 s including build). Complete
AMD64 backend/runtime/Wago tests pass again (53.30 s including build;
5.12/0.48/26.95 s test time). Native instruction/whole-compiler timing remains to
be measured after the layout and collector stages. No speed factor is claimed
from this load-order change.

The ARM64 physical-guard test passes under QEMU after rebuilding its raw ABI
fixture with the bound handle base (7.12 s cross-build, 0.087 s execution).
The focused native ABI loader/refresh tests reject the preceding version too.

## Compact metadata: hot type IDs and cold cards

ABI 11 replaces the handle's four-byte card-list link with its canonical type
ID, keeping the hot record exactly 16 bytes. All Go/native constructors and
evacuation publish that ID. This preparation still retains the original object
header, and Verify requires its type to agree with the new hot type field.

Card-list heads move into a separate collector-owned uint32 array. Nursery-only
collectors allocate no card array. On supported mapped collectors its bounded
reservation is created on first use and pages become accessible before the
native prefix is published. Only written old-parent links dirty physical pages.
Portable builds use a growable Go slice. Read-only card lookups do not grow it.
OS reservation/commit failure selects the existing conservative remembered-set
scan before changing card nodes. The native reference-array store checks the
cold prefix bound and pointer before looking up a card head.

The collector view grows from 200 to 216 bytes for the cold array pointer/count.
Collector adds one 24-byte slice descriptor; the optional mapped-backing owner
adds one pointer. Cold committed link pages cost four bytes per covered handle
index, with lazy physical writes; this is not a claim of zero side metadata.
The later header removal must earn this cost. Existing card/failure/root tests
use cold link accessors and retain the same semantic assertions.

Complete native collector and wagodebug suites pass (1.70/1.89 s test time).
Complete AMD64 backend/runtime/Wago tests pass (53.48 s including build;
5.15/0.42/26.94 s tests). ARM64 ABI, struct execution and native reservation
checks pass under QEMU (20.41 s cross-build, 0.192 s execution). The following stage records header removal
and its two-layout comparison.

## Compact physical layout

The working representation removes struct headers. The hot handle owns the
canonical type and logical byte extent. Pointer-free state uses a packed class
bit; old/large state derives from the space/generation metadata. Arrays keep an
eight-byte length/reserved prefix. V128 arrays align their payload to 16 bytes.
All physical sizes retain checked uint32 arithmetic and eight-byte rounding.
Empty structs keep an eight-byte minimum allocation.

`wago_gc_struct_headers` selects the comparison layout with an eight-byte struct
prefix; it does not duplicate canonical type/size fields. ABI 12 identifies the
header-free layout and ABI 13 the comparison layout. Artifacts cannot silently
cross either boundary. Stable compact references retain their identity across
movement and do not gain pointer semantics.

Native readers load type/extent from the hot handle. Array operations retain the
validated extent in an unrooted numeric frame home, including both operands of
copy, so a forged array length cannot authorize a physical out-of-bounds access.
Common resolver subtype checks cannot overwrite that retained limit. Per-value
check facts remain distinct from these temporary extent homes. Every bulk store
still finishes source/destination bounds checks before its first mutation.

The migration exposed a pre-existing native struct remembered-store gap:
remembered membership was treated as whole-object card coverage. Struct stores
now require an owned, bounded cold card covering all four field bytes, or use
the checked Go barrier. A regression with fields 0 and 32 fails under the old
fast path: the shadow verifier reports an uncarded edge at payload byte 128.

The array path already converted RSI to a byte offset before its card lookup.
An initial concern about element/byte confusion was therefore not a production
bug. It now shares the owned-card checker without another shift. A regression
at element 40 explicitly inspects that the authoritative head covers bytes
160..163; adjacent cards may coalesce, so node count is not the invariant.
Full validation and timing remain in progress.

Compact layout validation now passes: full default AMD64 Wago tests
(27.42 s including build, 26.86 s tests) and runtime package tests (0.42 s), AMD64 backend tests
(11.29 s including build, 4.87 s tests), full normal/debug collector suites
(3.88/3.95 s including build), and native GC tests with register assertions
(29.63 s including build, 2.71 s tests). Both normal and eight-byte-prefix
collector products pass all runtime tests. The comparison product's native GC
suite passes too (26.04 s including build, 2.79 s tests). Byte-sensitive Tiny budgets retain their allocation failure cases. Compiler test linking peaks near 3.5 GiB; that existing
large test product is not a low-RSS application result.

ARM64 cross-build takes 19.94 s. Its GC tests pass under QEMU in 9.09 s,
including scalar/packed/vector access, exact frame roots, reentry, foreign
instances, allocation, artifacts and relocation. Deadline-timer tests are
explicitly excluded because QEMU rejects creation with EINVAL; this is not a
native ARM64 OS validation result. Backend physical/far-call/relocation guard
tests pass under QEMU in 0.085 s.

A fixed 250,000-allocation-plus-promotion microbenchmark compares header-free
and eight-byte-prefix products on CPUs 12/14, GOMAXPROCS=2, five samples each.
The hot handle remains 16 bytes in both. Before the smaller old-space class,
small objects still consume a 32-byte allocation in both products. Header-free
logical size is 8 vs 16 bytes for i32/ref+i32 and 16 vs 24 bytes for two i64s.
Runtime medians are close/noisy and do not establish a speed win; raw timings
are in compact-pre16-summary.json. The next allocator change must remove that
32-byte floor before this representation can reduce small old-space charges.
Throughput array heap-limit failures now produce the guest allocation trap;
checked Tiny failure diagnostics remain visible. This matters for the pinned
Wasmtime overflow fixture after the physical header becomes smaller.

## Compact old-space allocation

The old allocator now supports a 16-byte class and retains 16-byte free-span
remainders, including batched promotion runs. A four-KiB heap retains 256 small
old objects instead of 128. Red/green tests fill the whole bound, replace every
other object without aliasing retained payloads, and reuse a 16-byte remainder
without growing past a retained guard object. The independent randomized span
model and every class/limit boundary still pass. A promotion-failure fixture now
uses 320 compact objects so it still exceeds the same bounded destination and
checks complete rollback. Dense survivor admission keeps its measured 32-byte
limit; adding a smaller class does not silently narrow that optimization.

Full native collector tests pass (3.81 s including build, 1.69 s tests), as do
debug/fault tests (4.04 s including build, 1.79 s tests). In the same fixed-population
screening benchmark, small old allocations charge 16 vs 32 bytes. Accessible
pages for 250,000 small objects fall from 15,273,984 to 10,162,176 bytes, including
fixed nursery and handle backing. This is accessible-page accounting, not RSS.
The process RSS maximum includes the unchanged vector case and stays about
25 MiB. Timings are screening results; whole-compiler qualification remains
outstanding. Raw five-sample medians are in compact-class-summary.json.

## First fixed compiler comparison

The isolated host copies use the same frozen transform-worker code and the same
three private managed-fork changes. The control is corrected to base 9d84600f1,
including its retained read-only summaries and diagnostic fix. The candidate is
3fe616449 (stable backing, compact metadata, 16-byte class). Neither uses Immix
or collection workers yet. Fresh native/result caches, pinned Wasm/request,
CPUs 12/14, GOMAXPROCS=2, -p8, 512 MiB heap and 64 MiB nursery are unchanged.

One screening pair: control 34.704 s, peak RSS 1,135,384 KiB; candidate 30.185 s,
peak RSS 614,980 KiB. Both output hashes match the pinned expected values, Wasm
validation passes, and main returns 42. These are one-pair observations, not a
qualified speed factor. Four seconds remains unmet. Full records are in
`measurements/gc-deferred-{control,compact}-r1.json`.

## Immix stage 1: opt-in region ownership

`GCConfig.Allocator = GCAllocatorImmix` opts into 32 KiB regions, 128-byte lines
and 16-byte allocation alignment. The default and Tiny profiles remain as
before. Limits must be whole regions. Separate reference/pointer-free cursors
allocate through free line runs. Dedicated large extents occupy independently
owned consecutive regions and retain the existing in-place young-large aging.
No guest reference is rewritten. Heap and handle bases retain their stable
backing rules and the portable comparison still works.

Each region owns object-start bits, packed line-use/mark/card bits, per-line
object-overlap counts, generation/occupancy/live-byte state and an epoch. Mark
epoch wrap invalidates old words before reuse. Coarse cards are conservative
locality hints; exact object cards stay authoritative for minor collection.
Metadata is pointer-free and capped by the configured region count (632 bytes
per region, about 1.93%). The ordinary collector gains one optional pointer
(+8 bytes, 3,232 bytes with the 512-handle batch). All exact layout assertions
are updated explicitly. Transaction snapshots also save both cursors and region
length. Failed destinations release ownership before restoring the snapshot.

Lazy old frees keep their exact object boundaries. They are reconciled only
when allocation needs another line run; they cannot be coalesced as generic
spans because shared line counts need each original object boundary. A live
object prevents reuse of its boundary line. Empty blocks lose old cursor claims
before changing class. Unpublished native large reservations are explicit
allocator owners in Verify until publication or cancellation.

Tests pass: complete collector/debug suites, five-thousand-operation randomized
mapped/portable retention runs, shared-line exclusion, lazy reuse, class changes,
independent large extents, transaction restoration, promotion failure injection,
packed epoch wrap, metadata caps and unused native reservation ownership.
Native reads, roots, artifact reload and repeated large native reservations pass
(25.92 s including build, 0.004 s tests). Region-local tracing, accelerated empty
sweep, page advice and selective evacuation are the next stage. No Immix speed
claim or default-profile switch is made from these tests.

## Immix stage 2: packed tracing and empty-region sweep

Full tracing now uses packed epoch words and integer work grouped by region.
Pointer-free leaves do not enter the work queue. Large reference arrays scan
512 entries at a time, draining children before resuming the array. Work nodes
use a reusable slab bounded by handle count; minor marking keeps its separate
existing young marks. Freed identities explicitly clear stale young marks
before reuse. Default paged tracing has no added per-edge dispatch.

A completed mark resets wholly white regions in one metadata operation and
removes their exact lazy debt. Partially live regions keep per-object frees.
Empty regions can return physical pages after two idle full cycles, or through
ReleaseUnusedMemory. Addresses and read/write access stay valid. Linux uses
MADV_DONTNEED; Darwin follows Go's MADV_FREE_REUSABLE/FREE_REUSE pair; Windows
uses MEM_RESET. Page contents are unspecified, and allocation initializes each
new object before publication. Advice counts are not measured RSS. Typed owners
remain alive until Close. Portable backing reports no page advice.

Platform contracts: https://go.dev/src/runtime/mem_darwin.go and
https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc
(the latter explicitly gives MEM_RESET no zero-fill promise).

Tests cover packed marks, epoch wrap, bounded wide-array work, old identity
reuse across young cycles, whole-region reuse, neighboring live payloads,
zero-initialized reallocation, mapped/portable backing and visible/retryable
page-advice failures. Full collector/debug and virtual-memory tests pass.
Metadata is 640 bytes per 32 KiB region plus reported mark scratch.

A five-sample, fixed 20-cycle screening comparison on CPUs 12/14, GOMAXPROCS=2,
shows this first Immix tracer slower than the paged collector: at 65,536 objects,
chain medians are 2.213 vs 1.193 ms; scalar-array 0.713 vs 0.646 ms; sparse scalar
0.130 vs 0.038 ms. The default remains paged. This is not evidence for changing
production admission. Raw samples and medians are immix-full-cycle-screen.log
and immix-full-cycle-summary.json. Selective evacuation is a separate stage.

## Immix promotion bounds and rollback

Equal-size promotion grouping is capped at 1,024 entries for Immix and stops at
pointer-free class changes. Ordinary objects reserve partial contiguous runs
within one region. This removes the quadratic rescanning fallback when a whole
group cannot fit. Existing paged run allocation retains its original admission.
A 10,000-object mixed-class promotion test validates destinations and ownership.

An empty-region claim journal restores complete idle/advice/epoch metadata after
failed allocations. It records only claimed empty regions, reuses storage, and
supports ordered nested transactions. Successful publication commits the journal;
allocation retries close the failed transaction before any collection. A red/green
test catches idle-region metadata drift. Partial-run rollback, complete debug
failure injection and the ordinary collector suite pass. The journal capacity is
included in Immix metadata accounting. Full object payload publication remains
after every fallible planning step.

## Immix stage 3: bounded selective evacuation

Collector.CompactOld and Instance.CompactGC select at most eight sparse ordinary
regions. Ranking uses live bytes, cross-region connections, dirty lines and
expected reclaimed bytes. Dedicated large regions remain in place. The live-byte
budget is explicit; zero selects 1 MiB. The first admission is conservative:
logical bytes at most one quarter of a region and occupied lines at most half.
This leaves room for 16-byte charges without a full-heap occupancy scratch map.

Selected source bytes use at most 256 KiB of temporary snapshots. The allocator
packs destinations into those same selected regions, with growth disabled. This
works at the hard heap limit, with no extra destination region. Metadata plans,
exact source metadata, cursors and search positions roll back before any payload
write on every injected planning/destination/commit failure. After all fallible
steps pass, complete logical payloads copy from snapshots and one stable handle
entry publishes each object. Guest references never change. Object cards remain
handle-relative; region card hints are reconstructed conservatively. No raw
address survives this exclusive-lease operation. The preceding full collection
is a separate completed operation; only evacuation is all-or-nothing. OS advice
is a separate explicit call, outside the evacuation transaction.

Native API entry uses the existing invocation, native-execution, domain and
public-root locks. Borrow checks and exact parked/shared-domain roots match
CollectGC. Native invocation and saved-artifact tests pass after compaction.
Tests cover full-heap cyclic graphs, mapped/portable storage, budgets, large-region
exclusion, old-to-young cards, vectors/alignment, repeated fragmentation and all
injected failures followed by retry. The complete debug collector suite passes.

Five fixed 20-iteration screening samples pack 256 survivors from four regions
into one in a median 93.922 us, making 98,304 region bytes empty. Scratch reports
143,012 bytes. Whole-process peak RSS is 12,864 KiB, including untimed setup.
Raw data: immix-evac-screen.log/json. Empty-region bytes are not measured RSS.
Immix remains opt-in: its current tracing screen does not justify replacing the
faster default collector. All three implementation stages are available for
continued workload qualification.

The final handle-bound audit applies compact-reference index limits before both
mapped and portable fast returns. Negative growth requests and index overflow
produce diagnostic errors without allocating or publishing. Boundary tests cover
both backing products.

## Collection execution prerequisite: opt-in cycle records

The wago_gc_workers build product admits GCConfig.Execution for collecting
Immix heaps. Default/minimal and Tiny products reject it explicitly; nil keeps
clocks, history and workers off. Options are copied and shared-domain admission
compares their values. Counts above 128 and incompatible profiles are errors.
The config gains one optional pointer (+8 collector bytes after alignment); all
exact size/offset assertions are updated. The optional owner lives in Immix.

Telemetry retains the last 64 full/minor cycles, phase and pause/wall times,
object/heap counts, failures and worker counts. Snapshot output is copied.
Reported worker time will be summed elapsed time, not OS CPU time. p99/max use
the bounded recent pause window. External process/PMU records are still needed
for CPU, cache misses, synchronization and RSS. The default product compiles out
instrumentation branches. Normal and worker-product collector suites pass;
tests cover profile/build admission, zero default history, history wrap, copied
options and shared-domain value equality. Worker phases land separately below.

## Execution phase 1: background metadata sweep

Optional background sweeping quarantines at most 64 ordinary regions and 32,768
exact dead spans per task. A worker sweeps copied pointer-free metadata. It never
reads or writes live object bytes, handles, cards, allocator cursors or mappings.
The owner alone publishes successful metadata and merges current card hints.
Busy regions cannot allocate. At heap pressure allocation joins, retries free
lines and exposes errors before growing/failing. Collection, compaction, explicit
FinishBackgroundSweep, verification and Close also join. Close joins before any
mapping release. An injected worker error restores every exact debt entry; no
failure is hidden. Empty-region OS advice retains its separate existing path.

No task starts below the byte threshold, without the A/B option, or when only
one processor is available. The default remains worker-free. Counters report
task count, swept bytes and join-wait time. Worker completion enters the same
bounded telemetry history with zero mutator pause. Worker elapsed time is not CPU
usage. Tests cover bounded admission, foreground allocation at the hard limit,
concurrent mutator card writes, minor collection, failure/retry and teardown.
Full worker/debug and focused race suites pass. Performance admission remains
explicit; later phase measurements compare synchronization/CPU and pause costs.

## Execution phase 2: parallel stop-the-world marking

Parallel marking uses CAS on packed epoch words. Workers keep private integer
queues in 16 region buckets. Shared deques transfer/steal at most 32 tasks per
lock, with bounded shared queues and parked idle workers. Arrays resume in
512-reference tasks. A pending-task counter covers both active and queued work;
zero closes the completion signal. Exact root enumeration finishes before any
worker starts. No payload or handle changes while workers run. After join, the
owner merges young marks, line/live-byte state and coarse connectivity hints.
Reusable scratch, task transfers/steals and worker elapsed time are reported.

Tests compare every live identity/payload with serial collection through repeated
cycles, persistent roots, epoch wrap and a following minor collection. They also
check bounded stealing and independent byte/object thresholds. Full worker/debug
and focused race suites pass. Default/minimal code compiles the worker branch out.

The matched screening run uses CPUs 0-15, GOMAXPROCS=16, 262,144 four-edge nodes
plus their array root, five samples of ten full cycles. Median cycle times are
16.572 ms (one worker), 25.197 ms (two), 27.026 ms (four), and 22.856 ms (sixteen).
Peak RSS for the whole mixed run is 38,632 KiB; total process CPU is 31.180 s over
8.662 s wall time, including untimed setup. Earlier short 16-thread samples looked
better, but the repeated matched run does not confirm that gain. Raw data are
`gc-parallel-mark-matched-screen.log/json`; small/four-core and short available-
thread screens are saved separately. Mark scratch stays about 1.4 MiB at this size.

These results reject automatic parallel-mark admission on this workload.
MinMarkBytes=0 therefore leaves parallel marking disabled, even when a worker
count is configured. An explicit measured byte threshold and object threshold
are required to run the A/B path. Nil execution options still create no workers
or clocks. No compiler speed claim is based on this experiment.

## Execution phase 3: parallel evacuation copies

Survivor/old allocation and every injected commit failure finish before any
worker starts. Plans divide into disjoint destination ranges of at least 64 KiB
per worker. Sources and inactive-survivor/old extents have diagnostic assertions.
Workers copy complete logical payloads while all handles still name their old
sources. The owner joins every worker before poisoning sources, publishing stable
handles, updating ages or installing old-to-young cards. Existing serial code
remains the default/minimal path. Large young objects still age without copying.
Selective old compaction remains serial because its bounded copy volume does
not justify worker startup.

Tests cover immediate old promotion, alternating survivor spaces, mixed young/old
ages, large in-place aging, reference cards, poisoning and threshold rejection.
Injected destination/commit failures prove no copy worker or publication runs
early; retry succeeds. Full worker/debug and focused race suites pass.

Three fixed five-iteration screens on CPUs 0-15 compare 16,384 numeric arrays.
For one-element arrays, median full-minor times are 1.090 ms serial and 0.893 ms
with four copy workers, but samples are noisy (one four-worker sample 1.294 ms).
For 128-element arrays (~16.1 MiB logical payload), serial is 3.419 ms, four workers
3.603 ms, and sixteen workers 4.208 ms. The small-array requested-16 case actually
uses at most four workers due to the 64-KiB chunk floor. Worker elapsed and full
planning/evacuation pause records are in gc-parallel-copy-screen.log/json. Whole
run peak RSS is 52,392 KiB; process CPU 1.198 s over 0.695 s wall, including setup.

The screen does not establish a broadly safe automatic copy threshold.
MinCopyBytes=0 therefore disables parallel copying until a measured threshold is
supplied, independently of parallel marking and background sweep. This preserves
small/default runtime performance while retaining explicit A/B experiments.

The portable capacity bound also respects the platform's maximum slice length.
Boundary tests use the platform integer maximum, so they compile on 32-bit
products without an overflowing constant. This is a compile/bounds check, not a
claim of native execution support on those targets.

A later region-reuse audit found a real failure-path bug: a multi-region large
allocation published its first region owner before the remaining OS reuse hints
succeeded. A failure on the second hint stranded part of the bounded heap. The
red test exhausted the heap on retry. Reuse now completes every fallible hint
before publishing any large-region owner. Verification also rejects invalid
large-owner extents. Injection, ownership and retry checks pass. Logical free
regions remain reusable even if an earlier successful OS hint changed physical
page accounting; no live payload or identity has been published at this point.


## Execution phase 4: bounded concurrent graph marking

The separate AMD64 `wago_gc_workers,wago_gc_concurrent` product adds an immutable
integer graph snapshot, insertion barriers, black births and bounded exact-root
remark. The graph worker never touches mutable heap/collector metadata. Native
reference stores preserve their parent key before card-check scratch reuse.
Default and Tiny builds compile these barriers out. The append-only view is now
232 bytes; default ABI remains 12 (padded 13), while concurrent ABI is 14 (padded
15), so old barrier-free artifacts cannot enter the concurrent product.

`StartConcurrentGC`, `FinishConcurrentGC`, `GCConcurrentStatus` and copied bounded
`GCCycleTelemetry` use the existing exact-root/domain/native lease. Optional
`AutoConcurrent` advances cycles at allocation/minor safepoints with paced starts.
Moving nursery and collecting Immix are required; custom instructions and borrowed
storage are excluded. Memory/decode/remark limits decline visibly without partial
sweep. A synchronous full collection cancels the snapshot and traces current
roots, preventing floating snapshot garbage from causing false heap exhaustion.

The proof, lifecycle, configuration and measured screen are in
concurrent-marking-design-2026-10-22.md. The large graph screen improves about 8%;
the small graph does not improve. A separate background overlap screen also
shows no clear gain (2.265 ms control versus 2.368 ms background median). Thus
background sweep, parallel mark/copy and concurrent marking remain opt-in;
explicit measured byte thresholds are required for mark/copy/concurrent work.
No default worker mode or four-second compiler result is claimed.

Portable cold-card storage now publishes its full zeroed slice capacity, matching
the mapped path. The Tiny build exposed needless native-view generation changes
when a new card used already allocated capacity. Existing slot-reuse assertions
remain strict; portable and default collector tests check the repaired behavior.

The padded-header matrix exposed test assumptions about a 16-byte physical
struct and an unpadded first vector field. Full-heap fixtures now derive their
object count from the physical descriptor; vector checks include the declared
field offset. They still fill the same hard-limit regions and retain all fault,
retry and alignment assertions. Both physical layouts are checked.


## Final qualification

24 selected final checks pass: collector/runtime, complete Wago and AMD64
backend, both layouts, workers/Tiny exclusion, guard-page product, combined race,
concurrent native/artifact/register checks, ARM64 GC/physical guards under QEMU,
and Darwin/Windows/386 cross-builds. QEMU alone excludes the known deadline
EINVAL test. Darwin/Windows execution and hardware PMU counts remain unavailable.
The temporary corpus symlink was removed.

Three serial matched cold-cache compiler pairs (CPUs 12/14, GOMAXPROCS=2,
512-MiB heap, 64-MiB nursery, no transform workers) give median wall time
33.622 s control versus 28.985 s final, and peak RSS
1,138,168 versus 620,524 KiB. Time falls 13.8% and
peak RSS 45.5% for this pinned job. Every Wasm/cache output hash matches,
validation passes and generated main returns 42. The final product uses the paged
default with nil execution options; optional collector screens are separate.
The four-second target is not met. Complete Wago tests take 40.026 s, also above
the user's 30-second activity target. Neither latency bug is claimed resolved.

Unstripped host bytes: 17,278,827 control; 17,358,095 final (+0.46%);
17,420,239 worker product; 17,473,291 concurrent product. The frozen matched host
retains three audited private managed-instance source changes. Current Dewdrop
Facet host/build edits and the existing ARM64 call change remain intact.
No active runtime, unrelated checkout or public PR was changed.

The committed Dewdrop research package contains the replayable patch series,
source/build identities, raw screening and final samples, runners, and validation
manifest. The Wago implementation is on dewdrop/gc-deferred-20261022.
