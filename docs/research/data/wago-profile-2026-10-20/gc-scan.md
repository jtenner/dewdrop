# Wago GC source scan, 2026-10-20

This is a source-based map, not a measured cause or a claim of speed gain. No builds or tests were run for this scan. The source is the pinned, patched tree at `/home/dev/Projects/dewdrop/.tmp/wago-transform-host/build-y_uuvb8q/wago`. The host source is its sibling `host` directory. Line numbers below refer to that tree. The other Wago checkout was not changed.

## Main result

Wago already has most of the GC counters needed. Enable them only in a separate diagnostic build, with `wago_gcstats` and a non-nil `GCConfig.Telemetry` recorder. They can show collection time, root work, copying, remembered-card work, allocation paths, and native handle refills. They cannot alone split the full guest-to-Go transition cost from checked helper work or guest native work.

The clearest missing probes are an overall internal-GC helper count and time, by helper ID and heap; a root-frame/callsite-comparison counter; and time spent in native execution versus time spent handling a host trap. Start with counts. Add sampled timing only where the CPU profile points. Per-call clock reads can bias a short helper path.

## Guest-to-Go path

- `src/core/runtime/hostcall_amd64.go:12-19` describes the protocol. Native code saves its state in an off-heap control frame, returns through the trap path, then resumes after Go handles the call. The machine-code stub is at lines 75-89.
- `src/core/runtime/engine.go:509-564` is the ordinary host trap loop. It calls `enterNative` or `resumeNative`, reads the active control frame, decodes argument counts, and copies ordinary call arguments. There are other specialized loops; instrument the loop used by the measured call, not just this one. Find them with `rg -n 'case tc == hostCallPending' src/core/runtime`.
- `src/wago/host_execution.go:200-218` handles the internal GC dispatch bit. It keeps the native execution lease and calls the GC helper directly. It does **not** pay the normal host-call release/reacquire protocol on each GC opcode.
- Normal host calls publish parked roots and host arguments first (`host_execution.go:230-255`), then release a local or global native lock (`257-271`). Thus time under `hostLoopActivation.dispatch` can include GC helper work, root preparation, host work, and lock work. Do not label all of it GC.

## Checked helpers and locks

- Every array helper calls `in.lockGCCollector()` (`src/wago/gc_array_helper.go:68-82`). Struct helpers do the same except the function-reference type test (`gc_struct_helper.go:79-99`).
- `src/wago/reference_store.go:919-937` takes the reference-store mutex, searches the heap-domain list, releases the store mutex, then takes the matched domain mutex. Private isolated workers normally have no shared domain entry, so the domain lock is absent; the store lookup still runs. Do not infer cross-worker contention from a high total lock count.
- Every may-allocate helper cancels any native allocation batch, gets the public GC state, locks it, and publishes frame roots (`gc_array_helper.go:77-82`, `gc_struct_helper.go:91-99`). The same branch also covers allocation-check helper IDs (`gc_struct_helper.go:54-64`). This work can occur even when no collection starts.
- `src/wago/gc_frame_roots_runtime_linux_amd64.go:25-66` validates root metadata, saved stack address, offsets, and compact reference values on each such helper. Lines 36 and 45-55 scan current-frame offsets before the collector uses the root set. The later scan of caller frames occurs only if roots are enumerated.
- Safepoint lookup is already constant time for dense compiler IDs, with a binary-search fallback for sparse IDs (`src/wago/code_mapping.go:436-461`). Do not treat it as a linear lookup.
- Native entry uses a private lock when the instance has independent execution; otherwise it can use the global lock (`src/wago/instance_native_context.go:180-208`, `303-318`). Record the selected path before making a lock-contention claim.

## Root scan work to test

- `src/wago/reference_store.go:628-707` walks the current frame and each caller. It visits each live offset, reads the return address, checks adapter returns, then finds the next caller map.
- The caller-map search is linear over all `callsites` for every caller frame (`reference_store.go:691-699`). Adapter-return search is also linear (`680-684`). This gives a possible cost that grows with call depth and total static call sites, beyond the number of live root slots. A frame count and a callsite-comparison count can confirm this without changing semantics.
- A foreign return address can cause a store lock plus scan of same-domain instances (`reference_store.go:663-677`, `1249-1263`). Separate foreign transitions from ordinary local frames.
- Before collection, generic global slots are synchronized once for the parked allocation attempt (`reference_store.go:422-432`). This flag is set again by the next helper. It does not synchronize every root twice during a minor-plus-full retry.
- Persistent roots can scan all same-domain instances, their globals, and tables under the store mutex (`reference_store.go:1184-1246`). Count instances, scanned global cells, and table slots if this path is hot.
- Normal host activation lookup also scans all call sites and may repeat that lookup over a bounded 512-byte wrapper area (`src/wago/gc_host_activation_linux_amd64.go:41-76`). This is outside the internal GC-helper branch. Measure it if a normal host call path is hot.
- A full collection at every invocation is **not** the general rule here. `src/wago/gc_array_globals.go:289-298` skips the boundary fallback when exact native roots exist and allocation-time collection is enabled.

## Existing telemetry

- Build gate: `src/core/runtime/gc/native/telemetry_build_enabled.go:1-5` and `telemetry_build_disabled.go:1-5`. Runtime gate: `collector.go:297-298`. A tagged build with a nil recorder stays on the no-telemetry path.
- Public APIs: `src/wago/gc_telemetry_api.go:7-29` has `GCTelemetrySnapshot()` and `ResetGCTelemetry()`. Snapshot/reset take the host-access native lock and collector-domain lock. Call them at quiescent phase boundaries, not repeatedly in the measured loop.
- `src/core/runtime/gc/native/telemetry.go:35-74` gives additive root, persistent-root, native-frame, marking/tracing, copy, sweep, and cleanup phase times; root counts and times are split by source.
- `telemetry.go:77-137` gives object/slot/payload visits, swept bytes, nursery allocations, survival, promotion/copy, remembered-card work, collection counts, and pause summaries.
- `telemetry.go:168-179` gives Go allocation paths, native fast allocations, handle refills, nursery exhaustion, backing growth, and copied backing bytes. Native fast allocations are derived from total allocations minus Go allocation paths (`telemetry_collector.go:75-81`). They are not direct instruction counts.
- `src/wago/gc_helper_stats_api.go:5-57` gives synchronous helper totals split into allocation and mutation families. `SetGCHelperStatsTracking(true)` selects **one collector for the whole process** and starts fresh counts. This cannot count the parent and two child heaps at once.
- The enabled helper recorder uses atomics and, for reference mutation, extra diagnostic object/card checks (`src/wago/gc_helper_tracking_enabled.go:39-108`). It changes the cost of the measured path. Count results are useful; compare elapsed time only with a matched control build/run.
- Static generated-code byte attribution is available with `WithGCCodeTelemetry(true)` on fresh compilation, then `Compiled.GCNativeCodeTelemetry()` (`src/wago/config.go:424-429`, `src/wago/api.go:4078-4091`). A codec-loaded module has no synthetic attribution. This measures code size, not executed native instructions.

## Telemetry timing limits

- Collection `TotalNS` starts after telemetry scans of nursery handles and root cards (`src/core/runtime/gc/native/telemetry_collector.go:10-38`). It stops before a managed-heap accounting scan (`53-66`; the scan is at `136-159`). Those are diagnostic costs outside `TotalNS`.
- Verify-after-collect checks are explicitly suspended from collection timing (`src/core/runtime/gc/native/collect.go:55-60`, `77-83`, `199-204`). Capture GC config, especially stress and verification settings, with every profile.
- Tagged runs include clock reads and object/phase accounting. Use an ordinary build for the main runtime result; use the tagged build to explain the work.
- Sum collection times only for sequential work. With two workers, per-heap GC time can overlap. It is thread work and cannot be subtracted directly from process wall time.
- Do not call `wall time - GC TotalNS` guest compute time. That remainder contains helpers, transitions, host calls, Go GC, waits, and diagnostic work.

## Isolated worker heaps

- `src/wago/managed_instances.go:192-196` gives the intended private-heap contract. At `253-266`, the fork copies the caller GC config, creates a private reference store, and instantiates from the same compiled module.
- The copied GC config also copies the telemetry pointer. The collector contract forbids one recorder attached to multiple active collectors (`src/core/runtime/gc/native/collector.go:35-40`). A diagnostic host must give each new child a distinct recorder (or observe one heap in a serial control run). Do not simply enable one parent recorder and run parallel forks.
- The pinned source test checks that each fork has a private collector/store and independent native execution (`src/wago/managed_isolated_fork_amd64_test.go:27-37`). This scan did not run the test.
- `host/workers.go:269-296` creates fresh children for each worker batch. Lines 304-325 execute jobs on each child in order and reuse the child for that batch. Fork/init and close time must be separate from worker compute time.
- Only copied bytes pass between heaps. `host/workers.go:190-244` checks GC array storage and copies bytes; lines 212 and 242 do the copies. Count input/output bytes if these host paths are hot. The shared plugin mutex protects job slots and result accounting (`307-324`); it is not held across `InvokeContext` at line 311.

## Smallest useful diagnostic set

1. At load, save the exact binary/build identity, build tags, full GC config, root-map callsite count, safepoint count, and whether each instance has independent execution. Keep setup, guest compile phases, worker fork/init, worker compute, and output writes separate.
2. Per heap, collect existing minor/full `TotalNS`, phase times, root counts, object/slot scans, allocations, copied/promoted bytes, refills, and nursery exhaustion at each compiler phase boundary. Take snapshots after the work stops.
3. Per heap and helper ID, record calls and optionally sampled total handler time at `host_execution.go:210-211`. Record allocation-check helper IDs separately. The difference between handler time and collection time is only an upper bound on checks/allocations/locks; it excludes native stub/loop overhead and includes diagnostic overhead.
4. If root enumeration is high, count caller frames, live slots, callsite comparisons, foreign-owner searches, and host wrapper candidates at the sites above. These counts can show whether large static maps, deep stacks, or live data cause the cost.
5. If transition/checked-helper work is high, bracket the used engine trap-loop intervals and inspect native sample PCs. Time inside `enterNative`/`resumeNative` includes native compute plus the native stub needed to return; time outside includes Go trap decoding/dispatch/result copy. Use this as a bounded split, not an exact instruction-level split.

No counter or optimization was added by this scan. The CPU profile must select the next step. In particular, do not change Dewdrop type layouts, root liveness, heap sizes, or GC assertions until measured samples and work counts identify the cost.

## Follow-up from the complete serial CPU profile

The parent agent supplied this profile summary: successful run 95.86 s; guest invocation 93.696 s; Wago native compile 1.06 s; instantiate 1.03 s. Of 98.14 sampled CPU seconds, `_ExternalCode` has 49.15 s flat, `newHandle` has 6.70 s flat, and `handleEntry.young` has 5.88 s flat. Cumulative internal GC helper time is 34.05 s, allocation 12.26 s, native struct preparation 7.00 s, handle reservation 7.25 s, and minor collection 10.86 s. These totals overlap. They must not be added. This scan has not independently re-read the binary profile.

### Strongest measured lead: native handle batch use

`src/core/runtime/gc/native/native_alloc.go:49-86` reserves 32 identities on every refill. It calls `newHandle(handleEntry{})` 32 times and appends all of them to the nursery list. At most three slice backing arrays may grow first (`55-61`), then a 32-entry contiguity check runs (`70-80`).

`src/core/runtime/gc/native/alloc.go:205-230` shows that `newHandle` has no full-heap scan. It pops a free identity and writes a 20-byte entry, or appends handle/mark/color metadata. When checked handles are active, it also checks and increments a generation. A high self cost here can be a high call count rather than one expensive search.

Every may-allocate helper cancels the current batch before its Go allocation (`gc_struct_helper.go:91-99`, `gc_array_helper.go:77-82`). A successful eligible initialized-struct helper then prepares a new batch (`gc_struct_helper.go:254-259`). `prepareNativeStructHandles` checks immutable type/field eligibility on each call (`gc_native_alloc_amd64.go:13-47`) and `PrepareNativeStructAllocation` refills when the prior batch is empty or uses an array chunk (`native_alloc.go:92-102`).

Thus a sequence of an eligible struct helper followed by a helper-only constructor can repeatedly reserve and cancel most or all of 32 identities. The source proves the mechanism; the profile does not yet prove this sequence is frequent. It is the first batch-use hypothesis to test because refill and `newHandle` already have measured cost.

The minimal counters are:

- Number of batches reserved (already `HandleRefills`).
- Sum of `Cursor` on batch discard; this is the number of reserved handles consumed natively.
- Sum of `Count-Cursor` on discard; this is reserved work returned unused. Also record a small cursor histogram (0, 1, 2-7, 8-15, 16-31, 32).
- Discard reason: before an allocation helper, collection, explicit preparation, or close. A tiny helper-ID counter at the pre-allocation cancellation site shows which constructor interrupts useful batches.
- `newHandle` calls split into native reservation and ordinary object allocation, and reused versus grown identities. Capture checked-handle state.
- Fallback `compactNurseryHandles` calls and total input entries at `native_alloc.go:247-251`. The normal canceled-batch trim is bounded to 32 entries (`227-245`); the fallback scans the full young list (`collect.go:818-852`). Do not assume the fallback is frequent without its count.

Use plain per-collector integers while the existing execution/heap lease is held. Do not add more global atomic writes to this hot diagnostic path unless access outside that lease requires them. Report counts before testing a different batch size or lazy/adaptive refill. Reducing the batch can save refill work but increase transition count; no gain is established yet.

`handleEntry.young` is only two space tests plus a flag test (`src/core/runtime/gc/native/survivor.go:17-18`). A high flat sample count does not identify its cause. It can be called from collection, remembered barriers, handle compaction, or other live-handle scans. The profile needs its inline caller/line attribution before selecting an optimization. Do not change this predicate from its top-row cost alone.

### Native half of CPU: newer profiler reuse limits

Read-only source inspected in `/home/dev/Projects/wago`:

- `src/wago/profile.go:59-70` creates a bounded metadata journal and attaches it with `WithCodeProfile`; it does not start a sampler. The build tag is `wago_profile`.
- `profile.go:80-109`, `112-131`, and `183-200` register and retire executable mapping generations and host-thunk regions. Exact mapping base, byte size, load/retire time, and code identity matter when addresses can be reused.
- `src/wago/profile_compile.go:15-80` requires compiler-finalized region metadata, with optional source/site/unwind information. Attaching after an unobserved compile reports the entire body as unknown (`profile.go:134-179`).
- `internal/profcapture/perf_linux.go:108-117` uses a native `perf record` sampler with `cpu-clock:u` and a monotonic clock. `internal/profcapture/capture.go:423-427` states that its Go pprof backend cannot give qualified guest PCs or guest call chains.
- `profile/export.go:48-49` provides a perf-map writer; `profile/samples.go:130-133` resolves native samples against mapping events; `profile/pprof.go:11-15` exports the resolved leaf samples. These are separate from the Wago metadata journal.

The complete newer profiler is a broad backport: compiler region production, compiled-code cache ownership, runtime mapping events, journal, native collector, and report tools. The smallest first diagnostic is a native leaf-PC sample run plus exact final function regions and mapping base/generation/identity. Source maps, unwind rules, and invocation spans can follow only if needed.

The pinned `Compiled.Entry`/`InternalEntry` arrays (`src/wago/globals.go:1013-1026`) give entry starts, not exact final function region ends or shared/literal boundaries. `InternalEntry` also carries compile-only flag bits that require decoding (`globals.go:1133-1154`). Do not infer exact body bounds from these arrays without backend evidence.

A perf map added after the fact cannot recover guest addresses already collapsed into `_ExternalCode` by the current Go CPU profile. A new native sample run is needed to split the measured 49.15 s into guest functions, native GC paths, and transition stubs. Host permission or collector support can block that run; the source journal alone cannot solve it.
