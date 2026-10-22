# Bounded concurrent marking: implemented first product

Status: implemented and checked in the deferred-GC series. Parallel mark/copy
and concurrent marking still require explicit workload thresholds. The default
collector creates no workers. This product overlaps immutable graph marking with
mutation; final publication, sweep and all relocation remain stopped.

Use a separate `wago_gc_concurrent` + `wago_gc_workers` AMD64 product. Tiny,
non-AMD64 and default builds reject concurrent options and compile native/Go
barrier branches out. Initial admission requires collecting Immix, a moving
nursery, no custom instruction module at the instance API, and explicit measured
heap/object thresholds. Default concurrent threshold remains off unless qualified.

At an existing exclusive native/GC lease boundary, cancel unused native batches,
join pending metadata sweep, capture exact standard roots and a complete immutable
integer object graph. Offsets index stable handle IDs; edges are uint32 IDs. The
root IDs occupy a prefix in the edge slab. Keep packed initial-alive and live bits.
The worker reads this graph only, never current payloads, handles, descriptors,
cards, region metadata or mappings. Bound total snapshot capacity (including
bitmaps/offsets/queues) explicitly. Declining a snapshot or remark budget must be
visible in status/telemetry; never perform a partial sweep.

This is a snapshot-at-start proof plus an incremental-update barrier:
- Initial exact root reachability is retained from the immutable start graph.
  Removing/replacing edges cannot lose their former descendants.
- Track any mutated initial parent in a dirty bitmap, including young parents and
  old-to-old writes. Go scalar reference stores use the central storeValue hook;
  bulk writes hook PostBulkWriteBarrier/fill/copy. Deferred stores must be covered.
  ArrayFillNoBarrier currently permits only null/i31, which cannot insert a GC edge.
- Native struct/array reference store leaves must dirty the validated parent at
  their shared successful-store join (including the nursery early branch). R8 is
  collector view, R9 parent handle entry, R11 payload base, RSI extent/byte index,
  RDI child. RAX/RCX/RDX/R10 are scratch at that join. The card checker consumes R9, so preserve the original compact parent on the
  stack and recover its full validated handle index from that saved word.
  Bounds-check its bitmap word, then OR its bit. These writes need
  no atomics: the domain permits one mutator; the graph worker never reads dirty
  bits. Never add a load barrier or Go call to native read paths.
- A native-view active flag occupies old padding offset212; appended dirty pointer
  and count need exact ABI/layout guards and typed owners. Concurrent products
  require a distinct native ABI gate (base12/13 +2), rejecting old artifacts before
  code without barriers can run. Default append-only prefix remains compatible.
- New objects are black. With no young collection during an active cycle, the
  nursery-handle prefix at start stays fixed: native unused-batch cancellation
  removes only new suffix entries. Scan every live born handle in the tail during
  remark. Moving-nursery admission makes large births young too. ForcePromote must
  cancel/join the concurrent cycle first, because it can remove ledger entries.
  Dead native allocation charges publish no identities. Synchronous full collection
  cancels the snapshot and traces exact current roots, so floating snapshot garbage
  cannot cause a false heap-exhaustion result. Minor collection finishes bounded
  remark first, or aborts it before its ordinary fallback. These paths run before
  any free/reuse. Thus initial live
  IDs cannot alias a new object while the snapshot exists.
- At a final lease boundary, join graph work, cancel unused native reservations,
  enumerate current exact roots, scan born objects and every dirty initial parent,
  then trace newly reached IDs through the immutable graph. Scanning all dirty
  parents is conservative, even if the parent was initially white. Births scan
  current fields; dirty parents cover later insertions. Current roots cover native
  frame-local changes. Stable references stay unchanged; only complete liveness
  may publish to existing packed mark/line state and sweep.
- Count roots, dirty words/parents, born handles/reference slots, queued snapshot
  edges and other remark work against an explicit work budget. On overflow, abort
  without sweep, expose the reason, disable barriers and retain all objects. A
  synchronous pressure collection may then run its ordinary correct full path.
  This bounds remark work, not OS scheduling latency; report measured p99/max.

Lifecycle: worker owns typed integer arrays until joined. Close joins before
unmapping. Start/finish use the same exact-root/native/domain locks as CollectGC.
Nested host reentry and helper collection must finish through these paths. Root
borrow/custom unsafe payload writers require exclusion or explicit cancellation.
GC numeric-only raw array APIs are harmless. Audit all GC payload write paths;
reference bulk native paths must stay helper-bound or gain the same dirty hook.

Implemented checks include: SATB deletion, old-to-old/young-parent insertion, birth reference
fields, all Go/bulk/deferred and native write leaves, array bounds/trap order,
changing roots and host reentry, shared collectors, helper minor/full, abort/finish
retry, ForcePromote cancellation, close, snapshot/remark budgets, artifact reload,
ABI rejection, race tests, minimal/Tiny exclusion, and CPU/pause/RSS/throughput
measurement with the feature off/on. No speed gain is assumed.


Snapshot storage uses two-pass exact CSR allocation, including zero reference
slots, packed alive/live/pending/dirty bits and type-count workspace. Both byte
capacity and decode work are bounded. Mostly-null arrays and duplicate roots
cannot evade the CPU bound. Growth during remark counts the temporary old and
new bitmaps against the memory limit. The worker observes immutable integer
storage only; channel join publishes its results before mutator-owned remark.

`AutoConcurrent` is an optional paced controller at existing exact allocation
and minor-collection safepoints. It requires `ConcurrentMark`; neither enables a
zero byte threshold. At least 64 allocations separate start attempts. Single-
processor execution declines automatic work. Expected snapshot/remark resource
declines remain visible in counters/status and preserve the ordinary allocation
path. Invariant failures remain errors. Manual start/finish remains available.

The native tests cover both original and reloaded artifacts, young and promoted
parents, distant struct cards, array leaves, host reentry, shared collector roots,
and automatic native allocation refill. Core tests cover cancellation, deletion,
insertion, births, bulk/deferred stores, budgets, close, exact pressure fallback
and race instrumentation. The full validation manifest is recorded separately.

Five ten-cycle screens on CPUs 12/14, GOMAXPROCS=2, compare a Go graph mutator.
At 262,144 nodes the median cycle wall time falls from 16.423 to 15.176 ms;
measured pause falls from 16.094 to 14.825 ms. Snapshot storage is 6,422,608 bytes
and allocation about 6.51 MB/cycle. At 4,096 nodes the candidate is slightly slower.
Whole mixed-run peak RSS is 50,036 KiB. These are screening data, not a Wasm
compiler result. No default concurrent threshold is justified by this screen.
Linux perf_event_open denied hardware counters with errno 1; elapsed worker
measurements are not CPU measurements. Process CPU and context switches are saved
by the external runner.
