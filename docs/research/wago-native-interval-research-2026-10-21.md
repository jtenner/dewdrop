# Native interval reuse: independent research

Astra and actual Claude Opus5.5 independently inspected the completed combined type-test stack. No cache is implemented or installed. Root asked research only; neither changed code or ran tests. Claude's first read-only run stopped at its30-tool-turn cap after170.929s; raw error_max_turns remains. A tools-disabled resume returned the report in123.562s. Do not classify the interrupted first pass as a completed report.

Both investigations reject a collector-move epoch alone: before-Invoke metadata corruption can remain in the same move epoch. Every Go/native entry and resume must invalidate; cross-instance execution needs a call-tree-wide generation or conservative post-call invalidation. Native allocation and payload writes also matter: malformed cursor/overlap metadata can change a previously checked object header while native code runs. No unused ABI storage was proved.

Astra proposes a shared trap-lifetime ID/sequence for standard AMD64 GC and all native GC writes. Claude instead recommends conservative compiler prologue/post-call/mutation boundaries and notes direct/inline bridge admission still needs proof. A possible alias from corrupted space bases to other storage broadens the theoretical mutation contract further; this is not a closed proof for a production cache. Existing trusted view/backing ownership assumptions must be made explicit rather than silently strengthened.

Root decision: measure and implement a smaller statically bounded read-only deconstruction first. Astra found801source prefixes/1085later same-local/type reads in276functions, but zero already fit the first field extent. Retain address plus validated handle extent, then check each larger handle/header extent at the original read. Stop before calls, GC writes, other objects/types or source-local changes. These are static upper bounds, not admitted sites, cache hit counts, or speed measurements.

The raw Claude report suggests increasing NativeABIVersion. User AGENTS.md overrides this: all unreleased versions/codecs remain1; any implementation must update layout/validation without inventing version2. Other source conclusions below are research evidence and unproved proposals, not repository instructions.

# Closed native interval generation: research report

This is research only. I made no edits and ran no tests or builds. All source is from `.tmp/wago-test-field-qualification`. I make no claim about hit rate or speed.

## Answer

**There is no single runtime entry or resume hook.** A runtime generation that only the Go→native stubs increment is not sufficient across cross-instance calls.

The cheapest universal seam is in the **compiler, not the runtime**. Increment a per-instance interval serial at three places:

- every function prologue
- after every CALL returns
- at every native GC allocation or GC store

Astra's overlap finding makes GC stores interval ends. With that rule, the interval becomes "call-free, allocation-free, GC-store-free region." A static, frame-local reuse of a checked address may be enough in that region, with no ABI change. Measure this before you build a runtime generation.

## Proved from source

1. **Go-side wrappers are not common.**
   - `native_scheduler.go:20-49` wraps `enterNativeRaw` and `resumeNativeRaw`.
   - Callers are spread over many files: `engine.go:186,207,225,540,548,622,630`, `engine_hostbounded.go:68,102,157,177`, `engine_hostmulti.go:50,73`, `prepared_bounded_helper.go:35,57`, `zz_engine_hostfixed.go`, `engine_hostview.go`, `zz_engine_hostfixedview.go`, and `sigtrap_linux_amd64.go:241`.
   - The bounded variants skip `entersyscall`. They still reach the same raw stubs.

2. **The raw amd64 stubs are a closed but plural set.** Each one transfers control into guest code:
   - `trampoline_amd64.s:enterNativeRaw`
   - `resume_amd64.s:resumeNativeRaw`
   - the nine `engine_int_amd64.s` entries (Int, Pair, Wide, Oct, Float, FloatOct, Mixed, IntPreboundContext, IntCall), which do `CALL R11` themselves
   - `inline_host_amd64.s:inlineHostEnterForeign` and `inlineHostResumeForeign`
   - the inline integer and multi variants

   Inline host callbacks run Go (`CALL R9`, line 38) and then resume through `inlineHostResumeForeign`. That path **bypasses `resumeNativeRaw`**. arm64 and TinyGo have separate stubs (`trampoline_tinygo_*.go`, `resume_arm64.s`, `engine_int_arm64.s`).

3. **Some GC fast paths exclude inline hosts.**
   - `prepared_function.go:481` (`tryInvokeScalarHost1`) and `host_execution.go:969,1024` reject `in.gc != nil`.
   - `gcPrepared` requires `NumImports == 0` (`prepared_function.go:279`).
   - **Not proved:** that every inline or direct-int path is closed to GC instances. For example, an instance with an imported or dynamic GC domain can have `in.gc == nil` (`reference_store.go:1314,1455`). Treat these paths as reachable.

4. **The bounded helper runs Go and then resumes.** `CallBoundedHelper` calls `host(...)` and then `resumeNativeBounded` (`prepared_bounded_helper.go:44,57`). This is covered by the resume stub.

5. **The native scalar leaf needs no boundary.** `native_leaf_amd64.go` copies only proven register arithmetic. It has no memory access and no Go code.

6. **Native code writes handle entries and headers.**
   - Struct allocation writes the header at R11 (`gc_direct.go:1906-1913`). It publishes entry offset, size, card slot and space at 1934-1941.
   - Array allocation does the same at 1573-1596.
   - Dead-struct charge stores at 2059.
   - Barrier and card stubs are at 2635 and 2780. Payload stores are `emitDirectGCStructSet:3019` and `emitDirectGCArraySet:3187`.

   So native code **does** mutate handle entries, not only payloads and cards. The premise "native code does not change handle entries" is false for allocation.

7. **There is no proved free ABI space.**
   - Basedata offsets 64–288 are all assigned. `ActualLinMemByteSize64Offset` is 288, and `BasedataSize` is 288 (`abi/basedata.go`).
   - `NativeCollectorView` ends at 200, and `ValidateNativeABI` checks its size.
   - `NativeInstanceView` has a native prefix of 32 bytes, with Go `keepTypes` at offset 32.
   - Any new field is a native ABI change and needs `NativeABIVersion` increased.
   - `RefreshGeneration` (offset 104) is not usable. Allocation and card refreshes increment it, and Astra showed that `ForcePromote` can miss it.

8. **Lock scope.** Host callbacks release all lease domains (`suspendGCInvocation`, `reference_store.go:1460-1490`). Go code in a callback can therefore mutate any collector in the lease, not only the callee's collector.

## Disproof: a runtime stub generation is not enough

Example:

1. Instance A calls instance B natively. Both have collectors in the lease.
2. B calls a host. Go corrupts A's metadata.
3. B resumes through a stub. That stub sees `BX` = B's basedata, so it can only increment B's counter (or the collector reached from B).
4. B returns to A by a native RET. No stub runs.
5. A's cached slot still matches A's generation. This is a false hit.

There are only two runtime fixes:

- **A process-global atomic counter.** This needs `LOCK XADD` on every entry and resume, which can cause cache-line contention between parallel workers. I did not check if Dewdrop's isolated workers are threads or processes.
- **Increment every collector in the lease at each stub.** This is not cheap in asm.

A non-atomic shared counter is **unsafe**: a delayed write can lower the value, so an old generation can appear again.

## Compiler seam (proposed)

Guest code is reached only in two ways:

- at a function entry, through the int stubs, `enterNativeRaw` or tail calls
- at the return address after a CALL, through `resumeNativeRaw` ("RET into wasm after the host CALL") or `inlineHostResumeForeign`

So a per-instance serial needs only three kinds of increment:

- **(a)** in each prologue
- **(b)** after each call returns, including helper, host, import, cross-instance and internal calls
- **(c)** at each native GC allocation or GC store

With this rule, each instance compares only its own serial. No coordination between instances is needed, because Go or foreign code that runs between two reads in A must be behind a call in A.

**Not proved for this seam:**

- exception-handling catch landings (they must also increment)
- whether interrupt or signal paths ever resume guest code other than as an exit
- whether two threads can run native code in the same instance at the same time. Astra noted that a parked callback allows another invocation. Slot updates must stay under the native lease of that instance.
- custom instruction maps (exclude them)
- arm64 and TinyGo

**Residual risk:** if private corruption can set a space `Base` into linear memory, table storage or global storage, then normal Wasm stores can also overwrite a validated header. In that case, all stores must end the interval. Root must decide if this case is in scope. I did not find a check that rejects it.

## Cheapest counter-only prototype

This is diagnostic-only. There is no cache use and no change to guest semantics.

1. Use Astra's family: successful fused final-struct field resolutions. Keep the dense site IDs and the per-instance table. Always run the original resolver. Never dereference a saved address.
2. Add one u64 interval serial in the table header.
3. Emitted code increments the serial at:
   - **(a)** every prologue
   - **(b)** every post-call return point
   - **(c1)** every native GC allocation, publish, card store or payload store
   - **(c2), separate variant:** every linear-memory, table or global store
4. Per site, on a normal resolver return, record ref, address and serial. Count:
   - resolutions
   - same-ref, same-address, same-serial (potential interval hit)
   - same-ref, same-address, different serial (lost to an interval end)
   - same-ref, same-serial, but a different address or a resolver failure (**must be zero**; any nonzero value disproves the design)
5. Count serial increments by kind (prologue, call, allocation, GC store, other store). This shows the instrumentation cost.
6. Use saturating counters with an overflow flag. Read them only when execution is quiescent.
7. Reject codec serialization of instrumented code.

If "same-serial" hits are rare compared to "lost to interval end," then the runtime generation design has little value. A static frame-local reuse inside the same regions should show the same opportunity with no ABI change.

## Blocker, in one sentence

No single runtime hook exists: amd64 alone has at least 13 entry/resume stubs, plus arm64 and TinyGo, and stub-only generations fail across native cross-instance returns, so universality needs the compiler-side post-call/prologue/GC-store increments described above.