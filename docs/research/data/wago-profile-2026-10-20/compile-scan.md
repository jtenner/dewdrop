# Wago compile and cache source scan

Date: 2026-10-20. Read-only scan. No build, test, benchmark, or source change was made.

Source root: `/home/dev/Projects/dewdrop/.tmp/wago-transform-host/build-y_uuvb8q/wago`.
Host root: sibling `../host`.
All source references below are relative to the Wago source root unless they start with `../host`.
The other Wago checkout was not used.

## Facts from the source

### Startup path

1. `../host/main.go:18` reads and decodes `wago-lock.json`. It maps lock bindings into selections.
2. `../host/main.go:47` reads `DEW_TRANSFORM_WORKERS`. Values are empty/0/2. This selects guest transform workers; it does not select native compiler workers.
3. `../host/main.go:58` calls `MainWithPluginSet` with an explicit artifact-cache identity: pinned Wago + Facet + patch + worker identity.
4. `cli/runtime/commands/run/command.go:84` resolves settings and compiler options.
5. `cli/runtime/commands/run/command.go:109` loads the runtime and plugins.
6. `cli/runtime/commands/run/command.go:111` loads the module.
7. `cli/runtime/commands/run/module.go:23` reads the whole file. A trusted .wago follows the direct artifact path at :27-40. Raw Wasm uses `Cache.LoadOrCompile` at :42.
8. `cli/runtime/commands/run/command.go:151` creates the instance. :157 invokes the guest. These need separate times from compile/load.

### Cache eligibility and lookup

`cli/runtime/internal/artifactcache/cache.go:45-97`:
- Validate the runtime config.
- Always call `PrepareCompile` before cache lookup (:60).
- Check eligibility.
- Hash the source/config/build ID and read an artifact.
- On a hit, call `prepared.Adopt` (:79).
- On a miss, call `prepared.Compile` (:83), then write the artifact (:90).

`src/wago/runtime.go:539-588`:
- Take a config snapshot, hook snapshot, binding snapshot, and custom-instruction snapshot.
- With source transforms, clone the full source before callbacks (:566), then clone the returned full source after each callback (:582).
- At :587, any source-transform callback OR any registered custom instruction disables automatic artifact caching.
- Compile observers alone do not disable the cache. They run after both compile and adoption in `finishCompile` (:668-688). Source digest cost at :679 applies when an observer exists.

The local transform worker plugin does not itself disable the cache:
`../host/workers.go:24-37` requests import, instance, and caller authorities.
`../host/workers.go:69-170` registers those services, with no source-transform callback or custom instruction.
This scan did not inspect the Facet dependency registration. Whether Facet adds such hooks remains to be checked or logged.

Other forced bypass cases:
- GC code telemetry enabled, or signals-based bounds mode: cache.go:67-70.
- Empty cache directory or no stable build identity: cache.go:100-106.
- Default build identity rejects modified VCS builds and mutable local replacements: cache.go:153-205.
- The pinned host supplies explicit identity (host main.go:58), so this host does not rely on the default Go build identity check (cache.go:146-150).

Cache location:
`cli/runtime/command_environment.go:25-29` uses
`wagopaths.DirsFor(versionString()).Cache/modules`.
Cache key fields at cache.go:108-143:
- cache format 5, OS, architecture
- core features, bounds mode, deferred bounds flag
- max function locals, max memory count
- ordered optimization selection bits
- explicit runtime build ID digest
- source bytes

Compiler worker count is deliberately absent from the key. Tests in
`cli/runtime/internal/artifactcache/cache_workers_test.go:50` describe reuse across worker policies.
Changing `-p` alone must not be taken as proof of a cold compile.

A cache read miss is silent:
- missing/nonregular/symlink file (:239-253)
- size outside artifact limits (:256-261)
- decode, validation, or artifact format/CPU compatibility failure through `ReadFromWithLimits` (:263-266)
- trailing bytes or changed file identity/size (:268-277)
A publication failure is reported on stderr (:90-95).
A hit still pays artifact read/decode/validation, adoption, module binding, observer, and instance cost.

### Cold compiler phases

`src/wago/runtime.go:642` enters `compileWithConfigAndInstructions`.

In `src/wago/api.go`:
- :1129 `wasm.DecodeModuleWithFeatures`
- :1133 resolve effective workers once
- :1141 `wasm.ValidateModuleWithAnalysis`
- :1156 requirement analysis, then product selection
- :1391 `frontend.BuildGCTypeMetadata`
- :1400 frontend support checks
- :1425 `newGCFrameRootPlan`
- :1448 native Railshot compiler
- :1479 onward build type/instance/segment metadata
- :2019 optional CodeImage ownership transfer; this is not by itself proof of executable mapping cost
- :2048-2070 flatten native GC root metadata
- later return completes compile; module adoption still follows in runtime.go:668.

Validation:
`src/core/compiler/wasm/validate.go:133-139` runs module validation on one thread before function validation.
Function validation uses an atomic increasing function index and one reusable validator per worker (:220-272).
Type-cache preparation is serial before parallel validation (:157, :279).

Effective native compiler worker policy:
`internal/functionworkers/policy.go:7-48`.
- 0 = adaptive, 1 = serial, greater than 1 = forced maximum.
- Adaptive stays serial below score `bodyBytes + 64*functions < 16 KiB`.
- Adaptive caps at four workers.
- All modes cap by local function count and `GOMAXPROCS`.
- API default is serial (`src/wago/config.go:352`); effective CLI setting can override it.
- `-p` is compiler/validator parallelism. `DEW_TRANSFORM_WORKERS=2` is a separate guest worker pool.

### amd64 native compilation

`src/core/compiler/backend/railshot/amd64/compile.go`:
- :1644 compute module hints.
- :1661 immutable-table analysis; :1679 host-adapter analysis.
- :1727 inline target analysis.
- :1757 module type cache.
- :1764 choose serial fast path versus worker/ordered join path.
- :1988 parallel entry; allocate worker scratch, arenas, and result slots.
- :2039-2040 atomically claim the next function in original index order.
- :2072 compile a whole function. Work cannot be split within one large function.
- :2119-2122 start workers and wait for all.
- :2157-2198 ordered serial copy to final code, preserving deterministic layout.
- :2201-2245 serial adapter sharing (if selected), literal/stub construction, relocation patching, and bounded prepared-entry resolution.
- Worker pointer-rich scratch is released before the join (:2033-2037).

Hint scan parallel rules are distinct:
- :2556 requires wide-loop-int-constant collection OFF.
- :2660 requires more than one worker, at least twice as many functions as workers, at most 2^18 global scratch entries across workers, nonempty encoded bodies, and at least 16 KiB total bodies.
- Wide-loop constant collection forces the serial hint branch even with many compiler workers.
Thus a parallel compile can still have a large serial hint phase.

`compileFunc` (:3133-3162) calls a single compile attempt (:3155); the current source does not discard a first codegen attempt to retry local pinning.
An isolated large function may still form the worker tail because the queue unit is a whole function.

GC root planning is serial:
`src/wago/gc_frame_roots_linux_amd64.go:95-176` loops over all candidate functions before native workers start.
At :157 it computes local liveness; :163 compacts live locals.
The initial may-collect filter reuses validation facts
(`src/wago/gc_frame_roots.go:30-50`).

Large-module compile has an explicit host GC check:
`src/wago/api.go:2181-2188` returns a `runtime.GC` callback for source >=8 MiB.
Native workers call it once when the shared emitted-byte threshold is reached
(amd64 compile.go:2114-2115).
A GC pause in a cold profile can therefore be deliberate as well as automatic.

## Low-impact timing points for the parent profile run

Add timing only in a separate diagnostic copy. Do not change the pinned input.

Use one stderr record per complete phase, plus one cache-status record. Take timestamps only when diagnostics are enabled. Do not print per instruction or per function on the normal path.

1. Host main: lock-read/decode, provider setup, CLI entry.
2. run command: `LoadRuntime`, `mustLoadModule`, `instantiate`, guest `Invoke`.
3. cache LoadOrCompile: `PrepareCompile`; eligibility reason; key/hash; artifact read; Adopt; fresh Compile; publish.
4. API compile: decode; validation; requirements/product selection; GC type metadata; GC frame-root plan; Railshot; final metadata.
5. amd64 Railshot: hints; adapter/inline/type planning; worker compile wall time; ordered copy; final patch/graph work.
6. If worker tail dominates, record per-worker elapsed time, function count, total Wasm bytes, native bytes, and largest function ID/body size. Add individual slow-function samples only in a later diagnostic run.

Record the resolved compiler worker count and `GOMAXPROCS`, source digest/size, binary ID, bounds mode, telemetry flag, transform-hook count, custom-instruction count, and cache key/status/reason. This distinguishes bypass from a real missing/corrupt artifact.

## Profile candidates, not findings

No timings were collected in this scan. These are source-based hypotheses:
- Repeated cold native compiles caused by a transform hook, custom instruction, signals-based bounds mode, or artifact decode rejection.
- Serial GC root/liveness work before codegen on large GC-heavy modules.
- Serial hint work due to wide-loop constant analysis or hint eligibility rules.
- One large function that holds the last compiler worker.
- Ordered native-code copy, relocation finalization, or bounded prepared call-graph work.
- Whole-source copies in each source transformer.
- Artifact decode/adoption or instance setup after a valid cache hit.
- Explicit runtime.GC checkpoint for source >=8 MiB.

`resolveBoundedPreparedEntries` has a repeated changed-until-stable scan
(amd64 compile.go:1146-1193), so it is a valid profile symbol. It has bounded call-work/depth admission and should not be called quadratic in this workload without measured evidence.

## Existing explain mode limits

`WAGO_EXPLAIN` enables native compiler statistics
(`amd64/stats.go:34`, compile.go:1690).
It changes analysis work:
- detailed hint/residency tracking is enabled at compile.go:1644
- report-only inline candidate analysis runs at :1715
- statistics storage and counters are allocated.

Use explain output as structural evidence, in a separate run from clean wall-time/profile comparisons.
The function stage time is summed per-function CPU/wall durations
(`amd64/stats.go:217-223`), not the worker pool elapsed wall time.
Do not add it to module wall time or treat it as the parallel phase duration.

