# Dew Agent TODO

> Execution-only backlog synchronized with [`docs/roadmap.md`](docs/roadmap.md) on August 13, 2026. Completed work is intentionally omitted. Each implementation tranche should land with focused tests, documentation, measurements where relevant, and one bounded atomic commit.

## Current priority order

1. Extend workspace interface reuse into body/layout/fragment caches and deterministic parallel scheduling.
2. Add fail-visible compiler work budgets and allocation/peak-memory measurement.
3. Complete package acquisition and reproducible release infrastructure.
4. Complete foundational standard modules and Wasm intrinsic parity.
5. Build formatter, documentation, and language-server tooling over lossless/incremental syntax.

## Incremental and parallel compilation

- [ ] Refine complete module body-inference artifacts into declaration/lambda jobs after module-value SCC, capture, and evidence dependencies have exact fingerprints.
- [ ] Cache layout and WasmGC fragment plans where deterministic rebasing is defined.
- [ ] Schedule independent module and body jobs across workers.
- [ ] Merge diagnostics and artifacts in deterministic source/manifest order.
- [ ] Add forward, reverse, and randomized completion-order tests.
- [ ] Require byte-identical cold, warm, incremental, and parallel output.
- [ ] Add hundreds-of-files and representative external-package stress workloads.

## Post-release performance work

The current measured baseline is fast enough for the first release. These items
are follow-up hardening and observability work, not release blockers.

- [ ] Define compiler budgets for graph size, nesting/width, alias expansion, inference, trait search, pattern usefulness, specialization growth, and diagnostic volume.
- [ ] Diagnose budget exhaustion deterministically without panic or partial cache publication.
- [ ] Add opt-in runtime allocation and phase counters with zero production overhead.
- [ ] Track compile, validation/encoding, runtime time, compiler allocations, and peak memory with warmup and variance.
- [ ] Extend cache measurements to external-package and multi-module workloads.
- [ ] Establish reviewed cross-engine regression thresholds for hot workloads; Array growth now has reproducible scalar-loop versus WasmGC `array.copy` measurements.
- [ ] Benchmark Array growth, large reference copying, write barriers, and GC behavior on each supported WasmGC runtime.
- [ ] Add representative heap, ordered-tree, queue, JSON, and generated typed-decoder performance suites.
- [ ] Use runtime allocation evidence to evaluate proof-driven constructor/store forwarding, physical nominal propagation, and private `Result` forwarding.
- [ ] Benchmark thresholded exact-`Set` JSON duplicate tracking only for substantially wider objects.
- [ ] Benchmark reusable nested JSON structural indexes only for repeated selective lookups with explicit ownership and memory contracts.
- [ ] Audit integer conversions, packed identities, and malformed-input-driven indexing.

## Modules, imports, packages, and visibility

- [ ] Define duplicate identical imports, opens, and aliases across files with both source locations.
- [ ] Extend `@alias` lookup through type, trait, enum-constructor, pattern, and static-implementation namespaces.
- [ ] Decide and define selective imports.
- [ ] Define re-exports and package visibility if needed.
- [ ] Define canonical standard operator-trait identities and diagnose conflicting local declarations.
- [ ] Decide import and canonical-preamble shadowing rules.
- [ ] Decide whether source syntax is needed for default-preamble opt-out.
- [ ] Add registry lookup, Git checkout, deterministic lockfile generation/update, and a content-addressed installed-package store.
- [ ] Package `dew.std` with the compiler or as a versioned dependency.
- [ ] Version the compiler and prelude ABI together initially.

## Type system and language surface

- [ ] Define method-level generic syntax and shadowing.
- [ ] Define explicit call-site type arguments.
- [ ] Implement structural match-set overload specificity.
- [ ] Keep inference variables out of frozen module type interners.
- [ ] Fix generic value-returning match joins with `Never` failure arms, then add testing value-extraction helpers.
- [ ] Decide associated types, associated constants, and supertraits for the first stable edition.
- [ ] Add negative/sealed implementations, higher-kinded types, or variance only when concrete requirements justify them.
- [ ] Design optional arguments and their ABI/evaluation-order rules.
- [ ] Add checked, saturating, wrapping, and explicit truncating conversions.
- [ ] Decide ordinary Boolean `while` and a second `loop` form.
- [ ] Enforce the `(Self, key) -> value` indexing functional dependency.
- [ ] Decide aggregate field mutation and alias semantics.
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
