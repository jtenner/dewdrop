# Dew Agent TODO

> Current handoff updated September 6, 2026. The older deferred backlog below
> comes from [`docs/roadmap.md`](docs/roadmap.md); it is not a claim that the whole
> roadmap was re-audited today. Use small commits with tests, docs, and measured
> compiler runs. Fix correctness before speed. Do not push without a new request.

## Current work — do this first

The standard-library migration and compiler audit are not complete. The detailed
history is in [`docs/research/stdlib-builtin-migration-worklist-2026-09-05.md`](docs/research/stdlib-builtin-migration-worklist-2026-09-05.md).
Scalar, packed `Into`, SIMD, and math migrations have landed. Typed Starshine FFI
names and unqualified enum support have also had implementation work; do not
restart them from scratch. Raw Unit array storage now passes both compilers.

### Compile-time type queries and branch removal

Native work is in progress. See
[`docs/research/compile-time-types-2026-09-05.md`](docs/research/compile-time-types-2026-09-05.md)
for the exact tested scope and the remaining work. September 6 progress is in
[`docs/research/compile-time-query-completion-2026-09-06.md`](docs/research/compile-time-query-completion-2026-09-06.md).
The native path now has 19
query/assertion declarations, logical generic keys, selected IR bodies, and
physical-boundary checks. This is not yet self-host parity or the full feature.

- [ ] Add real type-valued expressions for `field_type` and
  `variant_payload_types`. The user confirmed that the results must work in
  declarations and generic arguments; names and metadata are not enough.
  - [x] Native inline type positions: preserve local/imported member identity,
    generic owner arguments, aliases, and variant payload order. Test real Wasm
    scalar and tuple calls, parser recovery, cycles, and metatype storage errors.
  - [ ] Defer queries on an unconstrained generic owner until specialization.
    `field_type<Box<T>>("item")` works; `field_type<T>("item")` reports CT-035.
  - [x] Port inline computed member syntax and local/imported generic member
    resolution to the self-host parser and resolver; test exact source errors.
  - [ ] Add local compile-time type bindings.
- [ ] Add `field_names` and `variant_names`. Preserve declaration identity and
  source order, including imported and generic types.
  - [x] Native folding and fresh string-array constants, with Wasm execution tests.
  - [ ] Self-host folding and shared execution fixtures.
- [ ] Define valid layout-query types for `size_of`, `align_of`, and
  `field_offset`. WasmGC object byte layouts are not exposed; never invent them.
  - [x] Native scalar `size_of`/`align_of`; GC objects and unsupported layouts
    produce errors. Unit has size 0/alignment 1; Never has no layout.
  - [ ] Self-host scalar queries and an explicit aggregate layout contract for
    `field_offset` (GC field indices are not byte offsets).
- [ ] Port all query, trait search, assertion, and logical instance handling to
  the self-host compiler. Check both compilers with the same execution fixtures.
  - [x] Match the native compile-time `Type` identity and reject runtime storage,
    including aliases, nested generic arguments, tuples, and function signatures.
    Keep numeric records for invalid internal type indices and spans.
  - [x] Add the self-host pure scalar evaluator and structural logical types.
    Test pending/error separation, nested type identity, lanes, and scalar layout.
  - [ ] Connect the evaluator to specialization and emission; standalone evaluator
    tests do not prove that self-host source calls are folded.
- [x] Add native `is_unit::<t>()` as a pure compiler builtin with no Wasm call.
  Test the logical type: Unit is true, other known types are false, and unknown
  types stay pending. Never is not Unit. Resolve the query by identity, not by
  matching the name of an ordinary user function.
- [ ] Replace the query with a Boolean constant in each specialized body, then
  replace the `if` with its selected branch. Keep the shared generic body intact.
  This must run in debug builds too, before physical storage and call planning.
- [ ] Keep type-dependent checks inside their branch until the type is known.
  Check the selected branch with its known type facts. Both branches need valid
  syntax; unrelated source errors must not disappear.
- [ ] Make later passes visit only reachable code in that specialized body.
  Removed branches must not add calls, trait requests, locals, or storage types.
  Refresh flow and effect facts, keep source IDs for errors, and ensure distinct
  query results cannot share one specialized body by an ABI-key collision.
- [ ] Test the rewrite in native and self-host compilers. Cover Unit, scalar,
  reference, alias, Never, pending/error types, nested branches, separate
  specializations, branch-local type checks, and side effects. Check the IR and
  emitted Wasm, not only the returned value. No query or discarded branch may
  reach emission.

### Finish the standard-library migration

- [ ] Remove special `FixedArray` method and index dispatch. Compile the existing
  Dew method bodies and delete unused checked-read builders. Test Unit and tuple
  values, bounds, and evaluation order.
- [ ] Finish raw Wasm array contracts and storage adapters. Add product
  box/unbox support where needed; check full heap types, multiple generic
  parameters, and Unit effects. Missing types must not become reference storage.
  Raw instruction declarations must describe one Wasm instruction each.
- [ ] Move Array fields, length, capacity, growth, mutation, and iteration into
  Dew. Fifteen legacy Array builtins remain. Keep typed raw backing arrays;
  do not box every scalar to bypass a compiler defect. Nine checked/bulk
  algorithms already run in Dew.
- [ ] Remove the old Array wrapper layout and literal shortcuts. Use declared
  fields and exact construction recipes, not a guessed three-field layout.
- [ ] Move Map and Set hashing, buckets, growth, lookup, and iteration into Dew.
  Keep their values and bounds correct before tuning them.
- [ ] Move Queue, circular-buffer, and deque storage algorithms into Dew.
  Commit each library family separately with order and boundary tests.
- [ ] Move Text, Bytes, views, and builders out of compiler-owned algorithms.
  Keep encoding, bounds, and lifetime checks in ordinary library code.
- [ ] Convert remaining host-operation builtins into foreign declarations.
  Keep generated Dew types, provider metadata, and emitted signatures in sync.
- [ ] Remove all remaining standard-module path, declaration-number, and name
  dispatch. Use declaration IDs and explicit representation metadata, including
  Option variants and collection types. Names such as None, into, or RoadMap
  must not change compiler rules.
- [ ] Delete unused legacy builtin plans/builders after each migration. Enforce
  the opcode-or-unsafe-cast rule across every module, registry, and generator.
  Keep conversion behavior in `Into` impls where it is a type conversion.

### Finish the compiler correctness audit

- [ ] Complete physical-boundary checks. Reject missing, Generic, Error,
  conflicting, or consumed evidence before a reachable value reaches emission.
  Extend the existing specialization checks to every fragment/storage boundary.
- [ ] Finish exact call-target checks. A second different target must report
  SPC-303, not silently keep the first. Remove remaining first-candidate and
  name-based exceptions. Verify the emitter uses the frozen target.
- [ ] Finish call operand recipes for all call kinds and hidden arguments.
  Check Unit receivers, non-generic Unit indexed writes, and Never arguments.
  Evaluate each source once in order; stop after a non-returning argument.
- [ ] Complete full Wasm reference checks. Check heap type and nullability,
  not just an eqref label, for call operands, results, locals, and branches.
- [ ] Put constructor and other temporary locals in the frozen physical plan.
  No emitter step may invent a new carrier or overwrite conflicting evidence.
  Verify all worklist constraints at the fixed point and reject later mutation.
- [ ] Finish constructor non-returning-value tests. A Never field or payload
  must prevent later effects and construction, including generic tuple payloads.
- [ ] Complete the emission shadow stack. Track operand types and control
  frames through each instruction, including unreachable code and adapters.
- [ ] Complete solver transaction and arena checks. Require LIFO snapshots,
  parallel undo arrays, valid undo entries, bounded parent walks, and exact
  rollback contents. Check span ownership before relative-index subtraction.
- [ ] Complete SCC and linker checks. Every module must occur once, dependency
  order must hold, and stored identities, physical indices, and import offsets
  must agree. Missing bases or bodies must produce a diagnostic.
- [ ] Separate trait cycles and search limits from ordinary missing evidence.
  Use visited obligations and explicit limit errors, including implementation
  comparison and module-interface traversal.
- [ ] Complete stable numeric failure records and the negative invariant tests.
  Start with a valid state, change one field, and check the exact code and source
  context. Missing data or an unexpected trap must never count as a pass.
- [ ] Add stable phase snapshots to both compilers. Compare by semantic identity
  and stop at the first difference, from collection through emission. Keep
  bootstrap byte comparison as an additional check, not a substitute.
- [ ] Finish nested anonymous tuple patterns, such as `Some((left, right))`,
  in both parsers and downstream pattern handling. Current fixtures use a named
  payload followed by tuple destructuring. Extend imported/unqualified enum
  ambiguity and construction coverage while removing name-based backend rules.
- [ ] Keep readable, typed Starshine FFI names through regeneration. Audit any
  remaining numbered references; test identity and signature agreement rather
  than merely renaming incompatible reference types.

### Final checks for this work

- [ ] Run `tools/test-native.sh`, `tools/test-integration-native.sh`,
  `tools/dew-test/run.sh`, `tools/test-self-host-hardening.sh`, and
  `tools/check-generated.sh` after the remaining implementation batches.
- [ ] Run `tools/test-stress-native.sh` and `tools/test-starshine-native.sh`.
  These full lanes have not yet been run for this migration tranche.
- [ ] Run `tools/check-self-host-bootstrap.sh --clean --fast` after compiler
  changes. Require successful A/B/C builds and identical B/C output; the lane
  already exists and has passed, so extend it rather than creating it again.
- [ ] Measure every compiler run and record runs above 30 seconds as performance
  bugs. Cold native generation, aggregate test lanes, and bootstrap execution
  still exceed the limit. Address speed after the correctness work above.

## P1 — self-hosting

1. Finish the compiler port, including remaining optimization parity, cache codecs,
   and the compiler driver. The Dew parser, semantic pipeline, physical planning,
   and Starshine emission already pass a clean A/B/C fixed-point bootstrap.
   The current correctness and library tasks above remain active.

Use [`docs/research/self-hosting-compiler-gap-catalog-2026-08-16.md`](docs/research/self-hosting-compiler-gap-catalog-2026-08-16.md) for the audited host, Wasm, collection, and port-surface gaps. Port-enabling options in that catalog remain decisions, not active backlog items, until explicitly selected.

Indexed implementation uniqueness, mutable struct fields, and complete `@alias` namespace lookup are finished and therefore omitted from this execution-only backlog.

## P2 — deferred until self-hosting

Every unchecked item below is P2 unless the P1 compiler port proves it is a concrete blocker. Package acquisition, work budgets, optional arguments, annotations, ordinary Boolean `while`, higher-kinded types, negative implementations, TOML, formatter/documentation/LSP work, release infrastructure, and parallel compilation remain deferred.

## Incremental compilation

- [ ] Add hundreds-of-files and representative external-package stress workloads.

Parallel module/body jobs, completion-order tests, and parallel-output checks are intentionally absent from this execution backlog. MoonBit cannot run these compiler jobs in parallel. They become active work only after Dewdrop is self-hosted and Dew supports parallel computation; see [`docs/decisions/0002-parallel-compilation-after-self-hosting.md`](docs/decisions/0002-parallel-compilation-after-self-hosting.md).

## Post-release performance work

These are older, deferred performance tasks. They do not override the current
self-host timing bugs or the correctness work listed above.

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
- [ ] Define checked raw-opcode registry extensions, Wasm imports/exports,
  JavaScript bindings, and string/reference interop. Registry entries must not
  add compiler-owned library algorithms.
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
