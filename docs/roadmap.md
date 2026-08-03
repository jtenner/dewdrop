# Dew implementation roadmap

> Living roadmap as of August 2, 2026. Ordering is directional rather than contractual. Items may move as implementation and benchmarks expose better boundaries.

## Current baseline

Dew currently has:

- a refillable raw-file-descriptor WTF-8 cursor, a streaming lexer with exactly two decoded units of lookahead, and a one-token-lookahead non-backtracking parser;
- shunting-yard expression parsing plus declarations, traits, impls, structs, enums, aliases, patterns, matches, functional loops, tests, and structural recovery;
- deterministic multi-file/module collection, stable packed identities, frozen interfaces, dependency SCCs, and immutable semantic/lowering/linking plans;
- type resolution, alias normalization, local unification, rollback-based inference, impl coherence, method selection, flow, and local enum exhaustiveness analysis;
- static multi-module linking with direct calls, imported aggregates, program-wide WasmGC layouts, optimized subtype-family enums, shape sharing, and dense match dispatch;
- the complete fixed-width scalar set, all 100 scalar `Into<T>` conversions, typed memory operations, packed GC fields, native `V128`, and allocation-free `Swar32`/`Swar64` lane operations;
- strict-UTF-8 GC-owned `String`/`StringView`, arbitrary `Bytes`, consuming builders, strict shared/copied ranges, flat concatenation, and allocation-free matching;
- bounded WASI Preview 1 `Bytes` I/O through the 65,520-byte data region of one reusable memory page, including partial writes and chunked reads;
- exact callable reachability, compiler-owned import/runtime elision, frozen final indices, Starshine validation, and deterministic Starshine binary encoding;
- first-class `_test.dew` semantics, frozen test metadata, test-mode exports, 198 direct standard tests, and independent UTF/SWAR/WASI differential harnesses;
- compiler-owned generated standard mirrors under `src/semantic/`, pending replacement by selective on-disk standard-module loading;
- passing native, classic Wasm, WasmGC, JavaScript, Node/Wago differential integration, and scoped generated-source validation suites;
- a SHA-256 content-addressed persistent cache for diagnostics-free compiler-owned standard frozen interfaces, with versioned deterministic encoding, checksum validation, explicit disable/report controls, and fail-visible corruption handling;
- 175 deterministic compiler fixtures organized by language/runtime feature across calls, collections, control flow, enums, functions, generics, lanes, memory, modules, names, numeric operations, reachability, structs, tests, text, types, and WASI: 154 compiled WAT/runtime snapshots plus 21 compiler-error snapshots.

## Immediate execution queue

The compiler foundation is broad enough that the next work should improve the
end-to-end product rather than add isolated builtins. The queue below is ordered
by dependency and expected user value.

### 1. Establish deterministic module WAT snapshots

- [x] Use recursive `<feature>/<test>.dew`, `<feature>/<test>.json`, and `<feature>/<test>.wat` conventions without fixture manifests.
- [x] Compile every fixture as one production module and execute its exported zero-argument `main`.
- [x] Keep JSON minimal: ordered compiler `errors`, ordered compiler `warnings`, and `output` as ordered stdout strings; `null` means compilation failed and no WAT exists.
- [x] Produce snapshots only after Starshine validation and binary encoding succeed.
- [x] Pin one version-stable external WAT printer until Starshine owns deterministic rendering.
- [x] Preserve stable type, function, import, memory, global, export, and code ordering rather than normalizing away compiler decisions.
- [x] Add a fail-closed comparison runner that prints a normal unified diff on mismatch.
- [x] Add an explicit snapshot-update command; ordinary test runs never rewrite expected files.
- [x] Grow the suite to 175 fixtures: 154 compiled WAT/runtime snapshots and 21 compiler-error snapshots kept beside their features across `calls/`, `collections/`, `control-flow/`, `enums/`, `functions/`, `generics/`, `lanes/`, `memory/`, `modules/`, `names/`, `numeric/`, `reachability/`, `structs/`, `tests/`, `text/`, `types/`, and `wasi/`.
- [x] Capture successful `main` stdout as an ordered JSON string array; `text/concat` writes and verifies the complete concatenated string.
- [x] Snapshot deterministic compiler errors with `output: null` and no WAT, preserving multiline `Debug` diagnostics through a framed protocol.
- [ ] Continue adding successful cases, warnings, compiler failures, boundaries, and reduced stress cases within each feature.
- [x] Fix Bool literal-pattern emission with carrier-typed scratch locals and scalar equality instructions; `control-flow/bool-match` now verifies both cases through stdout and WAT.
- [x] Add focused passing and failing test-mode fixtures through the optional `<test>.tests/*_test.dew` convention.
- [ ] Connect ordered compiler warnings to the JSON oracle once stable diagnostic rendering exists.
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

- [x] Define a strict minimal `dew.json` manifest with an explicit root module and ordered module/file arrays.
- [x] Resolve manifest sources relative to the manifest directory, reject escaping/absolute/duplicate paths, and preserve listed order without filesystem enumeration.
- [x] Define ordered compiler-owned package roots, deterministic fixed-registry source selection, and real on-disk `dew.std` lookup with `--package-root`/`DEW_PACKAGE_ROOTS`.
- [ ] Extend package roots and identities to versioned external user dependencies.
- [x] Split text ownership into `std/string.dew`, `std/string_builder.dew`, `std/bytes.dew`, and `std/bytes_builder.dew` plus a private bootstrap text-runtime declaration file.
- [x] Compile `std/preamble/*.dew`, ambient Option/Result, split text/bytes modules, WASI, and selected lane sources as independent compiler-owned modules.
- [x] Collect and freeze each selected standard interface once per compilation session rather than once per user module.
- [x] Add a deterministic import prepass that selects lane, split text/bytes, and WASI standard modules plus their private dependency closure.
- [x] Resolve user modules only through the selected frozen standard interfaces; optional standard declarations no longer enter user declaration arenas.
- [x] Model `dew.std.preamble`, `dew.std.option`, and `dew.std.result` as implicit canonical imports.
- [x] Retain `--no-default-preamble` plus explicit `--bootstrap-std` modes for bootstrap and compiler tests.
- [x] Remove optional standard preamble-mirror injection from all supported host paths; generated byte tables remain only as portable source providers for independently collected modules.
- [x] Use the scalar WAT snapshot to verify that unrelated text, lane, and WASI signatures disappear: it now contains 951 type entries and 974 WAT lines before the frozen-module migration.
- [x] Elide dead imported signatures, external type references, callables, and nominal layouts before final program indexing.
- [x] Make installed/on-disk import-selected standard sources the default driver provider and require byte identity with generated bootstrap sources.
- [x] Add a persistent SHA-256 content-addressed frozen-interface cache for compiler-owned standard modules, including deterministic private serialization, cache-hit injection, checksum/identity validation, and fail-visible corruption handling.
- [ ] Extend persistent interface caching to versioned external user packages and decide when generated bootstrap providers can be removed.

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
- [ ] Print stable file-aware diagnostics with line/column, excerpts, and secondary labels.
- [ ] Add initial `compile-pass`, `compile-fail`, and `run-pass` fixture directories.

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

- [ ] Parse generic bounds and freeze trait obligations.
- [ ] Solve obligations using local and imported coherent evidence.
- [x] Define shared physical-carrier specializations and one nullable-`eqref` fallback for each public generic exported by the root module.
- [x] Emit exact-reference-to-erased callable adapters only when an escaping generic reference's concrete signature differs from its `eqref` fallback.
- [ ] Emit scalar boxes, unboxes, and scalar-to-erased adapters only at required boundaries.
- [x] Support executable generic enum construction, transport, and pattern access through deterministic erased physical-carrier fields.
- [x] Execute generic parameter-selector functions and transparent generic callback wrappers through deterministic call-site specialization, including imported calls and expected-type generic references.
- [x] Materialize deterministic physical-carrier specializations for general generic function bodies, including locals, structured control flow, nested/transitive generic calls, multiple type parameters, escaping references, and imported definitions.
- [x] Coalesce source shapes with the same Wasm carrier and assign deterministic declaration-plus-carrier ABI keys.
- [x] Keep unspecialized generic recipes out of the executable/export ABI until erased fallback adapters are defined.
- [x] Support generic struct construction/access through deterministic per-field erased carrier slots without scalar boxes.
- [x] Add root-exported erased callable fallbacks and exact nominal-reference adapters for specialization boundaries that cannot be statically closed.
- [ ] Extend erased adapters to scalar boundaries with deterministic WasmGC boxes.
- [ ] Define ABI/interface fingerprints after specialization and erasure rules stabilize.
- [ ] Defer trait objects, dictionaries, and `call_ref` dispatch until static generic execution is complete.

**Done when:** representative cross-module generic functions and aggregates
execute with deterministic specialization, bounded code growth, and a documented
erased fallback.

### Continuous hardening and measurement

- [ ] Expand generated lane tests from smoke coverage to every generated operation family.
- [ ] Add retained-range, small-inline-string, hashing, ordering, and UTF-8 scalar-iteration measurements before extending the text ABI.
- [ ] Add source provenance to every HIR node needed for user-facing diagnostics.
- [ ] Define explicit compiler resource budgets and diagnostic behavior before the later fuzzing phase.
- [ ] Track compile time, validation/encoding time, runtime time, allocations, and peak memory separately.
- [x] Re-run Wago Core 3 compatibility checks for `array<mut v128>`, erased generic enums, Dew text search, all compiler snapshots, and WASI host callbacks; the standalone CLI now supports explicit `--core 3` activation.
- [ ] Design optional arguments only after the callable ABI and interface format above stabilize.

## Source model and diagnostics

### File and source provenance

- [x] Add stable packed `FileId`.
- [x] Keep byte offsets source-local.
- [x] Add `SourceLocation(FileId, offset)`.
- [x] Retain declaration and body file provenance.
- [x] Retain file identity in parse and duplicate-name diagnostics.
- [ ] Retain file identity for every HIR expression, pattern, block, arm, field, and type syntax node where needed.
- [ ] Replace offset-only semantic diagnostics with source locations or body-relative provenance.
- [ ] Add stable line/column lookup per file.
- [ ] Add source excerpts and caret rendering.
- [ ] Support secondary labels for duplicate declarations, type mismatches, and impl conflicts.
- [ ] Preserve diagnostics after parser token eviction.
- [ ] Sort diagnostics by module, file order, byte offset, and deterministic rank.

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
- [ ] Specify orphan/foreign impl visibility across modules.
- [ ] Prevent private foreign evidence from leaking into public signatures.
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

### Remaining generic work

- [ ] Parse and represent generic bounds.
- [ ] Add trait obligations to generic signatures.
- [ ] Solve obligations using imported coherent evidence.
- [ ] Freeze selected evidence per generic call.
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
- [x] Merge owner-coherent imported impl evidence into method/operator dispatch indexes.
- [x] Add public/private evidence visibility checks and keep `foreign impl` evidence module-local.
- [ ] Diagnose structural overlap between independently imported or local/imported evidence.
- [ ] Add trait obligations on generic functions.
- [ ] Add cross-package orphan rules.
- [ ] Define negative impls only if required.
- [ ] Define sealed traits only if required.

### Runtime trait values

- [ ] Define trait-object source syntax.
- [ ] Define explicit or implicit boxing at erased trait boundaries.
- [ ] Plan WasmGC trait object layouts.
- [ ] Plan typed function-reference dictionary slots.
- [ ] Emit dictionary construction.
- [ ] Emit `call_ref` dynamic dispatch.
- [ ] Define mutable boxed scalar receiver behavior.
- [ ] Define trait-object identity and equality semantics.
- [ ] Optimize non-escaping trait boxes.

## Expressions and statements

### Scalar execution

- [x] Emit the scalar subset required by recursive Fibonacci.
- [x] Emit every integer comparison and arithmetic instruction.
- [x] Emit unsigned comparisons/division/remainder.
- [x] Emit `i64`, `f32`, and `f64` constants and operations.
- [x] Emit conversions and reinterpretations through registered builtins.
- [x] Emit prefix operators.
- [ ] Emit all local-let forms.
- [ ] Emit all return forms, including bare `return`.
- [ ] Emit drops for all non-tail value shapes.
- [ ] Validate unreachable and `Never` stack behavior.

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
  - [x] Directize transparent call-only callback wrappers interprocedurally for known lambda and named arguments.
  - [x] Snapshot an allocation-free directization fixture with no closure type or `call_ref`.
  - [x] Conservatively retain the closure ABI for captured, returned, passed, global, and imported values.
  - [x] Execute returned, nested, passed, module-level, and imported closures in Node.
  - [x] Box captured `let mut` bindings in shared carrier-specialized cells; closures capture and route the cell reference, while uncaptured mutation remains an unboxed Wasm local.
- [x] Emit typed indirect calls for non-capturing function values.
- [ ] Tail-call optimization if supported and measured.
- [x] Cross-module direct calls and static imports.

### Indexing

- [x] Define ambient `Index<key, value>` and reference-free `IndexSet<key, value>` traits.
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
- [ ] Handle generic struct ABI specialization/erasure.
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
- [ ] Implement growable `dew.std.array` over the same six physical carrier families.
- [ ] Define a standard persistent list representation only if measured workloads justify it.
- [x] Implement `dew.std.map` with ambient U64 Hash evidence, collision-safe equality, deterministic buckets, erased carriers, safe lookup, insertion/replacement, and index syntax.
- [x] Implement `dew.std.set` over the same collision-safe Hash table with idempotent insertion, linked-chain removal, clear, membership, emptiness, and length.
- [x] Add shared geometric Map/Set bucket growth with a measured maximum load factor of 1.0 and deterministic iterative rehashing that reuses stored hashes.
- [x] Add Boolean Map removal and alias-visible O(1) clear using the proven Set chain-unlinking machinery.
- [ ] Add deterministic allocation-free Hash implementations for String, StringView, and Bytes after finalizing their cross-type equality contract.
- [ ] Implement `dew.std.queue` interfaces and implementation.
- [ ] Add explicit iterator types and iteration protocols, then Map key/value/entry and Set key iterators while leaving hash traversal order unspecified.
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
- [ ] Add deep and wide execution tests.

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
- [ ] Global section.
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
- [ ] Emit scalar boxes/unboxes.
- [x] Emit exact nominal-reference static-to-erased adapters.
- [ ] Emit scalar-to-erased adapters.
- [ ] Define cross-module ABI fingerprints.
- [ ] Reject incompatible separately compiled interfaces.

### Validation and compatibility

- [x] Use Starshine as the sole compiler-side Wasm validator.
- [x] Encode with Starshine binary encoding only after Starshine validation.
- [x] Execute encoded output with Node as a runtime integration test.
- [x] Add execution tests for all supported scalar operations and conversions.
- [x] Add struct construction/field execution tests, including imported structs.
- [x] Add enum and basic match execution tests.
- [ ] Add loop, module-init, and dynamic-dispatch execution tests.
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
- [ ] Devirtualization of trait-object calls when evidence becomes exact.
- [ ] Enum representation specialization based on frozen usage/layout data.
- [ ] Profile-guided optimization only after deterministic baseline builds exist.

### Performance discipline

- [x] Keep phase-only and full-pipeline benchmarks for implemented major phases.
- [x] Track native, WasmGC, JavaScript, classic Wasm, and Node integration runners.
- [x] Add multi-file/module graph, import-resolution, and static-link benchmarks.
- [x] Add release-mode phase-only standard-interface cache benchmarks separating serialization (2.89 ms), decoding (3.09 ms), cached injection (1.77 ms), and fresh freezing (5.31 ms) on the all-standard wildcard workload.
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
- [ ] Core iterator traits if they are intended to be ambient.
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
- [ ] Add key/value/entry iterators after iterator types are available.

### `dew.std.queue`

- [ ] Define public queue API.
- [ ] Choose mutable ring-buffer, persistent queue, or separate types.
- [ ] Implement enqueue, dequeue, peek, size, and iteration.
- [ ] Add empty-queue result semantics.
- [ ] Benchmark array-backed and linked representations.

### Additional likely modules

- [ ] `dew.std.list`
- [x] `dew.std.fixed_array`
- [ ] `dew.std.array`
- [x] `dew.std.string`
- [x] `dew.std.set`
- [ ] `dew.std.iter`
- [ ] `dew.std.math`
- [ ] `dew.std.io`
- [ ] `dew.std.testing`
- [x] `dew.std.wasi`
- [x] Establish `dew.std.wasm.intrinsics` as the sole source-language home for direct compiler-known WebAssembly intrinsics; `@identifier` is now reserved for imported module aliases and the first migrated intrinsic is executable through that module.
- [ ] Complete `dew.std.wasm.intrinsics` coverage for every supported WebAssembly Core 3 scalar, reference, GC, memory, table, SIMD, conversion, control, and host-boundary builtin, with generated declaration/backend parity checks so no compiler builtin remains source-addressable outside the module.

### Structured data formats

- [ ] Implement `dew.std.json` entirely in Dew, including strict UTF-8 parsing, deterministic serialization, streaming/event parsing, DOM/value APIs, bounded depth/resource controls, canonical-number decisions, and differential conformance tests.
- [ ] Implement `dew.std.toml` entirely in Dew, including the package-manifest subset first, duplicate-key rejection, dotted/quoted keys, arrays/tables/inline tables, date-time representation policy, deterministic serialization, and conformance fixtures.
- [ ] Implement `dew.std.yaml` entirely in Dew after JSON/TOML foundations stabilize, with an explicitly versioned YAML subset, alias/anchor resource limits, duplicate-key policy, deterministic emission, and hostile-input tests.
- [ ] Keep the bootstrap driver free to use host JSON/TOML support initially, but require Dew-native parsers for the installed compiler, package manager, self-hosted tools, and standard-library APIs.

## Tooling and developer experience

### Command-line interface

- [x] `dew check`
- [x] `dew build`
- [ ] `dew run`
- [x] `dew test`
- [ ] `dew fmt`
- [ ] `dew doc`
- [ ] `dew clean`
- [ ] `--emit hir`
- [ ] `--emit lowering`
- [ ] `--emit wat`
- [ ] `--emit wasm`
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
- [ ] Cache frozen module interfaces.
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
- [ ] Compare ordered compiler warnings through the same JSON oracle once warnings exist.
- [x] Establish broad feature-oriented coverage with 146 compiled fixtures, 20 compiler-error fixtures, 91 nonempty stdout oracles, and 12 normalized trap oracles; every compiled fixture requires identical Node/Wago Core 3 output and traps, and checked-in WAT is 94,494 lines after adding cross-module recursive WasmGC groups.
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

- [ ] Create `tests/compile-pass`.
- [ ] Create `tests/compile-fail` with expected diagnostics.
- [ ] Create `tests/run-pass` with expected output/results.
- [ ] Add multi-module fixtures.
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

- [ ] Define package manifest and lockfile.
- [ ] Define package/module naming and version rules.
- [ ] Define dependency source and integrity verification.
- [ ] Package `dew.std` with the compiler or as a versioned dependency.
- [ ] Version the compiler/prelude ABI together initially.
- [ ] Add reproducible release builds.
- [ ] Add CI across supported MoonBit targets and host platforms.
- [ ] Publish compiler binaries and standard-library sources.
- [ ] Define language edition/version behavior before compatibility commitments.

## Decisions that should remain explicit

- [ ] Whether imports are contributed per file or declared once per module.
- [ ] Whether local declarations may shadow ordinary imports.
- [ ] Whether canonical preamble traits may be shadowed at all.
- [x] `Option` and `Result` are ambient separate standard modules rather than declarations inside `dew.std.preamble`; iterator traits remain undecided.
- [ ] Whether mutation is local-only or extends to aggregate fields and collections.
- [ ] Whether function values and closures are in the first complete language release.
- [ ] Whether associated types are required for collections/iterators.
- [ ] Whether ordinary Boolean loops are needed alongside functional loops.
- [ ] Whether cross-module generic code uses specialization, dictionaries, erasure, or a hybrid.
- [x] Strings use strict-UTF-8 custom WasmGC objects backed by `array<mut v128>`; malformed bytes use Bytes.
- [ ] Which WasmGC runtimes define the supported execution baseline.

## Suggested milestone sequence

1. **Module WAT snapshots:** canonical readable output fixtures, fail-closed diffs, deterministic regeneration, and multi-module coverage.
2. **Self-describing tests:** compiler-emitted test manifest, stable identities, filtering, expected traps, and assertion reporting.
3. **Installed standard packages:** replace generated bootstrap source providers with canonical package lookup and persistent content-addressed frozen-interface caching.
4. **Compiler CLI and fixtures:** `check`, `build`, `test`, then `run`, with deterministic diagnostics and compile/run fixture suites.
5. **Structured execution:** short-circuit logic, functional loops, nested/alternative patterns, and imported enum exhaustiveness.
6. **Linked module state:** globals, startup scheduling, eager-cycle diagnostics, imported impl dispatch, and cross-module recursive type groups.
7. **Executable generics:** obligations, specialization, erased fallback ABIs, adapters, and cross-module generic aggregates.
8. **Core collections and iteration:** array/list, hashing/ordering, map/set, iterators, and explicit mutation/persistence rules.
9. **Higher-order runtime features:** function values, closures, trait objects, dictionaries, and indirect calls if still required.
10. **Optimization and incremental compilation:** dead types, folding, inlining, escape analysis, fingerprints, caches, and deterministic parallel scheduling.
11. **Later quality and release:** fuzzing, formatter, LSP, package manager, compatibility matrix, conformance hardening, and reproducible releases.
