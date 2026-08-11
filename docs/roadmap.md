# Dew implementation roadmap

> Living roadmap as of August 10, 2026. Ordering is directional rather than contractual. Items may move as implementation and benchmarks expose better boundaries. `agent-todo.md` is the execution-only view of unfinished work in this document; completed work remains recorded here but must not remain in that backlog.

## Current baseline

Dew currently has:

- a refillable raw-file-descriptor WTF-8 cursor, a streaming lexer with exactly two decoded units of lookahead, and a one-token-lookahead non-backtracking parser;
- shunting-yard expression parsing plus declarations, traits, impls, structs, enums, aliases, patterns, matches, functional loops, tests, and structural recovery;
- deterministic multi-file/module collection, stable packed identities, frozen interfaces, dependency SCCs, and immutable semantic/lowering/linking plans;
- type resolution, alias normalization, local unification, rollback-based inference, generic bounds and obligations, impl coherence/orphan enforcement, method selection, flow, and local enum exhaustiveness analysis;
- static and runtime trait dispatch, including evidence-aware generic specialization, nominal/scalar/SIMD trait objects, shared typed dictionaries, imported evidence, and `call_ref`;
- postfix `derive(Eq)`, generated `Ne`, `derive(Debug)`, and `derive(Hash)` for structs and enums, including generic prerequisites, imported execution, ordinary coherence, and deterministic bounded-WASI Debug output;
- static multi-module linking with direct calls, imported aggregates, program-wide WasmGC layouts, optimized subtype-family enums, shape sharing, and dense match dispatch;
- the complete fixed-width scalar set, all 100 scalar `Into<T>` conversions, typed memory operations, packed GC fields, native `V128`, and allocation-free `Swar32`/`Swar64` lane operations;
- strict-UTF-8 GC-owned `String`/`StringView`, arbitrary `Bytes`, consuming builders, strict shared/copied ranges, flat concatenation, and allocation-free matching;
- bounded WASI Preview 1 `Bytes` I/O through the 65,520-byte data region of one reusable memory page, including partial writes and chunked reads;
- exact callable reachability, compiler-owned import/runtime elision, frozen final indices, Starshine validation, and deterministic Starshine binary encoding;
- first-class `_test.dew` semantics, frozen test metadata, test-mode exports, 198 direct standard tests, and independent UTF/SWAR/WASI differential harnesses;
- selective on-disk standard-module loading as the default, with compiler-owned generated standard mirrors under `src/standard_sources/` retained only as portable bootstrap providers that must stay byte-identical to the on-disk sources;
- passing native, classic Wasm, WasmGC, JavaScript, Node/Wago differential integration, and scoped generated-source validation suites;
- a SHA-256 content-addressed persistent V11 cache for diagnostics-free compiler-owned standard and versioned external dependency interfaces, with deterministic encoding, package integrity, dependency closure keys, checksum validation, explicit disable/report controls, and fail-visible corruption handling;
- a broad deterministic compiler-fixture suite organized by language/runtime feature across calls, collections, control flow, enums, functions, generics, lanes, memory, modules, names, numeric operations, reachability, structs, tests, text, types, and WASI; fixture totals are discovered from the checked-in tree rather than maintained as duplicated prose counts.

## Immediate execution queue

The compiler foundation is broad enough that the next work should improve the
end-to-end product rather than add isolated builtins. Most numbered foundation
milestones below are complete and retained as implementation history. The active
order is now:

1. implement ordered map/set wrappers and their range APIs over the completed red-black tree core;
2. take annotations/`Show` or deterministic cleanup as separate, bounded
   ergonomics milestones;
3. continue snapshots, measurements, resource budgets, optimization, packaging,
   and release hardening throughout.

### 0. Harden the advertised current language surface

- [x] Discard non-Unit tail expressions in Unit-returning functions and lambdas without constraining their value type to Unit or disrupting earlier method/operator inference.
- [x] Emit exact UTF-8 string literal patterns through the shared text runtime equality helper, including empty, ASCII, Unicode, and fallback cases.
- [x] Route local mutual and self module-value cycles to stable source-located eager-initialization diagnostics through the CLI, with related cycle-member labels and without duplicate inference fallout.
- [x] Cover bare returns, non-tail drops, unreachable calls, and `Never` joins across i32, i64, f32, f64, v128, reference, and Unit stack shapes.
- [x] Emit unreachable block items as ordinary source-located warnings and exercise the ordered warning JSON oracle with a compiled runtime fixture.

**Done when:** every syntax form accepted and typed by the advertised current
subset either executes deterministically or receives an intentional source-level
diagnostic before backend planning.

### 1. Establish deterministic module WAT snapshots

- [x] Use recursive `<feature>/<test>.dew`, `<feature>/<test>.json`, and `<feature>/<test>.wat` conventions without fixture manifests.
- [x] Compile every fixture as one production module and execute its exported zero-argument `main`.
- [x] Keep JSON minimal: ordered compiler `errors`, ordered compiler `warnings`, and `output` as ordered stdout strings; `null` means compilation failed and no WAT exists.
- [x] Produce snapshots only after Starshine validation and binary encoding succeed.
- [x] Pin one version-stable external WAT printer until Starshine owns deterministic rendering.
- [x] Preserve stable type, function, import, memory, global, export, and code ordering rather than normalizing away compiler decisions.
- [x] Add a fail-closed comparison runner that prints a normal unified diff on mismatch.
- [x] Add an explicit snapshot-update command; ordinary test runs never rewrite expected files.
- [x] Establish broad feature-oriented fixture coverage beside `calls/`, `collections/`, `control-flow/`, `enums/`, `functions/`, `generics/`, `lanes/`, `memory/`, `modules/`, `names/`, `numeric/`, `reachability/`, `structs/`, `tests/`, `text/`, `types/`, and `wasi/`; discover totals from the fixture tree.
- [x] Capture successful `main` stdout as an ordered JSON string array; `text/concat` writes and verifies the complete concatenated string.
- [x] Snapshot deterministic compiler errors with `output: null` and no WAT, preserving multiline `Debug` diagnostics through a framed protocol.
- [ ] Continue adding successful cases, warnings, compiler failures, boundaries, and reduced stress cases within each feature.
- [x] Fix Bool literal-pattern emission with carrier-typed scratch locals and scalar equality instructions; `control-flow/bool-match` now verifies both cases through stdout and WAT.
- [x] Accept and emit literal patterns for every fixed-width integer and float type, including signed and explicit-positive prefix forms.
- [x] Add focused passing and failing test-mode fixtures through the optional `<test>.tests/*_test.dew` convention.
- [x] Connect ordered source-rendered compiler warnings to the JSON oracle; the empty-warning baseline remains contractual until ordinary warning producers land.
- [x] Add minimal `<test>.files/` and `<test>.modules/<dotted.module>/` conventions for multi-file and multi-module fixtures without putting module graphs into JSON.
- [x] Keep generated `.wasm` temporary while committing the readable `.wat` expectations.
- [x] Include the complete snapshot suite in `tools/check.sh`, the standard full-project validation entry point; retain `--quick` for formatter/generated/native checks.
- [ ] Add separate optimized snapshots only after Dew has an optimization pipeline whose output is intentionally part of the contract.

**Done when:** compiler-output changes produce reviewable WAT diffs, accidental ABI
or index-order changes fail CI, and contributors can regenerate an intentional
snapshot change with one explicit command. See
`docs/research/module-wat-snapshots.md`.

### 2. Freeze test discovery and reporting

- [x] Replace source-regex and assembled byte-offset discovery in the standard runner with compiler-emitted frozen test metadata.
- [x] Replace the provisional `DEW_TESTS_V3` sidecar with one deterministic `dew.tests` Wasm custom section and make test binaries self-describing.
- [x] Promote module/file/display-name metadata into a validated stable test identity and diagnose duplicate file/display-name pairs during collection.
- [x] Make the standard runner consume only compiler-produced metadata.
- [x] Add deterministic exact module/file/display-name filtering, identity substring filtering, and metadata-only listing.
- [x] Add declaration-level `expect_trap` metadata, validate stable trap categories, and make the runner continue after matching expected traps.
- [x] Preserve dynamic failed-assertion messages by converting the runtime `String` to shared `Bytes`, writing it to WASI stdout through bounded staging, and trapping; remove static assertion metadata and globals.
- [x] Hide test-only values, nominal types, traits, and impl evidence from ordinary-file body/type resolution while preserving visibility within test files.
- [x] Exclude test-only nominal layouts and test-callable reachability edges from production WasmGC fragments.
- [x] Audit current `_test.dew` non-callable artifacts: frozen interfaces/import scopes exclude test-only impl evidence, nominal layouts are option-filtered, and initialization steps retain test-only ownership. Future module-global/startup emission must honor the frozen marker.

**Done when:** test binaries are self-describing, filtering and expected traps need
no source scanning, and production planning cannot retain test-only semantic or
runtime artifacts.

### 3. Replace bootstrap-wide standard-library injection

- [x] Define strict explicit `dew.modules.json` compiler graphs with a root module and ordered module/file arrays.
- [x] Resolve explicit graph sources relative to the graph, reject escaping/absolute/duplicate paths, and preserve listed order without filesystem enumeration.
- [x] Split convention-first `dew.json` package intent from exact `dew.lock` resolution; derive module/source ownership from `@scope/name` and sorted package paths.
- [x] Define ordered compiler-owned package roots, deterministic fixed-registry source selection, and real on-disk `dew.std` lookup with `--package-root`/`DEW_PACKAGE_ROOTS`.
- [x] Resolve semantic-version and Git dependency requests through exact root `dew.lock` records with canonical SHA-256 integrity, expected interface fingerprints, deterministic transitive module order, and conflict/cycle rejection.
- [x] Split text ownership into `std/string.dew`, `std/string_builder.dew`, `std/bytes.dew`, and `std/bytes_builder.dew` plus a private bootstrap text-runtime declaration file.
- [x] Compile `std/preamble/*.dew`, ambient Option/Result, split text/bytes modules, WASI, and selected lane sources as independent compiler-owned modules.
- [x] Collect and freeze each selected standard interface once per compilation session rather than once per user module.
- [x] Skip interface-time body inference for modules without exported top-level values, and reuse deterministic ABI graph records and direct dependency indices across fingerprint construction.
- [x] Add a deterministic import prepass that selects lane, split text/bytes, and WASI standard modules plus their private dependency closure.
- [x] Resolve user modules only through the selected frozen standard interfaces; optional standard declarations no longer enter user declaration arenas.
- [x] Model `dew.std.preamble`, `dew.std.option`, and `dew.std.result` as implicit canonical imports.
- [x] Retain `--no-default-preamble` plus explicit `--bootstrap-std` modes for bootstrap and compiler tests.
- [x] Remove optional standard preamble-mirror injection from all supported host paths; generated byte tables remain only as portable source providers for independently collected modules.
- [x] Use the scalar WAT snapshot to verify that unrelated text, lane, and WASI signatures disappear: it now contains 951 type entries and 974 WAT lines before the frozen-module migration.
- [x] Elide dead imported signatures, external type references, callables, and nominal layouts before final program indexing.
- [x] Make installed/on-disk import-selected standard sources the default driver provider and require byte identity with generated bootstrap sources.
- [x] Add a persistent SHA-256 content-addressed frozen-interface cache for compiler-owned standard modules, including deterministic private serialization, cache-hit injection, checksum/identity validation, and fail-visible corruption handling.
- [x] Extend persistent interface caching to versioned external user packages with dependency closure keys and V11 artifacts; source recollection and generated bootstrap removal remain deferred until installed artifact provenance is reliable.
- [x] Add installed artifact-only interface recovery so versioned dependencies can compile from verified cached artifacts without recollecting their original source tree. V1 content-addressed `.dpa` capsules bind exact lock identity, source, integrity, interface fingerprint, dependency requests, ordered source payloads, per-file checksums, and an envelope checksum; missing locked trees are restored atomically at their path so normal frozen-interface injection and static linking preserve byte-identical Wasm.

**Done when:** installed package lookup can replace generated bootstrap byte
providers without changing frozen interfaces or Wasm bytes, an ordinary module
pays only for reachable imported interfaces/artifacts, and a no-default bootstrap
mode remains available for compiler tests.

### 4. Add a usable compiler and test driver

- [x] Implement `dew check` over explicitly ordered multi-file/multi-module inputs and strict minimal package manifests.
- [x] Implement `dew build` with manifest/root-module selection and deterministic Starshine-validated statically linked `.wasm` output.
- [x] Implement explicit-file and strict-manifest `dew test` with self-describing V3 metadata, globally unique manifest-order multi-module exports, stable filtering, expected traps, and listing.
- [x] Implement `dew run` with deterministic zero-argument `main` execution and bounded Preview 1 stdin/stdout hosting.
- [x] Execute the complete immutable collection/interface/analysis/lowering/link DAG outside MoonBit test harnesses through `tools/dew`.
- [x] Add deterministic `--emit hir`, `--emit lowering`, `--emit wat`, and `--emit wasm` outputs.
- [x] Return deterministic nonzero status for CLI usage, I/O, compilation, linking, validation, emission, empty test filters, and test failures.
- [x] Print stable file-aware diagnostics with manifest-stable paths, byte-based line/column lookup, source excerpts, carets, and secondary labels.
- [x] Add initial `compile-pass`, `compile-fail`, and `run-pass` fixture directories plus a deterministic CLI fixture runner in `tools/check.sh`.

**Done when:** a checked-in multi-module example can be checked, built, tested,
and executed from a Dew CLI with deterministic output and diagnostics.

### 5. Complete executable structured control flow

- [x] Finish structural short-circuit logical lowering in every value context.
- [x] Lower functional `while` through frozen state/result-local plans.
- [x] Emit `continue Expr`, `break Expr`, return, divergence, and `Never` joins correctly.
- [x] Emit nested tuple, struct, and enum patterns.
- [x] Emit alternative patterns with shared binding identities and conditional extraction.
- [x] Consume complete imported enum domains during exhaustiveness analysis.
- [x] Add deep, wide, nested, and cross-module execution matrices.

**Done when:** loops and nested matches execute without recursive compiler passes,
and imported closed enums receive the same exhaustiveness guarantees as local
enums.

### 6. Finish linked module state and implementation evidence

- [x] Emit module globals and direct scalar constant global initializers.
- [x] Emit deterministic initialization functions and an explicit `__dew_init` export invoked by Dew hosts before entry points.
- [x] Diagnose direct and callable-transitive cross-module eager initialization cycles.
- [x] Merge owner-coherent imported impl evidence and exact method identities into method/operator dispatch indexes.
- [x] Enforce imported evidence visibility and foreign-impl privacy.
- [x] Diagnose structural overlap between independently imported or local/imported implementation sets.
- [x] Merge reachable physical WasmGC recursive SCCs spanning modules.
- [x] Replace supported `UnsupportedProgramForwardTypeReference` cases with deterministic program-wide recursive groups.

**Done when:** linked modules can own initialized values, use imported impls, and
share recursive nominal layouts without weakening deterministic identity or
direct typed references.

### 7. Define the executable generic ABI

- [x] Propagate selected executable evidence for parsed generic bounds through closed-call specialization; ordered `t: Trait + Trait` syntax, HIR retention, trait-namespace resolution, local/imported call checking, generic-body symbolic selection, recursive per-call evidence freezing, evidence-aware specialization identity, generic-implementation prerequisite checking, and cache V11 round trips are implemented. Dynamic trait boundaries use the typed dictionaries and runtime evidence ABI completed below.
- [x] Solve call-site and generic-implementation prerequisite obligations using local and imported coherent evidence.
- [x] Define shared physical-carrier specializations and one nullable-`eqref` fallback for each public generic exported by the root module.
- [x] Emit exact-reference-to-erased callable adapters only when an escaping generic reference's concrete signature differs from its `eqref` fallback.
- [x] Emit immutable scalar carrier boxes, unboxes, and deterministic exported scalar-to-erased adapters for demanded direct generic parameter/result boundaries.
- [x] Support executable generic enum construction, transport, and pattern access through deterministic erased physical-carrier fields.
- [x] Execute generic parameter-selector functions and transparent generic callback wrappers through deterministic call-site specialization, including imported calls and expected-type generic references.
- [x] Materialize deterministic physical-carrier specializations for general generic function bodies, including locals, structured control flow, nested/transitive generic calls, multiple type parameters, escaping references, and imported definitions.
- [x] Coalesce source shapes with the same Wasm carrier and assign deterministic declaration-plus-carrier ABI keys.
- [x] Keep unspecialized generic recipes out of the executable/export ABI until erased fallback adapters are defined.
- [x] Support generic struct construction/access through deterministic per-field erased carrier slots without scalar boxes.
- [x] Add root-exported erased callable fallbacks and exact nominal-reference adapters for specialization boundaries that cannot be statically closed.
- [x] Extend erased adapters to direct scalar boundaries with deterministic WasmGC boxes.
- [x] Add recursive representation adapters for generic occurrences nested inside aggregates and structural function signatures. Direct leaves and nested generic struct/enum graphs clone across erased boundaries with exact variant subtype reconstruction, lazy scalar box/unbox conversion, and deterministic recursive helpers at cyclic nominal edges. Structural callbacks use deterministic flattened closure subtypes that capture the source closure once, recursively wrap nested callback parameters/results, convert scalar leaves, populate function-valued struct/enum payload fields during nominal reconstruction, and dispatch through the source direct or environment-first signature. Instantiated generic aggregate fields and enum pattern bindings retain concrete structural signatures and execute through the ordinary function-value call path.
- [x] Complete the implemented ABI/interface compatibility layer: V4 callable fingerprints plus content-sensitive V2 nominal and transitive reachable-interface fingerprints persist through frozen-interface/cache V11 and ignore external `DeclId` assignment; language-version-2 `dew.abi` negotiation rejects incompatible providers; Node and in-Wasm consumers exercise scalar, exact-nominal, `v128`, aggregate, callback, runtime-trait-evidence, and imported generic boundaries.
- [x] Define and implement trait objects, prerequisite-aware local/imported dictionaries, scalar/packed/SIMD boundary boxes, external runtime evidence, and typed-field `call_ref` dispatch.

**Done when:** representative cross-module generic functions and aggregates
execute with deterministic specialization, bounded code growth, a documented
erased fallback, and typed runtime-trait dictionaries at actual dynamic
boundaries.

### Continuous hardening and measurement

- [ ] Expand generated lane tests from smoke coverage to every generated operation family.
- [ ] Add retained-range, small-inline-string, hashing, ordering, and UTF-8 scalar-iteration measurements before extending the text ABI.
- [x] Add source provenance to every HIR node needed for user-facing diagnostics.
- [ ] Define explicit compiler resource budgets and diagnostic behavior before the later fuzzing phase. Deterministic static Wasm/WAT size, section/entity, adapter, materialized-specialization, call, allocation-site, cast/test, and local-access metrics now gate closure, mutable-cell, generic-adapter, recursive-helper, and imported-package workloads.
- [ ] Track compile time, validation/encoding time, runtime time, allocations, and peak memory separately; static instruction-site budgets are implemented, while timing and peak-memory workloads remain.
- [x] Re-run Wago Core 3 compatibility checks for `array<mut v128>`, erased generic enums, Dew text search, all compiler snapshots, and WASI host callbacks; the standalone CLI now supports explicit `--core 3` activation.
- [ ] Design optional arguments only after the callable ABI and interface format above stabilize.

## Source model and diagnostics

### File and source provenance

- [x] Add stable packed `FileId`.
- [x] Keep byte offsets source-local.
- [x] Add `SourceLocation(FileId, offset)`.
- [x] Retain declaration and body file provenance.
- [x] Retain file identity in parse and duplicate-name diagnostics.
- [x] Retain file identity for every HIR expression, pattern, block, arm, field, lambda parameter, and type-syntax node needed by diagnostics.
- [x] Associate offset-bearing semantic diagnostics with stable source locations or their owning body/lambda provenance at the reporting boundary.
- [x] Add stable byte-offset-to-line/column lookup per retained source file.
- [x] Add source excerpts and caret rendering.
- [x] Support secondary labels for duplicate declarations/fields/tests, return-type mismatches, implementation conflicts, and cross-file cycles.
- [x] Preserve source-backed diagnostics after parser-token eviction by retaining immutable file path/source records independently of tokens.
- [x] Sort diagnostics by module order, manifest file order, byte offset, and deterministic rank.

### Multi-file behavior

- [x] Share one namespace across files in a module.
- [x] Resolve cross-file function calls.
- [x] Diagnose cross-file duplicates with both `FileId`s.
- [x] Emit one Wasm module from multiple Dew files.
- [ ] Add cross-file type, trait, impl, enum, struct, and module-let tests.
- [ ] Add forward/reverse simulated file-job completion tests.
- [ ] Add hundreds-of-files stress tests.
- [x] Treat qualified imports and opens from every source file as contributions to the owning Dew module's import scope; neither form affects another module.
- [ ] Define duplicate identical imports, opens, and aliases across files with both source locations.

## Module and visibility semantics

- [x] Default declarations are `ModuleVisible`.
- [x] `pub` controls visibility outside the module.
- [x] Files do not create private namespaces.
- [x] Remove `global` as a keyword and replace the misleading `global import` form with module-scoped `open module.path`.
- [x] Keep qualified `import` names out of unqualified lookup; `open` contributes public names only to the current module and never re-exports them.
- [x] Reserve `@identifier` for imported module aliases, parse `import path as @alias`, derive the final path segment as the default alias, resolve aliased imported function calls, reject qualified-import wildcards, and reject aliases on opens.
- [ ] Extend imported module aliases through type, trait, enum-constructor, pattern, and static-impl namespaces, plus duplicate-alias source labels; non-callable public module values are implemented.
- [ ] Define selective imports, if desired.
- [ ] Define re-exports.
- [ ] Define package visibility if module visibility is not sufficient.
- [x] Specify package ownership for ordinary trait implementations and keep explicit `foreign impl` evidence private to its exact declaring module.
- [x] Prevent private foreign evidence from leaking into public signatures or frozen interfaces.
- [ ] Define canonical standard operator trait identities across imports.
- [ ] Diagnose local declarations that conflict with canonical ambient traits.
- [ ] Decide default-preamble opt-out syntax.

## Type system and generics

### Existing foundations to extend

- [x] Canonical resolved primitive, generic, nominal, trait, `Self`, applied, and poison types.
- [x] Transparent aliases with cycle analysis and bounded expansion.
- [x] Body-local unification with rollback.
- [x] Rigid declaration generics and fresh call-site variables.
- [x] Monomorphic local and module lets.
- [x] Expected-type-driven calls, constructors, patterns, methods, and loops.

### Compile-time annotations and derivation

- [ ] Define `#annotation(...)` syntax with compile-time constant parameters, including the permitted constant types, name resolution, validation, retention, and interface serialization rules.
- [ ] Expose frozen annotations to compiler features and future tooling without making runtime reflection ambient.
- [x] Implement postfix `derive(Eq)`, generated `Ne`, `derive(Debug)`, and `derive(Hash)` for structs and enums through ordinary coherent implementations and evidence-aware generic specialization. Generated evidence retains field/payload prerequisites, cross-module interfaces, cache round trips, imported execution, and derive-site diagnostics.
- [ ] Extend derivation with `Show` only after its trait and builder contract are defined; settle typed lane Debug formats, recursion/resource limits, deterministic non-WASI behavior, and the relationship between postfix derive syntax and future annotations.
- [x] Route conflicts between derived and handwritten implementations through ordinary local/imported coherence, preserve both source locations, and prevent generated evidence from bypassing evidence visibility or dispatch filtering.

### Remaining generic work

- [x] Parse and represent ordered generic bounds through `t: Trait + Trait`, flat HIR provenance, trait-namespace resolution, and private frozen-interface cache V11 serialization.
- [x] Add trait obligations to generic signatures and enforce them at local and imported calls.
- [x] Enforce local and imported generic-implementation prerequisites when selecting coherent evidence.
- [x] Make generic bodies consume their declared symbolic evidence for operator and method selection.
- [x] Freeze selected evidence per generic call.
- [x] Resolve caller-bound evidence, include it in specialization identity, and execute symbolic method/operator calls through concrete implementation methods.
- [ ] Define method-level generic syntax and shadowing.
- [ ] Define explicit call-site type-argument syntax.
- [ ] Improve ordinary overload specificity from generic-count tiers to structural containment.
- [ ] Define associated types, or explicitly defer them from the initial language.
- [ ] Define associated constants, or explicitly defer them.
- [ ] Define supertraits, or explicitly defer them.
- [ ] Define higher-kinded types only if concrete library requirements justify them.
- [ ] Define variance only if exposed by subtyping or mutable generic references.
- [ ] Keep inference variables out of frozen module type interners.

## Traits, implementations, and dispatch

### Static dispatch

- [x] Validate trait impl method signatures.
- [x] Build deterministic impl indexes.
- [x] Check structural overlap and specialization.
- [x] Select inherent and qualified methods, including primitive-qualified static functions such as `StringBuilder::new()`.
- [x] Freeze exact impl/method evidence.
- [x] Directize trivial primitive wrappers.
- [x] Freeze and translate cross-module impl heads into consumer type arenas.
- [x] Merge owner-coherent imported impl evidence into method/operator dispatch and trait-obligation bucket indexes.
- [x] Add public/private evidence visibility checks and keep `foreign impl` evidence module-local.
- [x] Diagnose structural overlap between independently imported or local/imported evidence.
- [x] Add trait obligations on generic functions.
- [x] Enforce cross-package orphan rules for ordinary local, generic, derived, imported, and cache-backed trait evidence.
- [ ] Define negative impls only if required.
- [ ] Define sealed traits only if required.

### Runtime trait values

- [x] Define trait-object source syntax: a bare trait in value position denotes an erased runtime trait value.
- [x] Define implicit boxing at erased trait boundaries; nominal references enter directly, while scalar/packed/SIMD values allocate one carrier-specific snapshot box only at the boundary.
- [x] Plan WasmGC trait object layouts for nominal object-safe receivers.
- [x] Plan typed function-reference dictionary slots in deterministic trait source order.
- [x] Emit one shared local nominal dictionary per exact trait implementation.
- [x] Reconstruct imported trait signatures and emit linked dictionaries/adapters for imported implementations and receiver nominals.
- [x] Materialize closed generic implementation dictionaries and method specializations keyed by ordered prerequisite evidence trees, including imported providers.
- [x] Emit typed-field `call_ref` dynamic dispatch with single receiver evaluation.
- [x] Define mutable boxed scalar receiver behavior: a future mutable receiver changes only the trait-owned snapshot box and never writes back to the conversion source; current receivers remain immutable.
- [x] Define trait-object identity and equality semantics: ambient identity is unobservable and no universal erased-value equality exists; equality requires an explicitly object-safe operation.
- [x] Directize exact non-generic calls through transparent trait forwarding wrappers, eliminating their call-site boxes, dictionaries, adapters, and `ref.func` roots.
- [x] Add prerequisite-aware exact trait-object flow analysis through non-captured locals, same-evidence branches, transparent parameter returns, and effect-free forwarding chains; directize closed evidence, rewrite non-escaping carriers, and remove dead private wrappers plus unused runtime artifacts.
- [x] Resolve symbolic runtime-trait evidence through closed generic specializations; directize transparent tail/explicit-return parameter selectors, materialize exact dynamic dictionaries with recursive prerequisites, support imported generic providers, and canonicalize shared cross-module trait layouts.
- [x] Define the V1 external runtime-evidence ABI for public generic bodies whose symbolic bounds are consumed by erased trait coercions or direct bound methods/operators; append source-ordered `eqref` vtable parameters and validate both static and erased dispatch through a structurally typed external Wasm consumer.
- [x] Forward direct external runtime evidence through private, recursive, and imported generic call chains with contiguous callee hidden slots and call-site source-parameter forwarding.
- [x] Forward runtime prerequisites through statically selected concrete generic implementation evidence and exact implementation-method specializations.
- [x] Support escaping bounded function references/callbacks with immutable closure subtypes that capture source-ordered caller runtime dictionaries and invoke exact local/imported target specializations through environment-first trampolines.
- [x] Support erased trait dictionaries whose immutable receiver capture carries source-ordered caller-local runtime prerequisites through exact local/imported adapters without changing the V1 vtable ABI.
- [x] Broaden callback and runtime-trait effect/escape summaries across non-transparent public APIs: compute transitive total/discardable callable summaries, follow immutable callback aliases and forwarding chains across modules, directize exact internal calls while retaining public fallback bodies, and conservatively retain trapping, escaping, conditionally/multiply invoked, or unknown uses.

## Expressions and statements

### Deterministic cleanup

- [x] Add Boolean `is` pattern-test expressions with exactly-once scrutinee evaluation, standalone match desugaring, and branch-local bindings for direct `if` conditions and `&&` guards.

- [ ] Add `dew.std.disposable.Disposable` with an explicit cleanup operation and clear ownership/error semantics.
- [ ] Add `defer` for deterministic scope-exit cleanup, defining LIFO order across normal fallthrough, `return`, `break`, `continue`, and traps or explicitly documenting trap exclusions.
- [ ] Add `using` for scoped `Disposable` values, lowering it through the same cleanup plan without hidden nondeterministic finalization.
- [ ] Diagnose invalid cleanup captures, double disposal, unsupported asynchronous escape, and control-flow cases that cannot satisfy exactly-once disposal.
- [ ] Add parser, HIR, flow, lowering, WAT snapshot, runtime, and cross-module tests for `defer`, `using`, and `Disposable`.

### Scalar execution

- [x] Emit the scalar subset required by recursive Fibonacci.
- [x] Emit every integer comparison and arithmetic instruction.
- [x] Emit unsigned comparisons/division/remainder.
- [x] Emit `i64`, `f32`, and `f64` constants and operations.
- [x] Emit conversions and reinterpretations through registered builtins.
- [x] Emit prefix operators.
- [x] Emit the currently supported immutable and mutable name-binding local-let forms, including carrier-typed locals and captured mutable cells.
- [x] Emit valued and bare `return` forms.
- [x] Emit drops for non-tail expressions across the currently supported single-value Wasm carrier shapes.
- [x] Expand explicit unreachable/`Never`, discarded Unit-tail, bare-return, and supported-shape stack validation coverage across every current single-value carrier.

### Mutation

The first mutation tranche is deliberately limited to lexical locals declared
with `let mut`. Mutation belongs to the binding, not to its value type or to a
general mutable-reference qualifier.

```dew
let mut count = 0
count = count + 1
```

#### Source semantics and diagnostics

- [x] Parse and resolve `let mut` declarations while preserving binding mutability in exact local and capture identities.
- [x] Parse simple-name assignment as a block item: `name = expression`. Assignment is not a general expression and produces `Unit` for block sequencing and flow analysis.
- [x] Evaluate the right-hand side exactly once, after resolving the target, then replace the current value of the existing binding without introducing or shadowing a name.
- [x] Permit assignment only when the exact resolved target is a `let mut` local or a lambda capture whose ultimate source is a `let mut` local.
- [x] Diagnose assignment to immutable `let`, parameters, pattern bindings, module values, declarations, unknown names, and non-name targets at the assignment site.
- [x] Constrain the right-hand side to the binding's inferred/declared type and retain ordinary numeric, nominal, function, generic-shape, and `Never` checking.
- [x] Keep parameters and pattern bindings immutable in this tranche. A programmer must explicitly write `let mut copy = parameter` or rebind a pattern result before assignment.
- [x] Explicitly omit compound assignment (`+=`, `-=`, and related forms), increment/decrement syntax, destructuring assignment, aggregate field writes, and module-global mutation until each receives separate syntax, effect, and ABI decisions.

#### Runtime representation

- [x] Keep a mutable local that is never captured as an ordinary carrier-typed Wasm local; reads use `local.get` and assignments use `local.set`, with no GC allocation.
- [x] Promote a mutable local captured by any lambda to one shared WasmGC cell allocated when that `let mut` binding executes. The cell, not a copied scalar/reference value, is the capture payload.
- [x] Use carrier-specialized final cell structs with one mutable field for `i32`, `i64`, `f32`, `f64`, `v128`, and `eqref` storage. Preserve exact nominal/function casts at cell-read boundaries rather than proliferating nominal cell types.
- [x] Allocate exactly one cell per dynamic execution of the captured binding. Re-entering a block or function creates a fresh cell; constructing multiple sibling, nested, returned, or repeated closures over the same execution reuses the same cell reference.
- [x] Make reads and writes in the declaring body and every direct/transitive capturing lambda dereference that shared cell, so mutations are immediately visible in both directions and after the creator returns.
- [x] Route mutable captures through intermediate lambdas as the unchanged cell reference. Transitive capture planning never loads and recopies the current field value.
- [x] Keep immutable captures in flattened closure fields exactly as today. A closure may therefore contain a deterministic mixture of copied immutable values and shared mutable-cell references.
- [x] Pass the shared cell reference, rather than its current value, as a lifted parameter when a lambda with a mutable capture is directized. Allocation elimination may remove the closure object but must not remove or duplicate an observably shared cell.
- [x] Treat captured function values and nominal/reference values through the same `eqref` cell carrier. Preserve typed closure-entry and nominal casts after loading the cell field.
- [x] Omit physical storage for captured `Unit`; assignment still evaluates its right-hand side and yields `Unit`. `Never` cannot produce an initialized mutable binding.

#### Deterministic planning and optimization

- [x] Compute captured-mutable-local promotion from frozen exact capture provenance (`BodyLocalCapture`/`LambdaLocalCapture`) before Wasm local and closure-field planning.
- [x] Add explicit `PlannedLocalSet` and `PlannedCaptureSet` lowering operations; cell construction/read/write is selected from frozen mutable-capture provenance and carrier shape rather than generic source-expression forms.
- [x] Preserve source/first-use ordering for cell types, closure fields, lifted parameters, locals, and emitted instructions; snapshots do not depend on map iteration order.
- [x] Treat cell writes and allocation as observable by retaining assignment block items and conservatively excluding mutable bindings from closure-value elimination.
- [x] Keep conservative closure escape rules: returning, globally storing, capturing, importing/exporting, or passing a closure remains escaping even when its only mutable state is a cell.
- [x] Add snapshot allocation coverage proving uncaptured mutation allocates nothing, one captured binding allocates one cell regardless of closure count, and directized mutable captures allocate a cell but no closure.

#### Validation sequence

- [x] Land parser/HIR/name-resolution coverage for valid `let mut` assignment, exact target identity, and immutable/invalid-target diagnostics.
- [x] Land inference/flow/lowering coverage for scalar, SIMD, nominal, reference, and function-valued mutable locals.
- [x] Add runtime fixtures for uncaptured updates; declaring-body/closure bidirectional visibility; sibling closures; nested/transitive captures; returned closures; repeated calls; and directized mutable captures.
- [x] Add WAT coverage for carrier-typed `local.set`, cell `struct.new`, shared cell capture fields, `struct.get`/`struct.set`, and the absence of redundant closure allocations.
- [x] Re-run all native/WasmGC/JavaScript/classic-Wasm tests and Node snapshots; re-enable Wago Core 3 validation only after its sibling checkout is healthy.
- [x] Document final assignment and shared-cell semantics in `docs/spec.md` and `docs/research/closures-and-function-values.md` in the same implementation commit that makes them executable.

### Calls and values

- [x] Direct free, builtin, inherent, trait, and qualified method selection.
- [x] Parse deterministic `fn(T, ...) -> R` type syntax and preserve it through HIR collection.
- [x] Structurally intern, alias-normalize, import, cache, compare, and assign opaque reference shapes to first-class function types.
- [x] Resolve unambiguous and expected-type-selected non-generic local/imported function references and structurally type-check calls through function-valued locals.
- [x] Emit non-capturing function references and first-class calls with typed `ref.func`/`call_ref`.
- [x] Closures and captured environments.
  - [x] Parse explicit typed lambda expressions with forward-only cursor movement.
  - [x] Collect nested lambda bodies into isolated source-ordered HIR fragments.
  - [x] Resolve deterministic direct and transitive lexical capture sets.
  - [x] Resolve lambda signatures into canonical structural function types.
  - [x] Infer isolated lambda bodies, captures, calls, and declared results.
  - [x] Analyze isolated lambda control flow and exhaustiveness.
  - [x] Lower explicit closure construction, capture reads, and lambda bodies.
  - [x] Plan deterministic closure layouts and per-lambda capture fields.
  - [x] Emit environment-first entries, allocation, captured loads, and typed calls.
  - [x] Flatten each lambda environment into one closure subtype allocation.
  - [x] Directize immediate and call-only local lambdas with lifted capture parameters.
  - [x] Remove call-only local named-reference allocations and indirect dispatch.
  - [x] Elide unused local closure values, lambda entries, and physical subtypes.
  - [x] Reuse repeated escaping named references through one body-local closure cache.
  - [x] Unify linked module closure bases and promote each surviving named declaration to one deterministic program-wide singleton global.
  - [x] Directize transparent call-only callback wrappers interprocedurally for known lambda and named arguments, including expression tails, explicit returns, and immediate immutable local returns.
  - [x] Snapshot an allocation-free directization fixture with no closure type or `call_ref`.
  - [x] Conservatively retain the closure ABI for captured, returned, passed, global, and imported values.
  - [x] Execute returned, nested, passed, module-level, and imported closures in Node.
  - [x] Box captured `let mut` bindings in shared carrier-specialized cells; closures capture and route the cell reference, while uncaptured mutation remains an unboxed Wasm local.
- [x] Emit typed indirect calls for non-capturing function values.
- [ ] Tail-call optimization if supported and measured.
- [x] Cross-module direct calls and static imports.

### Indexing

- [x] Define ambient `IndexedGet<key, value>` and reference-free `IndexedSet<key, value>` traits.
- [x] Select exact indexing and indexed-setting evidence during inference.
- [x] Replace `UnsupportedIndexLowering` for trait-backed syntax and compiler-known FixedArray operations.
- [x] Define FixedArray bounds behavior: optional `get`; trapping index get/set, `set`, and unchecked operations.
- [ ] Enforce the `(Self, key) -> value` functional dependency and extend indexing to later Array/map types.

## Aggregates and runtime representation

### Structs

- [x] Parse, resolve, infer, and plan struct layouts.
- [x] Emit non-generic local and imported struct construction.
- [x] Emit typed local and imported field reads.
- [ ] Emit field writes if mutation is supported.
- [x] Handle generic struct ABI specialization/erasure.
- [ ] Add allocation and field-access benchmarks.

### Enums

- [x] Parse, resolve, infer, and plan enum variant layouts.
- [x] Assign stable source-order tags.
- [x] Emit one non-final subtype-family base per enum.
- [x] Reuse the base directly for physically empty unit variants.
- [x] Emit direct tuple and struct payload fields in final variant subtypes.
- [x] Emit tag reads, subtype casts, and payload field reads.
- [x] Share exact payload shapes within one enum family.
- [x] Remove the slower tagged-envelope representation after measurement.
- [ ] Add flat scalar-enum specialization only after representative measurement.

### Strings

- [x] Use distinct GC-managed String/StringView/Bytes wrappers and a consuming StringBuilder over zero-padded `array<mut v128>` chunks.
- [x] Require strict UTF-8 for String and preserve arbitrary data only in Bytes.
- [x] Emit GC-backed constants without `stringref`.
- [x] Add `dew.std.string` byte length, backing sharing, validation, String-only UTF-16 length, exact equality, and trapping byte-index APIs.
- [x] Add checked Bytes-to-String conversion that validates once, traps on malformed UTF-8, and shares backing on success.
- [x] Add shared StringView slicing and a consuming StringBuilder for String/StringView append.
- [x] Add BytesBuilder over the shared deterministic V128 builder engine.
- [x] Add shared Bytes ranges plus strict `view`, `subarray`, `slice`, and `compact` range semantics across text and bytes.
- [x] Add overflow-checked flat String/StringView/Bytes concatenation with exact start-zero V128 ownership.
- [x] Add allocation-free Bytes byte search plus exact prefix and suffix matching with a public semantic result enum.
- [x] Add exact allocation-free Bytes substring search with short-needle SIMD filtering and long-needle rolling fingerprints.
- [x] Complete a text-runtime hardening sprint with 17,471 deterministic parity checks, deliberate hash collisions, boundary matrices, full builder-consumption traps, nominal ABI regressions, and 64 KiB stress.
- [x] Add allocation-free String/StringView find, contains, prefix, and suffix matching across all String/View operand combinations.
- [ ] Add ordering, hashing, and code-point iteration.
- [x] Add bounded linear-memory scratch lowering for WASI Bytes interfaces.

### Arrays, maps, queues, and collections

- [x] Implement carrier-specialized mutable `dew.std.fixed_array` with safe optional get, trapping index get/set, explicit unchecked operations, aliases, and zero-length behavior.
- [x] Implement growable `dew.std.array` over the same six physical carrier families, with deterministic capacity growth, alias-visible mutation, optional pop/get, Boolean safe set, trapping indexed access, and clearing of removed reference slots.
- [x] Implement `dew.std.collections.circular_buffer` with bounded and growable modes, deterministic wraparound, and carrier-specialized storage.
- [x] Implement `dew.std.collections.stack` with explicit empty-pop/peek result semantics.
- [x] Implement growable `dew.std.collections.deque` with operations at both ends and logical-order iteration.
- [x] Implement `dew.std.collections.binary_heap` with retained deterministic comparator evidence, explicit min/max policy, Floyd heapification, and layout-order iteration.
- [x] Implement `dew.std.collections.priority_queue` as a thin value/priority wrapper over BinaryHeap with retained comparator policy and unspecified equal-priority order.
- [x] Implement `dew.std.collections.red_black_tree` with insertion/removal balancing, invariant checks, bounds, predecessor/successor, and deterministic range traversal.
- [ ] Implement ordered map/set wrappers and range APIs over the shared red-black tree core.
- [ ] Implement `dew.std.collections.finger_tree` only after sequence/deque/measure use cases and representation costs are specified and benchmarked.
- [ ] Define a standard persistent list representation only if measured workloads justify it.
- [x] Implement `dew.std.map` with ambient U64 Hash evidence, collision-safe equality, deterministic buckets, erased carriers, safe lookup, insertion/replacement, and index syntax.
- [x] Implement `dew.std.set` over the same collision-safe Hash table with idempotent insertion, linked-chain removal, clear, membership, emptiness, and length.
- [x] Add shared geometric Map/Set bucket growth with a measured maximum load factor of 1.0 and deterministic iterative rehashing that reuses stored hashes.
- [x] Add Boolean Map removal and alias-visible O(1) clear using the proven Set chain-unlinking machinery.
- [ ] Add deterministic allocation-free Hash implementations for String, StringView, and Bytes after finalizing their cross-type equality contract.
- [x] Implement `dew.std.queue` over growable circular-buffer storage with O(1) amortized enqueue/dequeue and stable FIFO iteration.
- [x] Add ambient `Iter<t>` plus explicit Array, Map key/value/entry, and Set key iterator types while leaving hash traversal order unspecified.
- [ ] Define remaining collection mutation and persistence rules.
- [ ] Benchmark WasmGC arrays and hash buckets versus linked/tree representations.

## Pattern matching and control flow

### Match emission

- [x] Parse and infer patterns, guards, alternatives, and rest patterns.
- [x] Analyze Bool/enum exhaustiveness and basic redundancy.
- [x] Build immutable basic enum-match decision plans.
- [x] Emit enum tag tests.
- [x] Emit payload casts and tuple/struct field extraction.
- [x] Emit top-level literal and catch-all tests.
- [x] Emit guard fallthrough.
- [ ] Share extraction work across nested alternatives.
- [ ] Add full nested pattern-matrix usefulness when needed.
- [ ] Preserve deterministic source-order diagnostics.

### Functional loops

- [x] Parse, resolve, infer, and flow-check functional `while`.
- [x] Lower state/result locals.
- [x] Emit structured Wasm blocks and loops.
- [x] Emit `continue Expr` state updates.
- [x] Emit `break Expr` results.
- [x] Handle returns and divergence inside arms.
- [x] Add deep and wide execution tests.

### Other control flow

- [ ] Decide whether reserved `loop` becomes a second loop form.
- [ ] Decide whether ordinary Boolean `while` is ever added.
- [x] Add short-circuit logical emission for all value contexts.
- [ ] Add tail-position branch optimization.

## Module values and initialization

- [x] Infer module-value dependency SCCs.
- [x] Separate type-solvable recursion from runtime eager-cycle legality.
- [x] Freeze deterministic eager initialization schedules.
- [x] Emit module globals.
- [x] Emit direct scalar constant global initializers when legal.
- [x] Emit per-value initialization functions for non-constant values.
- [x] Emit a deterministic `__dew_init` initializer export.
- [x] Order cross-module initialization by module dependency SCCs.
- [x] Diagnose direct and callable-transitive cross-module eager cycles.
- [ ] Define lazy module values only if required.

## WasmGC backend

### Section emission

- [x] Type section.
- [x] Import section.
- [x] Function section.
- [x] Export section.
- [x] Code section for the implemented scalar, aggregate, text, lane, test, and WASI subset.
- [x] Global section.
- [ ] Start section.
- [ ] Element/table sections for dynamic dispatch.
- [ ] Data/string sections as required.
- [ ] Name section.
- [ ] Source map or custom diagnostic section.

### ABI work

- [x] Freeze callable signatures and runtime shapes.
- [x] Assign deterministic module-local function/type indices.
- [x] Assign deterministic program-wide scalar function/signature indices.
- [x] Statically link scalar calls across module dependencies and SCCs.
- [x] Export only the selected root module's public functions.
- [x] Rebase module-local physical WasmGC groups and dependency-directed nominal references.
- [x] Merge physical WasmGC SCCs spanning multiple modules and emit binary-encodable final-index references inside shared recursive groups.
- [ ] Deduplicate equivalent ABI signatures.
- [x] Define generic scalar/reference specializations by canonical Wasm carrier.
- [x] Define root-exported erased `eqref` fallback ABIs.
- [x] Emit scalar boxes/unboxes for demanded direct generic parameter/result boundaries.
- [x] Emit exact nominal-reference static-to-erased adapters.
- [x] Emit deterministic scalar-to-erased export adapters.
- [x] Emit recursive adapters for nested generic aggregate/function representations.
- [x] Define cross-module ABI fingerprints with content-sensitive nominal and transitive reachable-interface fingerprints.
- [x] Reject incompatible separately compiled interfaces through versioned `dew.abi` negotiation.

### Validation and compatibility

- [x] Use Starshine as the sole compiler-side Wasm validator.
- [x] Encode with Starshine binary encoding only after Starshine validation.
- [x] Execute encoded output with Node as a runtime integration test.
- [x] Add execution tests for all supported scalar operations and conversions.
- [x] Add struct construction/field execution tests, including imported structs.
- [x] Add enum and basic match execution tests.
- [x] Add loop, module-initialization, and dynamic-dispatch execution tests across module snapshots, semantic/backend suites, Node, and Wago.
- [ ] Track required WasmGC feature versions and runtime compatibility.

## Optimization

### Deterministic semantic/backend optimizations

- [x] Directize trivial standard wrappers.
- [x] Elide unexported directized wrappers.
- [x] Exact callable reachability and dead function elimination.
- [x] Dead signature-type elimination, including removal of external type references contributed only by elided signatures.
- [x] Dead nominal/payload and compiler-runtime type elimination: frozen `uses_text_runtime` requirements prevent elided String signatures from retaining the V128 array and five text/bytes structs; the scalar smoke is 81 bytes and contains only its three function types.
- [ ] Constant folding after exact operation selection.
- [ ] Inlining using immutable call graph summaries.
- [ ] Tail-recursion optimization.
- [ ] Common subexpression elimination where allocation/effects permit.
- [ ] Escape analysis for boxes, payloads, and trait objects.
- [ ] Scalar replacement of short-lived aggregates.
- [x] Devirtualize trait-object calls when prerequisite-aware flow analysis proves exact evidence through locals, branches, parameter returns, and effect-free forwarding chains.
- [ ] Enum representation specialization based on frozen usage/layout data.
- [ ] Profile-guided optimization only after deterministic baseline builds exist.

### Performance discipline

- [x] Keep phase-only and full-pipeline benchmarks for implemented major phases.
- [x] Track native, WasmGC, JavaScript, classic Wasm, and Node integration runners.
- [x] Add multi-file/module graph, import-resolution, and static-link benchmarks.
- [x] Add release-mode phase-only standard-interface cache benchmarks separating serialization (2.89 ms), decoding (3.09 ms), cached injection (1.77 ms), and fresh freezing (5.31 ms) on the all-standard wildcard workload.
- [x] Parallelize independent full-check MoonBit target suites through isolated persistent target directories, prebuild and parallelize snapshot compilation with deterministic buffered output, and run the large UTF parity generator in release mode without reducing validation coverage.
- [ ] Add cache-file I/O/checksum timings, allocation/peak-memory measurements, and representative external-package workloads before treating cache hits as an end-to-end performance win.
- [ ] Track allocations and peak memory, not only wall time.
- [ ] Establish regression thresholds for hot workloads.

## Standard library

### `dew.std.preamble`

- [x] Initial `I32` `Add`, `Sub`, and `Lte`.
- [x] Complete primitive equality and ordering.
- [x] Complete primitive arithmetic and bit operations.
- [x] Complete the scalar `Into<T>` conversion matrix.
- [x] Ambient generic `Option<t>` and `Result<t, e>` through separate canonical `dew.std.option` and `dew.std.result` modules.
- [x] Define the ambient `Debug` system trait, primitive implementations, deterministic source-order derived formatting, and bounded partial-write-safe WASI output.
- [x] Add `debug(value)` using ordinary coherent `Debug` evidence and inference-time dispatch.
- [ ] Define `Show`, its relationship to `StringBuilder`, formatting stability, recursion/resource limits, typed lane formatting, and derived behavior.
- [ ] Add `show(value) -> String` using `Show` evidence.
- [ ] Define deterministic Debug behavior when WASI is unavailable.
- [x] Keep the minimal `Iter<t>` protocol ambient with `has_next` and trapping state-advancing `next`.
- [ ] Keep the ambient surface intentionally small.

### `dew.std.map`

- [x] Define public empty/singleton, insertion, replacement, lookup, membership, length, index, and indexed-setting APIs.
- [x] Define ambient `Hash` with U64 hashing and collision-safe `hash_eq`; complete Hash implementations alone qualify as keys.
- [x] Implement a canonical WasmGC map wrapper, deterministic bucket array, and erased unboxed key/value carrier entry layout.
- [x] Add exact frozen Hash evidence, collision-chain traversal, replacement, safe `Option` lookup, and missing-index traps.
- [x] Explicitly leave iteration order unspecified.
- [x] Add custom-key equal-hash collision, empty, replacement, carrier, Node, and Wago tests.
- [x] Add geometric bucket growth with deterministic stored-hash rehashing and a measured maximum load factor of 1.0.
- [x] Implement Boolean removal with deterministic head/middle/tail unlinking and logical-length updates.
- [x] Implement alias-visible O(1) clear by replacing bucket storage and resetting logical length.
- [x] Add allocation-free-per-element key/value/entry iterators with paired `MapEntry` access and unspecified traversal order.

### `dew.std.queue`

- [x] Define the public mutable queue API.
- [x] Replace the measured contiguous baseline with the mutable ring-buffer representation.
- [x] Implement enqueue, dequeue, peek, size, and iteration.
- [x] Add empty-queue result semantics.
- [x] Benchmark the contiguous FIFO baseline against carrier-equivalent LIFO removal; benchmark linked/persistent alternatives only if the ring representation misses budgets.

### Additional likely modules

- [ ] `dew.std.list`
- [x] `dew.std.fixed_array`
- [ ] `dew.std.array`
- [x] `dew.std.collections.circular_buffer`
- [x] `dew.std.collections.stack`
- [ ] `dew.std.collections.binary_heap`
- [ ] `dew.std.collections.red_black_tree`
- [ ] `dew.std.collections.finger_tree`
- [x] `dew.std.string`
- [x] `dew.std.set`
- [ ] `dew.std.iter`
- [ ] `dew.std.math`
- [ ] `dew.std.io`
- [ ] `dew.std.testing`
- [ ] `dew.std.disposable`
- [ ] `dew.std.http`
- [ ] `dew.std.crypto.fast`
- [ ] `dew.std.crypto.timing`
- [ ] `dew.std.crypto.password`
- [x] `dew.std.wasi`
- [x] Establish `dew.std.wasm.intrinsics` as the sole source-language home for direct compiler-known WebAssembly intrinsics; `@identifier` is now reserved for imported module aliases and the first migrated intrinsic is executable through that module.
- [ ] Complete `dew.std.wasm.intrinsics` coverage for every supported WebAssembly Core 3 scalar, reference, GC, memory, table, SIMD, conversion, control, and host-boundary builtin, with generated declaration/backend parity checks so no compiler builtin remains source-addressable outside the module.

### Cryptography and HTTP

- [ ] Define the security and API boundaries among `dew.std.crypto.fast` for non-secret fast hashes/checksums, `dew.std.crypto.timing` for constant-time primitives and secret comparison, and `dew.std.crypto.password` for password hashing/KDF APIs.
- [ ] Select reviewed algorithms and implementations, expose versioned parameters and algorithm identifiers, use cryptographically secure randomness where required, and document which APIs are not suitable for secrets.
- [ ] Add known-answer, differential, side-channel-aware, malformed-input, resource-limit, and cross-runtime tests; do not claim constant-time behavior without measurement on supported runtimes.
- [ ] Implement `dew.std.http` with bounded request/response types, header validation, streaming bodies, deterministic parsing/serialization, explicit limits, and host adapters separated from protocol semantics.
- [ ] Define URL/URI ownership, TLS boundaries, redirects, decompression, timeout/cancellation behavior, and client/server scope before committing a stable HTTP API.

### Structured data formats

- [ ] Implement `dew.std.json` entirely in Dew, including strict UTF-8 parsing, deterministic serialization, streaming/event parsing, DOM/value APIs, bounded depth/resource controls, canonical-number decisions, and differential conformance tests.
- [ ] Implement `dew.std.toml` entirely in Dew, including the package-manifest subset first, duplicate-key rejection, dotted/quoted keys, arrays/tables/inline tables, date-time representation policy, deterministic serialization, and conformance fixtures.
- [ ] Implement `dew.std.yaml` entirely in Dew after JSON/TOML foundations stabilize, with an explicitly versioned YAML subset, alias/anchor resource limits, duplicate-key policy, deterministic emission, and hostile-input tests.
- [ ] Keep the bootstrap driver free to use host JSON/TOML support initially, but require Dew-native parsers for the installed compiler, package manager, self-hosted tools, and standard-library APIs.

## Tooling and developer experience

### Command-line interface

- [x] `dew check`
- [x] `dew build`
- [x] `dew run`
- [x] `dew test`
- [ ] `dew fmt`
- [ ] `dew doc`
- [ ] `dew clean`
- [x] `--emit hir`
- [x] `--emit lowering`
- [x] `--emit wat`
- [x] `--emit wasm`
- [ ] phase timing and allocation reporting

### Formatting

- [ ] Define canonical formatting rules.
- [ ] Implement a formatter over parser ASTs or lossless syntax.
- [ ] Preserve comments and intentional multiline strings.
- [ ] Add idempotence and round-trip tests.

### Language server

- [ ] Incremental file parsing.
- [ ] Stable file/module identity in workspace state.
- [ ] Diagnostics.
- [ ] Go to definition.
- [ ] Find references.
- [ ] Hover types and selected impl evidence.
- [ ] Completion.
- [ ] Rename.
- [ ] Document symbols.
- [ ] Semantic tokens.
- [ ] Code actions for missing imports, methods, and match cases.

### Documentation generation

- [ ] Retain doc comments.
- [ ] Generate module/type/trait/function documentation.
- [ ] Link imported identities.
- [ ] Include signatures after alias normalization without erasing source spelling.
- [ ] Add runnable examples when the test runner exists.

## Incremental and parallel compilation

- [ ] Fingerprint source files.
- [ ] Cache parser events or compact syntax/HIR artifacts.
- [x] Cache compiler-owned standard and versioned external dependency frozen interfaces.
- [ ] Extend frozen-interface caching to ordinary workspace modules once source/artifact provenance and invalidation rules are stable.
- [ ] Cache body inference by declaration/body fingerprint.
- [ ] Cache layout and fragment plans.
- [ ] Invalidate dependents by interface fingerprint rather than implementation changes.
- [ ] Schedule module and body jobs across workers.
- [ ] Keep diagnostic and output ordering stable under parallelism.
- [ ] Add forward/reverse/random completion-order tests.
- [ ] Add reproducible-build byte-for-byte checks.

## Testing and quality

### Module WAT snapshots

Dew should follow the useful part of AssemblyScript's compiler-fixture model:
compile representative source modules, render the resulting module as readable
WebAssembly text, and compare it with a checked-in expectation. These snapshots
are intentionally sensitive to type shapes, indices, imports, exports, control
flow, and instruction selection so compiler-output changes are visible in code
review.

- [x] Add `tests/module-snapshots/` with source fixtures and canonical expected `.wat` files.
- [x] Infer source, expectation, WAT output, production mode, synthetic module identity, and `main` entry entirely from recursive filename conventions.
- [x] Define `<test>.files/`, `<test>.modules/<dotted.module>/`, and `<test>.tests/` sibling-directory conventions for multi-file, multi-module, and test-mode snapshots.
- [x] Validate with Starshine, encode, externally validate, and then render canonical WAT before comparison.
- [x] Keep the external WAT renderer version fixed so unrelated printer changes cannot rewrite the suite.
- [x] Compare byte-for-byte and emit a unified diff with the fixture name on failure.
- [x] Provide an explicit update mode for intentional compiler-output changes.
- [x] Execute `main` and snapshot representative ABI boundaries and lowering strategies while retaining semantic/runtime tests for combinatorial correctness.
- [x] Store ordered compiler errors, ordered compiler warnings, and ordered stdout strings in fixture JSON.
- [x] Require `output: null` and no WAT for failed compilations; successful compilations execute `main` and compare sibling WAT.
- [x] Render deterministic compiler error snapshots through MoonBit `Debug` representations.
- [x] Compare ordered, source-rendered compiler warnings through the same JSON oracle; the empty-warning baseline remains contractual until warning producers land.
- [x] Establish broad feature-oriented coverage; every compiled fixture requires identical Node/Wago Core 3 output and traps, and fixture totals are discovered from the checked-in tree rather than copied into this document.
- [ ] Continue growing successful, warning, compiler-failure, and edge cases beside the feature they exercise.
- [x] Correct Bool literal-pattern match emission and intentionally transition its error snapshot to successful stdout plus WAT.
- [x] Add byte-for-byte repeated-compilation reproducibility checks.
- [ ] Add reversed simulated job-order reproducibility snapshots.
- [x] Document intentional snapshot updates and preserve compiler decisions without normalization.

### Unit and white-box tests

- [x] Extensive tokenizer/parser/semantic/backend tests.
- [ ] Add tests for every new import/module rule.
- [ ] Add source-location assertions to all cross-file diagnostics.
- [ ] Add malformed standard-library source tests.
- [x] Add backend instruction-shape tests beyond Fibonacci.

### Integration and conformance

- [x] Create `tests/compile-pass` and run it through the CLI fixture harness.
- [x] Create `tests/compile-fail` with exact rendered diagnostics.
- [x] Create `tests/run-pass` with exact runtime output/results.
- [x] Add multi-module CLI and module-snapshot fixtures with deterministic linked execution and diagnostics.
- [x] Add direct standard-library conformance tests for the implemented surface.
- [x] Compare independent host expectations with Wasm execution through UTF, SWAR, and WASI differential harnesses.

### Later fuzzing phase

Fuzzing remains required, but it follows deterministic snapshots, the initial
CLI/fixture framework, and completion of the main executable control-flow
surface. Until then, focused adversarial matrices and iterative stress tests
remain easier to diagnose and maintain.

- [ ] Tokenizer byte fuzzing, including malformed WTF-8.
- [ ] Parser token-stream fuzzing.
- [ ] AST/HIR lowering fuzzing.
- [ ] Type solver operation-sequence fuzzing.
- [ ] Wasm module validation/encoding round trips.
- [ ] Differential parsing/formatting tests.
- [ ] Resource-limit fuzzing for deeply nested and very wide inputs.

### Stress and safety

- [x] Existing deep/wide iterative stress coverage.
- [ ] Define explicit compiler resource budgets.
- [ ] Bound alias expansion, inference work, pattern usefulness, and module graph size.
- [ ] Diagnose budget exhaustion without crashing.
- [ ] Audit integer conversions and packed identity limits.
- [ ] Audit all array indexing driven by malformed inputs.

## Interoperability

- [ ] Define Dew builtin registry extension API.
- [ ] Define Wasm import declaration syntax and ABI.
- [ ] Define export naming and collision rules.
- [ ] Define JavaScript host bindings.
- [ ] Define string and reference interop.
- [ ] Define component-model/WIT integration only after core Wasm ABI stability.
- [ ] Provide low-level escape hatches without making them ambient language semantics.

## Packaging and releases

- [x] Define separate convention-first `dew.json` package definitions and exact `dew.lock` resolution records.
- [x] Define `@scope/name` package identities, derived dotted module names, exact package versions, and basic exact/`^`/`~`/`*` requirements.
- [x] Verify materialized semantic-version and Git dependency sources through lockfile identity, source, SHA-256 integrity, and transitive interface fingerprints.
- [ ] Add registry lookup, Git checkout, lockfile generation/update, and a content-addressed installed package store.
- [ ] Package `dew.std` with the compiler or as a versioned dependency.
- [ ] Version the compiler/prelude ABI together initially.
- [ ] Add reproducible release builds.
- [ ] Add CI across supported MoonBit targets and host platforms.
- [ ] Publish compiler binaries and standard-library sources.
- [ ] Define language edition/version behavior before compatibility commitments.

## Decisions that should remain explicit

- [x] Imports and opens are contributed per source file to the owning module's shared import scope.
- [ ] Whether local declarations may shadow ordinary imports.
- [ ] Whether canonical preamble traits may be shadowed at all.
- [x] `Option` and `Result` are ambient separate standard modules rather than declarations inside `dew.std.preamble`; the minimal `Iter<t>` protocol is ambient.
- [ ] Whether mutation is local-only or extends to aggregate fields and collections.
- [x] Function values and closures are part of the first complete language release.
- [ ] Whether associated types are required for collections/iterators.
- [ ] Whether ordinary Boolean loops are needed alongside functional loops.
- [x] Cross-module generic code uses deterministic carrier specialization with erased `eqref` fallbacks; dictionaries remain reserved for runtime trait values.
- [x] Strings use strict-UTF-8 custom WasmGC objects backed by `array<mut v128>`; malformed bytes use Bytes.
- [ ] Which WasmGC runtimes define the supported execution baseline.

## Suggested milestone sequence

1. **Module WAT snapshots — foundation complete and continuous:** canonical readable fixtures, warning transport, deterministic regeneration, repeated-compilation checks, and Node/Wago execution are implemented; keep growing edge and completion-order coverage.
2. **Self-describing tests — complete:** compiler-emitted test metadata, stable identities, filtering, expected traps, and assertion reporting are implemented.
3. **Selective standard packages and interface caching — complete for installed source capsules:** on-disk standard lookup, persistent content-addressed standard/external interface caching, and verified installed dependency recovery are implemented; body/layout/fragment artifacts remain later optimization work.
4. **Compiler CLI — complete for the current product:** `check`, `build`, `test`, `run`, deterministic emit modes, file-aware diagnostics, and compile/run/multi-module fixtures are implemented.
5. **Structured execution and linked module state — complete:** short-circuit logic, functional loops, nested/alternative patterns, globals, explicit host initialization, eager-cycle analysis, imported impl dispatch, and cross-module recursive type groups execute.
6. **Executable generics and runtime traits — complete for the documented ABI:** bounds/obligations, evidence-aware specialization, erased fallbacks, recursive adapters, trait objects, typed dictionaries, runtime evidence, `call_ref`, imported providers, and compatibility negotiation execute.
7. **Current-language correctness hardening — complete for the audited gaps:** discarded non-Unit Unit tails, string literal pattern emission, stable local module-value cycle diagnostics, explicit `Never`/drop matrices, and the first ordinary warning producer are implemented.
8. **Artifact-only installed dependencies — complete for V1 source capsules:** verified versioned dependencies compile after their locked source tree is removed, with byte-identical Wasm after atomic artifact restoration.
9. **Core collections and iteration — Array/iterator, Stack, and Queue API tranches complete:** growable Array, ambient iteration, explicit collection iterators, LIFO Stack, and FIFO Queue semantics execute; circular-buffer replacement, heaps, and ordered trees are next, with the contiguous Queue benchmark already rejecting O(n) shifting as the final representation.
10. **Language ergonomics and cleanup:** annotations and `Show`, or deterministic `defer`/`using` through `Disposable`, should land as separate bounded milestones. Eq/Debug/Hash derivation and ambient Debug are already implemented.
11. **Optimization and incremental compilation:** folding, inlining, escape analysis, workspace fingerprints/caches, and deterministic parallel scheduling.
12. **Broader standard library:** structured data, cryptography boundaries, HTTP, and conformance/security hardening.
13. **Later quality and release:** fuzzing, formatter, LSP, package manager, compatibility matrix, conformance hardening, and reproducible releases.
