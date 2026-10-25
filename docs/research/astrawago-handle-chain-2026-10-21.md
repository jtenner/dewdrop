# Wago handle load chain: source review and bounded experiment

Source reviewed: installed combined Wago `321fae779`, at
`.tmp/wago-local-stack-2026-10-20/wago`. The existing ARM64 `call.go` edit is
user work and was not changed. This review did not build, test, or benchmark.
The follow-up experiment will use a separate worktree above public PR 948
head `2c53a783828d7ae3ca2d3fe92946a249d6fdf278`.

## Decision

Test a fixed-displacement **Old-only** space load first. Keep every current
guard and keep the indexed space path for Nursery, Large, and Tiny. This can
start the heap-base load in parallel with handle metadata. It needs no new
runtime state, cache, register, frame slot, native call, or ABI change.

A full object-pointer cache is possible, but it is not the first experiment.
It adds at least eight bytes per handle, has many update sites, and does not
permit removal of the existing mutable extent and type checks. Existing tests
require those checks even when guest type rules would make them redundant.

The profile supports a dependent-load hypothesis. It does not prove a cache
miss or predict a speed gain. A 9.3x end-to-end gap cannot be claimed fixed by
this change before measurement.

## Current layout and trust boundary

All source paths below are relative to Wago.

`src/core/runtime/gc/native/collector.go:116` defines this 16-byte entry:

| Offset | Bytes | Field |
| --- | ---: | --- |
| 0 | 4 | object offset in its space |
| 4 | 4 | authoritative object extent |
| 8 | 4 | one-based object-card slot |
| 12 | 2 | allocator class; also young-object age bits |
| 14 | 1 | space: Free=0, Nursery=1, Old=2, Large=3, Tiny=4 |
| 15 | 1 | remembered flag |

There is no padding to reuse. The native `Ref` in `native/ref.go` is 32 bits:
zero is null, bit zero marks an i31 value, and an object is `handleIndex << 1`.
It is not an address. Public checked refs additionally carry owner and
generation (`src/core/runtime/gc/collector.go`, `native/checked_handles.go`).
Wago's public reference tokens and domain conversion remain separate from
these raw collector-local integers. A native optimization must not bypass
those ingress checks or change root encoding.

`native/native_view.go` defines a 200-byte view. Handles is at byte 8,
HandleCount at 16, and the five 16-byte space descriptors start at 24.
Each descriptor has an eight-byte base and a four-byte length. Thus Old Base
is at 56 and Old Bytes at 64. Native ABI is currently 9 in this external
Wago tree. This experiment changes no format or ABI version.

The collector owns typed Go slices for handles, nursery, throughput memory,
and Tiny memory. The view exposes integer addresses but does not keep backing
alive itself. Invocation leases in `src/wago/reference_store.go:1354` exclude
conflicting collector mutations. Native entry paths, including
`prepared_direct_amd64.go`, retain `in` and `in.c` with `runtime.KeepAlive`.
The lease is not a proof that Go GC stops. A new integer pointer table must
retain the existing typed owners and exact roots, and must be refreshed after
a safepoint or host callback changes a backing.

## First implementation: fixed Old descriptor loads

Initial scope is the common AMD64 shared resolver and the four per-function
read/type resolver bodies that have the same register contract. Keep the
abstract-array helper, inline resolver, allocation, and barrier code unchanged
for this experiment.

At selection entry, R8 is the collector view, R9 the checked entry address,
R10 space scratch, and R11 base scratch. RCX is free: the shared resolver and
fused struct resolver saved required extent in RDI; final array get saved its
index in RSI; nullable-cast handling is complete in the other two stubs.

1. After entry address formation, load `[R8+56]` to R11 and `[R8+64]` to ECX.
   These are descriptor reads, not object reads. Start them before the space
   byte load. No extra live register is needed.
2. Load the space byte into R10D. Keep both current Free and space-range
   failure checks, with their current failure destinations.
3. Compare space with Old exactly. On the Old arm move ECX to R8D. On every
   other arm execute the existing indexed descriptor selection, which writes
   R11=selected base and R8D=selected length.
4. Join before the existing offset, size, required-extent, header, canonical
   type, subtype, and array index checks. Do not move an object load above
   those checks. Keep each stub's failure mode and trap order.

The Old base no longer depends on `handle.space`; it depends only on the view
pointer. The object address still depends on `handle.off`. The full range
proof is unchanged: `off <= bytes`, `size <= bytes-off`, and
`size >= requiredExtent` before object access. No guard is removed.

Old and Large normally share backing: `refreshNativeView` assigns Large from
Old. **Do not use the Old descriptor for a Large handle.**
`TestGCGeneralArrayLenNativeGuardFallback` in
`src/wago/gc_array_len_native_test.go` allocates a Large object, then changes
only its selected descriptor's length or base. Aliasing its descriptor to Old
would hide the current diagnostics. `ValidateNativeInstanceView` does not
validate equality of these mutable descriptors. A later Large fixed-load arm
must load its own descriptor at 72/80.

Expected risk: extra Old descriptor loads and one branch for non-Old objects;
an unpredictable Old/non-Old mix can cost more than the saved dependency.
Cold loads address valid descriptor storage even when Old has empty backing;
the zero base is not dereferenced on the fallback path.

### Resolver inventory

| File / function | Current space load | Initial scope |
| --- | --- | --- |
| `amd64/gc_direct.go:emitModuleGCResolveObjectStub` | byte, R8/R9/R10/R11 | Yes; shared exact, subtype, bounded, array-operand families |
| same, `emitNativeFinalCastArrayLenStub` | byte, same scratch | Yes; cast then length |
| same, `emitNativeDefinedTypeCheckStub` | byte, same scratch | Yes; cast and test; preserve mismatch versus invalid-ref behavior |
| same, `emitNativeFinalArrayRefGetStub` | byte, same scratch | Yes; preserve RSI index and physical/header extents |
| same, `emitNativeFinalCastStructRefResolverStub` | byte, same scratch | Yes; preserve pinned-register restore before trap tail (PR 1006) |
| same, `emitCheckedGCObject` | byte, allocator-selected regs | Later; register contract and spill handling differ |
| `amd64/gc_abstract_array_len.go:emitModuleGCAbstractArrayCastLen` | byte; R8 must retain view, RDX is byte count | Later; fallback returns status for Go helpers |
| `gc_direct.go:emitNativeBarrierSafeStructRefSetStub` | metadata dword | Later; allows Nursery/Old/Large only; retains parent-space barrier decision |
| same, `emitNativeCardSafeArrayRefSetStub` | metadata dword | Later; same allowed spaces and card/barrier checks |

All AMD64 paths above live under
`src/core/compiler/backend/railshot/`. ARM64 corresponding files are
`arm64/gc_object_stub.go`, `gc_array_direct.go`, `gc_branch_cast.go`, and
`gc_array_alloc.go`. They are outside the initial AMD64 experiment.

## Pointer cache design and complete update obligations

Appending `uintptr object` makes the entry 24 bytes on AMD64/ARM64, +50% of
handle-table bytes and a non-power-of-two stride. A separate `[]uintptr`
costs the same eight bytes per capacity slot, plus a 24-byte slice owner and
native-view pointer/count fields. One million slots cost about 7.63 MiB more,
before spare capacity. A side array retains the existing 16-byte addressing
but adds another array stream and another backing allocation.

Replacing off+size with a pointer loses authoritative extent. Replacing
cardSlot+class+space+remembered loses live barrier and allocator state.
Moving cardSlot to a side array permits a 16-byte pointer/size/metadata entry,
but still adds four bytes per slot, requires deriving offsets in all collector
operations, and changes barrier metadata access. Packing a pointer into 48 bits
and using spare bits for size cannot represent the existing 32-bit object
extent. A 32-bit direct ref with space bits would require rewriting every
reference on moves and changing root, object-field, and public conversion
rules. A single reserved virtual-address region could avoid per-object pointer
repair, but requires a new allocator/backing contract and is not bounded here.

If an eight-byte side cache is later tried, retain the original entry and all
guards. Require cached pointer equal selected base plus offset before use;
do not treat nonzero cache data as a liveness or extent proof. This allows
earlier speculative pointer-dependent work, but adds a stream and equality
check. Removing the equality and selected-space guards would change the
malformed-metadata behavior tested today. A prevalidated cache does not see
direct mutations of handle size, selected space bytes, or object headers.

The required cache coherence sites are:

| Source / path | Required action |
| --- | --- |
| `native/collector.go:NewCollector`, `tiny_alloc.go:newTinyCollector` | create zero entry 0 and typed cache owner before publishing view |
| `native/alloc.go:alloc`, `newHandle` | fill on both fresh and reused handles, only after final backing/extent and header are valid; checked generations remain unchanged |
| `native/tiny_alloc.go:tinyAlloc` | fill Tiny pointer; it uses `newHandle`, but header publication still follows |
| `native/native_alloc.go:reserveNativeHandles` | grow cache alongside handles in both checked and unchecked bulk paths; reserved entries must remain unavailable |
| `native/native_alloc.go:PrepareNativeLargeArrayAllocation` | do not publish a live pointer merely on reservation; it reserves an empty handle |
| AMD64 `gc_direct.go:emitNativeArrayAllocStub`, `emitNativeStructAllocStub` | generated publication must write the pointer before the ref becomes visible; includes large-array reservation activation and all inline/stub variants |
| ARM64 `gc_array_alloc.go`, `gc_array_direct.go` | audit every native handle-offset/size/metadata store; any native publisher must write or explicitly invalidate cache |
| `native/collect.go:commitPromotionPlans` | after each survivor copy update pointer; promotion calls `promoteHandleTo`; in-place Large aging keeps address |
| same, `promoteHandleTo` / immediate and individual promotion callers | update after copy and entry replacement |
| same, `finishMinorEvacuation`, `finishSparseMinorEvacuation`, `finishDeadNurseryEvacuation` | all have optimized `e.space = spaceFree` paths that bypass full entry clearing; invalidate cache or require liveness check before every use |
| same, `releaseHandle`, full sweep, `major_blocks.go`, Tiny sweep | invalidate before memory can be reused; free and reused identities must not expose old pointer |
| `native/nursery_growth.go:growDefaultNursery` | rebuild all surviving Nursery pointers after changing offsets and backing; old pointer must not outlive old typed backing |
| `native/throughput_alloc.go:growBacking` | rebuild every live Old/Large pointer after backing copy; heap helper has no collector handle list, so wire this at collector publication boundaries |
| same, `restoreAllocTransaction`, `rollbackSuccessfulAlloc`; callers in `alloc.go`, `collect.go`, `native_alloc.go` | repair or retain prior cache on every rollback; commit only against final backing after the full transaction; error returns must leave coherent data |
| `native/native_alloc.go:discardNativeStructHandles`, `discardNativeLargeArrayAllocation` | cancel unused reservations without leaving live cache entries; preserve used prefix and rewind rules |
| `native/collector.go:Close` | zero published cache pointer/count and release typed cache/backing owners after native lifetime ends |
| `native/native_view.go:refreshNativeView`, `refreshNativeHandles` | publish new cache backing with matching count whenever handle backing grows; cache pointer must not be kept across safepoints |
| `src/wago/gc_struct_helper.go`, GC array helpers, host storage paths | allocation routes through collector allocators; after callback resume reload cache/view rather than keep an address in a register |
| `src/wago/reference_store.go` foreign clone/domain paths | publish destination-local handles and cache entries; do not import an address from another collector |
| `src/wago/codec.go:411,1135`, `api.go:2766`, `code_mapping.go` | codec stores compiled native ABI metadata, not live heap pointers; never serialize a pointer cache; verify new layout compatibility before code runs |

These are the source-level obligations, not evidence that a cache has been
implemented or proved. Both backing growth and rollback are easy to miss.
Moving only live Nursery objects is O(young live); throughput growth would
add an O(old live) table rewrite on top of its backing copy. An epoch field per
cache entry avoids an eager rewrite only by adding space and a new guard, then
falling back for stale entries. It does not make stale integer addresses safe.

## Validation and paired benchmark plan

First add source-shape tests that prove fixed loads occur before the space
byte, the exact Old branch exists, and the indexed fallback is still emitted.
Then add execution tests with live objects in Old, Nursery, Large, and Tiny.
Check the actual entry space before timing; collection configuration alone
does not prove an object was promoted to Old. Test wrong type, null, i31,
handle-count failure, Free/unknown space, overflowing offset/size, short
handle/header, selected space length, and failed-store payload preservation
through the appropriate existing fixtures. Keep each trap category unchanged.

Use a loop that follows an immutable linked structure through struct.get, or
reads different handles through array.get. A single repeatedly-read object
can hide the load chain through hot cache state and existing address reuse.
Include a simple loop-control benchmark and allocation-free timed regions.
Construct each space fixture outside the timer, force promotion outside the
timer, and retain exact roots. Tiny and Nursery are regression controls.

Existing useful fixtures: `BenchmarkGCStructReferenceRead`,
`BenchmarkGCStructGetInstruction`, `BenchmarkGCStructGetNonFinalInstruction`,
`BenchmarkGCRefCastInstruction`, and `BenchmarkGCResolverCodeSize`. Add a
space-split fixture so an apparent gain cannot come from changing the heap
profile between candidate and control. Reuse the same fixture source on both
revisions. Compile separately from timed execution; no concurrent builds,
benchmarks, or full compiler jobs. Record all durations. Run short alternating
baseline/candidate samples first, then the root's fixed real-compiler input,
output hashes, validation, and main=42 check. Keep the change only on a stable
end-to-end gain with no space-control regression that defeats its value.

## Secondary option: facts across calls

An object's canonical type, array length, and immutable fields do not change
when it moves. A fact attached to an unchanged rooted local can survive an
ordinary internal call while its resolved address cannot. A later read must
reload physical address and extent. This could remove repeated casts, but
requires local version tracking, control-flow joins, exact rooted lifetime,
and invalidation on local writes. It must not reuse a mutable field value or
skip malformed current-header diagnostics. The current final-cast experiment
is already handled separately; no duplicate implementation is proposed here.

## Follow-up implementation and measurement

Root authorized an isolated implementation after this review. It is in
`/home/dev/Projects/wago-gc-old-space-descriptor-pr`, branch
`perf/gc-old-space-descriptor`, based on public PR 948 head `2c53a7838`.
The five read/type emitter bodies above now use the proposed fixed Old loads.
No allocator, pointer cache, layout, ARM64 code, or trap-tail restore changed.

The baseline source overlay fails the new load-order check as intended. The
candidate passes that check, all new selected-descriptor and actual-space
tests, and the focused existing root/codec/type checks. A disassembly pattern
needed to accept objdump's existing `+riz*1` spelling. All build/test commands
were timed and took less than 30 seconds. Full diagnostics are retained under
`.tmp/wago-next-gc-perf/old-descriptor/`.

The dependent-chain fixture has 4,096 nodes, checks every node's space, supplies
exact allocation roots, and performs no timed allocations. CPU 15,
GOMAXPROCS=1, 200 ms, three ABBA repetitions gave six samples per revision and
space (48 total). Median ns/op:

| Space | Control | Candidate | Change |
| --- | ---: | ---: | ---: |
| Old | 4.7965 | 3.5150 | -26.72% |
| Nursery | 4.7825 | 4.9720 | +3.96% |
| Large | 4.8020 | 4.9640 | +3.37% |
| Tiny | 4.7920 | 4.9545 | +3.39% |

This supports the Old load-chain hypothesis and confirms the fallback cost.
It is not a full compiler result. Root owns full qualification against the
separate cast/read fusion before any publication, combined pick, or install.
The benchmark lane was released to root immediately after these samples. No
V8 run was made for this experiment.

## Fallback refinements

The original Old-space experiment is preserved at `f596ee6e6`. A new clean
worktree, `/home/dev/Projects/wago-gc-old-space-refine-pr`, contains two separate
changes: `0a2442b1a` changes fallback stride multiplication to a checked 32-bit
shift; `7ba95e52b` then folds the selected descriptor offset into the two loads.
The selected descriptor remains exact for each space. No guard, register,
frame slot, or metadata field was removed or added.

Both variants pass red/green structural and focused runtime tests. The folded
variant also passes register-check/stats tests. Every build/test command was
timed and remained below 30 s. A quiet, three-way 72-sample comparison used
the same CPU, 200 ms samples, and unchanged four-space chain fixture:

| Space | Original Old path | Shift only | Folded loads |
| --- | ---: | ---: | ---: |
| Old | 3.5100 ns | 3.5125 ns | 3.5115 ns |
| Nursery | 4.9610 ns | 4.6280 ns | 4.4110 ns |
| Large | 4.9615 ns | 4.6385 ns | 4.3975 ns |
| Tiny | 4.9590 ns | 4.6325 ns | 4.3995 ns |

The folded path retains the Old median and lowers the three fallback medians
by 11.09%–11.37% against `f596ee6e6`. All samples remain in the data, including
one 7.661 ns folded Large outlier. The earlier no-fast-path control was not
rerun in this matrix. Recommend folded `7ba95e52b` for the next full compiler
comparison on the cast/read fusion baseline; the isolated result alone does
not authorize a speed claim for the full compiler. All heavy work stopped
immediately after the matrix and the lane returned to root.
