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
src/parser                    src/standard_sources
          |                         |             |
          v                         v             v
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
diagnostic collection, and raw binary emission sequence. The semantic package's
reviewable public contract is `src/semantic/pkg.generated.mbti`; the August 2026
surface audit and package-splitting decision are recorded in
[`research/semantic-public-surface-audit.md`](research/semantic-public-surface-audit.md).
Executables still
import lower packages for manifest construction, source-diagnostic rendering,
custom-section policy, and specialized output framing while those responsibilities
are migrated or intentionally retained.

`src/cache_binary` is a leaf package owning the aligned artifact-pack container,
canonical binary codecs, and portable BLAKE3-256; `src/semantic`,
`src/standard_loader`, and `src/compile_request` consume it. The diagram omits
leaf executables and generators: `src/compile_request` owns the versioned binary
host/compiler request codec, `src/core_linker` owns deterministic Core Wasm
static linking, and `src/compiler_driver` consumes both. `src/dew_cli` and
`src/dew_bootstrap` are executable packages above the driver: `src/dew_bootstrap`
owns whole-build caching, compiler fingerprinting, and process dispatch behind
`tools/dew`, while `src/dew_cli` implements the compiler-facing commands.
`src/compiler_proofs` is the proof-enabled leaf package: it separates executable
code in `.mbt` from logical predicates and lemmas in `.mbtp` and proves the
arena-span, physical-carrier, and dense type-remap obligations behind
`tools/test-proofs.sh`.

Starshine is pinned as the `starshine-mb/` Git submodule and MoonBit workspace
member. `src/backend` uses it to construct, validate, and encode WebAssembly.

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
body semantics: fresh name resolution plus cached-or-fresh inference/evidence
  |
  v
body artifact validation: exact source/interface provenance and HIR arena identity
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

Native persistent compiler data is grouped into one 16-byte-aligned artifact
pack under `.dew/cache/packs/`. The compiler reads the pack once, scans
contiguous fixed entry headers, and lazily decodes only selected payloads.
BLAKE3-256 binds exact owners, direct content, compiler/dependency context, and
payload bytes. The U32 digest lanes in entry headers are fast filters only.
Exact successful check, HIR, lowering, and Wasm entries are the default warm
boundary and bypass all compiler phases. `--no-program-cache` retains phase
entries while disabling that boundary; `--no-cache-pack` selects the legacy
per-artifact storage path.

Persistent executable semantics remain opt-in while the end-to-end admission
policy is evaluated on broader heavy-inference workloads. Their payloads remain
canonical binary inside aligned pack entries. `--body-cache` first uses a
complete module entry; its key
commits to exact module source, default-preamble policy, stable module identity,
and the transitive frozen interface/evidence fingerprint. `--body-family-cache`
implies that policy and may load one atomic `BFAM` pack entry. Each entry owns a non-module-value root body
and its nested lambda tree, commits to exact declaration source plus
location-independent module-value/signature/name/evidence context, and normalizes
expression/pattern IDs and absolute offsets before persistence. Lookup validates
owner/arena/type/evidence structure, rebases into current HIR, and mixes cached
and fresh jobs through the ordinary source-ordered merge. Family lookup uses one
fingerprint map and precomputed source ranges; applicable ordinary modules are not
duplicated into the larger complete-module cache, and partial misses do not
rewrite an existing baseline bundle. Name resolution and module-value SCC
inference remain fresh. The binary codecs pass isolated encode/decode and size
admission gates, but the explicit policy remains until broader end-to-end cache
costs are consistently below fresh inference.

`--plan-cache` independently persists canonical binary module type layouts and
baseline module-local WasmGC fragments as `LAYT` and `FRG0` pack sections. Layout
keys bind exact module source and frozen
semantic context. Fragment keys additionally bind root selection, planning mode,
and exact whole-program source/interface/evidence context because optimization
and reachability are interprocedural. Cached fragments contain no program-level
specializations or final indices. The physical linker always assigns final type,
signature, function, global, and initializer indices fresh. This planning cache
is also opt-in because current end-to-end file I/O and validation exceed fresh
planning despite fragment decoding being faster in isolation. Exact program
entries avoid that phase-level cost on unchanged warm requests.

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

Immutable direct-alias coalescing owns a deterministic body-local interval plan:
it records first and last expression-arena reads plus read/write counts for each
candidate local. Scalar carriers may share immutable sources directly. Exact
references and erased generics additionally require matching inferred type,
physical shape, and nominal evidence, no mutation or capture, and reads ordered
around the alias initializer so eliminating duplicate storage cannot lengthen the
source lifetime. These intervals remain an alias-elimination proof rather than a
general control-flow coloring model.

The backend separately performs bounded deterministic slot reuse for linear
root-block bodies with no nested block, conditional, match, or loop control flow.
Immutable uncaptured single-declaration `let` locals receive root-item lifetime
positions, and first-fit allocation reuses the first compatible slot whose prior
value is dead by the next initializer. Exact nominal references require one
physical type index, erased generics require one inferred generic type, and
scalar/SIMD carriers require one Wasm value carrier. Mutable locals, pattern
locals, captures, control-flow joins, and backedges remain distinct. This is a
measured linear allocator, not general graph coloring.

`PlannedTailCall` refines `PlannedDirectCall` after other call rewrites complete.
Every reachability, specialization, link-validation, physical-dependency, nominal
result, conversion-scratch, and backend emission query that recognizes direct
calls must recognize tail calls identically unless it is specifically choosing
between `call` and `return_call`. Tail transfers remain bounded to local
user-defined receiver-free non-generic scalar-only bodies; cross-function
transfers are added only inside terminal `if` branches and match arms so root
forwarding wrappers remain available to summary/directization passes.

Private scalar unit-enum specialization is a copied-lowering proof. The
type-layout plan freezes declaration visibility, generic arity, source-order
variant tags, and payload shapes. Body-local specialization requires one
immutable uncaptured local initialized by proven constructor/`if` tails whose
every read is an exact unguarded match scrutinee. Parameter specialization adds a
closed-call proof: a module-visible receiver-free non-generic function parameter
must have the same match-only usage, no function reference, and only direct or
tail call sites whose corresponding arguments are proven constructor/`if` trees
for that enum. Result specialization requires a complete constructor/`if` result
tree and every direct or tail call result to have exactly one direct unguarded
exact-constructor match consumer. The optimizer changes accepted local,
parameter, argument, result, call, scrutinee, and pattern carriers to `I32`.
Fragment planning emits a distinct private physical signature when an optimized
parameter or result differs from its resolved source function type, and
reachability omits the enum physical type when no retained value needs it.
Public callables, methods, generics, captures, guarded matches,
escaping/stored results, function references, and incomplete call or consumer
evidence remain reference-backed.

A second copied-lowering proof covers private scalar payload enums. Eligible
module-visible non-generic enums contain only unit variants or one `I32` tuple
payload and have at least one payload variant. The optimizer packs the frozen tag
into the low 32 bits of one `i64` and the exact payload bits into the high 32
bits. Closed parameter call-site evidence and result-consumer evidence match the
unit-enum rules; constructors, block/`if` joins, locals, private signatures,
calls, scrutinees, and root patterns change together to the `I64` carrier.
Backend packing evaluates each payload once before shifting/or-ing, and matching
uses the existing single-evaluation scratch local before tag comparison and
payload extraction. Public/generic/function-value/method/imported boundaries,
struct or multi/non-`I32` payloads, nested patterns, guards, alternatives,
catchalls, captures, escapes, and stored or duplicated result consumers remain
subtype-backed.

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

Compiler-owned `dew.std` modules use a reserved `ModuleId` range and stable
source-order declaration identities. Semantic selection, lowering, layout
planning, and backend runtime emission depend on those identities.

`tools/standard-builtin-registry.json` is the canonical compiler identity table
for Option, FixedArray, Map, Set, lane modules, collection methods, and index
implementations. Scalar `dew.std.math` builtins are ordinary inline builtin
names: exact float bit reinterpretation and Core unary math operations are
mapped in `src/backend/starshine_numeric_builtins.mbt`, while the integer and
floating policy layer remains generated Dew source. Portable `dew.std.io`
contains only ordinary traits, control flow, FixedArray state, immutable Bytes,
and BytesBuilder composition. Its architecture fixture rejects WASI imports and
linear memory, keeping host adapters outside the portable module. The
`dew.std.testing` helper layer is likewise ordinary source: it delegates failure
to the compiler-owned assertion builtin and does not own test metadata,
reachability, or runtime normalization. `dew.std.json` keeps grammar, scanning
policy, delimiter classification, limits, duplicate-key handling, tree
construction, Reader/Writer composition, and serialization in Dew source.
Wide-object duplicate-key checks compose four allocation-free
`dew.std.bloom_filter` scalar values with an exact source-order equality fallback
for every probabilistic positive; no JSON-specific membership builtin exists.
Serialization traverses authoritative arrays by index, reuses member prefixes
for exact duplicate checks, and appends validated clean `StringView` spans
without a second key array or iterator allocation. Its only new representation
primitives are the bounds-checked
`wasm_bytes_load_u8x16(Bytes, U32)` and
`wasm_string_load_u8x16(String, U32)` bridges over private GC-backed text
storage; `u32_ctz` and the remaining SIMD operations map directly to WebAssembly
instructions. JSON-specific runtime helpers are forbidden by architecture tests.
`tools/generate_standard_builtin_registry.py` generates
`src/semantic/standard_builtin_registry.mbt`, including typed
`StandardBuiltinOperation` cases instead of integer operation codes. White-box
collection tests validate generated slots and ordinals against bootstrap source;
generator and byte-identity checks fail when the JSON, `std/*.dew`, embedded
sources, or compiler identities diverge.

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
not derive a competing order from map iteration. Module and program plans also
own direct imported/runtime function lookup maps, including per-module runtime
lookups for linked output, so assembly does not rescan function classifications.

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

Flat storage is a performance decision. `src/semantic/arena_views.mbt` provides
zero-copy logical views for lowered bodies, resolved types, call specialization,
trait evidence, and linked program functions. Shared span validation runs when
module lowering and specialization plans cross phase boundaries; validated hot
loops retain direct indexed access.

Small iterative helpers centralize parallel-stack assertions, integer result-range
assembly, and reusable generation marks across alias import/normalization and
local unification. Transparent type aliases preserve their spelling for qualified
inherent method lookup while dispatching through the normalized target head, so
scalar aliases such as `BloomFilter = U64` retain one scalar carrier. Method-body
trait evidence includes contiguous implementation-owner and method-local generic
parameters. Dewdrop deliberately rejects a universal callback visitor:
phase-specific task enums and direct loops remain visible, as confirmed by the
native type-resolution and local-unification benchmarks.

### Body inference ownership

`BasicBodyInferencer` remains the single owner of one solver and shared scratch
arenas, while focused extension modules own pattern inference, member and
constructor resolution, method/operator/index resolution, callable and overload
selection, trait obligations/evidence, and result compaction. This avoids
allocation-heavy collaborator objects while keeping expression traversal in the
small orchestration core. The native basic-inference benchmark suite is the
required performance check for changes to these boundaries.

## Standard source ownership

Embedded bootstrap bytes live in the independent `src/standard_sources` package.
Its registry owns canonical source paths and path-to-byte lookup. Production
loading and provenance remain in `src/standard_loader`, which constructs either
on-disk or bootstrap `StandardLibrarySources`. Semantic collection consumes that
ordered provider and does not contain generated standard assets. Tests compare
every on-disk standard source byte-for-byte with the bootstrap provider.
Selective loading assigns each split module a stable registry slot and prepass bit;
`dew.std.iter` is slot 47 and is embedded from `std/iter.dew` by its dedicated
generator. `dew.std.wasm.intrinsics` is generated from every `builtin` declaration
whose external name is recognized by the complete backend inline-builtin
dispatch. Public aliases use a `wasm_` prefix to remain safe under wildcard opens;
the generator fails when a backend inline name has no Dew signature and emits the
bootstrap bytes from the same canonical source.

## Frozen interfaces and caches

Interface freezing owns the boundary between module implementation details and
cross-module semantic/ABI data. A `FrozenModuleInterface` contains translated
public declarations, types, callables, implementation evidence, dependencies,
and deterministic fingerprints.

The persistent cache stores checksummed serialized frozen interfaces. Corrupt,
incompatible, or identity-mismatched entries fail visibly. The cache
architecture is generalized around `InterfaceBundleCacheKey` and
`InterfaceBundlePolicy`: `interface_cache_envelope.mbt` owns the compatible
version 1 standard and workspace envelopes, `interface_bundle_cache.mbt`
owns provenance and module selection, `cache_pack.mbt` owns default unified I/O,
and `cached_analysis.mbt` owns semantic analysis using cached slots. One bundle
selects compiler-owned standard modules and verified external dependencies.
Ordinary non-root workspace modules use `IFCE` pack entries; acyclic modules
publish individually while multi-module and self-recursive SCCs publish and load
as one atomic entry.
Lookup occurs in dependency order and keys commit to manifest source identity
plus direct public content fingerprints. Private dependency changes retain
downstream hits while public interface changes invalidate dependents
transitively. Verified package
capsules provide artifact-assisted source-tree recovery for missing locked
dependencies.

The earlier syntax boundary is now `parse_event_cache.mbt`. It prepares each
workspace source before standard-module selection, prepares only the selected
standard sources afterward, and attaches one immutable `ParseEvent` array to the
file model. Import scanning and collection consume that same array in manifest
order. Default `PEVT` pack entries bind BLAKE3 owner/source/producer context and
payload bytes; `parse_event_cache_envelope.mbt` retains the legacy V1
key/source/checksum path. The payload is a direct tagged binary syntax graph with
exact IEEE float bits and no JSON bridge. The native platform shim publishes through a flushed,
POSIX-fsynced same-directory temporary file and atomic rename. Missing entries
are misses, while malformed, incompatible, mismatched, or corrupt entries fail
visibly. Body, layout, and fragment caches remain future extensions over these
source and interface provenance boundaries.

## Program specialization and erased ABI

Closed internal generic calls specialize by canonical physical carrier shapes.
Trait requirements retain exact evidence trees. Public generic boundaries may
also require deterministic erased fallbacks, adapter helpers, typed runtime
trait dictionaries, or evidence-capturing closures.

Semantic program planning owns the meaning and identity of those artifacts.
Backend emission owns only their Starshine/Wasm realization. The validated
specialization plan contains required carrier shapes, evidence parameters,
dictionary requirements, adapter relationships, and typed lookup keys before
ordinary code emission begins.

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

Single-module and linked-program bodies share one iterative expression, pattern,
local, capture, and call emitter. A static `StarshineExpressionEmissionContext`
supplies optional linked-program and adapter-plan data without callback-heavy
hot-path indirection. Single-module and linked-program section assembly remain
separate because their final index ownership differs.

The backend should not own source name resolution, trait selection, overload
choice, generic evidence discovery, package resolution, or standard declaration
identity assignment.

## Driver and host ownership

The MoonBit bootstrap command owns package-manifest and lockfile parsing,
package integrity checks, standard-package discovery, package capsules,
whole-build caching, compiler fingerprinting, and host execution. Cache-pack
hashing, decoding, validation, and lookup also remain in MoonBit with the
compiler. `tools/dew` is a small shell launcher that locates the repository and
starts `src/dew_bootstrap`; it owns no compiler or cache semantics.

The versioned binary compile request remains a private compatibility boundary for
matching compiler tools, but the MoonBit bootstrap currently invokes the MoonBit
compiler command directly. See [`compile-request.md`](compile-request.md) and
[`decisions/0004-moonbit-owned-bootstrap-and-cache.md`](decisions/0004-moonbit-owned-bootstrap-and-cache.md).

The MoonBit `compiler_driver` package owns the common
collect/analyze/lower/link/emit sequence used by command, snapshot, test, parity,
and benchmark executables. It returns the phase artifacts without hiding them so
specialized tools can render diagnostics and append purpose-specific custom
sections without rerunning compiler work.

## Validation contracts

- `tools/check.sh --quick` is the focused formatting/generated/native loop.
- `tools/check.sh` is the deterministic top-level scheduler for the full profile.
  It delegates formal proofs, generated checks, per-target MoonBit tests,
  CLI/cache/ABI checks, and parity/snapshot suites to directly executable tool
  runners.
- `tools/test-proofs.sh` runs the proof-enabled `src/compiler_proofs` package.
  These proofs define the first arena-span, physical-carrier, and dense
  type-remap obligations for the certified self-host lowering plan and the
  post-link type compactor.
- `tests/architecture-cases.json` declaratively records provider artifacts,
  performance budgets, optional consumers/invocations, expected values, and
  required/forbidden WAT properties; `tools/check-architecture-cases.py` runs
  those reviewable cases.
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
