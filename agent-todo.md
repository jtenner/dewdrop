# Dew Agent TODO

> Execution-only backlog synchronized with [`docs/roadmap.md`](docs/roadmap.md) on August 16, 2026. Completed work is intentionally omitted. Each implementation tranche should land with focused tests, documentation, measurements where relevant, and one bounded atomic commit.

## P1 — self-hosting

1. Pin the Starshine `.mbti` interfaces, generate direct typed guest exports and Dew foreign declarations for the public module-building API, and include the interface digests and exact guest bytes in deterministic compiler fingerprints.
2. Build one linked smoke compiler that reads the frozen source-Bytes request and emits one module.
3. Port tokenizer, parser, semantic analysis, optimization, backend, cache codecs, and the compiler driver to Dew in dependency order.
4. Add the fixed-point bootstrap test: MoonBit builds A, A builds B, B builds C, and B/C are byte-identical.

Use [`docs/research/self-hosting-compiler-gap-catalog-2026-08-16.md`](docs/research/self-hosting-compiler-gap-catalog-2026-08-16.md) for the audited host, Wasm, collection, and port-surface gaps. Port-enabling options in that catalog remain decisions, not active backlog items, until explicitly selected.

Indexed implementation uniqueness, mutable struct fields, and complete `@alias` namespace lookup are finished and therefore omitted from this execution-only backlog.

## P2 — deferred until self-hosting

Every unchecked item below is P2 unless the P1 compiler port proves it is a concrete blocker. Package acquisition, work budgets, optional arguments, annotations, ordinary Boolean `while`, higher-kinded types, negative implementations, TOML, formatter/documentation/LSP work, release infrastructure, and parallel compilation remain deferred.

## Incremental compilation

- [ ] Add hundreds-of-files and representative external-package stress workloads.

Parallel module/body jobs, completion-order tests, and parallel-output checks are intentionally absent from this execution backlog. MoonBit cannot run these compiler jobs in parallel. They become active work only after Dewdrop is self-hosted and Dew supports parallel computation; see [`docs/decisions/0002-parallel-compilation-after-self-hosting.md`](docs/decisions/0002-parallel-compilation-after-self-hosting.md).

## Post-release performance work

The current measured baseline is fast enough for the first release. These items
are follow-up hardening and observability work, not release blockers.

- [ ] Define compiler budgets for graph size, nesting/width, alias expansion, inference, trait search, pattern usefulness, specialization growth, and diagnostic volume.
- [ ] Diagnose budget exhaustion deterministically without panic or partial cache publication.
- [ ] Add opt-in runtime allocation and phase counters with zero production overhead.
- [ ] Track compile, validation/encoding, runtime time, compiler allocations, and peak memory with warmup and variance.
- [ ] Extend aligned-pack phase-cache admission measurements beyond the implemented 100-module startup benchmark to larger external-package and heavy-inference workloads before changing the default body-cache policy.
- [ ] Establish reviewed cross-engine regression thresholds for hot workloads; Array growth now has reproducible scalar-loop versus WasmGC `array.copy` measurements.
- [ ] Benchmark Array growth, large reference copying, write barriers, and GC behavior on each supported WasmGC runtime.
- [ ] Add representative heap, ordered-tree, queue, JSON, and generated typed-decoder performance suites.
- [ ] Use runtime allocation evidence to evaluate proof-driven constructor/store forwarding, physical nominal propagation, and private `Result` forwarding.
- [ ] Benchmark thresholded exact-`Set` JSON duplicate tracking only for substantially wider objects.
- [ ] Benchmark reusable nested JSON structural indexes only for repeated selective lookups with explicit ownership and memory contracts.
- [ ] Audit integer conversions, packed identities, and malformed-input-driven indexing.

## Modules, imports, packages, and visibility

- [ ] Define duplicate identical imports, opens, and aliases across files with both source locations.
- [ ] Decide and define selective imports.
- [ ] Define re-exports and package visibility if needed.
- [ ] Define canonical standard operator-trait identities and diagnose conflicting local declarations.
- [ ] Decide import and canonical-preamble shadowing rules.
- [ ] Decide whether source syntax is needed for default-preamble opt-out.
- [ ] Add registry lookup, Git checkout, deterministic lockfile generation/update, and a content-addressed installed-package store.
- [ ] Package `dew.std` with the compiler or as a versioned dependency.
- [ ] Version the compiler and prelude ABI together initially.

## Type system and language surface

- [ ] Add negative/sealed implementations, higher-kinded types, or variance only when concrete requirements justify them.
- [ ] Design optional arguments and their ABI/evaluation-order rules.
- [ ] Add checked, saturating, wrapping, and explicit truncating conversions.
- [ ] Decide ordinary Boolean `while` and a second `loop` form.
- [ ] Add lazy module values or additional startup entry points only if required.

## Annotations, derivation, and cleanup

- [ ] Define `#annotation(...)` syntax and permitted constant values.
- [ ] Define annotation resolution, validation, retention, and interface serialization.
- [ ] Expose frozen annotations to compiler features and tooling without runtime reflection.
- [ ] Define the relationship between annotations and postfix `derive(...)`.
- [ ] Add alias-mediated disposal/escape diagnostics only if affine tracking is adopted.
- [ ] Continue cross-phase and cross-module coverage for `defer`, `using`, and `Disposable`.

## Patterns, text, and primitive policies

- [ ] Add full nested pattern-matrix usefulness analysis when needed.
- [ ] Preserve deterministic source-order pattern diagnostics.
- [ ] Measure retained-range and small-inline-string representations before changing the text ABI.
- [ ] Define public string indexing and malformed-WTF-8 host-boundary behavior.
- [ ] Define stable float, Bytes, SWAR, and typed-lane Show formats.
- [ ] Define typed-lane Debug and non-WASI Debug behavior.
- [ ] Expand generated lane tests to every operation family.
- [ ] Complete cross-runtime execution and benchmark coverage for primitive/runtime features.

## Standard library

- [ ] Design a one-pass generated typed JSON decoder and public cursor/event core; slice-reparse typed and raw-index prototypes were measured and rejected, and minimal recursive generic visitors now link, so isolate the remaining JSON-specific callback/capture case before changing the compiler.
- [ ] Specify and benchmark workloads before adding finger trees or persistent lists.
- [ ] Implement bounded Dew-native TOML; add YAML only after JSON and TOML stabilize.
- [ ] Define cryptography boundaries and reviewed algorithms before implementation.
- [ ] Implement bounded HTTP semantics separately from host transport adapters.

## WasmGC backend and interoperability

- [ ] Add Start, element/table, or data/string sections only when selected runtime designs require them.
- [ ] Add deterministic Name and source-information sections.
- [ ] Deduplicate equivalent ABI signatures.
- [ ] Define and continuously test the supported WasmGC runtime baseline.
- [ ] Define builtin-registry extensions, Wasm imports/exports, JavaScript bindings, and string/reference interop.
- [ ] Define component-model/WIT integration only after the core Wasm ABI stabilizes.
- [ ] Provide explicit low-level escape hatches without ambient semantics.

## CLI, formatter, docs, and language server

- [ ] Add CLI phase timing and allocation reporting.
- [ ] Define canonical Dew formatting rules.
- [ ] Implement lossless/comment-preserving `dew fmt`.
- [ ] Add formatter idempotence and parse/format/parse tests.
- [ ] Retain documentation comments and implement `dew doc`.
- [ ] Link imported identities, preserve source spelling, and support runnable examples.
- [ ] Reuse incremental artifacts for language-server state.
- [ ] Add diagnostics, definition, references, hover, completion, rename, symbols, semantic tokens, and focused code actions.

## Testing, fuzzing, packaging, and releases

- [ ] Continue feature-adjacent success, warning, failure, boundary, trap-order, and stress fixtures.
- [ ] Add tests for every new import/module rule and cross-file source locations.
- [ ] Add malformed standard-library source and broader cross-file semantic matrices.
- [ ] Add tokenizer, parser, HIR, solver, and Wasm round-trip fuzzing.
- [ ] Add differential parse/format and resource-limit fuzzing after prerequisites land.
- [ ] Add reproducible release builds and CI across supported targets/hosts.
- [ ] Publish compiler binaries and standard-library sources.
- [ ] Define language edition/version behavior before compatibility commitments.
