# Fresh whole-GC audit

The user requested a brand-new Astra agent to step back and inspect the complete GC. `/root/astra_gc_system_fresh` was launched with `fork_turns=none` and model `gpt-6-astra`. It first read source, then the supplied profile. It did not use the earlier agents' reports, edit files, run builds/tests/benchmarks, or start other agents.

Primary source: `.tmp/wago-local-stack-2026-10-20/wago`, branch `dewdrop/local-gc-perf-20261020`, commit `073b2f61880e965d3c33ba83e32f72e9391a845d`. This is the installed stack of pushed safety and performance fixes. The separate getter candidate is now private commit `59cc97b8e` on `perf/gc-shared-getter`; it is not installed or published. Its full normal, checked and benchmark-package tests pass. Its kernel gain is 28.85%; its full-job median difference is 0.30%, inside the sample spread. Publication remains held while the wider design is assessed.

## Main conclusion

The problem is broader than collection speed. Stable handles, checked access, reference-call state and ordinary Wasm algorithms all cost time. Local fast paths do not provide a general way to compile a chain of reference reads into one checked region. Astra recommends that capability first. It does not claim the proposal will reach the known 4-second V8 time.

## Whole-system source model

Paths below are relative to the installed Wago source.

| Part | Current design and cost |
|---|---|
| References | `src/core/runtime/gc/native/ref.go`: 32-bit null/i31/stable handle words. Stable IDs survive movement, so normal copying does not rewrite every heap reference. |
| Object storage | `layout.go` has a 16-byte header; `collector.go` has 16-byte handle entries. Small objects therefore pay at least 32 bytes before payload, alignment, ledgers, mark and free-list storage. |
| Access | `amd64/gc_direct.go:emitModuleGCResolveObjectStub` checks tag, handle range, space, backing/object extent and canonical type. Instance view, collector view, handle, space and header form a dependent load chain. Shared code does not remove the chain. |
| Existing reuse | `gc_resolver.go` holds one same-local/type/covered-extent address proof. Ordinary calls and most control boundaries end it. `gc_pure_if.go` and lookahead cover limited inspected shapes. |
| Allocation | `native_alloc.go` and AMD64 allocation code already batch handles/space. Struct batches can reserve 512 handles; small arrays use 32 handles and 4 KiB chunks. Separate large-array state avoids destroying a different reservation. |
| Minor GC | `collect.go:CollectMinor` marks exact roots and remembered edges, copies/promotes survivors, and reclaims dead handles. Survivor age/space policy limits early promotion. Promotion failure must roll back safely. |
| Major GC | Old/large allocation classes support reuse; `major_blocks.go` has occupancy information for sparse sweeping. |
| Cards | `cards.go` tracks old-to-young ranges, validates linked metadata and falls back to whole-object scanning on bad metadata. `survivor.go:finishMinorCardMetadata` retains still-needed cards. |
| Calls/roots | `amd64/call.go:prepareGCFrameCallsite` maps source roots to stack homes. Ordinary calls flush/stage values and spill dirty local pins. Inlining must preserve source-mask order. A raw address is not a compact GC root. |
| Lifetime | `src/wago/prepared_gc.go` holds invocation/domain leases. Native backing pointers can change during helper work. Host re-entry, cross-instance calls, close and borrowed views constrain any cache. |

`NativeABIVersion = 9` is a pre-existing upstream Wago constant. The Dewdrop version-1 format rule must not be used to reset it. This work changes no ABI or codec version.

## Evidence correction and limits

The older profile recorded 79.27% of Go CPU samples in generated code and 12.93% cumulatively in `CollectMinor`. It precedes the last installed fixes; it is not an exact-HEAD measurement. Collector-loop tuning alone cannot credibly remove the whole gap to 4 seconds.

The raw `cpu-top.log` assigns 1.98 seconds flat / 2.24 seconds cumulative to `finishSparseMinorEvacuation`: **dead nursery handle reclamation**, not remembered-card finish. The earlier research note misnamed this cost. Root checked the raw log and corrected `wago-read-followups-profile-2026-10-21.md`. Card work must not be ranked using that number.

Generated code also includes real application searches. The saved Wasm's `intern_function` scans old signatures; `self_host_imported_requirement_identity` scans requirements. `array_get_unchecked` contains a branch, wrapper reads and an array read. These source observations do not establish dynamic cost shares. Dew source algorithm changes would require a new compiler Wasm and a separate comparison.

## Ranked changes for the same pinned Wasm

1. **Compile bounded reference-read regions.** Extend the compiler beyond numeric-only leaf inlining. Admit small read-only, non-allocating bodies with bounded branches and expansion of proved numeric leaves. Preserve dominating address/type/extent facts through the region, with a small fixed proof set and compact roots. Relevant code: `gc_numeric_inline.go`, `inline.go`, `call.go`, `gc_resolver.go`, `gc_direct.go`. This can remove calls and repeated resolution together. Reject the direction if dynamic coverage is small, accesses mostly discover new objects, or code/register pressure consumes the gain.

2. **Use effect and register-clobber summaries for remaining internal calls.** Separate collection, host entry, global/heap writes and physical register clobbers in `call.go`, `localstate.go`, `hints.go` and `compile.go`. A non-collecting callee may still clobber registers or observe dirty globals. Keep source-mask correctness and existing exact maps first. This is useful for hot helpers whose bodies should not be copied.

3. **Use escape analysis and scalar replacement for short-lived objects.** Generalize the narrow reductions in `gc_dead_new.go`, `gc_dead_group.go`, `gc_constructor_if.go`, `gc_struct_reduction.go` and `gc_array_reduction.go`. Remove temporary identity/allocation/read work together. Preserve allocation-failure, collection/accounting and identity behavior, using the existing dead-charge contract where needed. Reject objects whose identities escape into calls, globals or arrays.

4. **Reclaim dead nursery handles by cohort where safe.** `finishSparseMinorEvacuation` and `finishDeadNurseryEvacuation` still visit nursery identities. Fully dead handle runs could be recycled together, with separate survivor handling and a validity/epoch proof. Stable surviving IDs prevent simply clearing/resetting a table. Added validity work on every read can outweigh collection savings. The older profile puts a limited, roughly 2.24-sampled-second ceiling on this component.

5. **Consider compressed object addresses only after measurement.** This could remove handle/space indirection and metadata, but replaces the heap representation. Moving GC must rewrite all references and exact roots; stable public identities need a boundary form. An address range alone is not a liveness/object-start check. A prototype must cover fields, roots, globals/tables, public/foreign tokens, snapshots and host views, with explicit memory measurements. Use this only if dependent resolver loads still dominate after read-region work.

These are ranked source-backed proposals, not measured speedups.

## First experiment and measurement gate

Start with a generic bounded read-region pass: small acyclic bodies containing casts/tests/reads, integer work and branches; bounded expansion of already-proved numeric leaves. Exclude allocation, writes, host/unknown calls and loops initially. Keep the ordinary checked resolver at each first executed access. A later proof may remove a duplicate check; it must not move a failure before an earlier effect or make an untaken branch trap. Array index checks need their own range proof.

Qualification must cover null/type/bounds failures, untaken branches, changed locals, aliasing, returned references, roots at the next collection, malformed metadata, register pressure, code growth and compiler time. The deciding result is a clear full-job gain with the same pinned Wasm, request, output hashes and diagnostics. Static site counts alone are insufficient.

Run diagnostic counting separately from timing. Emit a compile-time candidate site map, then use plain per-instance counters only at selected region entries. Count dynamic calls/resolutions saved. Do not add an atomic increment at every read. At existing transitions/collections, aggregate batch refill reasons, allocated bytes/objects, nursery identities visited, survivors, copied/promoted bytes and root counts; write once at job end.

Also compare user CPU, elapsed time, code bytes, RSS and collection totals. Hardware sampling with generated-code maps can help distinguish resolver loads, call/spill work, allocation and ordinary Wasm. Small wrapper/array, alternating-object, loop-reuse and pointer-chasing kernels expose different limits. A pointer chase that discovers a new object each time cannot benefit from same-address reuse.

## Exact installed-head diagnostic profile

Source: `073b2f61880e965d3c33ba83e32f72e9391a845d`, archived without the held getter or type-fact candidates. The diagnostic build adds Go CPU profiling and native source maps only. It does not add helper or collector counters. Preparation took 9.542 seconds; the Go build took 7.981 seconds.

The full job completed with the fixed compiler/request/output hashes and output `main` result 42. Elapsed time was 35.6085 seconds, user CPU 35.8568 seconds, peak RSS 1,247,076 KiB. This is a **diagnostic run, not a matched latency result**. V8 was not rerun.

Of 35.80 sampled CPU seconds, generated machine code accounts for 28.73 seconds (80.25%). `CollectMinor` accounts for 4.57 cumulative seconds (12.77%). `finishSparseMinorEvacuation` accounts for 1.73 flat / 1.88 cumulative seconds: this is dead nursery handle reclamation. Generated code includes application algorithms as well as GC access code; this profile does not establish which instruction group causes the gap.

The separate leaf-PC probe obtained 1,761 samples, including 1,012 native samples. Native locality counts include array access 100, import identity 67, module implementation indexing 62, interning 47, byte access 44 and shared resolution 36. These are **location samples, not execution counts**. Probe stops total 110.214 ms. One sampling attempt reported `seize:1`; source metadata reported no drops. The sample is not error-free hardware profiling.

Small reports and a manifest for the larger raw profiles are in [the evidence directory](data/wago-fresh-whole-gc-profile-2026-10-21). The diagnostic host SHA-256 is `3905162be7a36b531557dca77105616294ee1ec7d0f7d7d059251d6829d3863d`. The result supports testing bounded read regions; it does not promise a four-second runtime.
