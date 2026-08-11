# Roadmap/code inventory — August 10, 2026

## Status

The truth-sync described by this audit was applied to `docs/roadmap.md`,
`agent-todo.md`, and `README.md` on August 10, 2026. Statements below about stale
summary text describe the pre-sync state retained here as the reason for the
documentation changes.

## Scope

This is a static inventory of the checked-in workspace compared with the
pre-sync roadmap and execution backlog. It examines implementation files,
standard-library sources, fixtures, and current design notes. The test suite was
not executed as part of this inventory because this agent session has no command
runner, so "implemented" below means supported by concrete code and checked-in
tests/fixtures rather than newly revalidated in this session.

## Executive conclusion

The roadmap's detailed implementation sections are substantially more current
than its summary queue, suggested milestone sequence, `agent-todo.md` priority
list, and parts of the README. The repository has already crossed several
milestones that those summaries still describe as future work:

- generic bounds, trait obligations, recursive evidence, and orphan/coherence
  enforcement are implemented;
- runtime trait values, dictionaries, scalar/SIMD boundary boxing, imported
  dictionaries, and typed `call_ref` dispatch are implemented;
- postfix `derive(Eq)`, `derive(Debug)`, and `derive(Hash)` are implemented for
  structs and enums, including generic prerequisites and imported execution;
- ambient `Debug` and deterministic bounded-WASI output are implemented;
- bare `return`, non-tail expression drops for supported single-value shapes,
  loop execution, module initialization execution, and dynamic-dispatch
  execution all have concrete lowering/emission paths and fixtures;
- the snapshot generator already transports ordered warnings into the JSON
  oracle, although there do not appear to be ordinary warning producers yet.

The single clearest unfinished item in the seven-item immediate execution queue
is installed artifact-only dependency interface recovery. The next user-facing
feature milestone after foundational cleanup is core collections and iteration,
beginning with growable `Array` and explicit iterator protocols. Before either,
a short correctness sprint should close known gaps in already-advertised syntax
and semantics.

## Current implementation inventory

### Frontend and executable language

Confirmed in code:

- streaming tokenizer and forward-only parser packages under `src/tokenizer/`
  and `src/parser/`;
- declarations for functions, tests, traits, implementations, structs, enums,
  aliases, module imports/opens, patterns, matches, functional `while`, lambdas,
  local mutation, assignment, indexing, and structured recovery;
- parser retention and semantic expansion of postfix derive requests through
  `src/parser/declarations.mbt`, `src/parser/derive.mbt`, and
  `src/semantic/collect.mbt`;
- bare return parsing and HIR retention (`ReturnItem(None, ...)` and
  `HirReturnItem(-1, ...)`), Unit checking in
  `src/semantic/infer_basic_bodies.mbt`, and Wasm `return` emission in
  `src/backend/starshine_code.mbt`;
- non-tail expression dropping in `FinishStarshineBlock` for supported
  value-producing shapes;
- executable functional loops and nested patterns, with runtime snapshots in
  `tests/module-snapshots/control-flow/`.

Confirmed absent or still intentionally deferred:

- constant-parameter `#annotation(...)` syntax and frozen annotation data;
- `defer`, `using`, and `Disposable` cleanup plans;
- method-level generics and explicit call-site type arguments;
- optional arguments;
- ordinary Boolean `while` and a second `loop` form;
- formatter/lossless syntax infrastructure.

Known supported-surface gaps remain documented in
`docs/research/coverage-gap-findings.md`:

1. string literal patterns parse and type-check but are not emitted;
2. a discarded non-Unit tail in a Unit-returning function can disrupt earlier
   method/operator inference;
3. local module-value cycles can surface weak CLI diagnostics rather than the
   intended eager-cycle diagnostic;
4. unconstrained target selection for narrow-literal `.into()` calls remains
   ambiguous.

These are more urgent than adding another broad syntax family because they
contradict otherwise-supported language behavior.

### Types, generics, traits, and derivation

Confirmed in code and fixtures:

- ordered generic bounds and trait obligations;
- recursive evidence freezing and evidence-aware specialization;
- local/imported coherence and package orphan rules;
- runtime trait object coercions, physical trait object/vtable plans, shared
  dictionaries, prerequisite-aware materialization, and `call_ref` dispatch;
- interprocedural directization and runtime-trait flow analysis in
  `src/semantic/program_optimization.mbt`;
- `derive(Eq)`, generated `Ne`, `derive(Debug)`, and `derive(Hash)` for structs
  and enums, including generic field/payload prerequisites, cross-module frozen
  evidence, cache round trips, and ordinary coherence conflicts;
- ambient `Debug` declarations and primitive implementations in
  `std/preamble/110-debug.dew`;
- deterministic Debug runtime emission in the backend and dedicated derive
  snapshots under `tests/module-snapshots/types/`.

Roadmap summary mismatches:

- `agent-todo.md` still names generic bounds/runtime trait values as priority 1,
  although its detailed runtime-trait checklist is already checked and the code
  implements the feature end to end;
- the suggested milestone sequence still says generic bounds and runtime trait
  dictionaries remain after the static ABI milestone;
- `agent-todo.md` says to add `#derive` initially for Eq/Debug/Show/Hash as if
  derivation were absent; Eq, Debug, and Hash are already implemented;
- README line 118 warns that `#derive` is planned, while the actual syntax is
  postfix `derive(...)` and the README later documents the implemented forms.

Still genuinely unfinished:

- `Show` and `show(value) -> String`;
- a settled relationship among `Show`, `Debug`, and `StringBuilder`;
- typed lane Debug formatting, recursion/resource limits, and explicit non-WASI
  Debug behavior;
- general annotation syntax and interface serialization;
- structural-containment overload specificity;
- decisions on associated types/constants and supertraits.

### Modules, packages, interfaces, and caching

Confirmed in code:

- strict explicit module graphs and convention-first packages;
- `dew.json` plus exact `dew.lock` records;
- materialized semantic-version/Git dependency validation;
- selective on-disk standard-source loading;
- V11 checksummed persistent interface bundles;
- cache policy for standard modules and versioned external dependencies;
- cached-interface injection before ordinary semantic analysis;
- file-aware diagnostics and cross-module fixtures.

The immediate installed-artifact foundation gap is now closed for V1 package
capsules:

- every verified locked dependency publishes a content-addressed `.dpa` capsule
  keyed by exact identity/version/source/integrity/interface provenance;
- the capsule commits to sorted dependency requests and ordered conventional
  source payloads through envelope, per-file, and recomputed package-integrity
  checksums;
- when the locked source tree is unavailable, the CLI validates the capsule,
  stages the complete package, and atomically restores it at the same locked path;
- the existing frozen-interface bundle is then injected normally, while restored
  executable bodies preserve byte-identical static-link output.

A later measured optimization may serialize collected bodies to avoid parsing
restored payloads, but package-tree availability and interface refreezing no
longer block verified dependency compilation.

Still deferred beyond that:

- registry lookup and Git checkout;
- deterministic lockfile generation/update;
- content-addressed installed package storage;
- ordinary workspace-module caching and interface-fingerprint invalidation;
- parallel module/body scheduling.

### Backend and runtime

Confirmed in code and fixtures:

- static linked WasmGC modules with program-wide type/function/global indices;
- recursive physical type groups;
- explicit `__dew_init` planning and host invocation;
- closures, mutable capture cells, generic adapters, runtime evidence closures,
  trait objects, dictionaries, and dynamic typed calls;
- fixed-width scalar, packed, SIMD, memory, text, WASI, FixedArray, Map, and Set
  runtime paths;
- loop, initialization, and dynamic-trait runtime fixtures, despite the roadmap
  still carrying one unchecked combined execution-test item;
- deterministic expression-item drops and bare return emission for the current
  supported value model.

Still absent or deferred:

- Wasm Start section ownership beyond explicit `__dew_init`;
- table/element sections for a future table-based dispatch model;
- deterministic Name and source-map/custom source sections;
- equivalent ABI signature deduplication;
- constant folding, general inlining, escape analysis, scalar replacement, CSE,
  and tail-recursion optimization.

### Standard library

Actually present under `std/`:

- preamble primitive traits/operators/conversions/memory/SWAR/V128/Debug;
- Option and Result;
- String, StringView-facing string operations, Bytes, and consuming builders;
- FixedArray;
- Map and Set;
- typed lane modules;
- WASI;
- initial `dew.std.wasm.intrinsics`.

Actually absent as modules:

- growable Array;
- iterator protocols/module;
- queue, circular buffer, stack, binary heap, red-black tree, finger tree, and
  persistent list;
- Disposable;
- math, general I/O, expanded testing, JSON/TOML/YAML, HTTP, and cryptography.

`Array` plus explicit iterators is the smallest coherent next standard-library
tranche. Iterators are required before Map/Set iteration and several later
collection APIs can be considered complete.

### CLI, tests, and developer tooling

Confirmed in code:

- `dew check`, `build`, `run`, and `test`;
- HIR, lowering, WAT, and Wasm emission;
- package integrity, strict manifest parsing, dependency expectations, and cache
  controls;
- module snapshot discovery/update/comparison;
- ordered warning transport in `src/module_snapshot_gen/main.mbt` and
  `tools/module-snapshots/run.py`;
- multi-file and multi-module snapshot fixtures;
- dedicated loop, initialization, runtime-trait, derived-trait, closure,
  collection, text, memory, numeric, lane, and WASI runtime fixtures.

Still absent:

- `dew fmt`, `dew doc`, and `dew clean`;
- phase timing/allocation CLI reports;
- LSP;
- package fetch/install/update commands;
- release CI and published compiler artifacts.

The roadmap contains inconsistent snapshot totals (175, 223, and 243 in
separate sections). Counts should be generated by the snapshot runner or one
shared checked source rather than copied manually into several prose sections.

## Roadmap entries that should be reconciled

The following are strong candidates to mark complete or rewrite after running the
full suite:

1. generic-bounds/runtime-trait priority and milestone summaries;
2. trait objects/dictionaries/`call_ref` in immediate queue item 7;
3. warning-to-JSON-oracle wiring;
4. bare return emission;
5. non-tail drops for the current single-value shape model;
6. loop, module-initialization, and dynamic-dispatch execution tests;
7. `Debug` as wholly future standard-library work;
8. Eq/Debug/Hash derivation as wholly future annotation work;
9. README's claim that `#derive` is merely planned;
10. duplicated and inconsistent fixture totals.

Entries that should remain explicitly partial rather than simply checked:

- derivation: Eq/Debug/Hash exist, but Show, annotations, limits, and final syntax
  remain;
- Debug: implemented, but Show/StringBuilder integration, typed-lane formatting,
  resource limits, and non-WASI policy remain;
- expression cleanup: ordinary drops and returns exist, but the known Unit-tail
  inference bug and a complete supported-shape matrix remain;
- dependency interface caching: versioned dependencies are cached, but still
  require source collection.

## Recommended next execution order

### 0. Reconcile project truth — completed August 10, 2026

`docs/roadmap.md`, `agent-todo.md`, and the README now distinguish implemented
generic/runtime-trait/derive/Debug/return/drop/test work from the remaining
annotation, Show, cleanup, artifact, collection, and hardening work. Duplicated
snapshot totals were removed from roadmap prose in favor of fixture-tree
discovery.

### 1. Close current-language correctness gaps

Use snapshots first, then implementation changes, for:

1. discarded non-Unit tails in Unit functions;
2. string literal pattern emission or an explicit parser/type-check rejection
   until emission exists;
3. local module-value cycle source diagnostics;
4. a complete bare-return/non-tail-drop/`Never` execution matrix;
5. the first real warning producer so the already-wired warning oracle is
   exercised.

This makes the advertised current subset trustworthy before its surface grows.

### 2. Finish installed artifact-only dependency recovery

This is the remaining immediate-queue architecture item. It should define an
artifact manifest containing enough verified module identity, dependency closure,
interface fingerprint, ABI version, and provenance information to build the
consumer's collected/imported semantic view without dependency source bytes.
Corrupt, missing, mismatched, or incompatible artifacts must remain fail-visible.

### 3. Start the next user-facing milestone with Array and iterators

Implement growable `dew.std.array` over the six existing carrier families, then
The growable Array and explicit iterator tranche landed on August 11, 2026,
including Array/Map/Set iteration. It builds directly on FixedArray, existing
carrier planning, mutable collection runtime machinery, generic specialization,
and IndexedGet/IndexedSet evidence. The next collection tranche is circular
buffers plus stack/queue APIs.

### 4. Then choose one ergonomics tranche

After Array/iterators, choose either:

- annotations plus final derivation syntax/retention and `Show`; or
- deterministic cleanup (`Disposable`, `defer`, and `using`).

Do not combine both in one milestone: each crosses parser, HIR, interface,
semantic, control-flow, lowering, runtime, diagnostics, and cross-module tests.

## Bottom line

The project is not waiting on generic bounds or runtime trait values; those are
already substantial implementations. The immediate roadmap should now read:

1. synchronize documentation with the code;
2. harden known current-language correctness gaps;
3. add artifact-only dependency interface recovery;
4. move to growable Array and iterator protocols;
5. then take annotations/Show or deterministic cleanup as a separately bounded
   ergonomics milestone.
