# Dew implementation roadmap

> Living roadmap as of August 18, 2026. This file records current product direction. Completed work is summarized compactly; detailed implementation history and measurements live in [`docs/spec.md`](spec.md), [`docs/architecture.md`](architecture.md), and [`docs/research/`](research/). [`agent-todo.md`](../agent-todo.md) is the execution-only backlog and contains no completed entries.

## Current baseline

Dew is an executable, statically linked WasmGC language implementation with:

- a streaming WTF-8 tokenizer and non-backtracking parser;
- deterministic multi-file and multi-module collection, diagnostics, frozen interfaces, package manifests, lock records, and dependency SCCs;
- local and imported types, structural product types, inferred array literals, traits, implementations, generic bounds, evidence-aware specialization, runtime trait values, closures, mutable captures, alias-visible mutable struct fields, module state, and recursive physical type groups;
- fixed-width scalar, packed-lane, SIMD, strict UTF-8 text, Bytes, strict bounded JSON, WASI Preview 1, test metadata, and deterministic Starshine validation/encoding;
- Eq, Debug, Hash, and Show derivation; explicit Show and Disposable evidence; deterministic `defer` and `using`;
- carrier-specialized FixedArray and Array, explicit iterators, Stack, Queue, CircularBuffer, Deque, Map, Set, allocation-free Bloom filters, BinaryHeap, PriorityQueue, red-black trees, ordered maps, and ordered sets;
- deterministic whole-program optimization including folding, immutable-summary inlining, scalar tail recursion, field CSE, local-alias coalescing, aggregate scalar replacement, enum-payload elimination, private unit-enum and packed single-`I32`-payload ABI specialization, box elimination, and exact trait-object directization;
- one-read 16-byte-aligned compiler cache packs with BLAKE3-256 provenance, lazy selected-entry decoding, exact successful check/HIR/lowering/Wasm reuse, parser/interface reuse, opt-in body/layout/fragment reuse, fast checksummed whole-build compiler fingerprinting, verified host output reuse, installed dependency source capsules, safe complete build-artifact cleaning, and byte-identical repeated builds;
- broad semantic/backend/parser/tokenizer tests, direct standard-library tests, architecture budgets, generated-source checks, CLI/cache/ABI checks, and deterministic Node/Wago module snapshots.

Suite totals are intentionally not copied into prose. Test runners discover the checked-in suites and print authoritative counts.

## Priority policy

### P1 — self-hosting

1. [x] Freeze the bounded source-Bytes version 1 compiler request and explicit `CompilerSessionConfig`; consume source and provider bytes directly with caches disabled and no environment mutation.
2. [x] Consume the pinned Starshine submodule's generated raw WasmGC FFI through an exact 32-export compiler subset, typed container/result bridges, and a BLAKE3 compiler fingerprint over the pinned revision, interface digests, selected signatures, and exact provider bytes; build a linked source-Bytes smoke compiler that emits byte-identical validated modules.
3. [ ] Port the parser, semantic phases, optimizer, backend, cache codecs, and compiler driver to Dew in dependency order. The tokenizer, full parser, packed semantic IDs, declaration collection, flat type/body HIR, namespace construction, duplicate diagnostics, multi-file collection, canonical type interning, local and imported signature resolution, alias SCC diagnostics, local and imported generic alias substitution, transparent normalization, public signature interfaces, exact/open/wildcard type, trait, and value imports, two-stage cyclic interface freezing, lexical body names, pattern bindings, loop controls, lambda captures, deterministic Eq/Ne/Debug/Hash/Show derive expansion, frozen callable/aggregate/implementation recipes, consumer-local imported semantic recipes, rollback-capable local type unification, the basic per-body inference core, iterative generic signature instantiation, local direct callable/overload selection, local fields, struct construction, inherent methods, all local enum construction forms, local unit/tuple/struct variant patterns, trait-backed operators, index selection, imported generic calls, imported generic fields, imported constructors and variants, imported unit/tuple/struct patterns, imported generic inherent methods, imported free-function overload sets, implementation-head indexing, orphan checks, generic overlap checks, duplicate inherent-method checks, trait method signature conformance, generic specialization ranking, coherent local method dispatch, imported implementation evidence merging, and concrete trait-evidence selection, recursive implementation prerequisite checks, and root body evidence publication are ported. The next phases are prerequisite/bound evidence trees, lambda-family inference, final body-job merging, and body flow. Module-value dependencies, dependency-first SCC scheduling, shared-SCC inference with imported selections, and frozen graph import into independent function solvers are ported. Successful basic body inference arenas are compacted; diagnostic-bearing bodies retain their original IDs conservatively. The persistent parse-event artifact format remains with the later cache-codec port.
4. [ ] Require the fixed-point bootstrap: the MoonBit compiler builds compiler A, compiler A builds compiler B, compiler B builds compiler C, and B/C are byte-identical.

The audited hard blockers, missing compiler-library operations, bootstrap-only boundaries, and optional port-enabling language additions are cataloged in [`docs/research/self-hosting-compiler-gap-catalog-2026-08-16.md`](research/self-hosting-compiler-gap-catalog-2026-08-16.md). Items described there as port-enabling do not become P1 automatically; promote them only when the port chooses that path.

Indexed implementation uniqueness, mutable struct fields, complete `@alias` namespace lookup, compiler-grade Array and Arena operations, structural FixedArray equality, content `Eq`/`Ne` for String, StringView, and Bytes, deterministic collection/sum rendering, bounded compiler diagnostics, direct integer builder output, Dew-native BLAKE3 and SHA-256, capability-based WASI/Facet filesystem and process adapters, bounded SemVer, Dew-native package file codecs, first-class product values, array literals, Option-returning iterators, `for` desugaring, the full Dew self-host parser, semantic collection/HIR, resolved type and alias normalization, signature-level module interfaces/imports, body name resolution, derive expansion, imported semantic recipes, local unification, and basic body inference are finished P1 foundations. Exact aliases now qualify values, functions, types, traits, enum constructors and patterns, implementation heads, and static implementation methods without opening their names.

### P2 — deferred until self-hosting

All remaining unchecked roadmap work is P2 unless a P1 port exposes it as a concrete blocker. This includes work budgets, package acquisition, TOML, optional arguments, annotations, ordinary Boolean `while`, higher-kinded types, negative implementations, formatter/documentation/LSP work, release infrastructure, and parallel compilation.

Every implementation tranche must preserve deterministic diagnostics and Wasm, include focused tests and documentation, and land as a bounded atomic commit.

## Optimization

- [ ] Defer profile-guided optimization until reproducible deterministic baseline builds and stable workload collection exist.

## Incremental compilation

- [x] Cache deterministic per-file parser events with versioned checksums, source/module provenance, atomic publication, and fail-visible corruption handling.
- [x] Extend frozen-interface caching to ordinary non-root workspace modules with exact manifest source identity, direct public dependency fingerprints, atomic publication, and fail-visible corruption.
- [x] Cache complete module body inference by exact source and transitive frozen interface/evidence fingerprints, with strict provenance validation, canonical binary payloads, and explicit opt-in controls pending broader end-to-end admission.
- [x] Refine module body artifacts into exact declaration-family jobs: one root body plus its nested lambda tree, normalized/rebased IDs and offsets, atomic per-module bundles, strict validation, deterministic mixed merging, map-based lookup, precomputed source ranges, and no duplicate module artifact or partial-bundle rewrite.
- [x] Replace parser-event, frozen-interface, complete-body, declaration-family, build-output-header, and compiler-fingerprint JSON or legacy payloads with bounded canonical binary artifacts; keep semantic caches opt-in until broader end-to-end admission is stable.
- [x] Cache module type layouts and baseline module-local WasmGC fragment plans under independently versioned canonical binary schemas; validate all local arenas and keep program-global index assignment fresh. The phase policy remains opt-in.
- [x] Replace per-file/per-module native cache I/O with one 16-byte-aligned BLAKE3 artifact pack, lazy selected-entry validation, atomic repacking, and exact successful check/HIR/lowering/Wasm entries. A 100-module exact warm hit is materially faster than both legacy phase files and fresh compilation.
- [x] Invalidate workspace dependents by public-interface content fingerprint rather than private implementation changes.
- [x] Cache cyclic workspace interface SCCs as one atomic artifact.
- [x] Require byte-identical cache-disabled, cold, warm, and private-edit output for planning artifacts.
- [ ] Add hundreds-of-files and representative external-package stress workloads.

## Parallel compilation after self-hosting

The current compiler is written in MoonBit, which cannot execute these compiler jobs in parallel. Internal worker scheduling is not active work and is not a release goal for the MoonBit implementation. Revisit it only after Dewdrop is self-hosted and Dew provides parallel computation. The deterministic identity, artifact, and merge contracts remain preparation for that later work. See [`decisions/0002-parallel-compilation-after-self-hosting.md`](decisions/0002-parallel-compilation-after-self-hosting.md).

- [ ] Schedule independent module and body jobs across workers in the self-hosted compiler.
- [ ] Buffer and merge diagnostics, artifacts, and final indices in deterministic source/manifest order.
- [ ] Add forward, reverse, and randomized simulated completion-order tests.
- [ ] Require byte-identical sequential and parallel output.

## MoonBit bootstrap migration

- [x] Replace `tools/dew-cli.py` with a MoonBit bootstrap command.
- [x] Move manifest/lockfile parsing, package resolution, package capsules,
  compiler fingerprinting, build-output caching, test/run/WAT dispatch, and host
  launch policy to MoonBit.
- [x] Keep cache-pack hashing, codecs, validation, lookup, and publication only in
  MoonBit; do not add a Python cache implementation.
- [x] Preserve current CLI output, exit status, corruption behavior, and package
  compatibility during the migration.

## Compiler resource and performance discipline

The measured compiler, collection, text, and backend baseline is fast enough for
the first release. Hot compiler caches now use deterministic bounded binary payloads inside one
aligned pack. Parser/body/family/interface codec speed and size gates pass.
Exact successful requests use one indexed pack read and skip compiler phases.
Semantic body and layout/fragment phase reuse stays opt-in because its decoding
and validation can still exceed fresh work when the exact entry misses.
Remaining MoonBit-compiler work is broader heavy-workload admission, hardening,
and observability rather than a release gate. Parallel compiler jobs remain
deferred until self-hosting.

### Post-release performance TODOs

- [ ] Define budgets for source/file/module graph size, nesting/width, alias expansion, inference/unification, trait search, pattern usefulness, specialization/adapter growth, and diagnostic volume.
- [ ] Diagnose budget exhaustion deterministically without panic, unchecked indexing, partial cache publication, or silent fallback.
- [ ] Add opt-in runtime allocation and phase counters at generic WasmGC aggregate emission points with zero production overhead.
- [ ] Track compilation, validation/encoding, runtime time, compiler allocations, and peak memory separately with warmup and variance reporting.
- [ ] Extend whole-build cache measurements to representative external-package and multi-module workloads.
- [ ] Establish reviewed cross-engine regression thresholds for hot compiler and generated-program workloads; Array growth now has reproducible scalar-loop versus WasmGC `array.copy` measurements.
- [ ] Benchmark Array growth, large reference copying, write barriers, and GC behavior on each supported WasmGC runtime.
- [ ] Add representative heap, ordered-tree, queue, JSON, and generated typed-decoder performance suites around the retained bulk Array growth path.
- [ ] Use runtime allocation evidence to evaluate proof-driven constructor/store forwarding, physical nominal propagation, and private `Result` forwarding.
- [ ] Benchmark thresholded exact-`Set` duplicate tracking only for substantially wider JSON objects; retain Bloom plus exact fallback for ordinary objects.
- [ ] Measure reusable nested structural JSON indexes only on repeated selective lookup workloads with explicit memory and source-retention contracts.
- [ ] Audit integer conversions, packed identity limits, and malformed-input-driven array indexing.

## Modules, imports, packages, and visibility

- [ ] Define duplicate identical imports, opens, and aliases across files and report both source locations.
- [x] Extend `@alias` lookup through type, trait, enum-constructor, pattern, and static-implementation namespaces.
- [ ] Decide and define selective imports.
- [ ] Define re-exports and package visibility if module visibility is insufficient.
- [ ] Define canonical standard operator-trait identities across imports and diagnose conflicting local declarations.
- [ ] Decide whether local declarations may shadow ordinary imports or canonical preamble traits.
- [ ] Decide the source syntax, if any, for default-preamble opt-out beyond the CLI switch.
- [ ] Add registry lookup, Git checkout, deterministic lockfile generation/update, and a content-addressed installed-package store.
- [ ] Package `dew.std` with the compiler or as an explicitly versioned dependency.
- [ ] Version the compiler and prelude ABI together for the first release line.

## Type system, traits, and language surface

- [x] Define method-level generic syntax as `fn name<t: Bound>(...)`; the immediate method scope may shadow containing trait/impl parameters and wins lookup by stable identity.
- [x] Define exact explicit call-site type arguments as `callee::<T, U>(...)`, including instance and qualified methods; method syntax supplies method-local arguments while containing impl arguments remain inferred.
- [x] Select ordinary overloads by strict structural match-set containment across the complete parameter/result signature; equivalent and overlapping-incomparable maxima remain ambiguous.
- [x] Keep body-local inference variables out of frozen module type interners and regression-test interner immutability across inferred and explicitly specialized calls.
- [x] Preserve `Never` for declared diverging calls before generic match joins, specialize match scratch/result carriers, emit unreachable continuation after no-result calls, and provide generic value-extracting testing helpers.
- [x] Exclude associated types, associated constants, and supertraits from the first stable language edition; reconsider them only through an edition-gated design after concrete library requirements exist.
- [ ] Add negative or sealed implementations only if concrete coherence/library requirements justify them.
- [ ] Define higher-kinded types or variance only if concrete library requirements justify them.
- [ ] Design optional arguments, including defaults, omission, overload selection, evaluation order, and ABI effects.
- [ ] Add checked, saturating, wrapping, and explicitly truncating conversion families beyond `Into<T>`.
- [ ] Decide whether ordinary Boolean `while` or a second `loop` form is needed alongside functional loops.
- [x] Enforce compiler-owned `IndexedGet` and `IndexedSet` as one implementation per concrete receiver type; overlapping receiver patterns are incoherent even when key/value arguments differ or one implementation is more specific.
- [x] Add `mut name: Type` struct fields and `value.name = replacement` block-item writes with base-before-value evaluation, alias-visible mutation, local/imported generic field support, frozen-interface/cache provenance, WasmGC `struct.set`, and conservative optimization barriers.
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

- [x] Implement `dew.std.iter` combinators over `Iter<t>::next() -> Option<t>`, with repeatable non-trapping exhaustion and Starshine scalar replacement for immediate Option matches.
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

- [x] Implement Dew-native JSON with strict UTF-8, exact number lexemes, deterministic serialization, bounded Reader/Writer and value APIs, source-level Bytes/String SIMD scanning, validated-String no-escape parsing, fixed parser and writer state, explicit retained-source and raw validated documents, specialized validation, parsed validate-once JsonNumber and escape-proven JsonString values, exact Bloom-assisted wide-object duplicate checks, allocation-free index traversal, validated clean-span output, and direct conformance coverage. Slice-reparse typed decoding, one-shot structural indexing, and unconditional exact-Set tracking were measured and rejected; future typed decoding must share one cursor/event pass.
- [ ] Implement Dew-native TOML, beginning with the package-manifest subset and deterministic duplicate/dotted-key behavior.
- [ ] Implement a versioned bounded YAML subset only after JSON and TOML stabilize.
- [ ] Define the boundaries among non-secret fast hashes, integrity hashes such as SHA-256, constant-time primitives, and password/KDF APIs before adding secret-key cryptography modules.
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
