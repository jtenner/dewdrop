# Rooted local handle certificates: source audit

Date: 2026-10-21. Source inspected: installed combined Wago
`dc961197a73698e7bbf3583769f8979fe3072fef` in
`.tmp/wago-local-stack-2026-10-20/wago`. This is a read-only architecture audit;
no unchecked resolver was implemented and no compiler timings were taken for it.
The separate fold-only descriptor experiment does not depend on this proposal.

## Finding

A live, unchanged local can carry a *logical object identity* across collection.
It cannot carry an object address. Under a correctly rooted and well-formed
collector, its handle cannot be freed/reused, and its canonical type cannot
change. Therefore a future compiler could retain a non-null/type certificate
across admitted calls and reconstruct the current address from the current
handle entry. This is stronger than a same-basic-block type fact.

However, the current successful cast is **not a full physical extent
certificate**. `emitNativeDefinedTypeCheckStub` checks that the selected handle
range fits the space and contains `HeaderSize`, then checks canonical type (or
subtyping). It does not establish the complete struct payload extent or the
array length-to-payload relation. The existing later field/element resolver
checks its required extent. Removing that check from a cast fact would change
current corruption diagnostics. Exact rooting does not close that gap.

I found no valid, documented high-level Wago API operation in the inspected
paths that changes the header/type/size of an already rooted object. In
particular, two plausible attacks are already closed: public compiled metadata
is detached from execution metadata, and guest payload views cannot be resliced
into headers or adjacent allocations. This is not an exhaustive proof of every
emitter, clone path, and plugin effect. Do not turn this audit into blanket
release-build guard removal.

## Conditional proof and what the compiler must establish

Let a certificate name `(function, local index, local definition version,
collector domain, non-null defined type, validated minimum extent)`.

1. A dominating successful non-null defined cast establishes an object rather
   than null or i31, and its type relation in the current canonical domain.
   A nullable cast needs an independent non-null proof. A true `ref.test` only
   establishes the fact on its true successor. A subtype match is not exact
   identity; retain the relation actually proved.
2. Every `local.set`/`local.tee` to that local ends the certificate, even if the
   assigned bits happen to equal its previous bits. Copying to another local
   needs a new versioned fact. Joins use the intersection of predecessor facts;
   loops need a fixed point, not linear emitter order. Exceptions and tail-call
   exits need explicit treatment. Current provenance is local-index based;
   `gc_resolver.go`, `driver.go`, and `inline.go` invalidate transient address
   facts on writes. They do not constitute the required cross-call versioned
   dominance analysis.
3. At every intervening collecting safepoint the *same compact value* must be
   in an actual enumerated root home. `GCFrameRootPlan.Exact` at function entry
   is insufficient: check the selected allocation/call site's local live mask,
   final frame offset, materialization, and final admission result. The plan can
   become `Exact=false` during emission. No trusted consumer may be published
   if final root admission fails.
4. The root plan is derived from validated source bytecode before native
   peepholes (`gc_frame_roots_linux_amd64.go`). Keeping the local.get that feeds
   a later access normally makes that value live across the call. A transform
   that deletes that use must preserve the certificate's root demand explicitly.
   Root masks must not be narrowed merely because native checks disappeared.
5. A collector must not reclaim a root or change its object identity. Moving
   collection may change entry offset/space and backing base, but preserves the
   handle index, header identity, length, and payload layout. Reconstruction
   must reload the current view/entry after the call, under the reacquired
   collector lease. Do not retain entry pointers, space bases, offsets, or raw
   object pointers across any allocating/callback boundary.
6. The physical layout being trusted must come from a well-formed allocation,
   or from a prior full physical validation covering the consumer. A cast alone
   only supplies `HeaderSize`. A larger later struct field needs its larger
   extent; array bounds remain dynamic even when type and array length are
   immutable. Null, index overflow, array index bounds, and public token checks
   are separate obligations.

Under these premises, induction over calls/collections gives a live unchanged
handle with unchanged type, so handle count/free-space/type tests are logically
redundant for that specific value. It does **not** give a persistent physical
address or permission to ignore arbitrary corruption introduced into the TCB
(the compiler, collector, and trusted native extensions).

## Source boundary inventory

Paths below are relative to the Wago tree.

| Boundary | Source and required invariant |
| --- | --- |
| Root planning | `src/wago/gc_frame_roots_linux_amd64.go:newGCFrameRootPlan`; `src/wago/gc_frame_liveness.go`; `src/core/compiler/backend/railshot/shared/gc_frame_roots.go`. Source call graph admission, live masks, EH fixed roots and final exactness must all agree. |
| Root publication | `src/core/compiler/backend/railshot/amd64/localstate.go:materializeGCFrameLocalsAt`, `gc_struct.go`, `call.go`; `src/wago/api.go` final `validGCModuleFrameRootPlan` and map publication. Candidate exactness can be revoked late. |
| Runtime stack walking | `src/wago/reference_store.go:gcNativeFrameRoots.rangeChain`: bounded frame extents, return-PC ownership, same collector, exact offset maps, and retained physical stack for suspended activations. Missing maps remain visible errors. |
| Native handle reuse | `src/core/runtime/gc/native/alloc.go:newHandle` reuses free slots. `checked_handles.go` adds generation bookkeeping only for checked Go API handles and retires generation overflow. A raw native uint32 has no generation. ABA is prevented by continuous liveness, not by native token bits. |
| Throughput collection | `native/mark.go`, `collect.go`, `survivor.go`: mark roots before reclamation, copy live object bytes, update handle entry, refresh native view. Promotion allocation is planned and rollback restores the previous observable heap. Do not cache any physical state across that transaction. |
| Tiny collection | `native/tiny_collect.go`, `tiny_alloc.go`, `barrier.go`: incremental root rescanning and barriers are part of the trusted liveness proof. Static exactness is not a replacement for these runtime mechanisms. |
| Collector ownership | `reference_store.go:hostCallNeedsGCSuspension`, `suspendGCInvocation`, resume: host callbacks release and reacquire domain ownership, including dynamically reachable domains. Scalar relay signatures do not prove absence of collection. |
| Parked callbacks | `gc_host_activation_linux_amd64.go:pushGCHostActivation/popGCHostActivation` preserves stack/control ownership and registers actual parked roots. Callback reentry can replace the instance engine; the parked physical stack must remain owned. |
| Go heap ownership | `hostcall.go` keeps `in` and `in.c` alive across native invocation. Collector-domain exclusion is not a Go GC exclusion. The collector and typed backing slices must remain owned; native uintptr values do not retain them. |
| Public ingress | `reference_store.go:stageGCRefArgument`, `issueGCRefLocked`, `issueHostGCResultLocked`, and `releaseGCRef`: tokens are store/owner/slot checked, rooted and translated to compact refs. Never extend an old certificate to a returned/reloaded value just because its numeric bits match. |
| Public collection | `gc_collect.go:CollectGC`, `prepareGCCollectionRootsLocked` uses the complete domain's parked/native/global/table/public roots and rejects active storage borrowing. Releasing a public token cannot kill a separate live native root. |
| Guest storage | `guest_storage.go:GCRef/gcArrayInfo/GCArrayBytes/GCArrayRef` validates callback lifetime, exact token ownership, object type, and array kind. Reference arrays have no raw byte view; writes require mutable scalar arrays. Immutable views are copied. |
| Payload slice bounds | `native/host_view.go:ArrayPayload` checks logical payload against object extent and returns `object[start:end:end]`. Capacity cannot expose allocation padding, another object, or header. `guest_storage_alloc.go:NewGCArrayResult` uses that same scoped payload and validates declared exact result type before token publication. Retaining a mutable slice past its documented callback lifetime violates the API contract. |
| Type query isolation | `guest_storage.go:DefinedType` calls `cloneDefinedTypeDescriptors` (PR1010). `compiled_snapshot.go:freezeExecution/cloneCompiledExecutionMetadata` deep-copies the public compiled containers; instances use the frozen view. Mutating a returned query/public descriptor is not a valid way to alter active type layouts. |
| Struct/array writes | `native/object_access.go:StructSet/StructSetTyped/ArraySet/ArraySetTyped/ArrayCopy` and AMD64 `gc_struct.go`/`gc_array.go` operate in payload and apply relevant reference barriers. They may change child refs and scalar fields, not the receiver's immutable type/length. A loaded child must get its own certificate. |
| Globals/tables | `globals.go:Set/SetValue`, `cross_instance.go` owner/import checks, `gc_ref_test_table.go:setTable`, `reference_store.go:rangeGCDomainPersistentRoots`, and generated global/table paths preserve typed reference ownership. A store changes a root slot, not the old object's type. A later reload must not inherit a certificate for the slot's old value. |
| Foreign clone | `gc_foreign_clone.go` allocates a distinct destination graph in its domain. Source-token validation and destination root publication remain mandatory. Domain/type mapping is not assumed equal. |
| Compiled codec | `codec.go` and frozen execution metadata define a new compiled image; they do not authorize replacing the heap of an active native invocation. Native collector codec APIs are a separate trusted/raw interface, not a mutation capability of `GuestStorage`. |
| Custom machine code | `src/core/plugins/instruction.go` explicitly calls Codegen trusted; `codegen/amd64/amd64.go` distinguishes managed checked-memory lowering from full access to encoder/registers. Full-access lowering can violate arbitrary heap/frame invariants and is TCB code. First admission should reject custom instruction maps and transitive unknown callees, rather than infer purity from an ordinary Wasm signature. |
| Lifecycle | Instance/domain leases and invocation lifetime must prevent close/rebind while the frame is live. A certificate belongs to its executing instance/domain, never to a process-wide integer handle or public token. |

## Lifecycle and physical extent follow-up

`Instance.Close` is a permitted callback action. It is a logical close: it gates
new invocations and requests interruption, but a parked activation may finish.
`instance_lifecycle.go:tryFinalize` refuses teardown while the invocation count
is nonzero. `reference_lifetime.go:finalize` repeats that condition before and
after transferring persistent ownership. `releaseResources` alone closes a
private instance collector. Therefore a host closing the current instance does
not free its collector underneath a returning native frame. Code and physical
stack ownership are likewise retained until the frame unwinds.

`Runtime.Close` starts asynchronous shutdown and `runtime.go:finishClose` waits
for active operations and terminal instance close before calling
`referenceStore.closeRuntime`. Store-owned collectors are released through
`releaseGCDomainLocked` after the resource-release lifetime event. Private
collectors are explicitly excluded from the shared topology in
`reference_store.go:registerInstance`; their collector lifetime remains with
the instance. A private reference store starts `runtimeClosed=true`, so that
flag alone must never be used as the proof that a native invocation has ended.
The relevant proof is the invocation/resource lifetime described above.

`ReleaseGCRef` can release the last public token after logical close. It clears
that token's global root and owner retention; it does not clear the parked
frame's root or end its invocation lease. A reference transfer into another
instance similarly cannot alter the first activation's local definition.
`CloneGCRefFrom` copies a graph into a distinct store; it does not replace or
retype the source object. The raw `native.Collector.Close` immediately clears
backing and handles, but no public high-level Instance/GuestStorage accessor
found in this audit hands out the active instance's raw collector. An internal
fixture or full-access extension calling `in.gc.Close` is TCB mutation, not the
same API operation as `Instance.Close`.

A better certificate seed is an **already executed checked field read** whose
`requiredBytes >=` the later read's requirement. This preserves initial
short-object diagnostics without moving any check ahead of source effects.
Use the actual canonical relation and exact rooted local version of that read.
Do not hoist a full-object validation just to manufacture this seed.

The moving collector preserves this extent: `throughput_alloc.go:alloc(size,
spaceOld)` records the requested `size` in the returned live handle even when
the physical size class is larger. Batched promotion constructs destination
entries with the source handle size. `collect.go:promoteHandleTo` copies source
bytes, changes header Flags, then replaces the source entry. The assignment to
`plan.entry.size` in `promotionPlansSorted` is a scratch allocation-class sort
key, not a mutation of the live object's declared extent. Nursery survivor
movement copies the entry and payload; Tiny does not relocate live objects.
Promotion failure rolls back before live entry publication.

Domain type growth (`native/collector.go:AddTypes`) appends immutable types;
old canonical IDs and type relations remain valid, but subtype interval backing
and canonicalization caches can change. Do not retain interval pointers, bounds,
or type-map backing across calls, even with a valid logical type certificate.

This stronger seed removes the initial HeaderSize-only gap. It still requires
the complete root/version/call-admission proof, reloads after relocation, and a
clear treatment of deliberately corrupted metadata after the seed.

## Diagnostics and counterexamples

A **valid API adversary** can pass a stale/foreign/wrong-type public token, change
mutable fields/globals/tables through valid operations, collect during a permitted
host callback, call another instance, mutate detached type queries, or attempt
an out-of-range field/element operation. Public rejection/semantic traps for
these cases must stay. An unchanged native local remains live independently of
mutable global/table contents.

A **TCB mutation test** uses package-private collector state, unsafe pointers, or
full-access native code to change `HandleCount`, `entry.space`, `entry.off`,
`entry.size`, space byte length/base, or object header. Existing tests deliberately
exercise this stronger physical-diagnostic contract; they are not automatically
obsolete because Wasm cannot produce the corruption.

Concrete counterexample to “successful cast proves all later spans”: take a
valid struct with a field past byte 16, then in a TCB mutation fixture shorten
its handle extent to 16 without changing its header/type. The standalone cast
can succeed, because its extent test is `>= HeaderSize`; the later checked
field read rejects the insufficient extent. A cast-based unchecked field read
would bypass that diagnostic and could read past the declared object. This is
not claimed to be a documented safe API attack. Likewise, changing a selected
space descriptor during a test-only host callback must still trap under today's
contract even though the local remains rooted.

A genuine API counterexample to a *weaker* “same local index” certificate is
ordinary guest code overwriting the local, dropping all references, collecting,
and allocating another type into the recycled handle slot. Numeric handle bits
may repeat. Definition versions and continuous per-site roots are essential;
comparing bits or remembering the local index is not a repair.

No valid high-level API counterexample to the full conditional theorem above
was identified. The missing items are a compiler certificate implementation and
proof of admission/effects for every allowed boundary, plus a deliberate choice
about preserving the stronger TCB-corruption diagnostics. This audit does not
claim those items are complete.

## Recommended bounded next step

Do not emit unchecked release loads yet. First add a source-side certificate
analysis seeded by an already executed checked field read of sufficient extent that retains the existing checked resolver and emits diagnostic
telemetry/assertions for the proposed proofs. Admit direct internal calls only
when the whole reachable call path has supported exact roots and no unknown
custom/host boundary; reject EH/tail/dynamic cases initially. Require the exact
local version in every intervening site mask and final accepted frame map.
Track the prior validated minimum extent separately from the type relation;
do not enlarge it by hoisting checks over source effects.
This can measure eligible hot accesses without changing memory safety or errors.

A later release trusted resolver would need an explicit contract decision and
checked-build parity tests (not silent removal/skipping of metadata tests).
Tests must cover local overwrite/ABA, null and subtype outcomes, joins/loops,
allocation-triggered minor/major/Tiny collection, promotion rollback, parked
host reentry, foreign domains, public token release, metadata query mutation,
selected-descriptor corruption, and casts whose header span is shorter than the
later field requirement. Whole-call admission must not trust only the immediate
callee's scalar signature.

The safe current alternative is the separate branchless descriptor address
calculation: it removes arithmetic and avoids an Old/Nursery branch while
keeping every physical/type guard. A larger upstream option is retaining precise
receiver/storage types in Dew Wasm instead of repeatedly erasing to eqref; this
reduces casts structurally, but needs its own compiler design and real-job
measurement. Neither alternative proves the proposed trusted resolver safe by
itself, and neither is claimed here to close the V8 gap.

## Bounded next candidate and generated-entry audit

Astra's final read-only proposal is a successful fused final-struct field read,
one admitted read-only same-module leaf call, then one covered read of the same
unchanged local/final type in a straight-line region. The certificate is logical,
not a cached raw address; the consumer reloads handle entry, selected base and
offset. Require seed requiredBytes >= consumer requiredBytes, local definition
version/dominance, the receiver in the actual call-offset root list, and final
root-map rejection to select the ordinary checked resolver. Clear on control,
local writes, second calls and unknown effects. Field values are reloaded.

Seed only from the fused resolver initially: it validates BOTH handle.size and
header.Size. The generic inline checked resolver does not establish the same
header-size diagnostic, so a generic checked-field seed is insufficient.
No unchecked resolver has been implemented or installed.

A source leaf is not by itself an effect proof. Current AMD64 wrapper/register
entries check a fixed mmap stack fence and optional interrupt cell using native
loads/branches. Failure restores the outer trampoline RSP and terminates the
invocation. Linux asynchronous interrupt likewise redirects to the outer RET
landing pad. There is no entry stack-growth/morestack helper. Internal CALL/RET
and approved fused final-read leaves do not invoke managed BeforeInvoke/AfterInvoke
or scheduler transitions; those surround the outer native invocation. Host
dispatch is a resumable lease-releasing path and must be excluded. Require a
final emitted-code classification: any Go helper, host dispatch, allocation,
unknown instrumentation or future resumable entry path cancels admission.

The first scope does not admit collecting callees. Corruption before the seed
still traps. Known callbacks/custom/unsafe instructions do not fit this narrow
interval and retain checked consumers. Checked builds should repeat all checks
as assertions. Preserve existing malformed-metadata tests; do not redefine
private corruption diagnostics silently. Tests must cover actual root-offset
fallback, both entry ABIs/interrupts, terminal stack/interrupt exits, helper
fallback, writes/joins/second call/collecting-call negatives, insufficient header
or handle extent, pressure and codec loading.

Real source opportunity: function2294 reads local2/type3610/field2, calls length
(which forwards to array_length435), writes unrelated local11, then reads
local2/type3610/field1. Seed extent covers the consumer. Existing telemetry shows
108 gcnative sites and58 internal calls in that function, not dynamic counts.
A text scan found278 possible read/call/read pairs in149 functions before actual
root, inline, forwarder and lowering checks. These are upper bounds, not measured
admission or a speed result.

## Concrete implementation handoff (installed 61881e2, research only)

The isolated branch `perf/gc-call-certificate` at
`/home/dev/Projects/wago-gc-call-certificate-pr` is unchanged at
`61881e2d0d5262e5c8362e024a95b7bec0a963e4`. No production edits, tests, builds
or timings were made for this handoff. Root implements; Astra researches.

### Admission and actual emitted effects

Start with one exact source shape for the resolved direct callee:
`local.get 0; ref.cast final T; struct.get T F; end`, one reference parameter,
one scalar or collector-reference result. Admit the actual target after
`directForwarder` resolution, not the source function name. Initially reject
modules with custom instruction overrides. Reject imports, indirect calls,
allocation, stores, nested calls, EH, threads, non-final casts and unknown
opcodes. If normal inlining removes the call, this is not a cross-call candidate.

Source recognition is only phase one. Record an unconditional compile-only
summary of the successful lowering attempt, independent of optional statistics.
The target must actually emit the fused final-struct resolver, with no helper,
host, custom, allocation or unknown native transition. A direct wrapper-to-own-
internal-entry adapter is permitted only as the audited native adapter path.
Native stack/interrupt checks are permitted only with their current terminal
trap behavior. Any fallback, retry or future entry path without that proof must
clear the summary. Never infer this summary from a missing optional stats field.

The exact source grammar plus positive successful-emitter evidence is the
smallest useful first proof. A broad read-only source effect analysis is not
needed yet. If a later emitter option can add a resumable transition, its
capability must invalidate the positive native effect summary.

### Caller state and actual root binding

Add a separate logical fact to `fn`; do not make `gcResolvedObject` survive calls.
Capture receiver local provenance before the seed emitter flushes the operand.
Seed only after the checked fused field-address emitter has emitted its call.
Record local definition/version, final local type, checked required byte extent,
and phase. The consumer must use the same local definition and final type, with
required bytes no larger than the seed. Consume once after exactly one call.
Use a small positive allowlist of intervening integer/local operations. Clear
on control, writes to the source local, second call, allocation, memory/global/
table/GC stores, unknown effects, and every non-admitted FB operation.

Invalidate in the actual local-write path, including optimized call-result
local.set handling and inline writes, not just the ordinary bytecode dispatcher.
Do not let an owned register snapshot masquerade as the current local definition.

In `callInternal`, after `prepareGCFrameCallsite` materializes roots, bind the
fact to the one actual emitted call relocation and the appended root record.
Require the receiver's local home from `plan.Locals` in the actual `rootOffsets`.
`TracksLocal`, `AllReferenceLocals`, source masks alone, or Candidate alone do
not prove publication. Record the call relocation index and callsite ordinal,
not a borrowed offset slice. Bind only when `finishRoots` records exactly one
call and keeps Exact true. Missing plans simply do not admit the optimization.

At final resolution, recheck Candidate, Exact, valid live masks, frame bounds,
receiver home membership, and that the final callsite ReturnOffset equals the
remapped actual call relocation offset + 4. Inspect root records after native
finalization and adapter sharing. A source root mask without a matching final
native call record must fall back. Keep the existing later Wago whole-module
root validation. Its rejection of another function does not introduce a
collecting edge into this proven noncollecting interval; it disables collection.
This argument does not authorize collecting callees in a later extension.

### Two-phase patching with a checked default

Keep the existing full checked consumer call and checked per-function stub.
Additionally record a pending candidate relocation at that consumer call. Its
compile-only sidecar identifies the callee, bound call/root record and extent
fact. Reserve a distinct pending relocation kind; it is never a runtime ABI.

Existing `finalizeNativeCode` remaps `f.relocs[].at`, and shared adapter passes
also remap those sites. After all functions and adapter rewriting, before
`buildModuleGCSharedStubs`, resolve pending candidates in both serial and
parallel module paths. First validate all candidate references; then compact
relocation arrays so stored call-relocation indices cannot shift mid-validation.
A failed candidate is removed from the relocation list, leaving the already
encoded checked local-call displacement. A passed candidate becomes an ordinary
relocation to the new module-owned certified resolver. Assert that no pending
kind reaches generic module relocation patching. Keep the original checked
stub even if all consumers pass in this first experiment.

Tests must verify that existing function compaction updates the encoded local
checked displacement as well as the pending relocation site. This is already
required for ordinary checked calls, but the pending-candidate path needs its
own serial/parallel and shared-adapter fallback tests. Do not add a second
runtime branch or change the callsite ABI.

The short shared leaf needs only the existing caller-clobbered RAX/RDX/RCX/R8:

```text
R8  = [RBX - GCNativeViewPtrOffset]
R8  = [R8 + NativeInstanceViewCollectorOffset]
EAX >>= 1; RAX <<= 4
RDX = [R8 + NativeViewHandlesOffset] + RAX
ECX = zero_extend(byte [RDX + NativeHandleSpaceOffset]); ECX <<= 4
R8  = [R8 + RCX + NativeViewSpacesOffset + NativeSpaceBaseOffset]
EAX = [RDX + NativeHandleOffsetOffset]
RAX += R8
RET
```

Use the existing exact descriptor stride/base constants and layout assertions.
No new pin, push/pop, persistent raw pointer, frame growth or call count is
required. R9-R11 and all callee-saved registers remain untouched. Existing
consumer setup can initially still load type/extent/nullability arguments;
removing those dead instructions is a separate refinement. The payload read
and reference-result root marking stay exactly as before.

### Safety and diagnostics boundary

The checked seed proves non-null non-i31 live handle, allowed space, selected
backing and entry span, expected final type, and BOTH entry/header field extent.
The unchanged local preserves the same handle identity. Native-only operations
and the approved leaf cannot release the collector domain lease, mutate those
facts or resume after a trap. Current entry checks either return normally or
terminate the invocation. Thus no handle reuse/ABA or backing destruction can
occur on a path reaching the consumer. Typed invocation ownership still holds
Go backing memory; the proof does not treat the collector lease as a Go GC lock.
The consumer reloads the address and field value.

This narrow scope deliberately does not rely on a general moving-GC theorem.
The root proof is retained as a strict admission condition and preparation for
a separately reviewed extension, not as permission to admit a collecting call.
Host Close/Release/reentry/GuestStorage actions cannot run inside this interval.
A caller containing such an edge gets the full checked consumer.

Corruption before the seed retains every existing checked failure. Malformation
observable through any admitted valid API path must retain the same behavior.
Private test mutation between reads through a host/custom edge is not admitted
and must keep its existing diagnostic. Concurrent raw mutation outside the
domain protocol is a separate trusted-code violation, not a valid API argument
for this optimization. Checked builds should deliberately retain the full
consumer checks. Preserve existing metadata tests and assert fallback for their
mutation edges; never skip them or silently alter expected errors.

### First red/green cases

1. Positive read/call/covered-read with an actual collector-reference local root;
   assert one final certified call and correct scalar/reference result. Also test
   a real allocation elsewhere so the caller has an exact root plan.
2. Same caller with only TracksLocal/type metadata, missing actual root home,
   mismatched return PC, or late Exact=false: assert checked fallback and the
   original short-header/entry-span diagnostic.
3. Same source getter forced to helper fallback, unknown instrumentation, custom
   override, import, allocation, nested call, store or indirect call: fallback.
4. Source overwrite, snapshot provenance, branch/loop/join, second call, unequal
   type, and larger consumer extent: fallback. Validate observable results.
5. Corrupt entry/header size or selected descriptor before seed: original error.
   Mutating host callback between reads: later checked read still reports error.
6. Both register and wrapper entry paths, interrupt enabled, terminal stack/
   interrupt exits, maximal pin pressure and PR1006 trap restoration.
7. Native compaction, serial/parallel compilation, shared adapter rewriting,
   code marshal/load round trip and checked-build full validation.

No runtime performance claim follows from this proposal. The previously noted
function2294 pair is a concrete source opportunity; actual final admission and
its dynamic frequency remain unmeasured.
