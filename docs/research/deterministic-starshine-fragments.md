# Deterministic Starshine WasmGC fragments

## Status

Implemented for nominal WasmGC type groups, callable signature types, builtin imports, defined-function entries, scalar body instructions, public function exports, complete module construction, Starshine validation, and binary encoding. Globals, startup code, aggregate construction, match decision trees, and functional-loop instructions remain later emission stages.

The implementation is split between:

- `src/semantic/wasmgc_fragment_plan.mbt`: immutable WasmGC-specific planning and stable module-local index assignment;
- `src/backend/starshine_fragments.mbt`: mechanical translation into `jtenner/starshine/lib` values.

The Starshine sibling checkout is linked through `moon.work` as `jtenner/starshine@0.1.1`.

## Planning API

```moonbit
pub fn plan_module_wasmgc_fragments(
  ResolvedModuleTypes,
  PlannedModuleLowering,
) -> PlannedModuleWasmGCFragments
```

Stable lookups are available for:

- nominal declaration to physical type index;
- enum variant to payload-object type index;
- callable declaration to function fragment.

The plan freezes recursive groups, physical struct types, physical fields, group-local or module-global references, callable signature indices, imported/defined function indices, parameter/result value types, source names and visibility, inline builtin classification, directizable wrapper evidence, wrapper elision, and source offsets.

## Physical type jobs and deterministic merge

Each nominal root becomes one physical type source. Each payload-bearing enum variant adds one payload-struct source. Unit variants add no payload type.

Physical jobs independently collect only their nominal dependencies. Job completion order does not assign indices. The stable merge then:

1. computes iterative Kosaraju SCCs;
2. orders SCCs dependency first;
3. preserves physical source order inside an SCC;
4. assigns consecutive module-local type indices;
5. builds final field recipes using those indices.

Forward and reverse simulated type-job schedules compare exactly equal. Traversal remains iterative for a chain of 1,024 nominal declarations and for a 512-member recursive group.

A reference to an earlier dependency group is frozen as:

```text
WasmModuleTypeReference(module_type_index)
```

A reference inside the current recursive group is frozen as:

```text
WasmRecursiveTypeReference(group_member_index)
```

The Starshine emitter translates these directly to `TypeIdx::new` and `TypeIdx::rec`. It therefore performs no SCC reconstruction.

## Struct representation

A Dew struct becomes one final WasmGC struct type with source-ordered runtime fields.

- `Bool`, `I32`, and `U32` use `i32` storage.
- `I64` and `U64` use `i64`.
- Floating values retain `f32` or `f64`.
- Nominal references use non-null typed references.
- String, StringView, StringBuilder, Bytes, and BytesBuilder ABI slots use `eqref`; emitted runtime values are distinct structs over shared `array<v128>` chunk storage, with builder mutability kept private until consumption.
- Rigid generic and trait values currently use nullable `eqref` erased slots.
- `Unit` and `Never` fields occupy no physical slot.

Physical fields are immutable because Dew construction initializes every retained slot and field mutation is not yet part of the language.

Generic scalar boxing at an erased `eqref` boundary is not emitted yet. The fragment plan marks the boundary without pretending the final boxing policy is complete.

## Enum representation decision

The implemented enum ABI is now an optimized WasmGC subtype hierarchy:

- one non-final tag-only base per enum;
- one final subtype per distinct exact payload shape within that base;
- direct typed payload fields after the inherited tag prefix;
- direct base allocation for physically empty unit variants.

The earlier tagged-envelope baseline was removed after Node and Wago measurements showed slower execution, a second allocation for payload-bearing values, substantially more runtime allocation work, and no compiler-performance advantage. The historical comparison remains in `docs/research/dual-wasmgc-enum-representations.md`.

A future flat scalar specialization may still be worthwhile for small scalar-only enums, but it must compare against the optimized subtype baseline rather than the retired envelope.

## Callable fragments

Every callable receives one function signature type after all physical GC types. Signature indices therefore satisfy:

```text
signature_type_index = physical_type_count + callable_source_index
```

Function indices obey WebAssembly section ordering:

1. non-inline builtin imports receive the first indices in source order;
2. executable, non-elided top-level and impl functions follow in source order;
3. inline builtins, elided module-visible wrappers, trait requirements, and bodyless impl signatures receive no function index.

A wrapper is directizable only when its frozen body consists of one exact direct call to a recognized inline builtin and forwards every parameter in order. Calls then emit the builtin instruction directly. A module-visible directizable wrapper is elided from `FuncSec` and `CodeSec`; a public wrapper remains materialized to preserve its export ABI.

Trait requirements still retain a Starshine function type for future typed dictionary slots.

`Unit` and `Never` produce no parameter/result slot. Generic and trait ABI values currently use nullable `eqref`; concrete nominal values use non-null typed references. Control-flow joins may temporarily use the common eqref carrier, but module and linked-program body emission applies the frozen final nominal result cast before satisfying an exact aggregate function ABI.

## Starshine emission API

```moonbit
pub fn emit_starshine_type_section(
  PlannedModuleWasmGCFragments,
) -> @lib.TypeSec

pub fn emit_starshine_import_section(
  PlannedModuleWasmGCFragments,
) -> @lib.ImportSec

pub fn emit_starshine_function_section(
  PlannedModuleWasmGCFragments,
) -> @lib.FuncSec

pub fn validate_starshine_type_fragments(
  PlannedModuleWasmGCFragments,
) -> Result[Unit, @validate.ValidationError]

pub fn emit_starshine_code_section(
  PlannedModuleLowering,
  PlannedModuleWasmGCFragments,
) -> Result[@lib.CodeSec, StarshineCodeEmissionError]

pub fn emit_starshine_export_section(
  PlannedModuleWasmGCFragments,
) -> @lib.ExportSec

pub fn emit_starshine_module(
  PlannedModuleLowering,
  PlannedModuleWasmGCFragments,
) -> Result[@lib.Module, StarshineCodeEmissionError]

pub fn emit_starshine_binary(
  PlannedModuleLowering,
  PlannedModuleWasmGCFragments,
) -> Result[Bytes, StarshineBinaryEmissionError]
```

Unrecognized builtin functions import from the reserved runtime module name `dew`. Recognized standard scalar builtins emit native instructions and consume no import/function index. Their declared registry key selects the expansion.

The emitter creates `RecType::group` for multi-member SCCs and self-recursive singleton types. A non-recursive singleton uses `RecType::new`. Starshine validation accepts the emitted mutual-struct, self-recursive, tagged-enum, and complete recursive-Fibonacci modules. The Starshine-encoded Fibonacci module also executes in Node.

## Performance

Release-mode fragment planning:

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| 512-type dependency chain | 182.70 µs | 136.94 µs | 382.66 µs | 692.22 µs |
| One 512-member recursive group | 149.60 µs | 106.21 µs | 267.55 µs | 497.55 µs |
| 256 enum payload variants | 110.19 µs | 73.01 µs | 177.01 µs | 360.35 µs |
| Full pipeline, 256-type chain | 581.01 µs | 526.23 µs | 1.24 ms | 1.84 ms |

Release-mode Starshine type-section construction from an already-frozen plan:

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| 512 singleton dependency groups | 129.78 µs | 42.39 µs | 51.06 µs | 534.80 µs |
| One 512-member recursive group | 95.62 µs | 32.85 µs | 41.73 µs | 465.13 µs |
| 256 enum payload variants | 58.97 µs | 22.59 µs | 30.58 µs | 264.76 µs |

The recursive-group workloads are faster than the equivalent singleton chain because they allocate and merge fewer group records. Starshine construction is cheaper than graph planning on native, WasmGC, and JavaScript; classic Wasm allocation overhead remains comparatively high.

## Remaining work

1. Extend body-local instruction emission beyond the current scalar Fibonacci subset.
2. Emit builtin import adapters when declared and host ABI shapes differ.
3. Emit enum/struct construction, tag tests, payload casts, and field reads.
4. Add generic scalar boxes and shape-specialized generic alternatives.
5. Emit module-value globals and the frozen eager initialization schedule.
6. Add start, name, and custom diagnostic/source-map sections.
7. Remove unreachable signature types after callable reachability is frozen.
8. Extend `dew.std.preamble` across the remaining homogeneous operators and primitive types.
