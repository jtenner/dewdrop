# Dew implementation roadmap

> Living roadmap as of August 13, 2026. This file records current product direction. Completed work is summarized compactly; detailed implementation history and measurements live in [`docs/spec.md`](spec.md), [`docs/architecture.md`](architecture.md), and [`docs/research/`](research/). [`agent-todo.md`](../agent-todo.md) is the execution-only backlog and contains no completed entries.

## Current baseline

Dew is an executable, statically linked WasmGC language implementation with:

- a streaming WTF-8 tokenizer and non-backtracking parser;
- deterministic multi-file and multi-module collection, diagnostics, frozen interfaces, package manifests, lock records, and dependency SCCs;
- local and imported types, traits, implementations, generic bounds, evidence-aware specialization, runtime trait values, closures, mutable captures, module state, and recursive physical type groups;
- fixed-width scalar, packed-lane, SIMD, strict UTF-8 text, Bytes, strict bounded JSON, WASI Preview 1, test metadata, and deterministic Starshine validation/encoding;
- Eq, Debug, Hash, and Show derivation; explicit Show and Disposable evidence; deterministic `defer` and `using`;
- carrier-specialized FixedArray and Array, explicit iterators, Stack, Queue, CircularBuffer, Deque, Map, Set, allocation-free Bloom filters, BinaryHeap, PriorityQueue, red-black trees, ordered maps, and ordered sets;
- deterministic whole-program optimization including folding, immutable-summary inlining, scalar tail recursion, field CSE, local-alias coalescing, aggregate scalar replacement, enum-payload elimination, private unit-enum and packed single-`I32`-payload ABI specialization, box elimination, and exact trait-object directization;
- checksummed per-file parser-event artifacts, verified standard/external/workspace interface caches, verified module body-inference reuse, verified whole-build output reuse, installed dependency source capsules, safe cache cleaning, and byte-identical repeated builds;
- broad semantic/backend/parser/tokenizer tests, direct standard-library tests, architecture budgets, generated-source checks, CLI/cache/ABI checks, and deterministic Node/Wago module snapshots.

Suite totals are intentionally not copied into prose. Test runners discover the checked-in suites and print authoritative counts.

## Active priority order

1. Extend the completed workspace interface reuse into body/layout/fragment caches and deterministic parallel module/body scheduling.
2. Add fail-visible compiler work budgets, allocation/peak-memory measurement, and regression thresholds.
3. Complete package acquisition, reproducible release infrastructure, and the supported WasmGC runtime matrix.
4. Complete foundational standard modules and Wasm intrinsic parity.
5. Build formatter, documentation, and language-server tooling over lossless/incremental syntax infrastructure.

Every implementation tranche must preserve deterministic diagnostics and Wasm, include focused tests and documentation, and land as a bounded atomic commit.

## Optimization

- [ ] Defer profile-guided optimization until reproducible deterministic baseline builds and stable workload collection exist.

## Incremental and parallel compilation

- [x] Cache deterministic per-file parser events with versioned checksums, source/module provenance, atomic publication, and fail-visible corruption handling.
- [x] Extend frozen-interface caching to ordinary non-root workspace modules with exact manifest source identity, direct public dependency fingerprints, atomic publication, and fail-visible corruption.
- [x] Cache complete module body inference by exact source and transitive frozen interface/evidence fingerprints, with strict provenance validation and independent controls.
- [ ] Refine module body artifacts into declaration/lambda jobs after module-value SCC, capture, and evidence dependencies have exact fingerprints.
- [ ] Cache layout and WasmGC fragment plans where deterministic rebasing is defined.
- [x] Invalidate workspace dependents by public-interface content fingerprint rather than private implementation changes.
- [x] Cache cyclic workspace interface SCCs as one atomic artifact.
- [ ] Schedule independent module and body jobs across workers.
- [ ] Buffer and merge diagnostics, artifacts, and final indices in deterministic source/manifest order.
- [ ] Add forward, reverse, and randomized simulated completion-order tests.
- [ ] Require byte-identical cold, warm, incremental, and parallel output.
- [ ] Add hundreds-of-files and representative external-package stress workloads.

## Compiler resource and performance discipline

- [ ] Define budgets for source/file/module graph size, nesting/width, alias expansion, inference/unification, trait search, pattern usefulness, specialization/adapter growth, and diagnostic volume.
- [ ] Diagnose budget exhaustion deterministically without panic, unchecked indexing, partial cache publication, or silent fallback.
- [ ] Track compilation, validation/encoding, and runtime time separately with warmup and variance reporting.
- [ ] Track compiler allocations and peak memory separately from wall time.
- [ ] Extend whole-build cache measurements to representative external-package and multi-module workloads.
- [ ] Establish reviewed regression thresholds for hot compiler and generated-program workloads.
- [ ] Audit integer conversions, packed identity limits, and malformed-input-driven array indexing.

## Modules, imports, packages, and visibility

- [ ] Define duplicate identical imports, opens, and aliases across files and report both source locations.
- [ ] Extend `@alias` lookup through type, trait, enum-constructor, pattern, and static-implementation namespaces.
- [ ] Decide and define selective imports.
- [ ] Define re-exports and package visibility if module visibility is insufficient.
- [ ] Define canonical standard operator-trait identities across imports and diagnose conflicting local declarations.
- [ ] Decide whether local declarations may shadow ordinary imports or canonical preamble traits.
- [ ] Decide the source syntax, if any, for default-preamble opt-out beyond the CLI switch.
- [ ] Add registry lookup, Git checkout, deterministic lockfile generation/update, and a content-addressed installed-package store.
- [ ] Package `dew.std` with the compiler or as an explicitly versioned dependency.
- [ ] Version the compiler and prelude ABI together for the first release line.

## Type system, traits, and language surface

- [ ] Define method-level generic syntax and shadowing.
- [ ] Define explicit call-site type-argument syntax.
- [ ] Improve overload specificity from generic-count tiers to structural match-set containment.
- [ ] Keep inference variables out of frozen module type interners.
- [ ] Fix generic value-returning match joins whose failing arm calls a `Never`-returning function, then add value-extracting testing helpers without backend carrier mismatches.
- [ ] Decide whether associated types, associated constants, and supertraits belong in the first stable language edition.
- [ ] Add negative or sealed implementations only if concrete coherence/library requirements justify them.
- [ ] Define higher-kinded types or variance only if concrete library requirements justify them.
- [ ] Design optional arguments, including defaults, omission, overload selection, evaluation order, and ABI effects.
- [ ] Add checked, saturating, wrapping, and explicitly truncating conversion families beyond `Into<T>`.
- [ ] Decide whether ordinary Boolean `while` or a second `loop` form is needed alongside functional loops.
- [ ] Enforce the `(Self, key) -> value` indexing functional dependency across arrays, maps, and user evidence.
- [ ] Decide whether mutation extends to aggregate fields; implement field writes only after alias semantics are fixed.
- [ ] Define lazy module values only if a concrete initialization use case requires them.
- [ ] Integrate additional host startup entry points only if explicit `__dew_init` is insufficient.

## Compile-time annotations and derivation

- [ ] Define `#annotation(...)` syntax and its permitted compile-time constant values.
- [ ] Define annotation name resolution, validation, retention, and frozen-interface serialization.
- [ ] Expose frozen annotations to compiler features and tooling without ambient runtime reflection.
- [ ] Define how annotations relate to existing postfix `derive(...)` without changing ordinary coherence or imported execution.

## Cleanup semantics

- [ ] Add ownership-aware alias-mediated disposal and escape diagnostics only if affine tracking is adopted.
- [ ] Continue parser, HIR, flow, lowering, runtime, trap-order, and cross-module coverage for `defer`, `using`, and `Disposable` as adjacent features evolve.

## Patterns and control flow

- [ ] Add full nested pattern-matrix usefulness analysis when simpler constructor coverage is insufficient.
- [ ] Preserve deterministic source-order diagnostics through every pattern analysis extension.

## Text, Show, Debug, and primitive policies

- [ ] Measure retained-range and small-inline-string representations before changing the text ABI.
- [ ] Define public string indexing units and malformed-WTF-8 behavior at any future host boundary.
- [ ] Define stable float, Bytes, SWAR, and typed-lane Show formats.
- [ ] Define typed-lane Debug formatting and deterministic Debug behavior when WASI is unavailable.
- [ ] Keep the ambient trait surface intentionally small; ordering, formatting, and cleanup evidence remain explicit.
- [ ] Expand generated lane tests to every operation family, including shuffle, saturation, narrowing, widening, masks, and lane-memory variants.
- [ ] Complete execution and benchmark coverage for primitive/runtime features across native, WasmGC, JavaScript, classic Wasm, Node, and Wago.

## Standard library

### Foundational modules

- [x] Implement `dew.std.iter` combinators over the minimal ambient `Iter<t>` protocol with explicit allocation/consumption behavior.
- [x] Implement `dew.std.math` with explicit overflow, trap, NaN, and signed-zero policies.
- [x] Implement portable `dew.std.io` abstractions separately from WASI adapters.
- [x] Implement `dew.std.testing` beyond compiler-owned assertion/test primitives.
- [x] Complete `dew.std.wasm.intrinsics` for every source-addressable compiler-supported WebAssembly Core 3 scalar, memory, SIMD, conversion, and control operation; keep reference/GC/table/host-boundary operations absent until Dew exposes corresponding safe carrier types and signatures.
- [x] Add generated declaration/backend parity checks so every backend inline builtin has a source-addressable `dew.std.wasm.intrinsics` declaration.

### Measurement-driven collections

- [x] Add a reusable allocation-free `U64` Bloom filter with explicit probabilistic-positive semantics and precomputed-hash operations.
- [ ] Specify and benchmark sequence/deque/measure workloads before implementing a finger tree.
- [ ] Add a persistent list only if measured workloads justify a distinct representation.
- [ ] Benchmark WasmGC arrays against linked representations only when a concrete sequence workload requires it.

### Structured data, security, and networking

- [x] Implement Dew-native JSON with strict UTF-8, exact number lexemes, deterministic serialization, bounded Reader/Writer and value APIs, source-level Bytes/String SIMD scanning, validated-String no-escape parsing, exact Bloom-assisted wide-object duplicate checks, allocation-free index traversal, validated clean-span output, and direct conformance coverage.
- [ ] Implement Dew-native TOML, beginning with the package-manifest subset and deterministic duplicate/dotted-key behavior.
- [ ] Implement a versioned bounded YAML subset only after JSON and TOML stabilize.
- [ ] Define the boundaries among non-secret fast hashes, constant-time primitives, and password/KDF APIs before adding cryptography modules.
- [ ] Select reviewed algorithms, version parameters, use secure randomness where required, and add known-answer, differential, malformed-input, resource, and side-channel-aware tests.
- [ ] Implement bounded HTTP message semantics and parsing separately from host transport adapters.
- [ ] Define URL ownership, TLS, redirects, decompression, timeout/cancellation, and client/server scope before stabilizing HTTP APIs.

## WasmGC backend and interoperability

- [ ] Add a Start section only if explicit host initialization is supplemented or replaced.
- [ ] Add element/table and data/string sections when a selected runtime representation requires them.
- [ ] Add a deterministic Name section and source-map or custom source-information section.
- [ ] Deduplicate equivalent ABI signatures.
- [ ] Define and continuously test the supported WasmGC feature/runtime baseline.
- [ ] Define the Dew builtin-registry extension API.
- [ ] Define Wasm import syntax and ABI, export naming/collision rules, JavaScript bindings, and string/reference interop.
- [ ] Define component-model/WIT integration only after the core Wasm ABI is stable.
- [ ] Provide explicit low-level escape hatches without making them ambient language semantics.

## CLI, formatter, documentation, and language server

- [ ] Add phase timing and allocation reporting to the CLI.
- [ ] Define canonical Dew formatting rules.
- [ ] Implement `dew fmt` over lossless syntax or an AST representation that preserves comments and intentional multiline strings.
- [ ] Add formatter idempotence and parse/format/parse round-trip tests.
- [ ] Retain documentation comments and implement `dew doc` for modules, types, traits, implementations, and functions.
- [ ] Link imported identities, preserve useful source spelling, and support runnable documentation examples.
- [ ] Reuse incremental file artifacts for language-server workspace state.
- [ ] Add language-server diagnostics, definition, references, hover, completion, rename, document symbols, semantic tokens, and focused code actions in that order.

## Testing, fuzzing, and safety

- [ ] Continue adding successful, warning, compiler-failure, boundary, trap-order, and reduced-stress fixtures beside each feature.
- [ ] Add tests for every new import/module rule and source-location assertions for cross-file diagnostics.
- [ ] Add malformed standard-library source tests and broader cross-file type/trait/impl/enum/struct/module-value matrices.
- [ ] Add tokenizer byte fuzzing, parser token-stream fuzzing, AST/HIR lowering fuzzing, type-solver operation fuzzing, and Wasm validation/encoding round trips.
- [ ] Add differential parse/format tests after the formatter exists.
- [ ] Add deeply nested, very wide, and explicit resource-limit fuzzing after work budgets exist.

## Packaging and releases

- [ ] Add reproducible release builds.
- [ ] Add CI across supported MoonBit targets and host platforms.
- [ ] Publish compiler binaries and standard-library sources.
- [ ] Define language edition/version behavior before compatibility commitments.

## Compact completed milestone history

The following foundations are complete for the currently documented surface. Details and decision-level contracts remain in the specification and research notes.

1. Streaming tokenizer/parser, deterministic recovery, source provenance, and file-aware diagnostics.
2. Multi-file/module semantics, frozen interfaces, package manifests/locks, static linking, module initialization, and recursive WasmGC type groups.
3. Executable generics, coherent local/imported evidence, orphan rules, carrier specialization, erased fallbacks, closures, runtime trait values, dictionaries, and `call_ref`.
4. Scalar, packed, SIMD, memory, strict UTF-8 text/Bytes, builders, WASI, and deterministic test metadata/runtime support.
5. Eq/Ne/Debug/Hash/Show derivation, explicit Show/Disposable evidence, deterministic `defer`, and scoped `using`.
6. FixedArray, growable Array, iterators, Stack, Queue, CircularBuffer, Deque, Map, Set, heaps, priority queues, red-black trees, ordered maps, and ordered sets.
7. Deterministic WAT/runtime snapshots, generated-source parity, architecture budgets, cross-runtime differential suites, and CLI/cache/ABI validation.
8. Persistent standard/external interface caches, verified whole-build output reuse, installed dependency source capsules, and safe `dew clean`.
9. Folding, inlining, tail recursion, field CSE, local alias coalescing, aggregate scalar replacement, enum payload elimination, private unit-enum and packed single-`I32`-payload enum ABI specialization, box elimination, and exact trait-object directization.
