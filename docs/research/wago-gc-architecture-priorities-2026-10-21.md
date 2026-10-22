# Wago GC architecture work against the four-second target

Checked 2026-10-21. Recommended order: **308 with native-code changes, 309's
remaining header work, 313, then 321**. This is a research result, not an
implementation or a promised speedup. No issue was reopened and no public
comment was posted.

## Status and measured boundary

All four GitHub issues are closed with state reason `completed`. However, all
carry `release/deferred` and each has a “will do later” comment. Code confirms
that closure does not mean the complete design was delivered. The 16-byte
handle part of 309 is already present on the default branch and our local stack.
Do not count a hypothetical 20-to-16-byte handle saving again.

I checked the issue bodies/comments, current default-branch source, and local
Wago stack at 9d84600f1/399f7721b. Main and the private stack have some different
collector tuning, but the relevant backing, header and allocator design remains
the same. Source snapshots and blob IDs are saved with the notes.

The saved pre-experiment diagnostic profile has 34.02 sampled CPU seconds:
26.64 seconds (78.31%) are generated native code; CollectMinor has 4.58
cumulative seconds (13.46%); throughput growBacking has 0.03 cumulative seconds.
Full collection is not a visible sampled cost. Native leaf samples repeatedly
land in reference resolver code, but the complete 26.64 seconds must not be
attributed to checks. Sampled CPU components are not precise wall-time bounds.
Collector parallelism alone cannot plausibly supply the roughly eightfold
whole-job speedup still required.

The completed frame-cache experiment has a corrected one-pair screen of
36.1586 -> 34.6758 seconds, nearly unchanged peak RSS, and 10.33% more native
code. Full normal/register-check suites pass. It stays private and uninstalled;
one pair and no dynamic hit/miss counters do not establish a retained win.
See [the experiment report](wago-gc-loop-keyed-value-homes-2026-10-21.md).

## 1. Issue 308: stable virtual backing, coupled to cheaper native reads

[Issue 308](https://github.com/wago-org/wago/issues/308) remains unfinished for
GC. `throughputHeap.growBacking` allocates a new aligned Go slice and copies the
old backing; `newHandle` appends to a Go slice. The native view explicitly says
backings can relocate. Its stable descriptor does not imply stable heap bases.
The separate linear-memory runtime already has Linux mapping/reservation,
Darwin mapping, and Windows VirtualAlloc code that can inform a shared owner.

This is the first foundation to test because it can remove transient old/new
backing copies, reduce growth-time RSS, and allow safe base caching. **Copy
removal alone is not the speed case:** it accounts for only 0.03 sampled seconds
in this job. The useful performance experiment must also reduce the dependent
base loads in generated reference resolution. Measure the backing-only and
backing-plus-code-generation changes separately.

Start with a bounded Throughput heap reservation and bounded handle reservation,
with lazy physical use and explicit Close ownership. Preserve the portable Go
backing for unsupported products. Reuse/factor mapping machinery rather than
create a second unrelated platform implementation. Linux's MAP_NORESERVE path
is not a portable explicit commit API: Darwin uses ordinary mapping; Windows's
current linear-memory path commits the range up front. Reserved virtual bytes,
commit charge and RSS must be reported separately. Never equate a reservation
with low RSS or low commit charge without measuring each platform.

Stable backing permits hoisting bases only. Handle count, object liveness, type
and extent checks remain unless a separate proof removes them. Collector/context
switches and nested host reentry must rebind the right bases. Saved artifacts
must contain relocatable bindings, not process addresses. Moving nursery or old
objects can still change handle offsets inside a fixed reservation; existing
raw-address invalidation remains necessary. Decommit/Close must respect live
handles, invocation leases and readable metadata. Growth/commit failure must
leave prior allocations usable and remain visible to the caller.

Work: medium to large; main risk is platform ownership and native ABI/binding
correctness. Best memory prospect of these steps for growth spikes. Runtime
benefit is unmeasured until the emitted reads change.

Sources: [backing growth](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/throughput_alloc.go#L369),
[native view contract](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/native_view.go#L7),
[Linux mapping](https://github.com/wago-org/wago/blob/main/src/core/runtime/mem_linux.go#L41),
[Windows mapping](https://github.com/wago-org/wago/blob/main/src/core/runtime/mem_windows.go#L52).

## 2. Issue 309: compact headers, retaining the existing 16-byte handle

[Issue 309](https://github.com/wago-org/wago/issues/309) is partly delivered.
NativeHandleStride is 16, class/age state is packed, and allocation size is
derived from size class. But ObjHeader still has four u32 words: TypeID, Size,
Aux and Flags. PayloadOffset remains 16. Handle size and header size are both
read/checked by native resolvers. The handle still contains cardSlot; canonical
type currently lives in the object header, not the hot handle.

Prototype an eight-byte scalar header first. An explicit design could retain
TypeID/Aux and make handle size authoritative, deriving generation/pointer-free
state from handle/type metadata. This needs a real representation contract,
updated verifier and artifact/native-layout admission. Merely deleting the
current second extent check would discard an existing integrity rule. Do not
load an old artifact with its constant 16-byte offsets under a new layout.

Alignment and allocation classes limit the memory win. This arithmetic model
uses current 16-byte object alignment and old-space classes; it is not a speed
measurement and assumes scalar payloads:

| Payload bytes | Nursery: header16 -> header8 | Old: header16 -> header8 |
| --- | --- | --- |
| 4 or 8 | 32 -> 16 | 32 -> 32 |
| 16 | 32 -> 32 | 32 -> 32 |
| 24 | 48 -> 32 | 48 -> 32 |

The old allocator's smallest class is 32 bytes. Tiny old objects therefore do
not become 16-byte allocations just because their header shrinks. A 16-byte
class/free-span policy is a separate change to evaluate. V128 payloads also
require 16-byte alignment; changing the one global PayloadOffset to eight is
not sufficient. Use per-type padding/layout or retain 16-byte payload starts
where required. Header-free structs are a later variant: moving canonical type
into the 16-byte handle needs space currently occupied by card/allocator data.
That intersects the region/card work in 313.

Work: large layout change, with direct relevance to native read instructions,
allocation traffic and collection copying. Better speed/RSS potential than
additional cache tables, but no measured factor is established.

Sources: [handle ABI](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/native_view.go#L36),
[object layout](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/layout.go#L9),
[old allocation classes](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/throughput_alloc.go#L13).

## 3. Issue 313: Immix-style old generation

[Issue 313](https://github.com/wago-org/wago/issues/313) is not implemented as the
proposed block/line old generation. Current old allocation uses size classes and
an address-indexed AVL free-span tree. `major_blocks.go` is an occupancy index
for groups of 256 **handles**, not Immix heap blocks or allocation lines. Full
marking uses a bool per handle and a shared serial mark stack.

Stable handles are a good fit for later selective evacuation: object bytes can
move and the handle entry can be updated without rewriting all stored guest
references. Existing exact roots, typed reference scan metadata and real dirty
cards are useful foundations. Region occupancy, object starts, line/free-run
metadata, packed mark epochs and transactional evacuation still need work.

Follow the issue's stages: experimental region allocator, mark/sweep without
evacuation, then selective evacuation with shadow verification. Preserve the
current collector until long fragmentation/liveness tests show better total
throughput and memory. Include small heaps, large objects, promotion batches,
failed destination allocation and page return. Mark/free metadata must have a
bounded memory cost; packing it is not optional at this workload's handle count.

Work: very large. It can improve fragmentation, reclamation and promotion
locality. The current compiler profile is mostly native execution and young
collection, so there is no evidence that an old-generation replacement is the
fastest route to four seconds. Reassess if full-GC/promotion or fragmentation
becomes the measured limit.

Sources: [allocator](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/throughput_alloc.go),
[handle occupancy index](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/major_blocks.go),
[collector state](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/collector.go).

## 4. Issue 321: parallel first, concurrent marking last

[Issue 321](https://github.com/wago-org/wago/issues/321) is explicitly deferred.
Exact roots and dirty-card inputs exist for this compiler workload. Stable
backing/regions, packed Throughput mark epochs, pause distributions and worker
ownership are not all in place. Current collection is synchronous. Throughput's
barrier records old-to-young edges after stores; Tiny's incremental shading is
a different product. Neither makes Throughput concurrent marking safe.

Keep the stated order: background sweep, thresholded parallel stop-the-world
marking, parallel evacuation, then concurrent marking with proven handshakes
and an incremental-update or snapshot-at-start barrier. Start with one/two/four
workers at measured live-heap thresholds. Keep small heaps and Tiny worker-free.
Additional queues, retained state and synchronization must earn their RSS/CPU
cost. Current allocator/free-list/card/mark-stack mutation cannot be shared
between workers by simply adding goroutines.

Concurrent relocation is not part of this first scope. Any change that allows
movement during native execution requires a new audit of all raw-address homes,
register certificates, roots and invocation leases. Fixed backing alone does
not make concurrent object movement safe. Avoid a read barrier on every access
unless later evidence shows it is needed and pays for itself.

Work: very large and cross-cutting. It mainly changes collector time/pauses;
it does not remove the dominant generated read work. Keep it last for this
single compiler job.

Sources: [collection](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/collect.go),
[current post-store barrier](https://github.com/wago-org/wago/blob/main/src/core/runtime/gc/native/barrier.go#L58).

## Concrete next experiment

Prototype only 308's bounded backing and native-base binding, preserving current
headers and collector algorithms. Use the same pinned full compiler/request,
serial cold-cache pairs and output/hash checks as the cache experiments. Record
backing-copy bytes, hot generated loads, commit-boundary latency, reserved/committed
bytes, RSS and page faults. If only backing copies disappear and native reads
stay unchanged, treat that as memory infrastructure rather than a four-second
speed result. Then test 309's scalar header layout with real allocation-size
histograms and explicit V128 alignment coverage. No implementation of these
four issues was made during this review.


## Implementation follow-up: 2026-10-22

All four requested designs now have local implementations. The [implementation
and qualification report](wago-gc-deferred-implementation-2026-10-22.md) records the
20-commit patch series, checks, optional-mode gates and matched compiler results.
The earlier sections remain the review made before this implementation.
