# Dewdrop compiler architecture

This document is the concise map of Dewdrop's current compiler architecture. The
language rules remain in [`spec.md`](spec.md), executable priorities remain in
[`roadmap.md`](roadmap.md), and detailed measurements and investigations remain
in [`research/`](research/).

## Design priorities

Architecture changes must preserve the project's priorities, in order:

1. fast generated programs;
2. low generated-program memory use;
3. deterministic compilation and output;
4. clear compiler phase boundaries;
5. low compiler overhead and bounded work.

Dewdrop deliberately uses compact IDs, flat arrays, and spans into shared arenas.
A cleaner boundary does not imply replacing those representations with object
graphs or adding allocation to hot loops.

## Package dependency map

```text
moonbit/core and moonbit/x
          |
          v
src/tokenizer
          |
          v
src/parser
          |
          v
src/semantic <---------------- src/standard_loader
          |                              |
          v                              |
src/backend <----------------------------+
          |                              |
          +-------------+----------------+
                        |
                        v
              src/compiler_driver
                        |
                        v
            compiler executables and generators
```

`src/compiler_driver` is the supported orchestration entry point for compiler
executables. It owns the common collect, cached-analysis, lowering, linking,
diagnostic collection, and raw binary emission sequence. Executables still
import lower packages for manifest construction, source-diagnostic rendering,
custom-section policy, and specialized output framing while those responsibilities
are migrated or intentionally retained.

Starshine is a sibling MoonBit workspace package used only by `src/backend` to
construct, validate, and encode WebAssembly.

## Compiler phase map

```text
ordered source bytes
  |
  v
tokenizer: decoded units and tokens
  |
  v
parser: forward-only declaration/expression events
  |
  v
collection: module-owned HIR arenas and stable source identities
  |
  v
interface freezing: public declarations, resolved types, ABI fingerprints
  |
  v
imported semantics: import scopes and translated imported identities
  |
  v
body semantics: name resolution, inference, evidence, flow
  |
  v
module lowering: backend-neutral executable operations and layouts
  |
  v
program optimization: callback/trait directization and wrapper elision
  |
  v
specialization planning: concrete carriers, evidence, dictionaries, adapters
  |
  v
physical linking: recursive type groups, initializers, indices, exports
  |
  v
backend emission: Starshine module construction, validation, binary encoding
```

The whole-program stages now have explicit implementation owners:

- `src/semantic/program_optimization.mbt` owns backend-neutral interprocedural
  rewrites behind `optimize_program_lowering`;
- `src/semantic/program_specialization_plan.mbt` owns reachability, generic
  specialization, runtime evidence, trait dictionaries, and fragment planning;
- `src/semantic/program_physical_link.mbt` owns recursive physical type groups,
  initializers, final program indices, and link assembly;
- `src/semantic/program_link_plan.mbt` retains shared program-plan data contracts,
  module-lowering orchestration, and cross-plan validation helpers.

Specialization produces the flat `PlannedProgramSpecializationPlan` handoff.
The physical linker validates its module order, packed-identity owners,
expression references, and evidence spans once before assigning final indices.

## Boundary and mutation policy

A public phase result should be treated as immutable by later phases. A phase may
use mutable scratch storage and may build its result incrementally before
returning it.

Whole-program lowering now has an explicit baseline and optimization boundary:

```text
plan_unoptimized_program_lowering
  -> PlannedProgramLowering
  -> optimize_program_lowering
  -> optimized PlannedProgramLowering plus elision summaries
  -> specialization and physical linking
```

The optimizer copies every arena it mutates, so the supplied unoptimized plan
remains available for characterization and future baseline snapshots. Callers
must not mutate returned lowering, frozen interfaces, analyzed semantics,
fragment plans, or final link plans.

## Identity ownership

### Source and semantic IDs

- `FileId` identifies a source file within deterministic module/file order.
- `ModuleId` identifies a collected module.
- `DeclId`, `BodyId`, `VariantId`, `FieldId`, and related IDs pack module and
  module-local identity.
- Negative integers and `0UL` are used as compact internal sentinels in selected
  arenas. Their meaning belongs to the arena that stores them and should be
  hidden behind validated helpers when crossing a subsystem boundary.

### Compiler-owned standard identities

Compiler-owned `dew.std` modules use a reserved `ModuleId` range and currently
have stable source-order declaration identities. Semantic selection, lowering,
layout planning, and backend runtime emission depend on those identities.

The current manually maintained registry lives primarily in
`src/semantic/module_system.mbt`. The intended owner is one generated and
validated standard ABI registry shared by semantic planning and backend plans.
Source-order changes must fail visibly rather than silently changing a builtin
identity.

### Wasm identities

`PlannedProgramLowering` owns one immutable `ProgramIndex` used by optimization,
specialization, initializer analysis, and physical linking. It stores the only
`ModuleId`-to-manifest-index map and resolves declaration, body, implementation,
type, and variant owners from their packed semantic identities without adding
parallel owner maps. Specialized-call maps use a typed key rather than allocating
concatenated lookup strings.
Module fragment plans own module-local physical and signature indices. The final
program link owns program-wide type, function, global, initializer, dictionary,
and singleton indices. Backend emission consumes those frozen indices and must
not derive a competing order from map iteration.

## Arena ownership

Dewdrop stores HIR, inferred types, lowering operations, evidence trees, fields,
patterns, and Wasm plans in flat arrays. `HirSpan` values identify contiguous
subranges in companion arrays.

The owner of an arena must:

- append entries in deterministic source or first-demand order;
- validate imported or cached spans before ordinary indexed access;
- avoid retaining inference variables in frozen interfaces;
- copy an arena before an optimization mutates data shared with an earlier
  result;
- expose logical views or query functions when another subsystem should not need
  the complete representation contract.

Flat storage is a performance decision. Planned arena views should centralize
validation and interpretation without changing the physical layout by default.

## Frozen interfaces and caches

Interface freezing owns the boundary between module implementation details and
cross-module semantic/ABI data. A `FrozenModuleInterface` contains translated
public declarations, types, callables, implementation evidence, dependencies,
and deterministic fingerprints.

The persistent cache stores checksummed serialized frozen-interface bundles.
Corrupt, incompatible, or identity-mismatched artifacts fail visibly. Cache
policy currently lives in `src/standard_loader/interface_cache.mbt`; it covers
compiler-owned standard modules and verified external dependency interfaces.
Future workspace caching should reuse a generalized bundle cache rather than add
parallel formats.

## Program specialization and erased ABI

Closed internal generic calls specialize by canonical physical carrier shapes.
Trait requirements retain exact evidence trees. Public generic boundaries may
also require deterministic erased fallbacks, adapter helpers, typed runtime
trait dictionaries, or evidence-capturing closures.

Semantic program planning owns the meaning and identity of those artifacts.
Backend emission owns only their Starshine/Wasm realization. The intended
specialization plan should therefore contain all required carrier shapes,
evidence parameters, dictionary requirements, adapter relationships, and final
lookup keys before ordinary code emission begins.

## Backend ownership

`src/backend` owns:

- conversion from planned value/storage types to Starshine types;
- instruction generation for lowered executable operations;
- runtime helper bodies selected by semantic plans;
- adapter, callback-wrapper, evidence-closure, and trait-adapter bodies, with
  program adapter planning and emission isolated in
  `src/backend/starshine_program_adapters.mbt`;
- deterministic section assembly, isolated for single-module and linked-program
  output in `starshine_module_assembly.mbt` and
  `starshine_program_assembly.mbt`;
- Starshine validation and binary encoding, owned by those assembly modules;
- compiler-owned Wasm custom sections.

It should not own source name resolution, trait selection, overload choice,
generic evidence discovery, package resolution, or standard declaration
identity assignment.

## Driver and host ownership

The Python bootstrap driver owns package-manifest and lockfile parsing, package
integrity checks, standard-package discovery, and host execution. The MoonBit
compiler executable owns compilation. `tools/dew` now sends one versioned binary
compile request containing ordered source inputs, dependency expectations,
standard-library/cache policy, build mode, and requested output. The protocol is
documented in [`compile-request.md`](compile-request.md), keeping package and
host policy separate from compiler orchestration and providing the same boundary
for future Dew-native tooling.

The MoonBit `compiler_driver` package owns the common
collect/analyze/lower/link/emit sequence used by command, snapshot, test, parity,
and benchmark executables. It returns the phase artifacts without hiding them so
specialized tools can render diagnostics and append purpose-specific custom
sections without rerunning compiler work.

## Validation contracts

- `tools/check.sh --quick` is the focused formatting/generated/native loop.
- `tools/check.sh` is the full deterministic validation entry point.
- White-box MoonBit tests validate individual arenas and phase plans. Shared
  test-only builders in `src/semantic/compiler_test_builders_wbtest.mbt` and
  `src/backend/compiler_test_builders_wbtest.mbt` provide ordered sources and
  stage-specific analyze/lower/link/emit helpers without changing production
  package surfaces.
- Module snapshots validate diagnostics, WAT, runtime output, and index order.
- Performance budgets validate static generated-Wasm costs.
- Differential suites validate UTF, SWAR, WASI, Node, and Wago behavior.

Architecture refactors in hot paths require focused characterization tests and
existing benchmark comparisons before old code is deleted.

## Decision records

Cross-cutting architecture decisions are indexed in
[`decisions/README.md`](decisions/README.md). Research notes may contain the
measurements behind a decision; the decision record states the accepted boundary
and links to those notes.
