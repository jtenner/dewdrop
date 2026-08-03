# Dew Agent TODO

This file tracks designed or partially designed features that remain unimplemented. Persistent/warm compilation and artifact serialization are intentionally deferred until the language, ABI, module, and backend surfaces below stabilize.

## Current priority order

1. Extend the on-disk package-root and persistent standard-interface cache model to versioned external dependencies with integrity and dependency-interface fingerprints.
2. Complete imported trait requirement validation, merge imported impl evidence into coherence/dispatch indexes, and define visibility/orphan rules.
3. Add stable file-aware diagnostics to the completed check/build/test/run and deterministic emit driver.
4. Define and implement generic obligations, specialization, erased fallback ABIs, and executable cross-module generic aggregates.
5. Add the deterministic optimization pipeline and optimized snapshots.
6. Continue deterministic snapshots, generated lane coverage, resource-budget definition, and phase/runtime/allocation measurement.

Performance and correctness work remains continuous: expand generated lane-family tests, measure retained text ranges and scalar iteration, define explicit resource budgets, and keep phase/runtime benchmarks current. Broad fuzzing begins later, after snapshots, the initial CLI/fixture framework, and the principal executable control-flow surface are stable.

## Primitive and runtime foundations

- [x] Define and implement `I8`, `I16`, `I32`, and `I64`.
- [x] Define and implement `U8`, `U16`, `U32`, and `U64`.
- [x] Define and implement `F32` and `F64`.
- [x] Define native physical, ABI, memory, operator, and broad lane-operation support for `V128`.
- [x] Define and implement allocation-free `Swar32` over Wasm `i32`.
- [x] Define and implement allocation-free `Swar64` over Wasm `i64`.
- [x] Differentially execute the selected deterministic integer lane surface derived from `JairusSW/as-simd`; the Node/Wasm harness now covers 61,000 checks and found/fixed a bad `Swar64` bitmask multiplier.
- [x] Finish scalar-packed `i8`/`i16`/`i32` multiply, min/max, saturation, comparisons, averages, abs/neg, masks, and reductions with 61,000 executable parity checks.
- [x] Add the 20 useful zero-wrapper packed-lane views over `V128`, `Swar64`, and `Swar32`; `F32x2` is intentionally excluded.
- [x] Keep every same-carrier reinterpretation explicit and instruction-free; numeric lane conversions remain separately named.
- [x] Add fixed-immediate native lane extract/replace operations and broad native widening, narrowing, extmul, dot, swizzle, rounding, and numeric conversion APIs.
- [x] Add deterministic named byte shuffles, concatenated-window shifts, scalar splat loads, lane loads/stores, widening loads, and partial zero loads.
- [x] Exclude relaxed SIMD and arbitrary-immediate shuffle syntax from the deterministic default surface; dynamic swizzle and named shuffles cover the intended workloads.
- [x] Replace provisional `stringref` with distinct GC-managed `String`, `StringView`, and `Bytes` wrappers plus a consuming `StringBuilder` over zero-padded `array<v128>` chunks.
- [x] Define `Bytes` and `b"..."` literals with executable GC constants.
- [x] Port strict RFC 3629 validation and UTF-16 length counting from `JairusSW/utf-as`, with executable cross-chunk parity.
- [x] Add exact-length V128 equality and bounds-checked dynamic byte indexing for String and Bytes.
- [x] Add checked Bytes-to-String conversion with strict validation, malformed-input traps, shared backing, and frozen runtime dependency reachability.
- [x] Add UTF-8-boundary-checked shared StringView ranges and a consuming, geometrically grown GC-backed StringBuilder with String/StringView append.
- [x] Add a consuming, geometrically grown GC-backed BytesBuilder with arbitrary Bytes and individual U8 append.
- [x] Complete StringBuilder with strict ASCII append, direct Unicode scalar encoding, and checked Bytes append.
- [x] Add shared Bytes ranges directly as Bytes plus strict String/StringView/Bytes `view`, `subarray`, `slice`, and `compact` operations.
- [x] Add overflow-checked flat `String.concat`, `String.concat_view`, and `Bytes.concat` with exact start-zero storage and no rope nodes.
- [x] Add SIMD `Bytes.find_byte`/`contains_byte`, exact `starts_with`/`ends_with`, and public `Option<U32>` without exposing a sentinel.
- [x] Add allocation-free exact `Bytes.find(Bytes)` and `contains(Bytes)` with empty/single-byte specialization, short-needle SIMD filtering, and long-needle rolling fingerprints.
- [x] Run a test-only text-runtime hardening sprint: 17,471 parity checks, all-byte/alignment and range/concat/builder matrices, deliberate rolling-hash collision, full consumed-builder aliases, nominal ABI joins, and 64 KiB stress.
- [x] Add allocation-free String/StringView find, contains, prefix, and suffix matching across all String/View operand combinations with byte-offset results.
- [x] Add bounded full-page WASI Preview 1 scratch lowering for GC Bytes writes and reads, including aligned four-vector copies, no-restage partial writes, short reads, errors, every alignment, multi-window coverage, and phase-only benchmarks.
- [ ] Add retained-range policy, small inline strings, hashing, ordering, and code-point iteration.
- [x] Add first-class MoonBit-style test declarations with frozen metadata, default elision, explicit test-mode exports, standard assert/unreachable builtins, and executable stdlib test infrastructure.
- [x] Permit compiler-known primitive types as qualified static roots and expose `StringBuilder::new()`, `StringBuilder::with_capacity()`, `BytesBuilder::new()`, and `BytesBuilder::with_capacity()`.
- [x] Generate direct MoonBit-style coverage for all 100 scalar conversions, every typed memory carrier, and every packed-lane identity's splat/extract/replace/add baseline.
- [ ] Expand `std/tests/*_test.dew` from lane-family smoke coverage to every generated operation family, including shuffle, saturation, narrowing, widening, masks, and lane memory variants.
- [ ] Design optional arguments as a future improvement; define defaults, omission, overload resolution, evaluation order, and ABI effects before implementation.
- [x] Define scalar literal typing and signed/unsigned range diagnostics, including minimum signed values beneath unary negation.
- [x] Define arithmetic, comparison, bitwise, shift, and prefix operations by scalar primitive family.
- [x] Define and implement `Into<t>` for every ordered pair of scalar numeric types.
- [ ] Add separate checked, saturating, and explicitly named wrapping/truncating conversion families beyond `Into<t>`.
- [x] Freeze exact conversion evidence before lowering and emit native Wasm conversion instructions and narrow-target guards.
- [x] Define explicit load/store intrinsic APIs, widths, signedness, natural alignment hints, memory-zero behavior, and bounds traps.
- [x] Freeze exact memory operation evidence before lowering and expose corresponding Wasm load/store instructions.
- [ ] Add complete native, WasmGC, JavaScript, classic Wasm, Node, and Wago execution/benchmark coverage; native tests and release semantic benchmarks are current.

## Module WAT snapshots

- [x] Use recursive `<feature>/<test>.dew`, `<feature>/<test>.json`, and `<feature>/<test>.wat` files; compile each fixture as one production module and execute its exported zero-argument `main`.
- [x] Render canonical WAT only after Starshine validation and binary encoding.
- [x] Pin the external printer used by the suite until Starshine owns deterministic rendering.
- [x] Commit readable `.wat` expectations while keeping generated `.wasm` temporary.
- [x] Compare snapshots byte-for-byte and print unified diffs.
- [x] Provide an explicit update command that ordinary test runs never invoke automatically.
- [x] Cover 146 compiled fixtures across collections, control flow, enums, generic sums, lanes, memory, modules, numeric operations, reachability, structs, tests, text, and WASI without duplicating combinatorial semantic tests.
- [x] Keep each JSON oracle to exactly ordered compiler `errors`, ordered compiler `warnings`, and ordered stdout-string `output`; `null` means no module or WAT was produced.
- [x] Capture successful `main` stdout through deterministic Preview 1 writes and snapshot complete multiline compiler errors through framed MoonBit `Debug` strings.
- [ ] Connect ordered compiler warnings to stable diagnostic rendering.
- [x] Define minimal `<test>.files/`, `<test>.modules/<dotted.module>/`, and `<test>.tests/` sibling-directory conventions; never encode module graphs in JSON.
- [x] Establish 166 fixtures with compiler failures kept beside their language features: 146 compiled WAT/runtime snapshots, 20 compiler-error snapshots, 91 nonempty stdout oracles, and 12 normalized trap oracles; every compiled fixture must match in Node and Wago Core 3.
- [ ] Keep expanding successful, warning, compiler-failure, boundary, and reduced-stress fixtures beside the feature they exercise.
- [x] Fix Bool literal-pattern backend emission with carrier-typed scratch locals and transition `control-flow/bool-match` to successful stdout plus WAT.
- [x] Add focused test-mode, same-module multi-file, and statically linked imported-module fixtures through the small sibling-directory conventions.
- [x] Add repeated-build reproducibility checks.
- [ ] Add reversed-job-order reproducibility fixtures.

## Test infrastructure

- [x] Emit versioned deterministic `DEW_TESTS_V3` metadata directly from semantic test records in one `dew.tests` Wasm custom section.
- [x] Replace regex and assembled-source-offset discovery in `tools/dew-test`; compile sorted test files individually.
- [x] Promote module/file/display-name records into duplicate-checked stable test identities.
- [x] Add deterministic exact filtering by module, file, and display name, identity substring filtering, and metadata-only listing.
- [x] Remove the metadata sidecar and make every CLI/standard test binary self-describing through `dew.tests`.
- [x] Add declaration-level expected-trap syntax, stable category validation, metadata transport, and runner support.
- [x] Transport dynamic failed-assertion messages through test-only bounded WASI stdout writes, with no static assertion metadata or globals and no production ABI change.
- [x] Hide test-only values, nominal types, traits, and impl evidence from ordinary-file resolution.
- [x] Exclude test-only nominal layouts and test-callable reachability edges from production fragments.
- [x] Exclude test-only impl evidence from frozen/imported interfaces and mark test-only initialization steps explicitly.
- [x] Omit marked test-only initialization steps from production module-global/startup emission.

## Executable core

- [x] Complete scalar integer arithmetic, comparison, unsigned division/remainder, bitwise, and shift emission.
- [x] Emit `i64`, `f32`, and `f64` constants and operations.
- [x] Emit numeric conversions and reinterpretations through registered builtins.
- [x] Finish structural short-circuit logical binary emission; scalar prefix operators are emitted.
- [ ] Validate `Never`, unreachable, drop, local-let, and return stack behavior across all value shapes.
- [x] Emit functional `while` using state/result locals and structured Wasm blocks/loops.
- [x] Emit `continue Expr` state updates and `break Expr` results.
- [x] Handle return and divergence inside functional-loop arms.
- [ ] Add deep and wide functional-loop execution tests.

## Pattern matching and flow

- [x] Emit nested tuple, struct, and enum destructuring.
- [x] Emit comma-separated alternative patterns with shared binding identities.
- [ ] Share extraction work across alternatives where paths overlap.
- [x] Complete literal, rest, and catch-all execution in nested patterns.
- [x] Consume frozen imported enum domains during exhaustiveness analysis.
- [x] Remove conservative open-domain behavior for complete imported enums.
- [ ] Add full nested pattern-matrix usefulness when justified.
- [ ] Add typed payload-local reuse, cast elimination, and extraction CSE.

## Module values and initialization

- [x] Export public module-level `let` types after the module-value inference barrier.
- [x] Emit Wasm globals and `PlannedModuleValueGet` for local, opened imported, and alias-qualified imported module values.
- [x] Emit direct scalar constant global initializers when legal.
- [x] Emit deterministic per-value initialization functions for non-constant values.
- [x] Emit an explicit `__dew_init` initializer called by Dew hosts before entry points.
- [x] Order cross-module initialization by dependency SCCs.
- [x] Diagnose direct and callable-transitive cross-module eager initialization cycles.
- [ ] Integrate host-provided initialization and startup entry points.

## Cross-module semantics and linking

- [x] Merge owner-coherent imported implementation evidence into method/operator dispatch indexes.
- [x] Enforce imported evidence visibility and foreign-impl privacy.
- [x] Preserve exact external implementation and method identities through lowering.
- [x] Diagnose structural overlap between independently imported or local/imported implementation sets.
- [x] Merge reachable physical WasmGC SCCs spanning multiple Dew modules.
- [x] Replace supported `UnsupportedProgramForwardTypeReference` cases with deterministic global recursive groups.
- [x] Distinguish qualified imports from module-scoped opens: `import` binds only `@alias`, while `open` contributes unqualified names only to the owning module and never re-exports them.
- [x] Remove `global` as a keyword, reserve `@identifier` for imported module aliases, support explicit `import path as @alias`, derive default final-segment aliases, and select aliased imported function calls.
- [ ] Extend `@alias` to types, traits, variants, patterns, static impls, and duplicate-alias source labels; non-callable values are implemented.
- [ ] Define selective imports and re-exports if retained.

## Generic executable ABI

- [x] Define shared physical scalar/reference ABI specializations keyed by canonical Wasm carrier.
- [x] Define one erased nullable-`eqref` fallback for each public root-module generic callable.
- [x] Emit exact nominal-reference static-to-erased adapters only when callable signatures differ.
- [x] Emit immutable scalar boxes, unboxes, and deterministic `$dew$<carrier>` adapters for demanded direct generic parameter/result boundaries.
- [x] Emit recursive representation adapters for generic occurrences nested inside aggregates and structural function signatures.
  - [x] Instantiate generic parameters recursively through structural function types during call/reference inference and specialize callback call signatures/results by carrier.
  - [x] Clone direct generic struct fields across static/erased boundaries, boxing and unboxing only the selected scalar carrier leaf.
  - [x] Recurse through acyclic nested generic struct graphs with deterministic scratch locals and leaf-only box/unbox conversion.
  - [x] Extend recursive conversion through generic enum tuple/struct payloads and acyclic nested struct/enum graphs with exact subtype reconstruction.
  - [x] Replace cyclic nominal rejection with deterministic per-adapter recursive conversion helpers that preserve finite runtime recursion through cyclic type graphs.
  - [x] Generate deterministic static-to-erased and erased-to-static structural callback wrapper closures using the flattened closure ABI, recursive nested callback wrapping, scalar leaf boxes, target-once typed dispatch, conversion of function-valued struct/enum payload fields, and executable calls through instantiated aggregate fields and pattern bindings.
- [x] Support executable generic enum and struct construction and access.
- [x] Support executable generic calls, nested fixed-point specialization, and escaping generic references.
- [x] Remove the obsolete executable generic-type rejection after generic aggregate carrier lowering.
- [ ] Define recursive generic aggregate instantiation and sharing.
- [ ] Define ABI compatibility fingerprints after the ABI stabilizes.
  - [x] Persist V2 SHA-256 callable ABI fingerprints in frozen-interface/cache V6 using normalized signatures, physical shapes, explicit box/closure schema domains, and stable dependency declaration identities.
  - [x] Replace exact external nominal `DeclId` members in callable fingerprints with dependency module path, declaration name, and generic arity.
  - [x] Add content-sensitive nominal declaration and transitive module-interface fingerprints with dependency content records in frozen-interface/cache V7.
  - [x] Emit versioned `dew.abi` schema/interface metadata, reject malformed or mismatched providers, and snapshot independently compiled provider compatibility.
  - [x] Add a deterministic Node host consumer that lists `$dew$<carrier,...>` exports and invokes scalar adapters with explicit parameter/result carrier conversion.
  - [x] Add in-Wasm package consumers for `eqref`, aggregate, callback-wrapper, and `v128` adapters.
    - [x] Add focused WasmGC consumers that construct struct and enum payloads containing direct `i32` callbacks, invoke `identity_box$dew$i32` and `identity_choice$dew$i32`, and call the reconstructed wrappers entirely inside Wasm.
    - [x] Add a standalone `eqref` consumer that constructs an exact nominal value, invokes the public erased fallback, casts the result, and reads it entirely inside Wasm.
    - [x] Add an in-Wasm `v128` consumer that invokes `identity$dew$v128` and extracts the returned vector lane without crossing the JavaScript value boundary.
    - [x] Add a multi-module provider whose root `$dew$i32` adapter exposes an imported generic callback aggregate and execute it through the same structurally equivalent Wasm consumer.

## Generic trait obligations and runtime traits

- [ ] Parse and represent generic bounds.
- [ ] Add trait obligations to generic signatures and bodies.
- [ ] Solve obligations using imported coherent evidence.
- [ ] Freeze selected evidence per generic call.
- [ ] Improve generic overload specificity to structural match-set containment.
- [ ] Define trait-object source syntax and concrete-to-erased coercion.
- [ ] Plan WasmGC trait object and typed dictionary layouts.
- [ ] Emit dictionary construction and `call_ref` dispatch.
- [ ] Define mutable boxed scalar receiver behavior.
- [ ] Define trait-object identity and equality semantics.
- [ ] Optimize non-escaping trait boxes.

## Driver, packages, and preamble

- [x] Define the initial strict `dew.json` root/module/ordered-file manifest for check and build.
- [x] Resolve manifest sources relative to the manifest directory and reject duplicate, absolute, escaping, missing, or non-Dew paths.
- [x] Define ordered compiler-owned package roots, deterministic fixed-registry source selection, and on-disk standard-library lookup through `--package-root` and `DEW_PACKAGE_ROOTS`.
- [x] Reserve stable identities for `dew.std` modules independently of physical package roots.
- [ ] Extend package identities, roots, versions, and integrity rules to external user dependencies.
- [x] Implement initial `dew check` and `dew build` over explicitly ordered multi-file/multi-module inputs with root selection and deterministic exit status.
- [x] Implement initial explicit-file `dew test` with V3 metadata, filters, and expected traps.
- [x] Extend `dew test` to strict package manifests and multi-module test programs with manifest-order global test ordinals.
- [x] Implement `dew run` for zero-argument `main` with Preview 1 stdin/stdout hosting.
- [x] Execute the complete immutable collection/interface/analysis/lowering/link DAG through the CLI.
- [x] Accept strict minimal package manifests for check and build.
- [x] Add manifest-driven multi-module tests without filesystem discovery.
- [ ] Replace ordinary package file lists with strict TOML manifests and deterministic sorted `src/**/*.dew` discovery under the root package and `.dew/packages/<name>/` dependencies.
- [ ] Add deterministic discovered source roots.
- [x] Write deterministic Starshine-validated `.wasm` output plus explicit HIR, lowering, pinned-printer WAT, and Wasm emit modes.
- [x] Split String, StringBuilder, Bytes, and BytesBuilder into separate standard source modules while retaining one private bootstrap text-runtime declaration file.
- [x] Add a deterministic import prepass that selects explicitly imported lane, split text/bytes, and WASI standard modules plus private dependency closure.
- [x] Use the scalar WAT snapshot to prove unrelated standard families are omitted: the two-function scalar module fell from more than 3,100 types to 951 type entries before the frozen-module migration.
- [x] Compile `std/preamble/*.dew`, Option/Result, and selected split standard sources as independently frozen compiler-owned `dew.std.*` modules.
- [x] Collect and load each selected frozen standard interface once per compilation session instead of reparsing optional sources into every user module.
- [x] Preserve primitive/static impl evidence and cross-module runtime dependencies through real imported interfaces.
- [x] Eliminate dead imported signatures, external type references, callables, and nominal layouts before final linking.
- [x] Replace `FindResult` with ambient generic `Option<U32>` and add standard `Result<t, e>` plus executable generic-enum carrier lowering.
- [x] Retain explicit `--no-default-preamble` and generated `--bootstrap-std` bootstrap/test modes.
- [x] Use import-selected installed/on-disk standard package sources by default and require byte-identical output against generated bootstrap providers.
- [x] Add persistent SHA-256 content-addressed caching for diagnostics-free compiler-owned standard frozen interfaces, with deterministic encoding, hit injection, checksums, explicit disable/report controls, and fail-visible corruption handling.
- [ ] Extend persistent interface caching to versioned external user packages and remove generated providers only after installed-package recovery is reliable.

## Source diagnostics

- [ ] Retain file identity for expressions, patterns, blocks, arms, fields, and type syntax.
- [ ] Replace offset-only semantic diagnostics with stable source locations.
- [ ] Add per-file byte-offset to line/column lookup.
- [ ] Add excerpts, carets, and secondary labels.
- [ ] Sort diagnostics by module, manifest file order, byte offset, and stable rank.
- [ ] Preserve useful diagnostics after parser token eviction.

## Additional language/runtime design

- [x] Define simple-name assignment for `let mut`, including unboxed uncaptured locals and shared boxed mutable captures.
- [x] Explicitly defer aggregate field mutation, destructuring assignment, and compound assignment to separate language/ABI decisions.
- [x] Define trait-extensible `Index`/`IndexSet`, exact inference evidence, block-item-only indexed setting, and FixedArray optional/trapping bounds behavior.
- [ ] Enforce `(Self, key) -> value` coherence; FixedArray and Map already use the implemented indexing and indexed-setting lowering.
- [x] Parse, resolve, structurally intern, alias-normalize, import, cache, and plan opaque-reference ABI shapes for `fn(T, ...) -> R` types.
- [x] Resolve unambiguous non-generic local/imported function names as values and type-check calls through function-typed locals.
- [x] Emit first-class named references, typed lambda entries, flattened WasmGC closure subtypes, lexical captures, returned/imported closures, and indirect calls.
- [x] Directize immediate and call-only local lambdas/named references, lift immutable captures into direct signatures, remove their allocations, and elide unused closure values.
- [x] Reuse repeated escaping named references through deterministic body-local closure caches.
- [x] Reuse every surviving named-function value through a deterministic linked-module singleton global initialized before source module state.
- [x] Add `let mut` local assignment with unboxed uncaptured locals and carrier-specialized shared WasmGC cells for mutable captures.
- [x] Select local/imported non-generic overloaded function references from deterministic structural expected types.
- [x] Unify closure-base physical identities and named-reference singletons across linked modules.
- [x] Summarize transparent call-only callback wrappers and directize known lambda/named arguments across module lowering.
- [x] Infer expected-type generic function references and execute call-only parameter-selector/callback specializations without closure allocation.
- [x] Extend generic specialization to arbitrary function bodies, imported definitions, and escaping references with per-shape singleton identities.
- [x] Close nested generic specialization demands, coalesce physical carriers, assign stable program ABI keys, and elide unspecialized export recipes.
- [x] Execute generic structs with deterministic erased carrier fields and shape-selected construction/access.
- [ ] Add erased generic callable fallback/adapters; extend interprocedural summaries to returned, stored, forwarded, and unknown callback uses.
- [ ] Define string indexing units and malformed-WTF-8 runtime behavior.
- [x] Implement carrier-specialized mutable `FixedArray<t>` across unboxed scalar/vector/reference shapes with safe `Option` get and trapping index get/set.
- [x] Implement ambient U64 `Hash` with collision equality and a mutable deterministic separate-chaining `Map<key, value>` with empty/singleton construction, lookup, insertion/replacement, membership, length, index syntax, and indexed setting.
- [x] Implement mutable deterministic `Set<key>` over the shared collision-safe Hash table with empty/singleton construction, idempotent insertion, linked-chain removal, clear, membership, emptiness, and length.
- [x] Add shared geometric Map/Set bucket growth with a measured maximum load factor of 1.0 and deterministic iterative rehashing that reuses stored hashes.
- [x] Add Boolean Map removal and alias-visible O(1) clear using the proven Set chain-unlinking machinery and logical-length updates.
- [ ] Add deterministic allocation-free `Hash` implementations for `String`, `StringView`, and `Bytes` after finalizing their cross-type equality contract.
- [ ] Implement growable `Array<t>` over the six existing physical carriers with separate logical length/capacity and cleared removed reference slots.
- [ ] Implement mutable ring-buffer `Queue<t>`, then explicit iterator types and Map key/value/entry plus Set key iterators; keep hash traversal order unspecified.
- [ ] Implement Dew-native `dew.std.json`, `dew.std.toml`, and `dew.std.yaml` parsers and serializers, beginning with the strict TOML package-manifest subset and retaining deterministic output plus bounded hostile-input behavior.
- [ ] Complete `dew.std.wasm.intrinsics` as the sole source-language catalog for every supported WebAssembly Core 3 builtin, with generated declaration/backend parity tests.
- [ ] Consider flat scalar-enum specialization only after representative measurement.

## Optimization after feature completion

- [x] Callable reachability and dead function elimination for compiler-owned definitions; user definitions remain roots.
- [ ] Dead signature and nominal type elimination.
- [ ] Constant folding after exact operation selection.
- [ ] Inlining from immutable call graph summaries.
- [ ] Tail-recursion optimization.
- [ ] Common subexpression elimination where effects permit.
- [ ] Escape analysis and scalar replacement of short-lived aggregates.
- [ ] Local lifetime coalescing and deeper payload-load CSE.

## Tooling and quality

- [x] Add deterministic Wasm/WAT size, type/function/global/export, adapter, call, allocation-site, cast/test, and local-access metrics with fail-visible JSON budgets.
- [x] Gate transparent closure directization and erased scalar generic adapters with initial static performance budgets in `tools/check.sh`.
- [x] Expand budgets to recursive aggregate/enum/callback adapters, mutable cells, imported/package specializations, and direct materialized-specialization counts.
  - [x] Gate direct/nested callback wrappers, callback-bearing struct/enum reconstruction, and an imported-package adapter plus its in-Wasm consumer.
  - [x] Add dedicated generic enum reconstruction and cyclic nominal-helper budgets.
  - [x] Add dedicated nested aggregate and mutable capture-cell budgets.
  - [x] Record exact materialized-specialization counts in versioned `dew.metrics` Wasm metadata and gate every static budget against them.
- [ ] Add compile/validation/encoding and Node/Wago runtime timing plus peak-memory workloads with warmup and variance reporting.
- [ ] Add the real compile-pass, compile-fail, and run-pass fixture suites.
- [ ] Later: add broader malformed-input fuzzing for tokenizer, parser, and lowering after deterministic snapshot and CLI fixture infrastructure is established.
- [ ] Define canonical formatting and implement `dew fmt`.
- [ ] Build LSP diagnostics, navigation, hover, completion, rename, and semantic tokens.
- [ ] Retain doc comments and generate linked API documentation.

## Deferred until the above stabilizes

- [ ] Source, user-package interface, body, layout, and fragment fingerprints; compiler-owned standard source/interface fingerprints are implemented.
- [ ] Persistent user-package and later compilation artifact serialization; compiler-owned standard frozen-interface serialization is implemented.
- [ ] Warm compilation and cache hit/miss paths.
- [ ] Incremental invalidation by public interface fingerprint.
- [ ] Parallel worker scheduling with deterministic output merge.
