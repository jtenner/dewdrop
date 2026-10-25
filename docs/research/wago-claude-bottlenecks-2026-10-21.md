# Wago/Railshot runtime review for Dewdrop: bottleneck isolation and ranked fixes

Second reviewer (Claude), 2026-10-21. This was read-only: no source edits, builds, tests, benchmarks or compiler runs. I read source on the installed stack worktree (HEAD `69c165ace`), the existing profiles via `go tool pprof`, and `compiler.wat` with bounded parsing.

**Path abbreviations** (relative to `/home/dev/Projects/dewdrop`):
- `A/` = `.tmp/wago-local-stack-2026-10-20/wago/src/core/compiler/backend/railshot/amd64/`
- `N/` = `.tmp/wago-local-stack-2026-10-20/wago/src/core/runtime/gc/native/`
- `W/` = `.tmp/wago-local-stack-2026-10-20/wago/src/wago/`
- `v4` = `.tmp/wago-next-gc-perf/array-profile-v4/`
- `WAT` = `.tmp/wago-v8-target/compiler.wat`

**How to read the evidence:**
- **Static counts** come from the WAT. They are not dynamic counts.
- **Sample shares** come from the v4 diagnostic native sampler: 1,662 native leaf-PC samples, about ±1.1 percentage points standard error at a 30% share. That build includes the unshipped cast+array.get path and excludes the array-length PR.
- **Second-scale numbers** are those shares applied to the ~49.5 s control. They are inference, not measurements.

## Bottom line

1. **About 63% of native time is the checked handle resolver.** Each resolution is a call into a per-function stub, about 45–55 instructions, and a 5–7-deep chain of dependent loads. Samples pile up right after two loads: the handle-entry load `[entry+0xc]` and the object-header load.
2. **Dewdrop's erased `eqref` ABI multiplies resolver calls by roughly 2–4 per logical access.** The repeats sit behind call boundaries, and the existing address certificate dies at every call.
3. **Two things nobody has flagged yet:**
   - **Inlining is turned off for the whole Dewdrop module.** Whenever exact GC frame roots are active, `A/compile.go:1948-1953` clears `inlineTargets`. Even `$lt`, `$add` and pure forwarders are real native calls.
   - **Functions with any reference in their signature never get the register ABI** (`A/call.go:175`). That is 95% of functions.
4. **My estimate: the five findings below together reach roughly 25–37 s, still 7–10× V8.** Getting near V8 additionally needs either typed Wasm emission from Dewdrop or cross-call type propagation. That would be an inlining tier plus facts, which is what V8's Turboshaft does here. This is inference.

## Where the time goes (diagnostic shares × 49.5 s)

| Bucket | Evidence | Share | ≈ s |
|---|---|---|---|
| Native resolver leaves | v4: `gc-struct-ref-get` 557, `gc-type-check` 361, `gc-array-ref-get` 59, shared `gc-resolver` island 68 | 63% of native | ~25 |
| Call/frame glue | unmapped no-site prologue/epilogue 174, `call` 105, `end` 29, `local.set` 15, gp spill/reload 51 | 22.5% of native | ~9 |
| Native allocation | `struct.new` 113, `gc-array-alloc` 27 | 8.4% of native | ~3.4 |
| Other native | | 6% of native | ~2.4 |
| Go: minor GC | `CollectMinor` 5.05/51.45 s (`finishSparseMinorEvacuation` 1.91 s flat) | 9.8% | ~4.9 |
| Go: helper dispatch, compile, other | `cpu.pprof` | ~8.8% | ~4.3 |

**Where the resolver stalls (stub-relative PC histogram, v4 `resolved-samples.json`):**
- `gc-struct-ref-get`: about 157 samples sit on the consumer of the handle-entry metadata load. About 116 sit on the consumer of the object-header load.
- `gc-type-check`: the same pattern, about 159 and about 53.
- My reading: the handle-entry load (an extra dependent miss V8 does not have) is the single largest stall.

## Ranked findings

### F1. Inlining is disabled module-wide under exact GC roots, so every helper, forwarder and getter is a real call

**Evidence**
- **The gate:** `A/compile.go:1948-1953` replaces `inlineTargets` with an empty table if `opts.GCFrameRoots != nil`. The comment says this keeps the Wasm call stream one-to-one with call masks.
- **Confirmed in the profile:** v4 has separate native regions for `gte` (11 samples), `lt` (10) and `add` (6). Bodies of 159 pure int leaves take 2.3% of native samples.
- **Static reach (WAT):**
  - 11,650 of 66,363 call sites go to those 159 pure int leaves.
  - 1,055 of 7,012 functions are pure forwarders (`local.get 0..n-1; call g; end`). They take 21,303 call sites (32%).
  - 3,834 forwarder sites end at an exact getter. Astra's getter inliner sees only 76 direct getter sites.
  - After resolving forwarders, 11,838 sites reach small, loop-free reference bodies: `array_get_unchecked` variants 4,272, `array_length` 3,619.
- **Sampled cost of those bodies:**
  - Forwarder bodies `length#0`, `length#8` and `indexed_get#10`: 3.8% of native.
  - `array_get_unchecked#16`: 9.1%.
  - `array_length#35/#279`: 4.6%.
- **Why every call is expensive:** each call spills all dirty pinned locals (`A/localstate.go:281` `spillLocalsForCall`, which marks them `lsMem`). It also ends the address certificate (`A/gc_resolver.go:19`; `0x10` is not on the allowed list).

**Change: three bounded branches**
- **F1a. Pure-int-leaf inlining under exact roots.**
  - Admit only callees whose body uses numeric, `local.*`, const, `select`, `drop`, `unreachable` and loop-free structured control. No calls, memory, globals, `0xfb` GC ops, atomics or tables.
  - At each inlined site, call `f.consumeGCFrameCallsite()`. This is the same mechanism Astra's getter path uses (`wago-gc-final-getter-pr/.../gc_getter_inline.go:91`).
  - Keep the prepass unchanged. The consumed mask is simply unused.
  - **Invariants:**
    - The inlined body contains no safepoint.
    - Inline locals are numeric and sit after `nLocals` (`A/inline.go:810`), so GC frame local offsets are unchanged.
    - The function end check `gcCallsiteIndex == CallMaskCount()` still holds.
  - **Follow-up:** let `prepareGCResolvedObject` treat a call to such a target as non-invalidating, because it cannot collect.
- **F1b. Forwarder call retargeting** (no inlining).
  - In `callOp` (`A/call.go:336`), before the getter and inline checks, follow at most 4 forwarder hops to a local function.
  - **Requirements:**
    - The forwarder has no declared locals.
    - Its param count equals the number of `local.get`s.
    - Every param and result position has the same machine class and the same `gcFrameRefType`.
    - Stop on cycles and on imports.
  - **Lowering:** use the target's ABI decision. Push results typed with the forwarder's signature. The callsite mask is unchanged because one call stays one call.
  - Tables, `ref.func` and exports still use the forwarder body.
  - Wasm leaves stack depth unspecified; trap backtraces lose one frame.
- **F1c. Readonly ref-leaf inlining** (after Astra's getter PR lands).
  - Generalize the exact-getter matcher to a "readonly GC leaf" class:
    - at most 2 params;
    - ops limited to param reads, final `ref.cast`, `struct.get`/`array.get`/`array.len`, numeric ops, `if/else/unreachable`, and calls only to F1a leaves.
  - This covers `array_get_unchecked`, `get_unchecked` and `bytes_byte_length`. It excludes allocation and reference stores, whose helper fallbacks are safepoints.
  - Consume one mask per eliminated call.
  - **Soundness argument:** bound reference arguments need no root inside the body, because there is no safepoint before they are consumed.

**Tests**
- **Fails on the old code:** a GC module with `struct.new` before and after `call $lt`, compiled with exact roots.
  - Assert the inline stats count is above 0 (currently 0).
  - Assert `Compiled.GCNativeRootAdmission().Exact` (`W/gc_frame_roots.go:197`) with the expected callsite count.
  - Run it in collect-every-allocation mode and check the reference values.
- **F1b:** retarget count above 0. Negative cases: a machine-class mismatch (i64 vs v128), an import target, and the cycle `f→g→f`.

**Measurement**
- Full ABBA run, plus a full-job mechanism counter: the number of inlined and retargeted sites.
- **Expected:** F1a about 1–2 s, F1b about 1–2 s, F1c about 2–3 s. These are inference. The upper bound is the glue bucket plus leaf and forwarder bodies, about 12 s.

**Complexity and memory**
- F1a is about 100 lines of code, F1b about 150, F1c about 400.
- No runtime memory. Code size grows only for F1c.

**Separation from existing branches**
- All three touch `callOp`; Astra's branch does too.
- Land F1a and F1b independently. Rebase onto the getter PR if it lands first; conflicts are trivial.

**Confidence:** high on the mechanism, medium on the magnitude.

### F2. Type proofs die with the address certificate; retain final-type facts per local across calls, allocation and GC

**Evidence (static, WAT)**
- 34,238 `local.get L; ref.cast (ref T)` pairs.
- 19,030 (56%) re-cast the same unmodified local to the same type.
- 13,836 of those repeats (73%) have a call or allocation in between. This is why the address-reuse experiments could not move the full job: their own write-up says "No proof crosses a safepoint".
- 6,026 of the 11,842 `local.get L; ref.test (ref T); if` sites start their then-arm with `local.get L; ref.cast (ref T)`. This is the Option/enum match shape.
- Every hot target is final (2455, 2463, 2464, 2465, 3628, 3610, 3624, 9020, 9021, 9030).

**Examples in the hot code**
- `bytes_byte_at`: stores the cast into `eqref` local 2, then casts it four more times.
- `self_host_index_module_implementations_with_imports`: runs `local.get 1; ref.cast (ref 3628); struct.get 3628 9` on every loop iteration. Param 1 is never written.

**Current code**
- Fused cast+get goes through `tryFuseFinalCastStructGet` (`A/gc_struct.go:737`) → `emitNativeFinalCastStructFieldAddress` (`A/gc_direct.go:831`). That path does an `f.flush()`, a stub call and a full checked resolution every time.
- `ref.test` goes through `emitNativeDefinedTest` (`A/gc_direct.go:807`) and does the same.
- There is no type proof that survives a call.

**Why a type fact is sound across calls and GC, unlike an address**
- The fact is "the object identified by L's handle is a non-null instance of final canonical type T".
- It comes from a successful runtime check, not from validation of the downcast.
- Handles are identities. Collection moves objects and rewrites handle entries, but never changes an object's type.
- A later read of L means L is live at every intervening safepoint. Root masks are liveness-based (`VisitLiveLocals`, `A/call.go:2261`), so the handle stays allocated to the same object.
- Callees cannot write the caller's locals.

**Change**
- **Fact table:** `factType[local]` (0 = none) plus an undo trail per control frame.
- **Sources:**
  - a successful non-null `ref.cast (ref T)` with T final (the code after the cast runs only if it succeeded);
  - the `ref.test (ref T)` then-arm;
  - values with a static non-null final type: `struct.new T`, `struct.get` of a field typed `(ref T)`;
  - `local.set/tee` of a value that carries a fact.
- **Kills:**
  - `setLocal` (`A/driver.go:1263`, which already calls `invalidateGCLoadFactsForLocal`);
  - `else`, `catch` and `end` restore the construct-entry snapshot, minus every local assigned inside the construct (accumulated while compiling it);
  - at `loop` entry, keep only facts for locals with **no remaining textual assignments**, meaning seen-sets equals total-sets. Total-sets is one linear prescan count per local, cheaply added to the hint scan at `A/compile.go:2849`.
- **Why that covers backedges:** the loop rule is the one place a single-pass compiler needs lookahead. With no remaining writes ahead, a backedge cannot change L.
- **Inlined bodies:** callee locals enter through `setLocal` (`A/inline.go:1085-1098`), so their facts are killed automatically.
- **Uses:**
  - (a) a non-fused `ref.cast (ref T)` on L with a fact is a no-op that keeps provenance;
  - (b) `ref.test (ref T)` becomes constant 1; constant 0 only for canonical-distinct finals;
  - (c) fused cast+get becomes a proven-object read with no foreign/null/i31/local-type/type/extent checks and no flush. It keeps the physical handle-range, space and bounds checks, matching the existing `arrayOperand` policy (`A/gc_direct.go:430-437`). It also becomes eligible for the existing one-entry certificate (`A/gc_direct.go:587`).
- **Extension (the loop-hoisting case):** immutable-field value facts. For L with fact T and an immutable field i, the loaded child handle can be reused for the rest of the activation.
  - It is sound across GC because the child stays reachable from L's rooted object and handles are stable.
  - This turns the `struct.get 3628 9` inside the loop into a single stack-slot load.

**Tests**
- **Fails on the old code:** cast, then a call that allocates, then cast again on a param. Expect 1 checked and 1 proven resolution (currently 2 checked).
- **Runtime negatives:**
  - reassignment inside the loop after the header: the second iteration must trap;
  - a fact from a non-dominating if-arm;
  - the false arm of `ref.test`;
  - a nullable cast (no fact in v1);
  - a throw after an assignment inside `try`;
  - collect-every-allocation and Tiny collectors.
- **Microbenchmark:** a repeated cast across an allocating call.
- **Full job:** a counter of elided casts and proven reads.

**Expected**
- About 3–6 s. That assumes ~50% of resolver work is provable and saves 40–60% of each proven resolution, minus latency-bound chains. Inference.

**Complexity and memory**
- 500–700 lines of code. O(n) compile time. No runtime memory. Native code shrinks.

**Separation:** new file `gc_type_facts.go`, plus hooks in `emitGCI31Cast`/`emitGCI31Test` (`A/gc_struct.go:635`/`535`), `setLocal` and `pushCtrl`. Do not build on the `cast-load-fusion` or `vector-array` working trees.

**Confidence:** high on soundness as specified, medium on magnitude.

**Follow-up (F2b): generation-validated address certificates for proven locals**
- After a call that may allocate, re-validate a cached address with `NativeCollectorView.RefreshGeneration` (`N/native_view.go:81`, offset 104).
- It is bumped by `refreshNativeView` (every collection and every backing change), card refreshes and handle refreshes (`N/native_view.go:300`, `:357`).
- That makes it conservative but sound for "an object may have moved".
- If the refill-driven bumps over-invalidate, add a dedicated move generation.

### F3. Sparse minor evacuation scrambles handle IDs, destroying handle-table locality for allocation, resolvers and GC

**Evidence**
- **The swap:** `finishSparseMinorEvacuation` (`N/collect.go:222`) bulk-appends nursery handles to the free list. It then fills each survivor slot with the current last element (`N/collect.go:252`).
- **The tail pop:** `reserveNativeHandles` pops the free-list tail in reverse (`N/native_alloc.go:97`).
- **The compounding:** each cycle injects about one far handle per survivor. Over about 135 minor cycles (270M allocations in a 64 MiB nursery), the young-handle order trends toward a permutation. That is inference; no order counter exists yet.
- **The hot lines:** in `finishSparseMinorEvacuation`, 1.29 s sits on `e.space == spaceNursery && e.cardSlot == 0` and 0.42 s on `c.mark[h]`. That is about 4.8 ns per handle on a loop that would stream if the order were monotone.
- **Table size:** about 52 MB of handle table in use (≈3.2M × 16 B), against the 8845HS's 16 MB L3.
- **The native allocator touches every entry:** it reads the entry at metadata offset +12 and writes all 16 bytes (`A/gc_direct.go:1909-1916`).
- **The resolver's largest stall** is on that same entry load.

**Change**
- Replace swap-from-end with order-preserving compaction:
  - walk the nursery in order;
  - append each dead nursery handle (set `spaceFree`) to `freeHandles` in order;
  - call `free(h)` for dead young non-nursery handles (it appends once, so no trim);
  - compact survivors in place to the front.
- Same O(n) cost; the existing bulk copy becomes sequential appends.
- Apply the same fix to the exceptional-entry swap in `finishDeadNurseryEvacuation` (`N/collect.go:297`).
- **Invariants:**
  - every dead nursery identity appears exactly once in `freeHandles`;
  - survivors keep relative order;
  - marks are cleared;
  - `nurseryBump` and `survivorFrom` updates are unchanged;
  - the `PoisonFreed` and non-fast paths are untouched.

**Tests**
- **Fails on the old code:** after K sparse cycles with a fixed survivor pattern, a reserved batch is monotone except at survivor holes. On the old code, breaks grow with the number of survivors.
- Existing `Verify` and free-list invariants must still pass.

**Benchmarks**
- Sparse evacuation with 2M handles after 50 warm cycles (ns per handle).
- Allocate, then traverse a list across cycles.

**Next measurement (before the A/B):**
- Add a diagnostic per-minor-GC "order breaks" counter to the full job.
- That sets the ceiling: about 1.4 s of evacuation, plus an uncertain 0.5–4 s of allocator and resolver misses.

**Complexity and memory:** about 40 lines of code, zero memory.

**Separation:** touches only `collect.go` finish paths. The promotion-bucket PR edits `promoteNursery`, so there is no overlap.

**Confidence:** high on the mechanism, low-to-medium on magnitude until the counter exists.

### F4. Reference signatures never get the register ABI: 6,667 of 7,012 functions use the memory wrapper ABI

**Evidence**
- **Gates:** `sigFitsRegABI` rejects any non-int/float param or result (`A/call.go:175`). The function-level decision is at `A/compile.go:3798`.
- **Per call, the caller pays** (`emitWrapperCall`, `A/call.go:3756`):
  - a full `flushWrapper`;
  - `storePinnedGlobals` and `storeModuleGlobals`;
  - `spillLocalsForCall`;
  - args and results passed through frame memory;
  - `derivePinnedGlobals` after the call.
- **Per entry, the callee pays** (`prologue`, `A/compile.go:4701`):
  - a full frame header and a results-pointer store;
  - stack-fence and interrupt checks;
  - args loaded from `[RDI]`;
  - eager zeroing of declared locals. Entry-init elision is disabled when a GC plan exists.
  - global derivation.
- **No compact frame header:** `compactFrameHeader = regABI && ...`.
- **Inliner exclusion:** `regABIIntOnly` (`A/inline.go:277`) is why reference functions are excluded from inlining even outside the F1 gate.

**Change: narrowest step**
- Classify one-slot reference params, and a single reference result, as GP for **direct internal calls only**, reusing `sigFitsTypedReferenceRegABI` (`A/call.go:288`).
- Keep host adapters, `call_indirect` and `call_ref` on their current paths at first.
- **Root invariant:** reference params are callee locals already listed in the callee's GC plan (`W/gc_frame_roots_linux_amd64.go:117-131`). Pinned reference params are written to frame homes by `spillLocalsForCall` before any callsite, and `materializeGCFrameLocalsAt` handles safepoints.
- **Result invariant:** a reference result in RAX is rooted by `setStackGCRoot` exactly as today.

**Tests**
- GC stress with reference params across allocating callees.
- Exact admission unchanged.
- Mixed direct and indirect callers of the same function.

**Expected:** about 2–4 s from the remaining glue after F1. Inference.

**Complexity:** high (ABI-wide).

**Confidence:** medium.

**Sequencing:** do this after F1, which removes many of these calls outright.

### F5. Shorten the checked resolver's critical path without removing any checks

**Evidence:** the emitters `emitModuleGCResolveObjectStub` (`A/gc_direct.go:438`), `emitCheckedGCObject` (`:667`) and `emitNativeFinalCastStructRefResolverStub` (`:2437`) all walk the same chain:
1. `[rbx-view]` → instance view
2. collector view
3. handles base
4. entry metadata
5. a 5-op space decode (`shr`, `and`, `test`, `cmp`, `imul`, `lea`/`add`)
6. space base
7. object header

**Changes, each separately measurable**
- **(a) Collector-view pointer in a fixed basedata slot.** It is instance-immutable, so this removes one dependent load from every resolver and allocation.
- **(b) Shorter space decode.** Use `movzx r, byte [entry+14]` (`NativeHandleSpaceOffset`), a single unsigned `(space-1) > 3` check, and `shl 4` with SIB addressing. That removes about 6 instructions and about 4 cycles from the chain.
- **(c) Stable handle-table reservation.** Back the table with an mmap reservation instead of `slices.Grow` (`N/native_alloc.go:81`). Handle entries hold no Go pointers. The base pointer then never moves and can live in basedata, removing two more chain levels.
  - **Memory:** alloc-space shows 256 MB cumulative `slices.Grow[handleEntry]` against 52 MB live.
  - **Invariants:** the `ValidateNativeABI` offsets change, so bump `NativeABIVersion`. `HandleCount` is still reloaded for the range check.

**Tests**
- Existing hardening and malformed-handle tests unchanged.
- ABI validation with the new offsets.

**Expected:** about 2–5 s across all remaining resolutions. Inference.

**Sequencing:** after the array-length PR, which touches `native_view.go`.

**Confidence:** medium.

## Does the gap need one particular transformation?

Yes, in two parts. Both are inference from the data above.

- **Typed direct access with retained proofs:** F2, then F2b. This targets the 63% resolver bucket.
- **Call-boundary elimination:** F1, then F4. Calls are what kill every proof and certificate today.

Loop hoisting falls out of F2 as a special case (never-written params plus immutable-field facts). Escape analysis or scalar replacement (Option boxes `struct.new 2455` in `array_iter_next_option`) only becomes possible after F1c inlining. With allocation at about 8% of native plus about 10% minor GC, it ranks later.

**Narrowest first step:** F1a, roughly a day of work. It is fail-closed: a count mismatch shows up as a non-exact `GCNativeRootAdmission`. It removes call boundaries from every loop header (`call $lt`) and enables the rest.

## Challenges to the current direction

1. **Astra's plan says "type facts across nonallocating operations".** That is too narrow: 73% of repeats cross calls or allocation. With handles, a type fact (not an address) is sound across both, and that is where the win is.
2. **The getter-wrapper work reaches only 76 direct sites.** It reaches 3,834 sites once forwarders are retargeted (F1b). Sequence F1b with it.
3. **The rejected cast+array.get fusion (77 s) should be re-tested before it is written off.** Its RSS (1.17 GB) matches the controls, so I don't think it lost exact roots. The regression is still unexplained. F2 subsumes it anyway, because a cast establishes a fact on the stack value.
4. **Dewdrop's emitter erases types. This is probably the biggest single lever, and it costs V8 nothing.**
   - Every reference local, param and result is emitted as `eqref`: `self_host/compiler/starshine_local_declarations.dew:44`; `self_host/compiler/starshine_module.dew:301-307` and `:17965-17971`.
   - Array storage is also erased: type 2464 field 0 is `(mut eqref)`, so it is re-cast to 9021 on every element read. Option payloads are `eqref` too.
   - Dewdrop already emits nominal field types when it knows them (`starshine_module.dew:14701`).
   - **Suggested pilot:** one struct type per Array backing array, plus typed params in monomorphized stdlib functions. Count dynamic casts before and after.

## Process guards (cheap; prevent misattributed results)

- **Record root admission in every full run.** In `docs/research/data/wago-local-perf-2026-10-20/measure.py` `full()`, add `GCNativeRootAdmission` (Exact, Safepoints, Callsites) and minor/full collection counts to the identity JSON. Fail the run if Exact drops. Admission is module-wide (`W/gc_frame_roots.go:252`): one non-exact function disables native-frame collection for the whole module.
- **Require a full-job mechanism counter in each PR.** Elided casts, inlined or retargeted calls, order breaks: proof the mechanism actually fired in the real job, not just in a microbenchmark.

## Memory (second priority)

- Wago peak RSS is 1.02–1.15 GB against V8's 0.49–0.50 GB.
- **Visible contributors:**
  - heap backing: `makeAlignedBytes` 242 MB in use, 315 MB cumulative;
  - handle table: 52 MB live, 256 MB growth churn (F5c addresses this);
  - `freeHandles`: about 10 MB;
  - codegen: about 176 MB of cumulative compile allocations.
- F2 shrinks native code; F1c grows it, bounded by the readonly-leaf class.

## Not verified

- No dynamic counts exist for cast repeats, forwarder calls or int-leaf calls; all reach numbers are static.
- Sample shares come from the v4 diagnostic build.
- The handle-scrambling magnitude needs the counter proposed in F3.
- The stall attribution assumes the sampled PC lands on the consumer of a stalled load.
