# Dew Agent TODO

> Execution-only backlog synchronized with every unfinished item in `docs/roadmap.md` on August 11, 2026. Completed work is intentionally omitted. Overlapping roadmap entries are consolidated here into one actionable item and must be removed from this file when completed.

## Current priority order

1. Finish bounded derived `Show` behavior, then take deterministic cleanup as a separate ergonomics milestone.
2. Build deterministic optimization, workspace-cache, and parallel-compilation pipelines while continuing fixtures, measurements, resource budgets, packaging, and release hardening.

## Snapshots, diagnostics, and fixture suites

- [ ] Continue adding successful, warning, compiler-failure, boundary, edge, and reduced-stress module snapshots beside each feature.
- [ ] Add optimized WAT snapshots once optimization output is intentionally contractual.
- [ ] Add reversed simulated job-order reproducibility snapshots.
- [ ] Add tests for every new import and module rule.
- [ ] Add source-location assertions to all cross-file diagnostics.
- [ ] Add malformed standard-library source tests.
- [ ] Add cross-file type, trait, impl, enum, struct, and module-let tests.
- [ ] Add forward/reverse simulated file-job completion tests.
- [ ] Add hundreds-of-files stress tests.

## Modules, imports, packages, and visibility

- [ ] Define duplicate identical imports, opens, and aliases across files and report both source locations.
- [ ] Extend `@alias` lookup through type, trait, enum-constructor, pattern, and static-impl namespaces, including duplicate-alias labels.
- [ ] Decide and define selective imports.
- [ ] Define re-exports.
- [ ] Define package visibility if module visibility is insufficient.
- [ ] Define canonical standard operator-trait identities across imports.
- [ ] Diagnose local declarations that conflict with canonical ambient traits.
- [ ] Decide default-preamble opt-out syntax.
- [ ] Add registry lookup, Git checkout, deterministic lockfile generation/update, and a content-addressed installed-package store.
- [ ] Package `dew.std` with the compiler or as a versioned dependency.
- [ ] Version the compiler and prelude ABI together initially.

## Compile-time annotations and derivation

- [ ] Define `#annotation(...)` syntax with compile-time constant parameters.
- [ ] Specify permitted annotation constant types, name resolution, validation, retention, and frozen-interface serialization.
- [ ] Expose frozen annotations to compiler features and tooling without ambient runtime reflection.
- [ ] Define how existing postfix `derive(Eq, Debug, Hash)` relates to future annotations without breaking its ordinary coherence, generic prerequisites, frozen interfaces, or imported execution.
- [ ] Add derived `Show` only after the `Show` trait and builder contract are settled.
- [ ] Finalize typed lane Debug formats, recursion/resource limits, and deterministic non-WASI behavior.

## Generics, traits, and dispatch

- [ ] Define method-level generic syntax and shadowing.
- [ ] Define explicit call-site type-argument syntax.
- [ ] Improve ordinary and generic overload specificity from generic-count tiers to structural match-set containment.
- [ ] Decide whether associated types are in the initial language and define them if retained.
- [ ] Decide whether associated constants are in the initial language and define them if retained.
- [ ] Decide whether supertraits are in the initial language and define them if retained.
- [ ] Define higher-kinded types only if concrete library requirements justify them.
- [ ] Define variance only if subtyping or mutable generic references expose a need.
- [ ] Keep inference variables out of frozen module type interners.
- [ ] Define negative implementations only if required.
- [ ] Define sealed traits only if required.

## Deterministic cleanup and executable language surface

- [ ] Add `dew.std.disposable.Disposable` with an explicit cleanup operation and defined ownership/error semantics.
- [ ] Add `defer` with deterministic LIFO scope-exit behavior across fallthrough, `return`, `break`, and `continue`; define or explicitly exclude trap unwinding.
- [ ] Add `using` for scoped `Disposable` values through the same cleanup plan.
- [ ] Diagnose invalid cleanup captures, double disposal, unsupported asynchronous escape, and control flow that cannot guarantee exactly-once disposal.
- [ ] Add parser, HIR, flow, lowering, WAT snapshot, runtime, and cross-module tests for `defer`, `using`, and `Disposable`.
- [ ] Design optional arguments, including defaults, omission, overload resolution, evaluation order, and ABI effects.
- [ ] Add separate checked, saturating, and explicitly named wrapping/truncating conversion families beyond `Into<T>`.
- [ ] Decide whether reserved `loop` becomes a second loop form.
- [ ] Decide whether ordinary Boolean `while` is added.
- [ ] Add tail-position branch optimization.
- [ ] Add tail-call optimization only if runtime support and measurements justify it.

## Indexing, aggregates, patterns, and module state

- [ ] Enforce the `(Self, key) -> value` indexing functional dependency and extend indexing to growable arrays and later map types.
- [ ] Emit aggregate field writes if aggregate mutation is adopted.
- [ ] Add aggregate allocation and field-access benchmarks.
- [ ] Add flat scalar-enum specialization only after representative measurement.
- [ ] Share extraction work across nested alternative patterns.
- [ ] Add full nested pattern-matrix usefulness analysis when needed.
- [ ] Preserve deterministic source-order pattern diagnostics.
- [ ] Define lazy module values only if required.
- [ ] Integrate host-provided initialization and startup entry points where the explicit `__dew_init` convention is insufficient.

## Text and primitive runtime hardening

- [ ] Measure retained-range policy, small-inline strings, hashing, ordering, and UTF-8 scalar iteration before extending the text ABI.
- [ ] Add String, StringView, and Bytes ordering, hashing, and code-point iteration.
- [ ] Define string indexing units and malformed-WTF-8 runtime behavior.
- [ ] Expand generated lane tests from smoke coverage to every generated operation family, including shuffle, saturation, narrowing, widening, masks, and lane-memory variants.
- [ ] Complete native, WasmGC, JavaScript, classic Wasm, Node, and Wago execution and benchmark coverage for supported primitive/runtime features.

## Collections and iteration

- [x] Implement `dew.std.collections.circular_buffer` with bounded and growable modes, deterministic wraparound, and carrier-specialized storage.
- [x] Implement `dew.std.collections.stack` with explicit empty-pop and empty-peek result semantics.
- [x] Implement growable `dew.std.collections.deque` with O(1) amortized operations at both ends.
- [ ] Specify and benchmark sequence/deque/measure use cases before implementing `dew.std.collections.finger_tree`.
- [ ] Define and implement `dew.std.list` only if measured workloads justify a persistent list representation.
- [ ] Add deterministic allocation-free `Hash` implementations for String, StringView, and Bytes after their cross-type equality contract is final.
- [x] Define the public `dew.std.queue` API behind a representation-independent mutable interface.
- [x] Implement queue enqueue, dequeue, peek, size, iteration, and empty-queue result semantics.
- [x] Replace the measured O(n) contiguous dequeue baseline with circular-buffer storage; benchmark linked/persistent alternatives only if the ring representation misses its budgets.
- [ ] Benchmark WasmGC arrays against linked representations only if measured sequence workloads justify adding one.

## `Show`, `Debug`, and output

- [ ] Define `Show` formatting stability, recursion/resource limits, and derived behavior.
- [ ] Define typed lane Debug formatting, recursion/resource limits, and deterministic behavior when WASI is unavailable.

## Broader standard library

- [ ] Implement `dew.std.iter`.
- [ ] Implement `dew.std.math`.
- [ ] Implement `dew.std.io`.
- [ ] Implement `dew.std.testing` beyond the current compiler-owned test primitives.
- [ ] Complete `dew.std.wasm.intrinsics` for every supported WebAssembly Core 3 scalar, reference, GC, memory, table, SIMD, conversion, control, and host-boundary builtin.
- [ ] Add generated declaration/backend parity checks so no compiler builtin remains source-addressable outside `dew.std.wasm.intrinsics`.
- [ ] Implement `dew.std.json` in Dew with strict UTF-8 parsing, deterministic serialization, streaming/event and DOM/value APIs, bounded resources, canonical-number decisions, and differential conformance tests.
- [ ] Implement `dew.std.toml` in Dew, starting with the package-manifest subset and covering duplicate keys, dotted/quoted keys, arrays/tables/inline tables, date-time policy, deterministic serialization, and conformance fixtures.
- [ ] Implement `dew.std.yaml` after JSON/TOML stabilize, with an explicitly versioned subset, alias/anchor limits, duplicate-key policy, deterministic emission, and hostile-input tests.
- [ ] Require Dew-native JSON/TOML parsers for the installed compiler, package manager, self-hosted tools, and standard APIs while allowing host parsers in the bootstrap driver.

## Cryptography and HTTP

- [ ] Define the security and API boundaries among `dew.std.crypto.fast`, `dew.std.crypto.timing`, and `dew.std.crypto.password`.
- [ ] Reserve `crypto.fast` for non-secret hashes/checksums, `crypto.timing` for constant-time primitives and secret comparison, and `crypto.password` for password hashing/KDF APIs.
- [ ] Select reviewed algorithms and implementations, version parameters and algorithm identifiers, use secure randomness where required, and label APIs that are unsafe for secrets.
- [ ] Add known-answer, differential, side-channel-aware, malformed-input, resource-limit, and cross-runtime crypto tests.
- [ ] Measure supported runtimes before making constant-time claims.
- [ ] Implement `dew.std.http` with bounded request/response types, header validation, streaming bodies, deterministic parsing/serialization, explicit limits, and host adapters separated from protocol semantics.
- [ ] Define URL/URI ownership, TLS boundaries, redirects, decompression, timeout/cancellation behavior, and client/server scope before stabilizing HTTP APIs.

## WasmGC backend and interoperability

- [ ] Add a Start section if explicit host initialization is replaced or supplemented by Wasm startup.
- [ ] Add element/table sections for dynamic dispatch.
- [ ] Add data/string sections as required by future runtime representations.
- [ ] Add a deterministic Name section.
- [ ] Add source maps or a custom diagnostic/source section.
- [ ] Deduplicate equivalent ABI signatures.
- [ ] Track required WasmGC feature versions and runtime compatibility.
- [ ] Define the Dew builtin-registry extension API.
- [ ] Define Wasm import declaration syntax and ABI.
- [ ] Define export naming and collision rules.
- [ ] Define JavaScript host bindings.
- [ ] Define string and reference interop.
- [ ] Define component-model/WIT integration only after the core Wasm ABI is stable.
- [ ] Provide low-level escape hatches without making them ambient language semantics.

## Optimization and performance discipline

- [ ] Add constant folding after exact operation selection.
- [ ] Add inlining from immutable call-graph summaries.
- [ ] Add tail-recursion optimization.
- [ ] Add common-subexpression elimination where allocation and effects permit.
- [ ] Add escape analysis for boxes, payloads, and trait objects.
- [ ] Add scalar replacement of short-lived aggregates.
- [ ] Add local lifetime coalescing and deeper payload-load/extraction CSE.
- [ ] Specialize enum representations from frozen usage/layout data.
- [ ] Consider profile-guided optimization only after deterministic baseline builds exist.
- [ ] Define explicit compiler resource budgets and fail-visible diagnostic behavior.
- [ ] Bound alias expansion, inference work, pattern usefulness, and module-graph size.
- [ ] Diagnose budget exhaustion without crashing.
- [ ] Track compile, validation/encoding, and runtime time separately with warmup and variance reporting.
- [ ] Track allocations and peak memory separately from wall time.
- [ ] Measure cache-file I/O/checksum costs and representative external-package workloads before treating cache hits as an end-to-end win.
- [ ] Establish regression thresholds for hot workloads.

## Incremental and parallel compilation

- [ ] Fingerprint source files.
- [ ] Cache parser events or compact syntax/HIR artifacts.
- [ ] Extend frozen-interface caching to ordinary workspace modules after provenance and invalidation rules stabilize.
- [ ] Cache body inference by declaration/body fingerprint.
- [ ] Cache layout and fragment plans.
- [ ] Invalidate dependents by public-interface fingerprint rather than implementation changes.
- [ ] Schedule module and body jobs across workers.
- [ ] Keep diagnostic and output ordering stable under parallelism.
- [ ] Add forward, reverse, and random completion-order tests.
- [ ] Add byte-for-byte reproducible-build checks for incremental and parallel paths.

## CLI, formatting, language server, and docs

- [ ] Implement `dew fmt`.
- [ ] Implement `dew doc`.
- [ ] Implement `dew clean`.
- [ ] Add phase timing and allocation reporting to the CLI.
- [ ] Define canonical formatting rules.
- [ ] Implement the formatter over parser ASTs or lossless syntax.
- [ ] Preserve comments and intentional multiline strings.
- [ ] Add formatter idempotence and parse/format round-trip tests.
- [ ] Add incremental file parsing to the language server.
- [ ] Keep stable file/module identities in language-server workspace state.
- [ ] Add language-server diagnostics.
- [ ] Add go to definition and find references.
- [ ] Add hover types and selected implementation evidence.
- [ ] Add completion, rename, document symbols, and semantic tokens.
- [ ] Add code actions for missing imports, methods, and match cases.
- [ ] Retain documentation comments.
- [ ] Generate module, type, trait, and function documentation.
- [ ] Link imported identities in generated docs.
- [ ] Show alias-normalized signatures without erasing source spelling.
- [ ] Add runnable documentation examples.

## Fuzzing, stress, and safety

- [ ] Add tokenizer byte fuzzing, including malformed WTF-8.
- [ ] Add parser token-stream fuzzing.
- [ ] Add AST/HIR lowering fuzzing.
- [ ] Add type-solver operation-sequence fuzzing.
- [ ] Add Wasm validation/encoding round-trip fuzzing.
- [ ] Add differential parsing/formatting tests.
- [ ] Add resource-limit fuzzing for deeply nested and very wide inputs.
- [ ] Audit integer conversions and packed-identity limits.
- [ ] Audit every array index driven by malformed input.

## Releases and compatibility

- [ ] Add reproducible release builds.
- [ ] Add CI across supported MoonBit targets and host platforms.
- [ ] Publish compiler binaries and standard-library sources.
- [ ] Define language edition/version behavior before compatibility commitments.

## Explicit open decisions

- [ ] Decide whether local declarations may shadow ordinary imports.
- [ ] Decide whether canonical preamble traits may be shadowed.
- [ ] Decide whether mutation remains local-only or extends to aggregate fields and additional collections.
- [ ] Decide whether associated types are required for collections and iterators.
- [ ] Decide whether ordinary Boolean loops are needed alongside functional loops.
- [ ] Define the supported WasmGC runtime baseline.
