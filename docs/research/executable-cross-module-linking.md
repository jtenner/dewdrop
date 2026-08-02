# Executable cross-module static linking

## Status

Dew can now compile scalar functions from multiple Dew modules into one validated and executable Wasm module. Imported direct calls retain their external `DeclId` through inference, lowering, program-wide index assignment, and Starshine instruction emission.

The linker now supports non-generic structs plus the sole optimized subtype-family enum ABI, including dependency-owned construction and matching. It still rejects cross-module recursive type groups and unspecialized generic calls rather than prematurely fixing those ABIs.

## Why one static Wasm module

The initial backend statically combines Dew modules instead of emitting one Wasm instance per Dew module.

This provides:

- native direct Wasm calls between Dew modules;
- one deterministic function-index space;
- no host-side module wiring;
- no cross-instance WasmGC reference ABI;
- support for forward calls and mutually recursive module SCCs;
- one export policy controlled by a selected root Dew module.

Separate binary modules and dynamic linking remain possible later, after the public ABI is stable.

## Backend-neutral program lowering

`plan_program_lowering` runs the existing module lowering phases in dependency-SCC order:

```moonbit
pub fn plan_program_lowering(
  CollectedProgram,
  AnalyzedProgramSemantics,
) -> PlannedProgramLowering
```

Each module still owns its independent immutable lowering plan. Final module slots remain manifest indexed.

The program phase does not repeat type inference, body name resolution, dispatch selection, flow analysis, or initialization analysis.

## Fragment jobs and stable merge

Program Wasm planning is split into two explicit phases:

```moonbit
pub fn plan_program_wasmgc_fragments(
  AnalyzedProgramSemantics,
  PlannedProgramLowering,
) -> PlannedProgramWasmGCFragments

pub fn link_program_wasmgc_fragments(
  PlannedProgramWasmGCFragments,
  PlannedProgramLowering,
  root_module_index : Int,
) -> PlannedProgramWasmGCLink
```

The convenience wrapper is:

```moonbit
pub fn plan_program_wasmgc_link(
  AnalyzedProgramSemantics,
  PlannedProgramLowering,
  root_module_index : Int,
) -> PlannedProgramWasmGCLink
```

Module-local fragment jobs never assign final program indices. The stable merge owns all final type/function index assignment.

## Deterministic order

Program functions are visited in:

1. dependency-SCC order;
2. manifest order inside one SCC;
3. source callable order inside one module.

Final Wasm function indices preserve the Wasm import-prefix rule:

1. non-inline runtime builtin imports;
2. non-elided Dew definitions in deterministic program order.

A single frozen map provides:

```text
DeclId -> PlannedProgramWasmFunction -> final function index
```

Code emission performs no module graph traversal and no declaration scan.

## Direct builtins and wrapper elision

Every module retains its local preamble declarations and directization evidence.

Program linking preserves the existing behavior:

- recognized inline builtins consume no function index;
- calls to directizable wrappers expand to native Wasm instructions;
- module-visible trivial wrappers remain elided;
- public wrappers remain materialized so they can preserve an export ABI;
- calls across Dew module boundaries use final program function indices.

## Root exports

Only public functions from the selected root module are exported.

Dependency functions are linked definitions and remain callable internally, but they do not become Wasm exports merely because they are public in their Dew module. This avoids export-name collisions and preserves the distinction between a Dew module interface and the final program entry surface.

## Backend APIs

```moonbit
pub fn emit_starshine_program_module(
  PlannedProgramLowering,
  PlannedProgramWasmGCLink,
) -> Result[@lib.Module, StarshineCodeEmissionError]

pub fn emit_starshine_program_binary(
  PlannedProgramLowering,
  PlannedProgramWasmGCLink,
) -> Result[Bytes, StarshineProgramBinaryEmissionError]
```

The emitter constructs:

- one function-signature type section;
- one runtime import section;
- one function section;
- root-only exports;
- one code section ordered by final function index.

It consumes frozen program evidence mechanically.

## Diagnostics and initial restrictions

The link plan publishes deterministic diagnostics for unsupported boundaries and missing evidence, including:

```moonbit
MissingProgramType(ModuleId, DeclId)
UnsupportedProgramForwardTypeReference(ModuleId, DeclId)
UnsupportedProgramGenericType(ModuleId, DeclId)
UnsupportedProgramGenericCall(ModuleId, DeclId, UInt64)
MissingProgramFunction(ModuleId, DeclId, UInt64)
```

Local and dependency-directed aggregate types are rebased into the program type section. Cross-module recursive type SCCs remain rejected until physical types from multiple modules can be merged into one recursive group.

Generic calls are rejected because the current callable ABI uses an erased `eqref` generic boundary and no scalar specialization plan has been frozen. Emitting an `I32` instantiation against that erased signature would be invalid Wasm.

## Tests

Coverage includes:

- dependency-first function indices;
- exact external `DeclId` preservation in lowering;
- mutually recursive module SCCs and forward calls;
- root-only exports;
- aggregate-link diagnostics;
- unspecialized generic-call diagnostics;
- complete Starshine module validation;
- complete binary encoding.

An integration smoke test validated the complete module through Starshine, encoded it through Starshine, and instantiated the resulting binary in Node. The linked root export returned:

```text
run(21) = 42
```

## Benchmarks

All measurements use native release mode and `@bench.T`.

### First implementation

| Workload | Mean |
|---|---:|
| Combined fragment planning and stable link, 64 modules | 330.19 us |
| Program module emission, 64 modules | 215.64 us |
| Validated binary emission, 64 modules | 5.33 ms |
| Full semantic/backend pipeline, 32 modules | 5.35 ms |

### Final split-phase implementation

| Workload | Mean |
|---|---:|
| Module-local fragment planning, 64 modules | 173.29 us |
| Stable program link merge, 64 modules | 51.92 us |
| Program module emission, 64 modules | 155.27 us |
| Validated binary emission, 64 modules | 3.87 ms |
| Full semantic/backend pipeline, 32 modules | 3.44 ms |

Fragment planning plus stable merge totals approximately 225.21 us, about 31.8% lower than the first combined measurement. Module emission improved by approximately 28.0%, binary emission by approximately 27.4%, and the measured full pipeline by approximately 35.7%.

The split also clarifies future parallelism: module-local fragment jobs can run independently, while only the small stable merge assigns final indices.

## Next dependencies

The next executable linker milestones are:

1. extend matching to nested and alternative patterns;
2. merge cross-module physical type SCCs into recursive groups;
3. merge imported impl evidence into coherence and dispatch;
4. define generic scalar/aggregate specialization and erased fallback ABIs;
5. emit imported module values and a cross-module initialization schedule;
6. expose the program pipeline through the compiler driver.
