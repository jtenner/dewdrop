# Runtime type layout plans

## Status

Implemented as deterministic backend-neutral recipes for nominal structs and enums. These recipes are embedded in `PlannedModuleLowering` and consumed by optimized subtype-family recursive-group planning described in `docs/research/deterministic-starshine-fragments.md`.

## API

```moonbit
pub fn plan_module_type_layouts(
  CollectedModule,
  ResolvedModuleTypes,
) -> PlannedModuleTypeLayouts
```

`PlannedModuleTypeLayouts::layout_of` performs stable declaration-identity lookup without hash-map iteration or allocation-address identity.

## Struct layouts

Every nominal struct layout retains:

- exact `DeclId`;
- declaration generic-parameter span;
- source offset;
- source-ordered contiguous field span.

Each field recipe retains exact `FieldId`, owning declaration, optional owning variant, zero-based source-order index, normalized `ResolvedTypeId`, backend value shape, and source offset.

Generic field types remain rigid generic recipes with `GenericPlannedValueShape`. Concrete scalar and reference fields receive the same shape classification used by expression lowering.

## Enum layouts

Every enum layout retains its exact declaration and source-ordered variant span. Variants receive deterministic zero-based tags in declaration order.

Payload recipes distinguish:

- unit variants;
- tuple variants with flat normalized type and shape spans;
- struct variants with exact contiguous `FieldId` layout spans.

Struct-variant field indices restart at zero for each variant. Tuple payload positions remain source ordered. Generic payload types are preserved rather than prematurely erased or monomorphized.

The semantic recipe deliberately remains independent of physical representation. The Starshine backend now consumes it as one non-final enum base plus exact-shared direct-payload subtypes, with physically empty unit variants mapped to the base.

## Determinism and complexity

Collection already emits declaration and immediate payload members contiguously. Layout planning verifies variant-field contiguity and builds declaration/variant spans with linear scans. No backend indices, allocation addresses, or map iteration order enter the output.

The implementation remains iterative for at least 1,024 enum variants. Empty structs and enums use zero-length spans without per-layout empty arrays.

## Performance

Release-mode measurements:

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| 512 generic structs / 1,024 fields | 46.19 µs | 24.97 µs | 74.92 µs | 191.74 µs |
| 1,024 mixed enum variants | 64.53 µs | 35.81 µs | 76.40 µs | 290.85 µs |
| Collect, resolve, and layout 256 structs | 545.33 µs | 537.95 µs | 861.89 µs | 2.11 ms |

## Remaining work

1. Benchmark flat scalar-enum specialization against the optimized subtype baseline.
2. Define generic ABI-shape specialization and erased fallback layouts.
3. Add scalar boxes, trait-object dictionaries, closures, and module-value global layouts.
4. Merge cross-module recursive physical type SCCs while preserving stable identities.
5. Extend construction and matching to nested and alternative patterns.
