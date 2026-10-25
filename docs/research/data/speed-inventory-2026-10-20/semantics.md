# Front end, inference, and cache speed inventory

Date: 2026-10-20. Read-only source review. No build, test, or benchmark was run. No production file was changed. Priorities below rank work for a speed program. A priority does not claim a measured hot spot. Costs are proved from loops; real time and memory gains still need a new profile.

Scope: MoonBit `src/semantic`, compiler driver and standard-loader caches, plus matching Dew code under `self_host/compiler`. The two compilers do not have all the same optimizations. Keep their measurements separate.

## Evidence limits

I read the saved reports `docs/research/compile-scaling-2026-09-14.md`, `compile-hotpaths-2026-09-14.md`, `compile-imports-2026-09-14.md`, `self-host-compiler-profile-2026-08-26.md`, `module-value-scc-inference.md`, `basic-body-type-inference.md`, and the self-host inference merge and compaction notes. I also checked raw `data/compile-imports-2026-09-14/pipeline-128-warm.json`, `self-host.json`, and `data/compile-hotpaths-2026-09-14/profile-before.json`.

The old 128-module warm CLI median was 1.587 s after three fix rounds. Its samples range from 1.536 to 1.827 s. The old Node profile has large hash, copy, import, and allocation costs. It is a profile from before those fixes. It does not prove that these functions still dominate today. Saved A-to-B and B-to-C self-host runs were about 20 s each. Changes to the MoonBit importer did not make the unchanged Dew compiler much faster. The old 30.5-to-13.4 CPU-second field-lookup result is already fixed. Wall time in that report had severe host contention.

## 1. P1 — Stop making family cache records on the no-cache path

**Code evidence:** `src/semantic/infer_basic_bodies.mbt:4518` makes a family artifact for every non-module-let body. `:4627` sends the normal imported inference entry through the family-cache path, then takes only `.inferred` at `:4639`. The no-import entry does the same at `:4552`. `src/semantic/body_inference_family_artifact.mbt:783` scans every module lambda for each body. `:340` allocates and rebases call-expression, call-target, operator-target, and diagnostic arrays. Hit validation also scans all lambdas at `:732`.

**Cost:** Even with family caching disabled, B bodies and L lambdas require B×L root-owner checks. Family records and rebased arrays are then discarded by normal callers. This adds allocation and peak live data before the module merge. This is not a claim that all type arrays are copied: the record spread keeps many arrays shared.

**Change:** Add an explicit request to publish family artifacts, or split normal inference from cache export. Build a flat root-body-to-lambda index once for make and validate. Keep job type graphs and diagnostic checks.

**Expected gain:** Remove cache-only work from all cold/no-cache inference. Make lambda-family assembly linear in total bodies and lambdas.

**Risk and proof:** Cache-enabled results must still contain the root and all nested lambdas in stable order. Compare inferred arenas and diagnostics with artifacts on/off. Measure allocation counts, peak bytes, and time for many small bodies with zero, one, and nested lambdas.

## 2. P1 — Replace the per-expression call-target scan with a mark array

**Code evidence:** `src/semantic/infer_basic_bodies.mbt:1631` scans all `call_expressions` to answer whether one expression is a syntactic call target. `:1648` calls it for each live expression at `:1657`, before restricting work to name and qualified expressions.

**Cost:** E expressions and C calls require O(E×C) checks. A large straight-line function with many small calls can take quadratic work, including checks for literals and other expressions that cannot be function references.

**Change:** Mark target expression indices once when collecting calls. Use an indexed read. As a smaller first step, restrict the query to possible name/qualified targets, but that alone leaves the bad worst case.

**Expected gain:** Linear setup and constant-time classification. One bit or byte per expression is sufficient.

**Risk and proof:** Preserve call-target consumption, overloaded reference selection, and poison behavior for imported call names. Count queries and call-list visits. Scale a body from hundreds to thousands of calls. Include first-class function values and calls through locals.

## 3. P1 — Reuse Dew solver state and module indexes across body jobs

**Code evidence:** `self_host/compiler/semantic_basic_body_inference.dew:8413` creates one inferencer per body. `:551` creates a fresh `SelfHostLocalTypeSolver` at `:566`. `new_with_solver` rebuilds a member-type context when it is absent at `:580`, then scans all collected callables at `:583` to find the current body owner. In contrast, MoonBit builds declaration indexes at `src/semantic/infer_basic_bodies.mbt:4365`, creates one solver at `:4387`, and resets it between jobs at `:4442`.

**Cost:** Dew repeats solver-array allocation, member-context setup, and a callable-list search for each body. The callable search is quadratic when callable and body counts grow together. The context cost can scale with module type/field size for each tiny function.

**Change:** Pass a module-owned callable index and immutable member context into jobs. Use one resettable solver/scratch set per worker. Freeze or copy each published job result before reusing solver storage.

**Expected gain:** Fewer short-lived objects and scans in the self-host compiler. This is a direct parity opportunity with the existing MoonBit design.

**Risk and proof:** The current Dew finalization can retain solver arrays in error cases; those arrays must not alias a later reset. Test error bodies, captures, nested lambdas, snapshot rollback, and sequential jobs with different sizes. Measure bytes per body and peak memory as well as CPU time. Do not claim a MoonBit gain for this item.

## 4. P1 — Hash each settled interface's body evidence once per compile

**Code evidence:** `src/standard_loader/body_inference_cache.mbt:335` sorts imported interfaces and calls `frozen_interface_body_evidence_fingerprint` for each dependency at `:358`. That fingerprint at `src/semantic/frozen_interface_cache.mbt:461` allocates normalized copies of declaration, field, variant, callable, parameter, and implementation records, serializes the whole interface at `:502`, and hashes it at `:504`. The same helper is used for each module's family context at `body_inference_cache.mbt:207` and again by fragment program context at `src/standard_loader/planning_cache.mbt:176`.

**Cost:** A common large imported interface is copied, serialized, and hashed once per importer and again across cache layers. Dense imports can approach M² interface visits. A large preamble or utility interface creates high fan-out even on sparse graphs.

**Change:** Keep per-compile evidence-digest slots keyed by exact module/interface state. Invalidate a slot when deferred interface types change. Also permit serialization without allocating normalized record copies by using a writer mode that writes zero locations.

**Expected gain:** Remove repeated arena copies and hash work from warm-cache builds and module misses. Index storage is linear in module count.

**Risk and proof:** `analyze_program_semantics_with_body_cache` explicitly states at `:879` that body inference can complete earlier interfaces. A digest memo keyed only by module number is unsafe before that barrier. Compare cached and full recomputation after all deferred updates, and keep concrete identity, evidence, and dependency distinctions. Measure serialization count, bytes hashed, and peak allocations on high fan-out imports.

## 5. P2 — Reuse source digests and stable cache-key parts across cache layers

**Code evidence:** `body_inference_source_digest` copies every file into a buffer and hashes it at `src/standard_loader/body_inference_cache.mbt:309`. It is called by body lookup at `:492` through `:398`, then again by store at `:569`. Layout keys call it at `src/standard_loader/planning_cache.mbt:114`. Fragment program context calls it for all modules at `:168`, and per-module fragment keys call it at `:194`. Source is immutable after transform expansion.

**Cost:** Each enabled layer recopies and hashes the same module bytes. Cold misses can repeat lookup/store work. This scales with source bytes times the number of active cache operations. It is linear rather than a new quadratic claim.

**Change:** Make one compilation fingerprint context after transforms. Cache source digests there. Reuse full keys only after their interface state is settled. Prefer a streaming hash over constructing a second full source buffer if the hash API supports it.

**Expected gain:** Lower hash CPU time and temporary memory on large source files, including warm builds.

**Risk and proof:** Keep paths, module IDs, source lengths, default preamble, planner policy, and compile identity in the same identity rules. A source-only memo can be safe earlier than an interface memo. Count bytes copied and hashed per compilation with caches off, cold, warm, and after a private edit.

## 6. P1 — Update an existing body-family bundle after a partial miss

**Code evidence:** `src/standard_loader/body_inference_cache.mbt:802` restores matches from an existing bundle, infers all misses at `:817`, but publishes a new bundle only under `if existing is None` at `:828`. The key test at `src/standard_loader/body_inference_cache_wbtest.mbt:283` proves that a private declaration can change its own key while the other family keys stay the same.

**Trigger and cost:** Build the original module with family caching. Edit private function A without changing its names or interface. A misses in the old bundle and is inferred, but the new A artifact is never saved there. Now edit private function B. The exact-module cache misses again, and unchanged edited A also misses the old family bundle. Repeated editing keeps paying for bodies changed since the first bundle. An exact repeat can still hit the complete-module cache; this is not a claim that every identical build reinfers A.

**Change:** After any family miss, merge current valid artifacts into the bundle and replace its entry. Keep a bounded policy for old versions if they are useful. Do not write only on an absent bundle.

**Expected gain:** Restore intended incremental body reuse across a sequence of private edits.

**Risk and proof:** Keep context identity and corruption validation. Test three builds in sequence: original, edit A, edit B. On the third build, A must be a family hit. Compare emitted bytes and diagnostics with cache disabled. This is a source-confirmed policy gap; no runtime reproduction was run in this scan.

## 7. P2 — Hash family source ranges without copying each declaration

**Code evidence:** `src/standard_loader/body_inference_cache.mbt:101` groups and sorts declarations by file. `:152` makes a fresh buffer per declaration and copies each source byte in a loop. The resulting `Array[Bytes?]` is retained for module-value and per-family hashing at `:165` and `:283`.

**Cost:** Family-key setup allocates one owned byte string per declaration and copies most of each source file before hashing. It runs on each whole-module body-cache miss even if most families hit. Sorting and grouping add work when source ranges are already available from collection.

**Change:** Retain stable `(file, start, length)` declaration ranges in the collected artifact, or build them once for cache use. Feed ranges to a streaming/range hash without owning separate copies. Reuse range digests where safe.

**Expected gain:** Lower temporary memory and per-edit work in large modules with many declarations.

**Risk and proof:** Current source boundaries include whitespace/comments through the next declaration. Keep exact key behavior first. Methods, derived declarations, equal offsets, and trailing source need explicit cases. Measure total copied bytes and allocation count; do not assume ranges overlap quadratically.

## 8. P1 — Narrow fragment cache dependencies after recording whole-program facts

**Code evidence:** `src/standard_loader/planning_cache.mbt:148` writes every module's path, ID, full source digest, interface digest, and evidence into one program context. `:189` includes that context in every module's fragment key. `:675` then looks up every fragment. Any source-byte edit changes all those keys.

**Cost:** A private body edit invalidates all module fragments. Even modules with unchanged local source and unchanged imported ABI miss. The cache still helps exact repeat builds, but gives no module-level fragment reuse for such edits.

**Change:** Split immutable local fragment data from whole-program choices. Record which global facts each fragment used: callable liveness, function-value roots, runtime trait support, and generic-enum instantiations. Hash those facts plus local and actual dependency identity. A first safe step is to separate independent layout/signature portions from usage-sensitive portions.

**Expected gain:** Reduce post-edit planning work from the entire program toward the changed dependency region. This is an architecture change, not a small key deletion.

**Risk and proof:** Current global context is conservative for good reasons. `src/semantic/program_specialization_plan.mbt:3025` computes selected demand and callable roots; `:3036` computes generic enum instantiations; `:3070` onward chooses cacheable fragments. Generic-enum usage can make even an unchanged defining module need new layouts. Keep this bypass and test imported generics, trait dictionaries, exports, and call/reference liveness against uncached output. Measure exact repeat and private edit workloads separately.

## 9. P1 — Wake only constraints affected by a newly known type

**Code evidence:** `src/semantic/infer_basic_bodies.mbt:3200` repeats pending calls/operators/methods, runs `constrain_members(false)` twice per round, and stops only when no progress occurs. Each `constrain_members` at `src/semantic/infer_members_and_constructors.mbt:645` scans the full body several times, starting at `:652`, `:668`, and `:725`. Dew repeats pending-field scans at `self_host/compiler/semantic_basic_body_inference.dew:8267`; `constrain_pending_fields` at `:6637` allows up to F passes over F pending fields.

**Cost:** A valid dependency chain that resolves only one pending item per round can require quadratic visits. The current progress guards prove termination but not low cost. Deep field/call/index chains are the key workload, not a broad claim that all bodies are quadratic.

**Change:** Keep pending constraints indexed by unresolved type-variable root or by expression inputs. Queue dependents when union/find or member selection makes those inputs ready. Start with a compact unresolved-member queue so resolved and irrelevant expressions are not scanned every round.

**Expected gain:** Reduce retries and full-body scans for long mixed constraint chains.

**Risk and proof:** Union-find root changes, rollback/snapshots, guarded branches, expected types, and late member projections can wake more than one dependency. Keep deterministic diagnostics and a visible stuck-constraint path. Add visit counters and scale reversed field/method/index chains. The pathological runtime size is unmeasured here.

## 10. P1 — Index materialized MoonBit specializations by exact key

**Code evidence:** `src/semantic/program_specialization_plan.mbt:1070` searches every function in an owner module for each materialization request. It compares declaration and ABI key, then checks structural shapes. The base function already has an indexed lookup at `:1091`. Dew has declaration-local request indexes at `self_host/compiler/semantic_program_specialization_index.dew:100` and exact shape/evidence checks; those are existing work to preserve.

**Cost:** R requests in a module with F base/materialized functions cause O(R×F) search. F grows with requests, so many distinct specializations can cause quadratic work even before planning each body.

**Change:** Add a per-module map from exact declaration and ABI identity to function index. Seed it from restored fragments. Preserve the structural shape check on hits rather than trusting a hash alone.

**Expected gain:** Make lookup scale with requests, apart from key construction and shape checking.

**Risk and proof:** Preserve logical compile-time type distinctions, erased fallback visibility upgrades, trait evidence, hidden arguments, and first materialization order. Compare many distinct and many repeated requests. Measure code size too: a quicker request path must not permit duplicate functions or unbounded specialization growth.

## 11. P1 — Index MoonBit specialized-call replay checks

**Code evidence:** `src/semantic/program_specialization_plan.mbt:1449` scans all prior calls at `:1459` for `(caller body, caller ABI key, expression)`. Function references have the same pattern at `:1539`. These arrays are program-wide. Dew appends at `self_host/compiler/semantic_program_specialization.dew:535` and verifies with nested exact integer maps at `:559`, rather than a scan for every insert.

**Cost:** C unique records require roughly C²/2 identity comparisons. Long string ABI comparisons can add cost. A large generic call graph makes this independent of the function-scan issue above.

**Change:** Use a stable identity-to-record index, then invoke the existing complete replay check on a hit. Keep deterministic append order. Intern ABI identities if string cost is measured.

**Expected gain:** Linear expected record construction plus replay verification, with linear index storage.

**Risk and proof:** Never drop the target/evidence mismatch check at `:1488`; it catches real inconsistent replay. Test same-key same-target, different target, different ABI, and different forwarded evidence. Benchmark one caller with many calls and many specialized callers. Do not report this as an unfixed Dew scan.

## 12. P2 — Add path indexes where they are still absent

**Code evidence:** Dew `self_host/compiler/semantic_module_interfaces.dew:51` finds a module path by scanning the full path array. `self_host/compiler/semantic_program_interfaces.dew:251` also scans all earlier module paths to find duplicates; `:285` scans earlier files. Missing-import checks at `:373` use the linear path lookup. The MoonBit compiler already uses `CollectedProgram.module_lookup` at `src/semantic/module_system.mbt:148`. However, its transform source-pool closure at `src/compiler_driver/source_pool.mbt:26` reparses import prefixes and scans every pooled candidate at `:35` for each import, repeating the closure after expansion at `:106`.

**Cost:** Dew exact imports cost O(import count × module count), and manifest duplicate checking is quadratic. The optional MoonBit source-pool path has a similar candidate scan, and repeated transform expansion can revisit already scanned source prefixes. Wildcards inherently visit matches, but need not scan every unrelated module.

**Change:** Build exact path-to-first-index maps for Dew manifests and source pools. Keep ordered prefix buckets or a sorted path table for wildcards. Memoize import-prefix results by source identity across closure rounds. Preserve source order when appending selected modules.

**Expected gain:** Better scaling for many modules/imports and large transform source pools. This is not an unfixed exact-lookup defect in MoonBit's collected-program graph.

**Risk and proof:** Duplicate diagnostics must still name the first source position. Wildcards must keep exact namespace boundary rules, self-import handling, and stable selected IDs. Test duplicate modules/files, absent imports, wildcard prefixes, and transforms that add imports. Measure ordinary and source-pool builds separately.

## 13. P2 — Reuse settled module-value inference across interface and body stages

**Code evidence:** MoonBit freezes public module values using `infer_frozen_module_values` at `src/semantic/module_system.mbt:4005` and again on the SCC repeat path at `:4043`. That helper resolves names at `:3862` and imports at `:3871`. Body analysis resolves names/imports again at `src/semantic/imported_semantics.mbt:921`, and body inference calls `infer_module_values_internal` at `src/semantic/infer_basic_bodies.mbt:4373`. Dew infers values during signature freezing at `self_host/compiler/semantic_program_interfaces.dew:488`, then again in lowering at `self_host/compiler/semantic_program_lowering.dew:1758`; body inference itself includes all collected bodies at `semantic_basic_body_inference.dew:8413`.

**Cost:** Modules with public inferred values repeat dependency/name/import work and constraints. Cyclic imports can require extra signature-stage passes. This can be significant for modules that use large initializers. Modules with no public module lets do not take the same signature-inference path.

**Change:** Preserve a validated module-value job artifact from the last interface pass and pass it into final body inference. Key it by the settled resolved/import scope and source identity. Consider keeping name resolution too when its scope is unchanged.

**Expected gain:** Avoid repeated inference for large initializers and reduce duplicate scratch allocation.

**Risk and proof:** Early signature passes can be provisional. Reuse only after the import SCC has settled. Preserve module-let SCC solver sharing, forward references, unconstrained recursive-value errors, and physical initializer dependencies. Compare public inferred values, private lets, generic applied values, and cyclic imports. Count stage-specific inference runs before seeking a time claim.

## 14. P2 — Remove Dew's full provisional signature/type pass where a graph skeleton is enough

**Code evidence:** `self_host/compiler/semantic_program_interfaces.dew:399` resolves types and freezes every module without imported interfaces at `:408`. It then builds all provisional import scopes at `:422`, obtains a module graph at `:444`, copies provisional interfaces/scopes at `:448`, and resolves/freezes each module again in graph order at `:478`. Cyclic SCCs receive two of these final passes at `:462`. Lowering rebuilds the module graph at `self_host/compiler/semantic_program_lowering.dew:1736`.

**Cost:** Every module pays at least one extra whole-module type-resolution/freeze pass, even for a simple acyclic exact-import graph. The graph and provisional scopes also have extra live storage. This is a separate Dew cost; MoonBit constructs its dependency graph directly from collected imports at `src/semantic/module_system.mbt:1523`.

**Change:** Build the import dependency graph from collected import records first. Seed only declaration/type heads needed for cyclic resolution. Run full imported resolution once for acyclic modules, with explicit cyclic SCC completion. Carry the graph into lowering rather than recreating it.

**Expected gain:** Less front-end work and temporary data for the self-host compiler, especially a large acyclic package.

**Risk and proof:** Provisional interfaces may supply nominal IDs and constructor evidence needed by cyclic modules. Do not remove them without listing consumers. Test forward imported types, aliases, public inferred lets, constructors, and cycles. Profile each pass and compare exact output before deciding whether a lighter skeleton earns its complexity.

## 15. P1 — Use bounded worker queues at existing immutable result boundaries

**Code evidence:** Parse-event work is serial per file at `src/standard_loader/parse_event_cache.mbt:354`. Function root jobs are serial at `src/semantic/infer_basic_bodies.mbt:4406`, after module-value inference at `:4373`. Lambdas read already completed parent jobs at `:4487`. Final merging is already a separate function at `:3794`. Module analysis is serial in SCC order at `src/semantic/imported_semantics.mbt:915`. Module layout jobs are serial at `src/standard_loader/planning_cache.mbt:579`. Backend-neutral module lowering has preallocated result slots and a module-local loop at `src/semantic/program_link_plan.mbt:501`. Fragment jobs at `program_specialization_plan.mbt:3059` follow whole-program demand and liveness computation.

**Change and safe order:**

1. Parse selected files in parallel after transforms finish. Return immutable parse events in stable file slots. Build shared cache-pack output in one writer stage or use a safe merge; do not let workers mutate the current pack unsafely.
2. Infer independent root-body families in parallel after frozen module values. Give each worker its own solver, call scratch, importer caches, and diagnostics. A family includes its descendant lambdas. Run parent before child and use the existing stable body/lambda IDs in the final merge. This has a much clearer ownership boundary than sharing one union-find solver.
3. Compute per-module type layouts and backend-neutral lowering in parallel once semantic inputs and program-wide raw-array/reference facts are fixed. Write one stable slot per module. Keep whole-program query folding and optimization barriers after those jobs.
4. Run ready import SCCs on a graph frontier, rather than all modules in one flat order. Keep each cyclic SCC as an ordered unit until a safe interface-fixpoint design exists. Deferred type completion currently mutates earlier interfaces (`src/standard_loader/body_inference_cache.mbt:879`), so freezing needs a stricter immutable result barrier before this becomes safe.
5. Plan independent base fragments in parallel after selected-demand, liveness, trait-use, and generic-enum facts are fixed. Merge specialization requests deterministically. Do not parallelize mutation of the shared specialization arrays without a separate request collection and merge design.

**Expected gain:** Use several CPU cores on large modules and many-module packages. Bounded workers cap per-worker scratch and retained job data. File parsing and root families are the best first experiments; a long import chain still limits graph-level parallelism.

**Risk and proof:** There is no verified thread/worker ABI or measured transport cost in this scan. A JavaScript worker that copies the whole HIR per task can lose the gain and multiply memory. Measure 1/2/4/8 workers with raw elapsed time, CPU time, serialization bytes, peak memory, queue sizes, and output determinism. Include skewed bodies so one huge job does not leave all other workers idle. Do not infer a parallel speedup from independent-looking loops alone.

## Already fixed, or not supported by this scan

- MoonBit exact module-path lookup is already a map (`module_system.mbt:148`). Do not add a second map for that path.
- Module-value graph extraction already uses generation marks, flat edges, and iterative SCCs. A generic recursive-SCC rewrite is not a new opportunity. Independent SCC scheduling can still be useful.
- MoonBit already reuses a solver and call scratch across bodies. The fresh-solver issue above applies to Dew.
- Import type interning already uses structural maps. The old full-arena intern scan was fixed and measured in the September import audit.
- Interface content-hash reuse for completed modules, requested-root hashing, saved-index binary search, and loaded cache owner buckets were already added. Do not quote their old costs as current defects.
- Dew specialization requests already use declaration-local indexes and queue cursors. MoonBit call-record and materialized-function scans remain separate findings.
- Self-host body output already has compaction. Error bodies keep original arenas to preserve diagnostics. A claim that every published body retains all dead solver terms is false.
- Parse-event preparation checks `file.parse_events` first at `parse_event_cache.mbt:260`. Repeated collection does not always reparse each file. The import-prefix work in the optional source-pool closure is a narrower case.
- Layer body caches are opt-in in `body_inference_cache.mbt:50`. All family-cache gains must state that mode. The family-artifact overhead in item 1 still occurs when those caches are disabled.
- There is no current native/WasmGC/JavaScript cross-target profile in this scan, no new allocation data, and no benchmark proof of the proposed gains. Historical profiles are evidence for what to measure, not a new baseline.

## Suggested first measurement sequence

Use the root agent's single measurement lane. First count call-target list visits, family artifact builds/lambda visits, Dew solver/context creation, fingerprint calls/bytes, and constraint retries. Then compare time and memory on: many tiny bodies; one large call-heavy body; nested lambdas; long field/method/index chains; high fan-out imports; many distinct generic instances; and private-edit sequences. Test cold, exact-repeat, and incremental modes separately. Keep compiler identity, source hash, output hash, cache state, and host load with each sample. Fix the proven repeated work before measuring a worker pool, so the pool does not hide avoidable serial cost.
