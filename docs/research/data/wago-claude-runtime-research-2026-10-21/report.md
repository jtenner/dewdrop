# Wago runtime: larger changes for the Dewdrop compiler job

Date: 2026-10-21. This review was read-only: no edits, builds, tests or timings. I read the installed Wago `61881e2d0` source at `.tmp/wago-local-stack-2026-10-20/wago/src/`, the research notes, the profile data and `compiler.wat`.

Labels:
- **[M]**: measured earlier. Profile numbers come from the older profile, taken before the folding and guard changes.
- **[S]**: static count.
- **[H]**: hypothesis.

## Summary

| Rank | Change | What it removes | First step |
|---|---|---|---|
| 1 | Per-site handle-translation cache, checked by a collector move epoch | Handle-table and descriptor loads for repeated objects, across calls and loops | Verify-only mode with hit counters |
| 2 | Identity compaction at tenure | Scattered free-list, allocation and old-object handle-entry work | Counters for slots to rewrite, then a collector-only flag |
| 3 | Read-leaf inlining through shared stubs | Calls to the hot array and field leaves | Admission counters and a code-size cap |
| 4 | Decision gate: direct references | The handle table on every access | Only after the rank 1–2 counters |

Context: V8 with Liftoff only took 23.956 s and default V8 took 4.0 s [M, not repeated]. Wago takes 37–40 s. So Wago is slower than a V8 tier that has no inlining but uses direct pointers [H]. To reach about 4 s, Wago must cut both the cost of each object access and the repeated work across calls. No single change below is enough.

## Source facts I checked

- **Resolver chain.** Each object resolution walks `[RBX-280]` → instance view → collector view → handle table → handle entry → space byte → space descriptor → object header (`core/compiler/backend/railshot/amd64/gc_direct.go:463–539`, `:574–584`). The hot profile PCs sit on the instructions that wait for the space-byte load and the header load [M].
- **Address reuse today.** There is only one reuse slot, held in a register. It ends at calls and at most control flow (`amd64/gc_resolver.go:5–41`).
- **`RefreshGeneration` cannot prove that objects did not move.** It changes on each Go-side allocation (`core/runtime/gc/native/native_view.go:357–365`; the test `wago/gc_native_view_amd64_test.go:72–80` checks this).
- **`ForcePromote` moves objects outside a collection** (`native/barrier.go:589–616`; checked API at `core/runtime/gc/object_access.go:158`).
- **Inline `struct.new` loads the handle entry of each reference field value** (`gc_direct.go:1818–1830`). In `array_iter_next_option`, the hot `shr eax,0x10` PC (7 samples) sits right after that load [M]. The similar PCs in two `self_host_*` functions are probably the same load [H].
- **Stubs are copied per function and per family** (`gc_direct.go:1032–1142`). Native code is 24,170,715 B [M].
- **Minor GC (old profile):** 4.52 s cumulative (11.83%); `finishSparseMinorEvacuation` 1.74 s flat; `handleEntry.young` 0.73 s flat [M].
- **Allocation trace:** 317,075,456 allocations, 146 minor and 0 major collections. Only 6.97% of handle batches were contiguous [M].
- **WAT counts [S]:** 40,476 `ref.cast (ref N)`, 12,054 `ref.test (ref N)`, 19,481 `struct.new`.

## 1. Per-site handle-translation cache (main recommendation)

**Mechanism**
- Each admitted resolution site gets one slot in a per-instance table: `{handle u32, epoch u32, addr u64, canonicalType u32}`.
- Add a `MoveEpoch` counter to the collector view.
- A probe hits when the compact ref equals `handle` and the slot epoch equals the live epoch.
- On a hit, skip the handle range, entry, space, descriptor, offset and handle-size work. Keep the null, i31, header-type and header-size checks.
- On a miss, run the existing resolver and fill the slot.
- Put the probe inside the existing per-function and shared stubs, before their register pushes. Each site then adds only one slot-offset immediate.

**Examples [S]**
- `array_get_unchecked#16` (WAT 13842–13858) resolves its wrapper (param 0) and the backing array (wrapper field 0) on every call. A caller loop over one array sends the same two handles each time, so both sites can hit.
- `local.get 1; ref.cast 3628; struct.get 3628 9` inside a loop (WAT 181918–181920) also hits.
- The cache key is the handle value, so no dataflow analysis is needed.

**Why this is not one of the held regressions**
- **Type-only facts:** they kept the translation chain. This removes the chain and keeps the cheap type compare.
- **Getter inlining:** this duplicates no resolver bodies.
- **Recycling:** this does not change the collector's handle order.
- **Old preloads:** this adds no per-space branch.
- **Astra's certificate:** this proves nothing across a collection, needs no rooting argument, and keeps the type checks. The two changes can be combined: Astra's removes checks, this one removes translation.

**Source hooks**
- View layout: `native/native_view.go:74–120` and `ValidateNativeABI`.
- Two basedata slots (table pointer and epoch pointer) next to `GCNativeViewPtrOffset` (`core/runtime/abi/basedata.go:96`). Install them at `wago/instantiate.go:1685`.
- Probes in the stubs:
  - `emitModuleGCResolveObjectStub` (`gc_direct.go:443`)
  - `emitNativeFinalCastStructRefResolverStub` (`:2442`)
  - `emitNativeFinalArrayRefGetStub` (`:2355`)
  - `gc_cast_array_get.go`
- Site numbering in `emitNativeFinalCastStructFieldAddress` (`:842`) and `emitDirectGCObjectWithStub` (`:600`).

**Proof obligations**
- **Moves.** Bump `MoveEpoch` on every change to an entry's `off` or `space`, a space `Base` or `Bytes`, or any handle free. That means:
  - `CollectFull` and `CollectMinor` (`collect.go:9`, `:37`)
  - `ForcePromote`
  - `growDefaultNursery`
  - `growBacking` and its rollback
  - `releaseHandle`
  - Tiny frees and Tiny backing growth
  - `Close`

  Do not bump it in `refreshNativeHandles` or `refreshNativeCards`.
- **Roots.** Nothing changes. The table is not a root. A cached address is used only in the epoch where it was filled. A handle can be reused only after a free, and a free bumps the epoch.
- **Calls and host.** Any call is allowed, because the probe checks the epoch again after the lease returns. Host APIs that move objects go through collector methods that bump the epoch.
- **Traps.** Null, i31, wrong type and short extent all go to the old resolver. Trap kinds and trap order stay the same.
- **Metadata.** Canonical type IDs are append-only (`AddTypes`). Version 1 admits final types only.
- **Unsafe and custom code.** Reject functions that have custom instruction maps. Test fixtures that write handle entries or descriptors directly must bump the epoch or run with the cache off. **Root must decide this contract.**
- **Codec.** Slot indices are part of the code layout. Tables start zeroed and the epoch starts at 1. Never serialize table contents.
- **Concurrency.** Confirm that two threads never run one instance at the same time. If they can, use per-thread tables.
- **Wraparound.** Compare the low 32 bits. Clear the table when the low word wraps.

**Rejection cases:** the Tiny profile, foreign `anyref` operands, subtype sites, custom instruction maps, and receiver locals that are assigned inside the innermost loop (one cheap prescan finds these).

**Counters**
- Static: admitted sites and table bytes.
- Dynamic: probes, hits, misses, fills, and epoch bumps (expect about 146 plus growth events).
- Code bytes.
- Exact roots must stay at 25,794 safepoints and 56,923 source calls.

**Benchmarks**
- A loop over one array (should hit).
- Two arrays that alternate at one site (thrash case).
- A walk over distinct objects (all misses; this measures the probe cost).
- A collection or `ForcePromote` inside the loop.
- Then the fixed full job, run as an ABBA series.

**Cost [H]:** about 7 B of code per site, about 60 B per stub body, and 24 B per admitted site per instance (20,000 sites is about 480 KiB).

**Compatibility:** the native view and basedata layouts change. Bump `NativeABIVersion`, so cached artifacts recompile. The public API does not change.

**Smallest first prototype: verify-only mode**
- Run the probe, but always run the full resolver too.
- If a hit address differs from the resolved address, trap with a new diagnostic code.
- Count hits for each site.

This checks on the real job that every move bumps the epoch, and it gives the dynamic hit rate. It changes no result. Turn on the skip only after a run shows zero mismatches.

## 2. Identity compaction at tenure

**Mechanism**
- When a young object is promoted, give it a new dense handle in an old-identity region, in nursery order.
- In the same minor collection, rewrite every slot that refers to it.
- Mark its old young entry as `Forwarded` (space 5) until the next minor collection.
- Young allocation then bumps through a young window and skips the few survivor handles. The young free list goes away.

**What it removes**
- The scattered writes to dead handles in `finishSparseMinorEvacuation` (`collect.go:220`) and in `handleEntry.young`.
- Non-contiguous batches in `reserveNativeHandles` (`native_alloc.go:73`).
- Scattered handle entries for old objects. For example, one site in `self_host_imported_requirement_identity` has 37 samples on the handle-entry load while it walks the list elements [M].
- Stable recycling showed that this kind of locality matters: the full-job median fell by 6.13% [M].

**Why this is not the held recycling change:** stable and canonical recycling only reordered a free list. Their order depended on earlier cycles, and the adverse micro interleaved cohorts. Here the order comes from the design itself: the young window resets each cycle, and old IDs follow promotion order. There is no sort in each cycle.

**Source hooks**
- `markNurseryRef` (`native/mark.go:179`) becomes forward-and-rewrite.
- Promotion: `promoteNursery`, `commitPromotionPlans` and `promoteHandleTo` (`collect.go:329`, `:504`, `:761`).
- Root writes go through `RootSlot.SetRef` (`native/roots.go:21–31`). Native frames use the read-only `DirectRootRefSet` today, so they need a write path.

**Proof obligations**
- **Roots.** Rewrite native frame homes, operand-stack root slots, helper root scratch, globals and tables, public tokens, parked and cross-instance frames, remembered cards, and the fields of promoted objects.
- **Reload.** After each safepoint, read every reference again from its home. Pinned locals already become `lsMem` after calls (`amd64/localstate.go:297`). Audit stack values and the R9–R11 pushes around inline allocation (`gc_direct.go:1688–1708`).
- **Rollback.** Plan all new IDs before the commit point. Write slots only after it.
- **Traps.** A missed rewrite reaches a `Forwarded` entry. The resolvers already reject space > 4 (`gc_direct.go:483–484`), so it traps.
- **Host API.** Rekey any Go map keyed by `Ref` bits. Update checked handle generations and foreign clone.
- **Astra's premise.** "A handle never changes" now holds only between collections. Astra's proof must be updated.
- **Codec.** There is no heap state in the codec, and the native read code does not change.

**Counters:** for each minor collection, record promoted objects, rewritten slots by root class, `Forwarded` hits (must be 0), young-window contiguity, and handle-table page crossings.

**Smallest first prototype**
1. Add diagnostic counters on the real job: promoted objects and the slots that refer to them, by root class.
2. Build a collector-only config flag. Check it with `Verify` and the operations fuzz test.
3. Then run the 2,097,152-identity warm micro and the guest that regressed with canonical recycling.
4. Then run the full job.

**Compatibility:** high. Collector behavior and the root API change. The guest ABI does not change.

## 3. Read-leaf inlining through shared stubs

**Mechanism**
- Add a read-leaf class next to `restrictGCNumericInlineTargets` (`amd64/gc_numeric_inline.go:11`; the gate is at `compile.go:1956`).
- Admit only two-parameter bodies that contain local reads, final casts, struct and array reads, numeric leaves and a trapping `if`. No allocation, store or call.
- Consume one source root mask for each removed call (`consumeGCFrameCallsite`, `call.go:2257`).
- Send the inlined reads to the module-shared stub island (`gc_direct.go:385`). Do not make new per-function stub copies.

**Why it should not repeat the getter regression [H]:** the held getter experiment probably added stub copies to many callers; this was never proven. This version adds no new stub families and has a hard limit on total code bytes. After rank 1, its value is mainly the removed calls.

**Counters:** inlined sites, removed native calls, stub bytes (`addGCSharedStubBytes`), and total code bytes against the limit.

**Compatibility:** none, except the code layout.

## 4. Decision gate: direct references

Only direct references take the handle table off every access. That change touches the `Ref` encoding, every emitter, the write barriers, the collector and host conversion. Decide after ranks 1 and 2 report their counters. If misses on distinct objects still dominate after compaction, plan it then. Do not start with it.

## Other notes

- The referent loads in inline `struct.new` are a small target that you can measure. Measure them first, because the cache miss can simply move to the next read of the same object.
- Do not use `RefreshGeneration` as proof for any cached address.
- None of these changes has a speed estimate. Each one needs the counters above and a matched full-job result first.
