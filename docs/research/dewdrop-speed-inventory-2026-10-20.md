# Dewdrop speed inventory — 2026-10-20

This scan found **56 candidate tasks**. The main plan is to remove repeated work,
reduce allocations, then run the remaining independent work on more CPU cores.
Generated-program speed comes first, followed by memory use. Compiler speed
must include startup, source transforms, planning, linking, and output checks.

This is an inventory, not an implementation. No compiler code changed. No new
build, test, or timing run was made. A source scan can show repeated work; it
cannot prove the size of a speed gain.

Baseline: Dewdrop `69ea1cb533edd60353e0a9f49d6169403c92ef41`, Starshine
`1b237952167f582abd492aec27adf10c5a6c9e60`. Source locations below refer to
that state. The scan covered the MoonBit compiler, Dew compiler, standard
library, cache layers, backend, transform interpreter, Wago worker plugin, and
build/test tools. Three independent read-only scans supplied the detailed notes:

- [Inference, imports, specialization, and caches](data/speed-inventory-2026-10-20/semantics.md).
- [Generated runtime code and code generation](data/speed-inventory-2026-10-20/codegen.md).
- [Transforms, worker costs, and parallel stages](data/speed-inventory-2026-10-20/parallel.md).

Those notes contain source lines, proposed changes, risks, and benchmark cases.
They are source-review evidence, not benchmark results. The main scan checked
the leading findings against current source and reviewed saved measurements.
Claude review was unavailable because the account quota was exhausted. No
Claude assessment is claimed.

## First work

1. **Measure the current phases and allocation costs** (items 1–3). The tools
   already support CPU profiles and paired runs. Extend them; do not create a
   second benchmark system.
2. **Use bulk Array copies** (item 4), then make/fill/extend (5–6). This is a
   small, general library change that can help user programs and the Dew
   compiler. `array.copy` already exists. Keep the algorithms in Dew.
3. **Remove unused cache export work and repeated call-target scans** (17–18).
   Both costs are visible in the normal MoonBit inference path.
4. **Prepare each transform snapshot once per child, send it once, and bound
   child heaps** (34–36). More workers should follow this work.
5. **Fix repeated hashing, specialization searches, and query copies**
   (20–21, 26–27, 31), selected by the new profile.
6. **Test coarse parallel jobs after stable compiler barriers** (46–50).
   Begin with a stage that has enough measured work to cover transport cost.

**First code task:** item 4, starting with `Array.copy`, `slice`, and
`copy_within`. Add overlap, reference, Unit, packed-value, empty-range, and trap
tests. Capture the old timings before the edit. Compare runtime, allocation,
code size, and a complete self-host compile after the edit. This is smaller and
easier to prove than a new compiler-wide worker scheduler.

## Current evidence

The newest worker samples show a performance problem, not a parallel win:

| Per-instance GC heap / nursery | Serial wall time | Two workers | Serial peak RSS | Two-worker peak RSS |
| --- | ---: | ---: | ---: | ---: |
| 512 MiB / 64 MiB | 93.303 s | 169.750 s | 1,340,032 KiB | 2,217,528 KiB |
| 2 GiB / 512 MiB | 92.427 s | 135.474 s | 3,260,208 KiB | 8,061,880 KiB |

Sources: [small-heap raw data](data/transform-workers-2026-10-20/small-heap.json)
and [large-heap raw data](data/transform-workers-2026-10-20/large-heap.json).
Each cell comes from one cold process on a shared AMD64 host. Each process
includes native compilation of the compiler in a fresh `WAGO_HOME`. These are
not isolated transform times or measurements of retained guest heap. The output
and cache bytes match across modes. There is no native ARM64 measurement.

The same [worker report](transform-workers-2026-10-20.md) records 106.291 s for
315 Dew transform tests and 88.790 s for the full bootstrap check. Individual
bootstrap build/execution stages were below 30 s. These are previous runs,
not tests repeated for this inventory. Work above 30 s remains a performance
fault under the project rules.

Older profiles help select tests, but do not describe today's cost distribution.
For example, the September [self-host study](self-host-performance-followup-2026-09-14.md)
measured 18.402 s → 14.294 s after changes already shipped. Do not count those
gains again. Its remaining hot functions can also have changed since then.

## Priority and proof

- **P0:** measurement or resource control needed before wider parallel work.
- **P1:** strong source evidence or a useful near-term experiment.
- **P2:** later work with a larger design cost or a less certain payoff.

These are work priorities, not promised gains. **Source** means the cost pattern
is visible in current code. **Design** means a safe implementation boundary
still needs proof. **Historical** means an older result must be reproduced on
the current compiler. A P1 item can still lose its benchmark and be rejected.

### Measurement

| ID | Priority | Task and reason | Proof needed |
| --- | --- | --- | --- |
| 1 | P0 | Add phase timers and work counters for read/hash, parse, transform preparation/check/reflection/execution, inference, specialization, optimization, emission, link, validation, and publication. Existing [CPU profile support](../../tools/self-host-common.sh) and [profile summarizer](../../tools/summarize-self-host-profile.py) provide a base. | Cold and warm runs with exact compiler/request hashes. Separate host native-code compilation from guest work. |
| 2 | P0 | Measure dynamic allocations, bytes copied, GC time, and live/peak memory. [Wasm metrics](../../tools/wasm-metrics.mjs) count static instruction sites; a site can execute millions of times. | Use engine counters or opt-in benchmark instrumentation. Measure its overhead. Do not call encoded bytes, heap reservations, or static sites “live memory.” |
| 3 | P0 | Add a current scaling and edit benchmark matrix to the existing [compile](../../tools/benchmark-compile-scaling.py) and [self-host](../../tools/benchmark-self-host-compile.py) harnesses. | Repeated paired samples, output checks, cold/hit/miss/private-edit/public-edit cases, wide and deep module graphs. Keep raw samples and report variance. |

### Generated-program runtime and memory

Details and exact test cases: [code generation scan](data/speed-inventory-2026-10-20/codegen.md).

| ID | Priority / evidence | Task and cost removed |
| --- | --- | --- |
| 4 | P1 / Source | Replace item-by-item `copy`, `slice`, and `copy_within` in [Array](../../std/array.dew) with checked bulk `wasm_array_copy`. Preserve overlap and independent destination storage. The [intrinsic](../../std/wasm/intrinsics.dew) already exists. |
| 5 | P1 / Source | Use `array.new` for Array `make`. Add a general one-to-one `array.fill` intrinsic for `fill`, with both compiler and interpreter support. Remove repeated push/set work. Check Unit effects and packed storage. |
| 6 | P1 / Source | Reserve once and bulk-copy Array `extend`. The current push loop can grow and copy the destination several times. Preserve overflow checks, self-extension, and the documented capacity behavior. |
| 7 | P2 / Source | Remove the temporary one-element blank array in `array_clear_suffix` when backing storage is full. Repeated fill/pop cycles allocate this object repeatedly. A replacement needs the exact typed default and must release removed references. |
| 8 | P1 / Design + Historical | Add one cursor/event core for typed [JSON](../../std/json.dew) decoding. Build a typed value directly instead of always building a dynamic tree. The earlier slice-per-field prototype lost; do not repeat it. Keep exact numbers, limits, Unicode, duplicate-key rules, and errors. |
| 9 | P2 / Source + Historical | Test exact hashed duplicate-key tracking only above a measured JSON object width. The current Bloom-filter path can still scan many prior keys. Unconditional Set tracking already lost on small objects. |
| 10 | P1 / Design | Extend private aggregate scalar replacement across known calls and loop state in [program optimization](../../src/semantic/program_optimization.mbt). Pass fields directly; create the object only when it escapes. Bound specialization and code growth. |
| 11 | P1 / Design | Extend private enum/result carriers beyond the existing unit and one-I32 cases. Test U32, I64, references, and small products separately. Public, foreign, and function-value boundaries need exact adapters. |
| 12 | P1 / Design | Carry exact reference-type facts through immutable locals and known calls to remove redundant casts in [storage emission](../../src/backend/starshine_code.mbt). Keep required erased-boundary checks, null checks, and trap order. |
| 13 | P2 / Design | Use one ABI path for a closure call when flow proves its signature and capture kind. [Closure emission](../../src/backend/starshine_closure_calls.mbt) otherwise builds several alternatives. Exact directization already exists for some cases; measure the remaining indirect cases. |
| 14 | P2 / Design + Historical | Convert safe self-tail recursion to a local loop with simultaneous argument updates. Tail-call instructions alone did not always run faster in the [saved study](tail-recursion.md). Keep reference-tail-call restrictions until their runtime cause is resolved. |
| 15 | P2 / Design | Avoid reconstruction by [erased adapters](../../src/backend/starshine_program_adapters.mbt) when source and destination have a proved identical physical representation. Test aliases, cycles, identity, and mutation; equal-looking shapes alone are insufficient. |
| 16 | P1 / Historical | Recheck hash/map regressions and redundant passes in [optimizer profiles](../../src/dew_bootstrap/optimization.mbt). The [September deep study](starshine-deep-pipeline-2026-09-10.md) found only about 0.73% extra aggregate runtime gain over `speed`, at much higher optimizer cost. Select passes from current measured results. |

For these items, measure Node and Wago runtime, dynamic allocations, Wasm bytes,
and native code size where available. Test both raw and optimized output.
Compiler-time cost is part of the result. A faster program with a severe compile
or memory regression needs a separate policy decision.

### Front end, inference, and incremental compilation

Details: [semantic scan](data/speed-inventory-2026-10-20/semantics.md).
“MoonBit” identifies the implementation, not its execution target. The current
ordinary [CLI host](../../tools/run-dew-cli-host.sh) runs the MoonBit compiler as
JavaScript; native tests and helper tools are separate.

| ID | Priority / evidence | Task and cost removed |
| --- | --- | --- |
| 17 | P1 / Source | Stop making body-family cache artifacts when no caller needs them. [Inference](../../src/semantic/infer_basic_bodies.mbt) still builds and rebases these artifacts on the normal no-family-cache path, then callers discard them. Index nested lambdas by root body instead of scanning all lambdas for each body. |
| 18 | P1 / Source | Replace `is_syntactic_call_target`'s call-list scan with an expression mark array. It currently scans C calls for each of E live expressions: up to E×C checks in a call-heavy body. |
| 19 | P1 / Source | Reuse a solver, immutable member context, and callable-owner index across [Dew body jobs](../../self_host/compiler/semantic_basic_body_inference.dew). MoonBit already reuses solver scratch. Freeze published/error results before resetting storage. |
| 20 | P1 / Source | Hash each settled interface's body evidence once per compile. [Evidence hashing](../../src/semantic/frozen_interface_cache.mbt) makes normalized record copies and serializes them; cache layers repeat this across importers. Invalidate the memo when deferred types change. |
| 21 | P1 / Source | Reuse source digests and stable key parts across [body](../../src/standard_loader/body_inference_cache.mbt), [planning](../../src/standard_loader/planning_cache.mbt), and transform caches. Stream hashes instead of copying whole source buffers where possible. Preserve all identity fields. |
| 22 | P1 / Source | Refresh an existing body-family bundle after misses. It is currently stored only when `existing is None`. Test original → edit private A → edit private B: the third build should reuse edited A. Exact-module hits can hide this gap. Measure write cost before enabling broader cache use. |
| 23 | P2 / Source | Hash declaration source ranges without allocating one owned byte buffer per declaration in family-key construction. Preserve exact boundaries, comments, methods, and trailing bytes. This is separate from the already-fixed cache-pack range hashing. |
| 24 | P1 / Design | Make fragment-cache dependencies more precise. [Fragment keys](../../src/standard_loader/planning_cache.mbt) include a whole-program source context, so one private edit changes every key. Record actual global demand, liveness, generic-layout, and trait facts before narrowing keys. |
| 25 | P1 / Source + Design | Wake only inference constraints affected by new type information. Current [member](../../src/semantic/infer_members_and_constructors.mbt) and call/field retry loops can repeatedly scan the full body or pending set. Account for union-find merges, rollback, and delayed projections. |
| 26 | P1 / Source | Index materialized MoonBit functions by exact declaration/ABI identity in [specialization planning](../../src/semantic/program_specialization_plan.mbt). Current lookup scans existing functions per request. Keep full shape checks on hits and stable first-insertion order. Dew already has request indexes. |
| 27 | P1 / Source | Index MoonBit specialized-call and function-reference replay records by caller, ABI, and expression. Current insertion scans all earlier records. Keep target/evidence mismatch assertions; the index must speed up the check, not remove it. |
| 28 | P2 / Source | Add missing exact path indexes in [Dew manifests](../../self_host/compiler/semantic_program_interfaces.dew) and [MoonBit transform source pools](../../src/compiler_driver/source_pool.mbt). Add ordered prefix lookup for wildcards and reuse import-prefix scans. Ordinary MoonBit module lookup is already indexed. |
| 29 | P2 / Design | Reuse settled module-value inference between interface freezing and final body inference. Both implementations repeat some work. Only reuse after the import cycle has settled; early provisional results are unsafe. |
| 30 | P2 / Design | Build Dew's import graph from collected imports before full type resolution. [Signature freezing](../../self_host/compiler/semantic_program_interfaces.dew) currently does a provisional full pass, then imported passes; [lowering](../../self_host/compiler/semantic_program_lowering.dew) builds the graph again. Retain the declaration heads needed by cycles. |
| 31 | P1 / Source + Design | Replace full-module compile-time query instance copies with body-local changes over immutable source data. [Query specialization](../../src/semantic/compile_time_specialization.mbt) copies module arenas and evidence arrays per logical instance. Preserve logical type identity, body-owned IDs, source immutability, and resource accounting. |
| 32 | P1 / Source | Build def/use indexes for aggregate optimization. The component replacement path in [program optimization](../../src/semantic/program_optimization.mbt), around lines 5380–5441, scans all expressions again for each matching local read, inside each aggregate candidate. Index users and field projections once; update or discard indexes after mutation. |
| 33 | P2 / Source | Intern adapter helpers and signatures with complete keys. [Helper insertion](../../src/backend/starshine_program_adapters.mbt) and [type assembly](../../src/backend/starshine_program_assembly.mbt) scan prior helpers/wrappers. Preserve distinct modules, directions, substitutions, and stable indices. |

For item 31, first measure module bytes copied per query instance and the
fraction that changes. Use one large module with 1/16/64 distinct logical
instances, including equal physical carriers with different logical types.
For item 32, scale both aggregate count and expression count, then check that
optimized output still has the same allocations, traps, and results.

### Source transforms and Wago workers

Details: [worker scan](data/speed-inventory-2026-10-20/parallel.md).
Workers already share compiled code and run with private collectors. The
interpreter already has bytecode and caches. Those are not missing features.

| ID | Priority / evidence | Task and cost removed |
| --- | --- | --- |
| 34 | P1 / Source | Prepare and check each exact source snapshot once per child per batch. [Worker execution](../../self_host/compiler/transform_workers.dew) currently decodes, prepares, checks, and collects reflection data for each application. Reuse immutable plans; retain fresh application state. |
| 35 | P1 / Source | Encode one snapshot plus application sites per batch. The current batch repeats the full snapshot in each job, with input size `12 + N × (28 + snapshot_bytes)`. This also causes early fallback at the byte limit. |
| 36 | P0 / Source + Measured baseline | Give private child GC heaps a total process memory budget. [Isolated forks](../../tools/wago-transform-host/patches/managed-isolated-fork.patch) inherit parent GC settings. The managed linear-memory limit does not cap GC heap or RSS. Keep collectors private. |
| 37 | P1 / Source | Reduce byte-at-a-time conversions and worst-case output buffers in [worker transport](../../self_host/compiler/transform_workers.dew). Keep the copy needed for ownership transfer. Use bulk copies and bounded exact-size/chunked output, without rerunning a transform to obtain its size. |
| 38 | P1 / Design | Reuse the bounded child pool within one compile request. [The host](../../tools/wago-transform-host/workers.go) currently creates and closes children per batch. Measure start/reset/close cost; preserve cancellation, module leases, and complete cleanup on every exit. |
| 39 | P1 / Source | Replace fixed even/odd job assignment with a bounded shared queue. Store results by original site index. Uneven jobs can leave one child idle. Keep one invocation per child and deterministic error selection. |
| 40 | P1 / Design | Avoid predictable speculative replay. Prove conservative transform effects before scheduling body-only work; unknown effects stay serial. Imports, declarations, and signature changes currently discard candidate work and replay the round. |
| 41 | P1 / Source + Design | Keep bounded immutable bytecode with the prepared child plan. A fresh machine per job loses helper bytecode caches. Preserve exact specialization keys and resource charges; never share globals, closure cells, or mutable constants between applications. |
| 42 | P2 / Source | Reduce slot and argument-array allocation in [bytecode calls](../../self_host/compiler/transform_bytecode.dew). Start with exact sizing, then test machine-local frame storage. Recursion must not overwrite live frames; clear released references. |
| 43 | P1 / Source + Design | Reuse original-body reflection once per snapshot, then test demand-driven context fields. [Reflection](../../self_host/compiler/transform_expression_types.dew) performs another whole-program pass whenever annotations exist. Preserve reflection errors and original-versus-expanded source semantics. |
| 44 | P1 / Source + Design | Reuse immutable parse/annotation results across validation, reflection, stripping, and late-import rounds. [Transform source preparation](../../self_host/compiler/transform_source.dew) revisits source. Keep separate entries for original, validation, and generated bytes. Final generated-source checks remain required. |
| 45 | P2 / Design | Track actual transform dependencies before narrowing the persistent cache key. [The cache](../../self_host/compiler/transform_cache.dew) hashes the full source pool. Track late import lookups, missing results, duplicates, API identity, and configuration; the initial import closure is insufficient. |

The transform implementation must remain an interpreter. It must not require a
host to run a newly generated Wasm payload. Protocol changes can remain version
1 under the project's unreleased-format rule.

### Wider parallel compilation

These are **design candidates**, not thread-safe operations proved by this scan.
Both the [semantic](data/speed-inventory-2026-10-20/semantics.md) and
[worker](data/speed-inventory-2026-10-20/parallel.md) notes describe the barriers.

| ID | Priority | Stage and required boundary |
| --- | --- | --- |
| 46 | P1 experiment | Parse selected immutable files into stable file slots. Merge cache-pack writes through one writer. Measure task size and transport first; do not send a whole program per file. |
| 47 | P1 experiment | Infer independent root-body families after module values and imports settle. Each worker owns its solver and scratch. A family includes nested lambdas, with parent-before-child order. Merge body results by assigned IDs. |
| 48 | P2 | Schedule ready import cycle groups on a dependency graph. A cycle group is a set of modules that depend on one another. Keep its internal interface passes ordered until a safe replacement is proved. Deferred interface updates are a current barrier. |
| 49 | P1 experiment | Run module layout/lowering and then fragment jobs after their respective global facts are frozen. Index specialization requests by module. Keep query folding, demand analysis, and global specialization discovery at explicit barriers. |
| 50 | P1 experiment | Emit function bodies from a frozen function/type/helper plan, then merge in index order. [Code-section assembly](../../src/backend/starshine_program_assembly.mbt) is currently serial. Audit hidden mutable caches and cap the sum of live instruction arrays. |

Suggested order of stages:

```text
Select source and finish ordered transform rounds
    ↓
Parse files independently → merge stable declaration IDs
    ↓
Resolve import cycle groups → freeze interfaces and module values
    ↓
Infer body families independently → merge checked results
    ↓
Lower/query-fold/optimize → settle specialization and global demand
    ↓
Plan independent module fragments → freeze global type/function indices
    ↓
Emit bodies independently → ordered assembly/link → validate → publish
```

Not every edge exists in this form today. This is the target ownership plan.
Do not reorder source effects or remove a required compiler pass to fit it.
Compile-time queries and generated imports can force an earlier barrier to run
again. A deep import chain offers less module parallelism than a wide graph.

Use one CPU and memory budget across the whole request. Avoid a worker pool
inside each worker. Bound queued jobs and retained results. Small tasks should
stay serial when copying and scheduling cost more than the work. Start with
1 and 2 workers; add 4 and 8 only after the design and memory budget support
them. The current transform option accepts only 0 or 2.

### CLI, build tools, and checks

| ID | Priority / evidence | Task and measurement |
| --- | --- | --- |
| 51 | P1 / Source | Reduce repeated CLI startup and compiler identity work. [tools/dew](../../tools/dew) enters `moon run`; [bootstrap_compile](../../src/dew_bootstrap/main.mbt) traverses and hashes compiler sources before output-cache restore; a miss enters another host build check and JS/Wasm process. Time each step. Test a build-time identity or safe source/stat memo and a prebuilt host path. Preserve edit detection and tool identity. |
| 52 | P2 / Source | Cache the patched [Wago host build](../../tools/build-wago-transform-host.py) and [compiler adapter](../../tools/prepare-wago-compiler.py) by complete content/tool identity. Each build extracts and patches a private tree; adaptation prints/parses Wasm text. Compare cold/hot setup time. Keep atomic publication and exact test provenance. |
| 53 | P1 / Source | Prebuild request/link helper executables once and invoke them directly in [transform request checks](../../tools/test-transform-requests.sh) and [bootstrap](../../tools/check-self-host-bootstrap.sh). Repeated `moon run` adds build checks/process work. Keep all positive/negative cases and fresh case outputs. |
| 54 | P2 / Design | Reduce full check-lane time with measured partitions or persistent test hosts. The [native integration lane](../../tools/test-integration-native.sh) is serial because a combined runner had severe contention. Test bounded jobs with isolated build directories and a total memory cap; do not simply remove the limit. |
| 55 | P2 / Source | Replace repeated full Wasm text printing with one import inventory, and remove proven duplicate validation of unchanged bytes in [bootstrap](../../tools/check-self-host-bootstrap.sh). It prints each linked output twice for import checks, and can validate a copied raw compiler again. Keep validation after every byte-changing or untrusted boundary. |
| 56 | P1 / Historical + Source | Isolate and reduce remaining cold native tool builds above 30 s. Measure MoonBit generation, C compilation, linking, and first execution separately. Test incremental reuse and smaller translation units before lowering runtime optimization. The [debug-generator change](parity-generator-cold-builds-2026-10-18.md) and [parallel linker LTO](self-host-performance-followup-2026-09-14.md) are already done. |

Item 51 is based on the current MoonBit bootstrap path. The older
[August report](compiler-performance-2026-08-14.md) describes a fingerprint memo
in an earlier path; it does not prove that today's bootstrap skips the scan.
The September artifact-hash experiment was slower than source hashing, so
replacing source hashing with hashing a large executable is not the default fix.

For 53–56, record build-tool startup separately from compiler execution. Reusing
a host must still make fresh per-test guest state where required. Bootstrap
A → B → C is a dependency chain and cannot run in parallel. Independent
post-build probes can, if memory and host limits permit it.

## Benchmark and acceptance plan

Use the existing tools. Do not run every full suite for this inventory.

| Workload | Main measurements and controls |
| --- | --- |
| Tiny program | CLI/build checks, source identity, output-cache hit, cold startup. Separate direct compiler API from the normal command. |
| Many small bodies / one large body | Family artifact work, call-target visits, solver bytes, constraint retries. Scale each dimension independently. |
| Wide imports / deep chain / cycles | Interface hash count, resolved modules, ready graph width, peak scratch. Keep duplicate and missing-import diagnostics. |
| Private/public edit sequence | Parse, interface, body-family, layout, fragment, and transform hit/miss counts; bytes read/written. Include edit A then edit B. |
| Heavy generics and type queries | Unique requests, repeated requests, module copies, replay checks, code growth, exact logical identities. |
| 2/8/32/64 transform applications | Prepare/check/reflection counts, bytecode hits, copied bytes, replay reasons, child active/idle time, heap costs. Include large source with tiny transforms and uneven jobs. |
| Array, JSON, maps, callbacks, aggregate loops | Dynamic input and checked results; runtime distributions, allocation/GC, Wasm and native bytes. Keep both fast and failure paths. |
| Full self-host compile | Same request and provider identity; phase times, RSS, exact output/fixed point where applicable. Report cold code compilation separately. |

Alternate before/after order. Keep at least several independent process samples,
plus enough in-process samples for small kernels. Report raw samples, median,
spread, host load, architecture, engine/tool versions, compiler/provider hashes,
source hashes, flags, cache state, and GC settings. Use enough observations
before reporting tail percentiles. Run timed work in one controlled lane.

Use `tools/self-host-common.sh`'s `self_host_measure` for compiler commands.
Keep the 30-second performance fault visible. A slow full lane can be split
into measured stages for diagnosis; splitting it is not itself a speed gain.

A change passes only when:

1. It has the same semantics, diagnostics, errors, and resource rules.
2. It has a repeatable gain on the workload it targets, with ordinary cases
   checked for regressions.
3. Time, allocation, peak memory, and code-size tradeoffs are reported.
4. Serial and parallel results are deterministic. Cache keys preserve all
   dependencies; corruption and stale data remain visible.
5. Compiler changes pass the appropriate native, integration, and self-host
   checks. Code-preserving changes should keep exact Wasm bytes. Codegen changes
   can change bytes, but must pass validation and both engine execution tests.

Keep every runtime algorithm in ordinary Dew library code. Builtins remain
one-to-one Wasm instructions, explicit unsafe casts, or pure compile-time
queries/assertions. No standard-module path, declaration ordinal, or name
shortcut may select a special algorithm.

## Work that must not be counted twice

- Bytecode transforms, persistent transform-result caches, private Wago worker
  heaps, and compiled-code reuse already exist.
- Indexed Dew specialization requests, several call/field lookups, imported
  type interning, body result compaction, cache-pack range hashing, and lazy
  cache indexes already exist. Inspect the exact remaining path before a fix.
- Static allocation/code budgets, paired compile benchmarks, CPU profiling,
  native package lanes, and parallel snapshot runs already exist.
- Snapshot fixtures already use a prebuilt compiler and bounded concurrency.
  Multi-target checks already use isolated build directories. See
  [validation performance](validation-performance.md).
- A more aggressive optimizer, a smaller Wasm file, or more workers does not
  by itself prove faster runtime. Historical JSON Set, slice-decoding, SIMD,
  tail-call, and deep-pass losses are controls in the detailed runtime notes.
- Sharing mutable GC references across Wago children would reintroduce the
  collector race and serialization described in the worker report. Keep private
  stores and collectors; exchange checked owned bytes.

The first milestone is a faster serial baseline with lower allocation.
The next is a measured two-worker win within a fixed memory budget.
Only then should wider parallel compilation become a default.
