# Transform and parallel work speed inventory

Read-only source scan, 2026-10-20. No builds, tests, or new timing runs. Claude usage is exhausted until 2026-10-24; no Claude run was made. These are measured baseline results and source-based improvement candidates, not measured gains.

## Existing evidence and rules to keep

Saved results: `docs/research/data/transform-workers-2026-10-20/small-heap.json` and `large-heap.json`.

| GC heap / nursery | Serial seconds | Two-worker seconds | Serial peak RSS KiB | Two-worker peak RSS KiB |
| --- | ---: | ---: | ---: | ---: |
| 512 MiB / 64 MiB | 93.303 | 169.750 | 1,340,032 | 2,217,528 |
| 2 GiB / 512 MiB | 92.427 | 135.474 | 3,260,208 | 8,061,880 |

The output and cache hashes match in both modes. Each mode has one cold process on a shared AMD64 host. Each uses a fresh `WAGO_HOME`, so it includes native compilation of the compiler. This does not isolate transform CPU, a retained heap, or the cause of the full time difference. There is no native ARM64 evidence. Do not divide these times by application count to estimate interpreter cost.

Workers already run at the same time. They reuse compiled code. They have private reference stores, collectors, and execution locks. They are off by default. Keep these facts; adding more goroutines alone does not fix the main costs. See `tools/wago-transform-host/workers.go:247`, `tools/wago-transform-host/patches/managed-isolated-fork.patch:11`, and `tools/wago-transform-host/README.md:93`.

Keep copied byte messages across instances; scoped GC views; one job at a time per child; no nested workers; source-order results and errors; deadline and caller cancellation; close plus wait on all children; payload bounds; exact site/header/report checks; serial replay for imports, declarations, and signature changes. Keep compiler/API identities in caches. Cache publication must follow final source/link checks and a successful output write (`self_host/compiler/transform_cache.dew:30`, `self_host/compiler/main.dew:408`).

Each annotation clears globals and initialization flags, resets work/allocation counts, and drops scratch memory (`self_host/compiler/transform_expand.dew:317`). Shared bytecode is not permission to share these values. Environment snapshots already use copy on write; binding cells stay shared for closures (`self_host/compiler/transform_environment.dew:1`). Source indexes and negative bytecode results already have caches. Preserve their semantics.

## Ranked candidates

### 1. P0: Prepare one checked plan per child and source snapshot

**Source:** `self_host/compiler/transform_workers.dew:116`, `:123`, `:126`; `self_host/compiler/transform_validation.dew:93`, `:98`, `:112`, `:121`, `:155`.

**Cost:** Each application decodes the same full snapshot, scans and parses all files, collects the validation program, resolves interfaces, infers and lowers it, collects proofs, then runs the original-body reflection pass. The parent has already checked the plan before it sets `worker_ready`. Thus N applications add N full checked preparations. Two workers split this added work; they do not remove it.

**Change:** Send a prepare operation once to each child, then small application-site jobs. Retain a checked plan in that child for that exact snapshot. First implement this within one batch; a process-wide plan cache is a larger change.

**Rules:** Do not pass GC references between children. Bind the plan to the complete source digest, trusted API bytes, preamble, and compiler identity. Separate immutable proofs from report lists, lazy maps, fresh-name state, and application state. Reset per-annotation state. Keep serial replay when a result can affect another application.

**Measure:** Count prepare/check/reflection calls. Measure each phase and allocations with 2, 8, 32, and 64 small applications over small and large source graphs. Hold native-code cache state fixed. Expect preparation count to follow child count, not application count.

### 2. P0: Send each source snapshot once per batch

**Source:** `self_host/compiler/transform_workers.dew:59`, `:70`, `:337`, `:341`, `:355`.

**Cost:** The snapshot is encoded once, then copied into each job and again into the batch. Input size is `12 + N * (28 + snapshot_bytes)`. This raises CPU and peak live bytes. It also makes larger source graphs fall back at the 32 MiB batch limit even if each function takes little input.

**Change:** A version-1 batch can contain one bounded source snapshot plus a table of sites. Dispatch site records to prepared children. The project permits version-1 format changes before release.

**Rules:** Keep the total and individual bounds, full-consumption checks, checksum, UTF-8 checks, and source-order site mapping. A job cannot select a different snapshot by an unchecked integer.

**Measure:** Record snapshot size, encoded input size, copied bytes, encode/decode time, and peak live bytes. Test the current 32 MiB fallback edge and many tiny targets in a large graph.

### 3. P1: Reduce byte conversion and output buffer costs

**Source:** `self_host/compiler/transform_workers.dew:27`, `:39`, `:164`, `:342`, `:360`; `tools/wago-transform-host/workers.go:190`, `:212`, `:338`.

**Cost:** Dew converts between `Bytes` and `WasmArray<U8>` one byte at a time. The Go host then makes its required ownership copy. Child input and output repeat the conversions. The parent allocates an output array for the worst allowed function size: about 1 MiB per job plus report bounds, even for a tiny result. Host result slices also coexist with the combined result buffer.

**Change:** Add a bulk copy using the ordinary byte-array library representation if it is safe. Keep the one copy needed to cross ownership domains. Use bounded chunks or a size-then-read result API to avoid the large worst-case output array. Do not add a general unsafe GC-reference escape.

**Rules:** Keep storage views inside `WithGuestStorage`, array type/mutability checks, exact output length, and one publication per job. Do not let output sizing repeat a transform.

**Measure:** Separate encode, crossing, decode, and result-retention times. Record allocated bytes and peak live bytes for 64 tiny outputs and a near-limit output.

### 4. P0: Give child heaps a real memory budget

**Source:** `tools/wago-transform-host/workers.go:33`; `tools/wago-transform-host/README.md:60`; saved patched Wago source `.tmp/wago-transform-host/build-y_uuvb8q/wago/src/wago/managed_instances.go:253`.

**Cost:** `ForkIsolated` copies the parent's GC configuration into each private child. A 32 MiB managed-instance grant limits linear memory, not the GC heaps or process RSS. The saved large-heap run reaches about 7.69 GiB RSS with workers. The saved data shows a budget issue, but does not identify retained versus temporary heap bytes.

**Change:** Add a worker-specific GC profile or split one process memory budget across parent and children. Select child count using memory as well as CPU limits. Keep workers opt-in until a useful end-to-end case wins within a stated memory cap.

**Rules:** Private collectors must remain private. A smaller heap must produce a clear resource error, not silent output changes. Linear memory limits remain in force.

**Measure:** Record per-collector reserved, committed, live, and peak bytes; collection counts and pause time; process RSS/PSS; child start/close costs. Sweep child heap/nursery sizes with repeated samples and identical compiler/request hashes.

### 5. P1: Avoid repeated child start and close work

**Source:** `tools/wago-transform-host/workers.go:269`, `:287`, `:288`; `tools/wago-transform-host/README.md:47`.

**Cost:** Every batch creates two isolated children in a serial loop. Each child runs the compiler's normal Wasm start function. The host closes and waits for both before return. Multiple import-expansion rounds repeat this cost.

**Change:** Reuse the bounded children within one compile request, with explicit prepare/reset/end operations. Measure start cost first. Parallel child creation is an option only after the manager and plugin setup paths are proved safe.

**Rules:** Keep caller-lifetime cancellation and child ownership. No child or snapshot can leak into a later request. Every success, trap, deadline, and partial fork failure must still close and wait. Reuse compiled code through the existing lease; keep the CLI module-lifetime patch.

**Measure:** Time child creation, Wasm start, prepare, work, and close separately. Test one batch and many import rounds. Check post-close live reservations and heap bytes.

### 6. P1: Use a shared job queue instead of fixed strides

**Source:** `tools/wago-transform-host/workers.go:302`, `:306`, `:329`.

**Cost:** Child 0 takes sites 0, 2, 4; child 1 takes 1, 3, 5. A set of slow even sites leaves one child busy while the other is idle.

**Change:** Let each child claim the next unstarted index. Store its result at that index. Apply a small-job threshold so queue overhead does not dominate.

**Rules:** One active invocation per child. Keep results and failure selection in source order. Do not cancel a lower-index job merely because a later job failed.

**Measure:** Use alternating heavy/light sites, one large outlier, and equal small sites. Record per-child active/idle time and the last-job tail.

### 7. P1: Reduce predictable speculative replay

**Source:** `self_host/compiler/transform_workers.dew:124`, `:140`, `:141`, `:284`, `:295`; `self_host/compiler/transform_expand.dew:554`.

**Cost:** Workers run all selected applications. One signature change, bridge, import, declaration, or deferred semantic issue causes the parent to discard the round's candidate results and execute it serially. The completed work and output checks then bought no result.

**Change:** Add conservative effect information for checked transform call graphs, or retain a request-local replay decision for an exact transform/source identity. Schedule only applications proved to fit the current body-only contract. Keep unknown effects serial.

**Rules:** Prior applications can add declarations/imports that change later meaning. Do not reuse independent-looking results across such a change without a dependency proof. Do not publish speculative reports.

**Measure:** Count attempts, replay reasons, and discarded CPU/bytes. Test a body-only round, a late signature change, generated imports, generated declarations, and prior-application dependencies.

### 8. P1: Reuse immutable bytecode across applications in a child

**Source:** `self_host/compiler/transform_model.dew:131`, `:150`; `self_host/compiler/transform_workers.dew:138`; `self_host/compiler/transform_bytecode_compile.dew:431`.

**Cost:** The serial expansion uses one machine; worker jobs each create a new machine. Thus repeated helpers lose compiled bytecode and cached unsupported results at each job boundary. The cache already distinguishes execution frame and exact source site, and has work/byte caps.

**Change:** Put bounded immutable bytecode in the prepared child plan or a separate plan-local cache. Keep runtime values in fresh application machines. Reuse negative entries too.

**Rules:** The key must retain frame specialization and source identity. Constants/call targets in cached code need a mutability audit before sharing. Preserve per-annotation work charges, allocation fees, depth, globals, and scratch reset. Do not share closures or mutable binding cells as cache data.

**Measure:** Count bytecode builds/hits/fallbacks per helper and frame. Compare one helper used by many sites, many generic frames, and unsupported bodies. Record actual cache memory, not only `estimated_bytes`.

### 9. P2: Reduce bytecode call-frame allocations

**Source:** `self_host/compiler/transform_bytecode.dew:201`, `:205`, `:278`.

**Cost:** Each bytecode call allocates a slot array, grows it to the frame size, and fills it. Each call instruction also builds a separate argument array. Tight helper loops can allocate far more arrays than their output needs.

**Change:** Use exact-capacity storage first. Then consider a machine-local frame stack with slices/spans for arguments. Profile before changing dispatch.

**Rules:** Recursive and reentrant calls cannot overwrite live caller values. Clear released reference slots so the cache or frame pool does not retain an object graph. Keep reference aliasing, flow, depth, and resource-report behavior.

**Measure:** Count calls, slot bytes, argument arrays, and GC work for small recursive helpers and tight loops. Compare tree/bytecode results, traps, work counts, and allocation reports.

### 10. P1: Avoid full reflection and context work when it is unused

**Source:** `self_host/compiler/transform_expression_types.dew:265`, `:276`, `:301`; `self_host/compiler/transform_expand.dew:336`, `:344`, `:345`.

**Cost:** Any annotation triggers a second whole-program collect/freeze/infer/lower pass for original-body reflection. Every annotation then constructs syntax and expression-type nodes in its context, even if the transform only returns a constant body. The validation pass has different bodies, so it cannot simply replace original-body inference.

**Change:** Prove which context fields a checked transform and its callees can read; avoid unused data where that proof is complete. Alternatively introduce a library-level lazy query with the same source semantics. Cache original-source reflection once per prepared snapshot.

**Rules:** Preserve reflection errors and the distinction between original and expanded bodies. Unknown/dynamic field use requires the full context. Preserve resource-report rules or explicitly update their contract and golden data.

**Measure:** Time original-body reflection and context construction separately. Compare constant transforms, syntax-only transforms, and expression-type queries on large untouched modules.

### 11. P1: Reuse parsed immutable source across transform phases and rounds

**Source:** `self_host/compiler/transform_source.dew:1`, `:25`, `:192`, `:294`, `:423`; `self_host/compiler/transform_validation.dew:192`, `:248`, `:262`; `self_host/compiler/main.dew:260`.

**Cost:** Syntax detection tokenizes source. Active preparation tokenizes and parses it again. Validation and reflection collect source again. New-import rounds repeat preparation over the growing graph. The final stripping pass prepares the selected graph again before normal final compilation.

**Change:** Keep a request-local content index for immutable original bytes, annotation scan, tokens, and parsed events. Reuse unchanged modules as imports append. Retain separate entries for clean validation source, original reflection source, and generated output.

**Rules:** Key by exact bytes/path/test flag and parsing options. Preserve site/module identities and annotation offsets. A plan's source-index cache currently detects append counts (`transform_source_index.dew:48`); replacing contents at the same count needs explicit invalidation. Final generated-source semantic checking must remain.

**Measure:** Count tokens/parses and bytes per phase and round. Test deep late-import chains, placeholder-name collisions, body/signature changes, and a large source pool with few selected modules.

### 12. P2: Reduce transform-cache hashing and unrelated invalidations

**Source:** `self_host/compiler/transform_cache.dew:80`, `:98`, `:123`, `:124`, `:384`.

**Cost:** Every lookup hashes all source bytes in both manifest and entire source pool. A change to an unselected pool module invalidates the whole expanded-source cache. This is safe but coarse. A hit still needs final ordinary source checks, by design.

**Change:** First reuse exact file digests in the request/loader and combine them with the existing path/order/test metadata. A later cache can track selected dependencies and import lookup outcomes rather than all pool contents.

**Rules:** Generated late imports can select previously unused modules. Dependency tracking must cover those lookups, missing modules, duplicate candidates, and relevant API/compiler/config identities. Do not narrow the key to the initial closure alone. Publish only after successful final output.

**Measure:** Separate key hashing, decode, and final-check times. Edit a selected dependency, an unrelated pool module, and a module selected only by a generated import. Check exact invalidation and report equality.

### 13. P2: Cache the pinned host build and compiler adapter by content

**Source:** `tools/build-wago-transform-host.py:25`, `:32`, `:36`, `:48`, `:62`, `:76`; `tools/prepare-wago-compiler.py:96`.

**Cost:** Each host-build call extracts a fresh private Wago tree, initializes Git, applies patches, copies host sources, and runs Go build. Random private replacement paths can also limit build-cache reuse. The compiler adapter prints the whole Wasm to text, edits it, parses it, and validates it on each call.

**Change:** Store a completed immutable host artifact by pinned module checksum, patch bytes, production host bytes, Go version, target, and build flags. Store adapted Wasm by compiler bytes and adapter/tool identities. Keep identity files and test evidence separate from an untested build.

**Rules:** Preserve checksum-verified upstream sources and exact patch application. Cache publication must be atomic. Never label an artifact tested because another artifact with a different test/build identity passed. This improves setup/build cost; it is separate from guest runtime speed.

**Measure:** Time download lookup, extraction, patch, Go build, and adapter stages. Test cold and hot tool caches and verify exact output identities. Do not mix this gain into transform CPU claims.

### 14. P1 research: Run independent module stages in parallel after explicit barriers

**Source:** `self_host/compiler/semantic_program_interfaces.dew:310`, `:399`, `:457`, `:501`; `self_host/compiler/semantic_program_lowering.dew:1733`, `:1749`, `:1786`, `:1828`.

**Cost:** Collection and module body planning are serial loops. Much body work uses a module's own output storage after interfaces are frozen. The current result assembly also searches planned module indices for each output module (`semantic_program_lowering.dew:1800`), which adds quadratic work.

**Change:** Start with deterministic module jobs: assign IDs from manifest positions, collect into indexed slots, then run constructor-wrapper installation as its own barrier. Freeze interfaces by dependency-ready strongly connected component (a cycle group). After all interfaces are frozen, audit and run independent module body plans. Place results directly in their original module slot.

**Rules:** Interface freezing updates scopes/interfaces in place and uses ordered passes inside cycles. Do not run all members at once or consume a partly updated interface. Module planning also ends with global raw-array binding and compile-time query folding; keep those as barriers until split safely. No shared mutable inference/type arena between jobs. Keep diagnostic and module order. The current worker protocol only runs transform sites; wider compiler jobs need their own bounded protocol.

**Measure:** Record stage work and graph width before implementation. Test wide independent graphs and deep chains, plus import cycles, inferred exported values, constructor wrappers, compile-time queries, and stable diagnostics. Compare 1/2/4 workers with a strict total memory budget and message-cost counters.

### 15. P1 research: Parallel module fragments after specialization is complete

**Source:** `self_host/compiler/main.dew:390`; `self_host/compiler/semantic_wasmgc_fragment_plan.dew:892`, `:902`, `:905`, `:932`, `:984`, `:1015`.

**Cost:** Fragment planning loops over all modules. Each iteration builds its own physical type, field, function, and lookup arrays. These are a promising larger job size than tiny transform applications. Each module also scans the full specialization-request list.

**Change:** Complete specialization and global type/reachability demand first. Index specialization requests by module. Run audited module fragment jobs against frozen inputs, then gather by module index and do the global link step in a fixed order. This is a better first broad parallel stage than a shared global specialization worklist.

**Rules:** Confirm helpers do not mutate shared lowering, specialization caches, type maps, or capture data. Preserve local type/function indices and the final link order. Keep global specialization discovery and representation validation ordered until they have an explicit deterministic merge scheme. Do not send the full program again for every fragment.

**Measure:** Time demand analysis, fragment work per module, serialization, and linking. Use balanced modules, one very large module, and heavy generic specialization. Compare byte-for-byte Wasm, validation, code size, peak memory, and native runtime. A cross-build or emulated run is not a native runtime result.

## Measurement order

Add stage timers and byte/allocation counters first. Run at least one warm native-artifact case, one cold case, and one persistent-instance case with the same compiler/request identity. Keep transform-result cache misses separate from hits. Randomize serial/parallel order; retain raw samples, CPU time, RSS/PSS, GC data, host/kernel/architecture, heap settings, and code-size data. Then fix repeated checking/snapshot work before increasing worker count. No source scan can prove the size of a speed gain.
