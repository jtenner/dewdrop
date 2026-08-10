# Temporary architecture TODO

> Created August 10, 2026 from the architecture review of recent Dewdrop work.
> This is a temporary coordination list, not a permanent roadmap or specification.
> Remove this file once the work has been moved into stable plans, completed, or
> deliberately rejected with its reasoning recorded in `docs/research/`.

## Working rules

- Preserve runtime performance, low memory use, deterministic output, and flat
  arena storage unless measurements justify a change.
- Use characterization tests and benchmarks before moving hot compiler code.
- Keep each architecture commit atomic and behavior-preserving where possible.
- Prefer deep modules with small interfaces over abstractions that merely move
  code between files.
- Apply the deletion test: an extracted concept should be removable without
  leaving its former owner incoherent.
- Update this list in the same commit as completed, superseded, or rejected work.
- Do not let this file become a second permanent roadmap.

## Phase 1: establish boundaries and shared entry points

- [x] **Document the current compiler architecture and intended phase boundaries.**
  - [x] Add a concise package and compiler-phase diagram.
  - [x] Record ownership of IDs, flat arenas, frozen interfaces, standard-library
        identities, caches, specialization plans, and backend plans.
  - [x] State which phase boundaries are immutable and which transformations are
        intentionally in-place.
  - [x] Start a lightweight decision log for architecture choices that span more
        than one research note.
  - Relevant areas: `README.md`, `docs/research/`, `src/*/moon.pkg`.

- [x] **Add one compiler pipeline facade for tools and generators.**
  - [x] Define compile options, requested artifacts, diagnostics, cache status,
        and test/production planning mode.
  - [x] Centralize collect → analyze → lower → link → emit sequencing.
  - [x] Make command executables responsible only for input parsing, output
        framing, and process exit behavior.
  - [x] Migrate `dew_cli`, snapshot generation, test generation, string
        benchmarks, and parity generators incrementally.
  - Relevant files: `src/dew_cli/main.mbt`, `src/module_snapshot_gen/main.mbt`,
    `src/dew_test_gen/main.mbt`, `src/string_bench_gen/main.mbt`,
    `src/swar_parity_gen/main.mbt`, `src/utf_parity_gen/main.mbt`, and
    `src/wasi_parity_gen/main.mbt`.

- [x] **Formalize the Python-host/MoonBit-compiler protocol.**
  - [x] Replace repeated internal CLI arguments and environment-variable policy
        with one versioned compile request.
  - [x] Include ordered modules/files, the root module, dependency interface
        expectations, standard-library policy, cache policy, build mode, and
        requested outputs.
  - [x] Keep package resolution and host execution separate from compiler phase
        orchestration.
  - [x] Preserve a straightforward path from the Python bootstrap driver to
        future Dew-native tooling.
  - Relevant files: `tools/dew-cli.py`, `tools/dew`, `src/dew_cli/main.mbt`, and
    `src/standard_loader/`.

- [x] **Add reusable compiler test builders.**
  - [x] Provide ordered single- and multi-module source builders.
  - [x] Provide stage-specific analyze, lower, link, emit, and diagnostic helpers.
  - [x] Keep semantic tests from requiring backend emission unless emission is
        the behavior under test.
  - [x] Keep backend tests from manually reconstructing the complete compiler
        pipeline and diagnostic count.
  - Relevant files: `src/semantic/*_wbtest.mbt` and
    `src/backend/*_wbtest.mbt`.

## Phase 2: make program optimization and linking explicit

- [x] **Create an explicit program-optimization phase.**
  - [x] Separate construction of module lowering from interprocedural rewriting.
  - [x] Extract callable effect summaries.
  - [x] Extract transparent callback directization.
  - [x] Extract generic parameter-selector rewriting.
  - [x] Extract runtime-trait flow directization and wrapper elision.
  - [x] Define a clear optimized-lowering result or equivalent phase boundary.
  - [x] Preserve a valid unoptimized path for future baseline/optimized snapshot
        contracts.
  - Relevant file: `src/semantic/program_link_plan.mbt`, especially the work
    currently performed before and inside `plan_program_lowering`.

- [x] **Separate specialization and evidence planning from physical linking.**
  - [x] Give generic specialization identity and worklists one owner.
  - [x] Give runtime-evidence normalization and forwarding one owner.
  - [x] Give trait dictionary and evidence-closure materialization one owner.
  - [x] Produce a compact validated specialization plan for the linker.
  - [x] Keep recursive physical type groups, initializer scheduling, final
        function/global/type indices, and link diagnostics in the physical
        linker.
  - Relevant file: `src/semantic/program_link_plan.mbt`.

- [x] **Create one immutable program index used by optimization and linking.**
  - [x] Centralize module, declaration, body, implementation, type-owner, and
        variant-owner lookup without duplicating owner maps already encoded in
        packed semantic identities.
  - [x] Stop rebuilding `Map[ModuleId, Int]` throughout program planning.
  - [x] Replace concatenated specialization lookup strings with a canonical
        typed key.
  - [x] Validate the index once before hot planning loops use it.
  - Relevant files: `src/semantic/program_link_plan.mbt` and related program
    planning tests.

## Phase 3: reorganize backend emission

- [x] **Extract backend adapter compilation from ordinary instruction emission.**
  - [x] Move erased aggregate adapters into a cohesive planner/emitter.
  - [x] Move callback wrappers and recursive adapter helpers with them.
  - [x] Move runtime-evidence closures and captured trait dictionaries with them.
  - [x] Make ordinary body emission consume completed adapter plans rather than
        discovering adapter architecture while emitting instructions.
  - Relevant file: `src/backend/starshine_code.mbt`.

- [x] **Unify the shared core of single-module and linked-program emission.**
  - [x] Define the narrow operations expression emission needs for function,
        type, runtime, module, and specialization lookup.
  - [x] Reuse instruction, pattern, local, capture, and call emission where the
        behavior is genuinely identical.
  - [x] Keep separate module/program assembly paths where unification would add
        hot-path indirection or obscure index ownership.
  - [x] Consolidate duplicated section and runtime lookup behavior after the
        shared context is proven by tests and benchmarks.
  - Relevant file: `src/backend/starshine_code.mbt`.

- [x] **Separate backend module assembly from instruction generation.**
  - [x] Isolate type, import, function, global, export, element, and code section
        assembly.
  - [x] Isolate validation and binary encoding from Starshine instruction
        construction.
  - [x] Keep deterministic index assignment in plans rather than rediscovering
        semantic relationships during assembly.
  - Relevant files: `src/backend/starshine_code.mbt`,
    `src/backend/wasm_custom_sections.mbt`, and `src/backend/starshine_fragments.mbt`.

## Phase 4: tighten semantic and standard-library ownership

- [x] **Audit and reduce the semantic package's public surface.**
  - [x] Identify public declarations used only by tests or by another semantic
        file in the same package.
  - [x] Identify the minimal data contracts needed by the backend, standard
        loader, and compiler driver.
  - [x] Group model/IR, semantic analysis, and program planning behind clearer
        package or facade boundaries.
  - [x] Avoid package splitting that copies large arenas or adds unmeasured
        runtime/compiler overhead.
  - Relevant files: `src/semantic/pkg.generated.mbti`, `src/semantic/moon.pkg`,
    `src/backend/moon.pkg`, and `src/standard_loader/moon.pkg`.

- [ ] **Generate a canonical standard-library identity and builtin registry.**
  - [ ] Replace manually maintained module slots and declaration ordinals for
        Option, FixedArray, Map, Set, lanes, methods, and index implementations.
  - [ ] Replace integer builtin operation codes with typed operation kinds.
  - [ ] Generate or validate the registry from one canonical declaration source.
  - [ ] Fail visibly when `std/*.dew`, bootstrap mirrors, and compiler identities
        diverge.
  - [ ] Make future Array and collection additions extend the registry rather
        than add more hardcoded identity branches.
  - Relevant files: `src/semantic/module_system.mbt`,
    `src/semantic/infer_basic_bodies.mbt`, `src/semantic/lowering_plan.mbt`,
    `src/semantic/wasmgc_fragment_plan.mbt`, and
    `src/backend/starshine_code.mbt`.

- [ ] **Move embedded bootstrap standard sources out of semantic analysis.**
  - [ ] Give generated fallback source bytes a dedicated package or owner.
  - [ ] Keep source loading and provenance in `standard_loader`.
  - [ ] Make semantic collection consume an ordered source provider without
        owning generated standard-library assets.
  - [ ] Preserve byte-identity checks between on-disk and bootstrap providers.
  - Relevant files: `src/semantic/standard_*_sources.mbt`,
    `src/semantic/standard_*_preamble.mbt`, and `src/standard_loader/`.

- [ ] **Generalize the frozen-interface cache architecture.**
  - [ ] Rename standard-only cache concepts now used for external dependencies.
  - [ ] Separate cache envelope/I/O, cache-key provenance, cacheable-module
        selection, and semantic analysis using cached slots.
  - [ ] Replace expanding Boolean policy parameters with an explicit bundle
        policy.
  - [ ] Prepare the substrate for later workspace-module and artifact-only
        interface caching without changing current corruption behavior.
  - Relevant file: `src/standard_loader/interface_cache.mbt`.

## Phase 5: simplify inference and arena contracts

- [ ] **Decompose `BasicBodyInferencer` into focused collaborators.**
  - [ ] Extract trait obligation solving and evidence construction first.
  - [ ] Separate callable/overload resolution from expression traversal.
  - [ ] Separate member, method, operator, and indexing resolution where their
        worklists and invariants are independent.
  - [ ] Separate pattern inference and result compaction.
  - [ ] Retain shared scratch arrays and one solver to avoid allocation-heavy
        object graphs.
  - [ ] Benchmark every extraction against existing inference workloads.
  - Relevant file: `src/semantic/infer_basic_bodies.mbt`.

- [ ] **Encapsulate flat arena bundles while preserving flat storage.**
  - [ ] Introduce logical views for lowered bodies, types, call specialization,
        trait evidence, program functions, and program types.
  - [ ] Centralize span slicing, sentinel interpretation, and debug validation.
  - [ ] Validate arena relationships at phase boundaries so hot loops can use
        direct indexed access safely.
  - [ ] Avoid replacing compact IDs and arrays with allocation-heavy object
        graphs or pervasive boxed options.
  - Relevant files: `src/semantic/lowering_plan.mbt`,
    `src/semantic/wasmgc_fragment_plan.mbt`, and
    `src/semantic/program_link_plan.mbt`.

- [ ] **Extract small reusable iterative traversal primitives.**
  - [ ] Centralize aligned task/state/result-stack handling.
  - [ ] Add debug assertions for parallel stack lengths and finish-state
        contracts.
  - [ ] Share applied/function result assembly where representations match.
  - [ ] Reuse generation-mark storage where it reduces repeated bookkeeping.
  - [ ] Reject a universal callback-heavy visitor if benchmarks show overhead or
        if it hides phase-specific invariants.
  - Relevant files: `src/semantic/alias_normalization.mbt`,
    `src/semantic/infer_basic_bodies.mbt`, `src/semantic/impl_index.mbt`,
    `src/semantic/resolve_types.mbt`, `src/semantic/imported_semantics.mbt`,
    `src/semantic/local_unification.mbt`, and `src/semantic/hir_types.mbt`.

## Phase 6: make validation orchestration data-driven

- [ ] **Reduce `tools/check.sh` to a deterministic top-level scheduler.**
  - [ ] Keep clearly named quick and full profiles.
  - [ ] Move cache, ABI, external-consumer, custom-section, and WAT assertions
        into focused runners.
  - [ ] Preserve deterministic per-target logs and fail-visible errors.
  - [ ] Keep each runner directly executable for focused development.
  - Relevant file: `tools/check.sh`.

- [ ] **Describe ABI, performance, and WAT assertions declaratively.**
  - [ ] Extend the existing performance-budget data model where appropriate.
  - [ ] Describe provider fixture, optional consumer, invocation, expected value,
        required/forbidden WAT properties, and metric budget in case data.
  - [ ] Replace repeated build → parse → consume → grep shell blocks.
  - [ ] Keep intentional snapshot and budget updates explicit and reviewable.
  - Relevant files: `tests/performance-budgets/`, `tools/wasm-metrics.mjs`,
    `tools/dew-wasm-consumer.mjs`, and `tools/check.sh`.

## Exit criteria for this temporary file

Delete `architecture-todo.md` when all remaining unchecked items have one of
these homes:

1. completed implementation and documentation;
2. a stable roadmap entry with an executable scope;
3. a focused `docs/research/*.md` plan with measurements and prerequisites;
4. a recorded decision to reject or defer the opportunity.

Before deletion, verify that the permanent documentation includes the final
compiler phase map, package ownership, and the location of every continuing
architecture initiative.
