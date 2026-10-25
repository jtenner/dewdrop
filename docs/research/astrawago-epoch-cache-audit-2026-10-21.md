# Epoch handle-cache audit, 2026-10-21

Research only. No runtime edits, builds, tests or timings. Source was read from
the installed Wago tree; HEAD at the end was
`8e4a3d7d4427b2bd7de84bf261e51f57a618db05`. Claude's report reviewed 61881e2.
The separate call-certificate worktree remains unchanged.

## Decision

Do not enable Claude's rank-1 hit shortcut under the current checked-access
contract. A move/free epoch can establish that an address is still the address
of a live object under legitimate collector operations. It cannot establish
that the current mutable native metadata would pass the required checks.
Changing private corruption tests to bump the epoch would conceal this gap.

A verification-only locality probe is useful. Always run the original resolver,
never dereference the saved address, and never substitute the saved result.
Count repeated refs and repeated resolved addresses after successful checks.
These are locality counts, not a proof of usable cache hits or a speed result.

A later shortcut could be limited to a closed native interval proven not to
change the relevant metadata. Alternatively, invalidate at every native entry
and every resumable host/helper/custom boundary as a real runtime rule. That
second rule also needs proof for all generated native mutation paths. It is
much stricter than a collector-move epoch and must not be a test-only hook.

## Exact diagnostic counterexample

Warm a fused final-field read site on a valid object. At a serialized host or
private test boundary, reduce that handle's size below the requested field
extent, or set the selected space Bytes to zero. Do not change the object
header, compact ref, object address or proposed epoch. Re-enter the same site.
The existing fused resolver reports TrapCastFailure before the payload read.
The proposed cache hit reads a valid header at the old address and succeeds.
Changing HandleCount, the selected entry's space, offset or the Handles base
gives further examples. Keeping the header/type checks does not repair them.

These mutations are private runtime metadata corruption, not legal guest Wasm
operations. They nevertheless have explicit existing diagnostics that root
requires us to preserve. Relevant tests include
`src/wago/gc_space_byte_amd64_test.go:TestGCResolverSpaceByteRejectsInvalidEntries`
and the packed/scalar field guard tests. Some general resolver tests, including
`gc_array_len_native_test.go`, require a Go-helper fallback to recover and return
the original result after a malformed native view; they do not require a trap.
Preserve each original outcome and order, rather than imposing one new error.

A warmed-cache regression must be added, with the original metadata mutations
and no artificial epoch update. Existing tests that start with cold slots do
not demonstrate warm-hit parity. Address equality alone also cannot detect
short-size or zero-space-length corruption.

`NativeCollectorView` currently says generated code may cache only the view
pointer and must reload all consumed mutable backing pointers/counts. An epoch
shortcut changes this documented native ABI contract. The exported NativeView
returns a mutable descriptor pointer for trusted native integration; it does
not grant callers permission to violate collector invariants. The ordinary
Wago public APIs do not expose raw heap headers or handle-table storage.

## Mutation inventory

Paths below are relative to `src/core/runtime/gc/native`. An epoch covering
these must advance before a reader can resume, including error paths. It need
not increment once per dead object if a whole serialized operation invalidates
the domain once before its first mutation. Never roll an epoch back with heap
transaction state.

| Path | Address/lifetime effect and obligation |
|---|---|
| `CollectMinor`, `commitPromotionPlans` in collect.go | Copies live nursery objects to the other survivor region or Old, publishes new entries, resets/reuses Eden. Invalidate the whole operation before mutation. |
| `finishMinorEvacuation`, `finishSparseMinorEvacuation`, `finishDeadNurseryEvacuation` | AMD64 fast paths set entry.space=Free directly. They bypass releaseHandle. A hook only in releaseHandle misses these frees and subsequent ABA reuse. |
| `CollectFull`, `sweepAll`, `major_blocks.go:sweepMajorBlocks` | Sweep/free paths, including deferred throughput reclamation. Invalidate when object lifetime ends, not when a deferred span is eventually reused. |
| `promoteMarkedNurseryImmediate`, `promoteHandle`, `promoteHandleTo` | Old promotion and entry replacement. Include both planned and immediate paths. |
| `barrier.go:ForcePromote` | Public checked wrapper exists in gc/object_access.go. It can move an object without collection and without refreshNativeView when Old backing length did not change. RefreshGeneration is not a substitute. Large in-place tenure changes age/flags, not address. |
| `nursery_growth.go:growDefaultNursery` | Allocates a new nursery backing and adjusts live survivor entry offsets. Both address components change. |
| `throughput_alloc.go:growBacking` | Copies the entire Old/Large backing; both descriptor spaces share that backing. Can occur during allocation or promotion, including collection-disabled allocation. |
| `restoreAllocTransaction`, `rollbackSuccessfulAlloc` | A failed promotion/allocation can replace grown backing with the old slice. Keep invalidation monotonic across rollback and publish the final view before native resume. Unpublished temporary spans do not themselves represent cacheable objects. |
| `releaseHandle`, `free`, `deferThroughputFree`, `freeTinyPrepoisoned` | Clear published identity and return handle to free list; poisoning/free lists may overwrite the old header before reuse. Must invalidate before cached-address dereference can resume. |
| `tiny_collect.go:Step`, tiny sweep, allocation debt/near-exhaustion assists | Tiny incremental Step can free outside CollectFull/Minor. Current Tiny backing is fixed at construction, not dynamically grown. Tiny is excluded from Claude's first candidate, but shared invalidation helpers must not make a false general claim. |
| `alloc.go:newHandle`, `native_alloc.go:reserveNativeHandles` | Reuse compact handle numbers and grow/move handle table backing. With complete prior free invalidation, new publication alone need not invalidate existing object addresses. Appended table backing growth does not move heap objects. This optimization needs a proof, not a blanket claim that allocation is irrelevant. |
| native struct/array emitters and reservation preparation/cancel | Native code publishes reserved entries and headers. Reserved unused handles are still Free; cancellation returns only unpublished reservations and can rewind their exclusive allocation tail. Existing cached objects must be disjoint. Native preparation may collect or grow Old/Large before publication. |
| `Collector.Close`, `tinyHeap.Close`, `throughputHeap.Close` | Release backing and clear tables. Epoch must become unusable before release, but an epoch pointer cannot extend the lifetime of its owner. Closed views and instances must never execute cached loads. |

`AddTypes` appends immutable canonical type descriptors without moving objects,
but can move type/interval backing. A cached canonical ID can remain a number;
a cached map/interval pointer cannot be reused on that premise. Final-only
static sites must still use their instance's canonical map. Header TypeID, Size
and array Aux are immutable after legitimate publication; field contents are
not. A hit must still read current field data.

Native view refresh publishes Handles/count and space descriptors. Cards-only
refreshes do not invalidate object addresses. NativeView's RefreshGeneration
increments frequently on allocations/cards and can miss a ForcePromote address
change; neither its frequency nor its value is the needed epoch proof.

## Domain, thread, lifetime and wrap rules

`src/wago/reference_store.go:gcStoreDomain.invocationMu` serializes active native
execution against collection and result handoff for a collector domain. Host
callbacks suspend that lease while parked roots stay published.
`host_execution.go` also releases the native execution mutex and may restore a
different active context on return. Another invocation can run while one is
parked. A per-instance table can be shared only while these native leases hold;
a probe/update must contain no resumable helper or callback between its reads
and writes. Re-read epoch after resume; never keep a half-probed cache hit.

One Compiled image can serve multiple instances and domains. Keep slots per
instance, not in shared executable bytes or a global table keyed only by site.
Bind their lifetime to the instance and their identity to its current collector.
A raw u32 ref is not globally unique; slot/epoch equality from a different
collector must never count as a hit. Cross-instance calls must select the
callee's basedata/context. Preserve existing upper-bit/foreign-reference checks
before narrowing a key to u32. A same numeric low word is not a valid foreign
reference check. Initially exclude custom instruction maps at module level.

Instance.Close defers physical resource release until active invocations unwind
(`instance_lifecycle.go:tryFinalize/releaseResources`); domain ownership controls
collector release. The cache must follow that ownership. Stored addresses must
be uintptr/numeric values, not Go pointers that retain old backing or roots.
Typed instance/collector ownership must still keep current backing alive while
native code runs; the collector lease does not stop Go GC.

A 32-bit epoch wrapping requires clearing EVERY table in the collector domain,
including other instances and parked activations, before publishing the reused
value. Clearing only the active instance is unsafe. There is no such table
registry today. Prefer a u64 epoch with an explicit saturation rule: disable
cache use permanently at exhaustion (or perform a proved domain-wide reset).
Neither width nor 'unlikely to wrap' is a proof. Zero can mark invalid slots.

A 24-byte slot with u32 handle/epoch and u64 address/type padding is plausible.
A u64 epoch, u64 address, u32 handle and validity can also fit in 24 bytes if the
static site supplies expected type. Retaining a canonicalType word may increase
that to 32 bytes. Count the real aligned structure; do not use the report's
7-byte/site estimate before register/ABI emission is designed. A shared stub
needs an explicit site ID and its existing argument registers are already in
use. 'Before register pushes' is not a register-preservation proof.

## Basedata and codec changes are real

`GCNativeViewPtrOffset` is 280. Offset 288 is already
`ActualLinMemByteSize64Offset`; BasedataSize is 288. Two extra slots cannot just
be placed beside 280. Changing basedata requires a larger aligned allocation,
JobMemory accessors and reset/grow paths, InstanceContext layout/publish/restore,
cross-instance and parked context handling, and architecture consumers/tests.
An explicit versioned NativeInstanceView extension avoids that second basedata
channel and uses its existing context restore path; it still changes native ABI.

NativeABIVersion is currently 9 and codec loading checks exact compatibility.
Instrumented/optimized native code must require the layout that provides its
table, never load against a zero or older slot. Keep codec container version 1;
this is a native ABI requirement, not a request to version the public codec.
Compile metadata needs validated site count/size bounds and stable site IDs.
Allocate tables before execution and keep typed owners; do not serialize table
contents, addresses, epochs or counts. Loaded code gets fresh zeroed slots.
Diagnostic artifacts must either carry their required metadata or be explicitly
rejected for serialization/loading; never silently load them without a table.

## Smallest semantics-preserving probe

Start with one clearly reported family: successful fused final-struct field
resolutions. Assign dense site IDs, record function index/Wasm PC/type/extent
for reporting, and allocate a fixed per-instance diagnostic table. No timed
allocation or per-access Go call. Do not call a diagnostic Go helper from native
code: that would add a new safepoint and change the experiment.

At a site, store the current compact ref to a pending field before argument
setup. Execute the original checked resolver unchanged. Only on its normal
return, observe RAX (the actual checked object address) and update that site's
state using existing caller-clobbered scratch registers. This avoids retaining
an unrooted raw pointer or adding a stack spill across the checked stub. The
checked stub has no callback, so pending state cannot be overwritten by reentry.
All failure paths retain the current trap or helper-fallback behavior.

Per-site state: pending ref, previous successful ref, previous successful
address, valid bit, successful resolutions, same-ref count, same-ref-and-address
count. Derive cold/ref-change misses and same-ref/address-change misses from
those totals, or retain explicit counters if simpler. Use saturating u64
counters with an overflow flag so wrapping cannot fabricate a hit rate. Values
are numeric: NEVER dereference the old address, even on an apparent match.

Read/export counters after execution is quiescent, preserving the original
result/error. Do not introduce Claude's new guest trap on mismatch: that changes
semantics. A verification harness may separately report/fail on mismatches while
retaining the original guest outcome in its evidence.

Phase one needs no move epoch. It measures exact consecutive-success ref/address
locality per site. Call that `same-address repeat rate`, not usable epoch hit
rate: a free/reuse ABA can produce the same numbers. Report coverage and all
miss categories; do not extrapolate uninstrumented families.

Only if that result warrants it, add a diagnostic-only mutation serial with the
full inventory above and compare predicted epoch hits against the full resolver.
Count same-ref/same-epoch but different checked address, and full-resolver
failures after predicted hits. Keep the old metadata tests unchanged. Even zero
address mismatches on the compiler job does not prove all failure diagnostics or
epoch hooks: it is workload evidence, not permission to remove the physical walk.

A shortcut that preserves current diagnostics needs either the compiler's
closed-interval proof or real cache invalidation on every native entry and
every external mutation/resume boundary, plus all native allocation/mutation
proofs. The report's unrestricted 'any call is allowed' claim is not established.
