# Program-wide WasmGC aggregates

## Status

The static program linker now supports non-generic WasmGC struct types across Dew module boundaries.

Implemented paths include:

- local aggregate declarations in a linked program;
- dependency-owned aggregate parameters and results;
- aggregate fields referencing types from earlier dependency modules;
- imported struct construction;
- imported field access;
- program-wide type-index rebasing;
- `struct.new` and `struct.get` emission;
- external validation and execution in Node;
- transitive reachability through imported aggregate fields and enum payloads;
- deterministic physical SCC merging across module boundaries;
- binary-encodable shared Wasm recursive groups.

Generic aggregate specialization, erased fallback ABIs, enum construction, imported exhaustiveness, nested pattern matching, and mutable collection storage are implemented elsewhere in the compiler.

## Preserving external nominal identity

Module-local Wasm fragment planning previously converted unknown external nominal types to nullable `eqref`. That was sufficient for isolated provisional module planning but discarded information required by a static linker.

The fragment model now preserves exact external identities:

```moonbit
WasmExternalNominalRefStorage(DeclId)
WasmExternalNominalRefValue(DeclId)
```

Local references remain:

```moonbit
WasmNominalRefStorage(WasmModuleTypeReference(local_index))
WasmNominalRefStorage(WasmRecursiveTypeReference(group_index))
WasmNominalRefValue(local_index)
```

This separation lets module-local jobs remain index-independent while the stable program merge decides the final representation.

An important correctness fix accompanied this change: module-local physical dependency discovery now checks `semantic_id_module` before interpreting a declaration's local component. Without that check, two declarations from different modules with the same local ID could create a false local type dependency.

## Program-wide type assignment

`PlannedProgramWasmGCLink` now freezes:

```text
ModuleId -> manifest module index
DeclId   -> final Wasm type index
DeclId   -> final Wasm function index
```

For acyclic links, each module receives a stable type base in dependency-SCC order and a local reference is rebased mechanically:

```text
global_type_index = module_type_base + local_type_index
```

An external reference uses the exact imported `DeclId` to look up the dependency's final type index. This fast path preserves all established acyclic snapshots.

If an external physical reference would point forward, the linker instead builds one deterministic graph over every reachable physical type. Local module references, local recursive references, imported nominal fields, and enum subtype bases become dependency edges. Iterative Kosaraju SCC discovery produces dependency-first components with stable member order. Every module-local physical index then maps through a frozen `module_type_indices` table rather than assuming module contiguity.

## Program-wide recursive groups

Cross-module type SCCs such as:

```text
module a: struct A { b: B }
module b: struct B { a: A }
```

now emit one shared Wasm recursive group. The linker first closes reachable nominal roots transitively through struct fields and enum tuple/struct payloads, ensuring that a signature-reachable `A` also retains dependency-owned `B`.

Physical SCCs are emitted before callable signatures only on this cross-module path. This permits every type in a shared group to occupy a contiguous final type-index range while leaving the established acyclic layout unchanged.

Starshine's relative `TypeIdx::rec` representation validates WAT-level recursive references but its binary encoder intentionally rejects that internal form. Shared program groups therefore encode field and subtype references with their final type-section indices, which WebAssembly permits inside the surrounding recursive group. Missing imported physical types still produce `MissingProgramType`; `UnsupportedProgramForwardTypeReference` has been removed.

## Imported aggregate semantic evidence

`ResolvedModuleImports` now includes translated fields:

```moonbit
pub struct ResolvedImportedField {
  field : FieldId
  declaration : DeclId
  variant : VariantId?
  name : String
  type_ : ResolvedTypeId
}
```

Fields are grouped by exact owner declaration. Their type recipes are imported lazily into the consumer's resolved-type arena.

Body inference now supports dependency-owned structs in:

- explicit construction expressions;
- expected-type-driven object expressions;
- field access;
- nested direct calls.

Selections preserve exact external identities:

```moonbit
StructConstructionSelection(external_decl, type_arguments)
FieldAccessSelection(external_field)
```

Local declarations still take precedence during name lookup.

## Struct ABI and emission

The initial physical struct ABI remains:

- immutable WasmGC struct;
- source-ordered physical fields;
- scalar fields remain unboxed;
- nominal fields use typed non-null references;
- `Unit` and `Never` consume no slot.

Program code emission now handles:

```moonbit
PlannedStructNew(DeclId, type_arguments, fields)
PlannedFieldGet(FieldId, base)
```

Construction emits field values in physical declaration order followed by:

```text
struct.new <final-type-index>
```

Field access emits:

```text
struct.get <final-type-index> <physical-field-index>
```

The owning module is derived from the packed `FieldId` or `DeclId`, then resolved through one frozen `ModuleId -> module index` table. Per-field and per-type owner maps were deliberately removed.

## Generic aggregate boundary

Generic aggregate layouts still use rigid generic/`eqref` recipes and do not have a frozen scalar specialization or boxing policy.

The linker therefore emits:

```moonbit
UnsupportedProgramGenericType(ModuleId, DeclId)
```

rather than constructing an invalid scalar-to-`eqref` ABI.

## Field-order optimization

Source construction fields may appear in any order, while `struct.new` operands must follow physical declaration order.

The initial emitter found every physical field by rescanning the source field list, making wide construction quadratic.

The optimized strategy is:

- at most eight physical fields: allocation-free linear scans;
- more than eight fields: build one temporary `FieldId -> ExprId` map, then emit in physical order.

This preserves low overhead for common small structs and linear behavior for wide generated records.

## Benchmark evidence

All measurements use native release mode and `@bench.T`.

### Stable aggregate merge

The rejected aggregate baseline, which only produced diagnostics, measured:

```text
51.65 us, 64 modules
```

After initial aggregate support and owner maps:

```text
62.54 us
```

Moving external-reference discovery into fragment planning had only a small effect:

```text
61.86 us
```

Replacing per-type and per-field owner maps with packed-ID ownership plus one module lookup reduced the controlled measurement to:

```text
54.63 us
```

That is approximately 12.6% lower than the first supported implementation and approximately 5.8% above the old diagnostic-only baseline.

A later full benchmark sweep measured 59.18 us, showing the expected machine-noise range for these short workloads. The adjacent before/after runs are the more useful optimization evidence.

### Wide imported construction

A complete two-module pipeline with a dependency-owned 32-field struct measured:

```text
266.20 us
```

After the thresholded field-order lookup:

```text
252.12 us
```

This is approximately a 5.3% reduction in the controlled adjacent run. A later full-suite sweep measured 269.39 us, again reflecting host noise rather than a semantic change.

### Final full benchmark sweep

| Workload | Mean |
|---|---:|
| Scalar module fragment planning, 64 modules | 179.75 us |
| Scalar stable link merge, 64 modules | 52.28 us |
| Scalar module emission, 64 modules | 150.28 us |
| Scalar validated binary emission, 64 modules | 3.84 ms |
| Aggregate stable link merge, 64 modules | 59.18 us |
| Aggregate module emission, 64 modules | 176.16 us |
| Imported 32-field struct full pipeline | 269.39 us |
| Full scalar semantic/backend pipeline, 32 modules | 3.42 ms |

The scalar stable merge remains effectively unchanged from the earlier 51.92 us result, so aggregate support did not materially regress scalar linking.

## Validation

Tests cover:

- program-wide physical type indices;
- dependency-owned aggregate function signatures;
- external aggregate fields;
- cross-module recursive physical SCC assignment and binary emission;
- imported struct construction selection;
- imported field selection;
- source fields emitted in physical declaration order;
- complete Starshine module validation;
- complete binary encoding.

An integration smoke test compiled a consumer that allocated a dependency-owned `Item`, passed it through linked functions, and read its field. The compiler validated the complete module through Starshine before Starshine encoding. Node instantiated the resulting binary and returned:

```text
run(21) = 21
```

The temporary dump harness and binary were removed after the integration test.

## Next dependencies

1. Define generic aggregate specialization, boxing, erased fallbacks, and adapters.
2. Diagnose structural overlap between independently imported and local/imported implementation evidence.
3. Revisit enum type flattening and control-flow optimization in the deterministic optimization pipeline.
4. Add resource budgets and retained-allocation measurements for program-wide physical SCC planning.
