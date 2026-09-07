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

Implementation is complete in both compilers. The shared corpus now has 96
execution checks. Read the [query guide](docs/compile-time-types.md) for the
20 builtins, examples, and layout limits. The full history and measured checks
are in the [completion log](docs/research/compile-time-query-completion-2026-09-06.md).

- [x] Pure query/assertion builtins in `dew.std.types`. Use logical type identity;
  keep unknown types pending and errors diagnostic. Emit no runtime query calls.
- [x] Real `field_type` and `variant_payload_types` results in declarations,
  lambda signatures, and generic arguments. Support imported/generic owners,
  deferred member projections, aliases, `Self`, and block-local type bindings.
- [x] Ordered `field_names` and `variant_names`, with fresh string arrays.
- [x] Scalar and ordered-tuple raw layout queries. Reject unsupported GC layouts;
  never invent object offsets or turn missing layout evidence into a reference.
- [x] Private specialized IR bodies and exact logical keys. Fold query guards,
  local aliases, captured scalar query values, and short circuits before planning.
- [x] Branch-local `implements` proofs and type facts. Recheck selected fields,
  operators, calls, overloads, results, and generic method bounds, including imports.
  Preserve concrete source errors and trait cycles/limits.
- [x] Remove dead calls, locals, captures, lambdas, and storage demand. Keep source
  IDs, argument effects, Never prefixes, and the exact selected emitter input.
- [x] Native/self-host positive and negative tests, numeric invariant records,
  shared Wasm execution, and checks that no query reaches physical emission.
- [x] Complete the final full-lane run and fresh byte-identical B/C bootstrap.
  Native 913 tests, integration 266 tests, stdlib execution, hardening 220 tests
  and 29 records, generated checks, 15 stress tests, and all 10,982 pinned
  Starshine tests pass. The refreshed provider passes hardening and integration.
  Compiler B/C core and linked Wasm bytes match in the clean bootstrap run.

### Performance follow-up

Correctness comes first. Keep these timing defects visible after query completion.

- [ ] Reduce full-module query instance copies to body-local overlays. Keep exact
  logical keys, immutable source templates, and one selected emitter input.
- [ ] Profile and share repeated query source/evidence maps where safe. Keep local
  and capture IDs tied to their owning body; do not reintroduce ID guessing.
- [ ] Reduce compiler builds, test lanes, and bootstrap stages that exceed
  30 seconds. Record both cold and warm timings; do not hide or skip slow tests.

### Finish the standard-library migration

- [x] Remove special `FixedArray` method and index dispatch. Compile the existing
  Dew method bodies and delete unused checked-read builders. Thirteen shared
  tests cover Unit, tuples, references, packed values, bounds, and evaluation
  order. Native/self-host checks and a clean B/C fixed point pass. See the
  [migration log](docs/research/fixed-array-library-migration-2026-09-06.md).
- [x] Finish raw Wasm array contracts and storage adapters. Both compilers bind
  raw owners from checked declarations, preserve typed scalar and product
  storage, and support `array.new_default` and `array.copy`. Fourteen shared
  cases cover multiple generic parameters, Unit effects, and storage bounds.
  Missing types fail at the storage boundary. Clean bootstrap passes. See the
  [contract log](docs/research/raw-array-contracts-2026-09-06.md).
- [x] Declare Array storage fields in Dew and compile length/capacity through
  ordinary library calls. Remove the native layout override and self-host size
  method shortcuts. Tests check actual field identities and changed method
  bodies. See the [accessor log](docs/research/array-library-accessors-2026-09-06.md).
- [x] Move Array allocation, growth, mutation, and iteration into Dew. All 13
  remaining builtins now have Dew bodies, with typed raw backing storage.
  Both compilers pass 28 shared Array checks and the clean B/C fixed point.
  Native method/operation ordinal dispatch and the iterator layout override are
  removed. See the [algorithm log](docs/research/array-library-algorithms-2026-09-06.md).
- [ ] Remove the old Array wrapper layout and literal shortcuts. Use declared
  fields and exact construction recipes, not a guessed three-field layout.
  Unused native Array operation nodes and emitters are now removed; literal
  construction remains; shared ring producers are now removed. See the
  [cleanup log](docs/research/array-legacy-ir-cleanup-2026-09-06.md).
  Literal storage now rejects unresolved evidence and preserves packed integer
  widths; all 29 shared checks pass. The unused opcode switch/helpers are gone.
  See the [literal storage log](docs/research/array-literal-storage-2026-09-06.md).
- [x] Move Map hashing, buckets, growth, lookup, and iteration into Dew. Typed
  entries preserve aliases, cached hashes avoid repeated user calls during
  growth, and all 12 shared native/self-host checks pass. Native Map IR and
  self-host Map runtime emitters are removed. The clean B/C fixed point passes.
  See the [Map log](docs/research/map-library-storage-2026-09-06.md).
- [x] Move Set storage and iteration into Dew using Map with Unit values.
  Eight shared checks pass in both compilers. Special Set inference/layout/IR,
  the remaining native hash-table runtime, and its extra target arrays are gone.
  The clean B/C fixed point passes. See the
  [Set log](docs/research/set-library-storage-2026-09-06.md).
- [x] Move Queue, circular-buffer, and deque storage algorithms into Dew.
  Each family has a separate commit. Declared typed storage replaces the shared
  Array layout, and unused native ring code is removed. Twenty shared checks
  pass in both compilers, including Unit, tuples, references, bounds, growth,
  clearing, floats, and Iter. See the
  [storage log](docs/research/circular-buffer-library-storage-2026-09-06.md).
- [ ] Move Text, Bytes, views, and builders out of compiler-owned algorithms.
  Keep encoding, bounds, and lifetime checks in ordinary library code.
  Bytes equality, hash, searches, affixes, UTF-8 validation, and checked String
  conversion now run in Dew. Bytes storage operations and the SIMD storage
  bridge still need migration. See the
  [Bytes log](docs/research/bytes-library-algorithms-2026-09-06.md).
  StringView scans also run in Dew, with shared native/self-host tests and a
  fix for reference-identity equality. View storage remains.
  See the [StringView log](docs/research/string-view-library-algorithms-2026-09-06.md).
  String scans and concatenation use the Bytes library path. String equality
  still needs an explicit literal-pattern call plan before its runtime builder
  can be removed. See the [String log](docs/research/string-library-algorithms-2026-09-06.md).
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
- [x] Run `tools/test-stress-native.sh` and `tools/test-starshine-native.sh`.
  After the Set migration, all 15 stress tests and 10,982 pinned Starshine tests
  pass. Run them again after the remaining compiler changes.
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
- [ ] Measure full-array pop allocation and Unit marker storage. The Dew clear
  path uses one temporary default slot only when storage is full. Remove that
  cost only with a checked storage design that also works for literal producers.
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
