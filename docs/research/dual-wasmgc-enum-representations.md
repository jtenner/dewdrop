# Dual WasmGC enum representations

## Historical status

This document records the completed comparison that led to removing tagged envelopes. Dew no longer retains two production representations.

The active compiler emits only optimized subtype families:

```text
one non-final tag-only base per enum
one final subtype per distinct exact payload shape within that base
unit variants map directly to the base
```

`WasmEnumRepresentation`, `TaggedEnvelopeEnumRepresentation`, `AutomaticEnumRepresentation`, envelope physical types, and envelope-specific construction/matching code have been deleted.

The `_with_options` planning APIs remain only to compare distinct versus exact-shared subtype planning and linear versus dense dispatch. Representation state does not enter parsing, HIR, name resolution, inference, flow analysis, or backend-neutral lowering.

The remaining sections are historical descriptions and measurements of the retired comparison implementation.

## Tagged-envelope representation

The envelope root remains:

```text
struct EnumEnvelope {
  tag: i32
  payload: ref null eq
}
```

Every non-empty payload-bearing variant has one distinct typed payload struct. Unit and physically empty variants store `ref.null eq`.

Construction therefore requires:

- one envelope allocation for unit variants;
- one payload allocation plus one envelope allocation for payload variants.

Matching reads the envelope tag, loads the erased payload reference, casts it to the exact payload type, then extracts fields.

## Subtype-family representation

Every enum receives one non-final base type:

```text
struct EnumBase {
  tag: i32
}
```

Every source variant receives one final subtype. The inherited tag prefix is repeated in the physical struct definition, followed by the variant payload fields.

Examples:

```text
None  -> final subtype EnumBase(tag)
Some  -> final subtype EnumBase(tag, value)
Move  -> final subtype EnumBase(tag, x, y)
```

All values flow through the enum ABI as a non-null reference to the base type.

Construction requires one allocation for every variant. Matching reads the base tag, casts the enum value itself to the exact variant subtype, then extracts fields directly.

## Compact metadata

Module fragments freeze:

```moonbit
enum_representation
variant_declarations
variant_tags
payload_type_index_by_variant
field_names
```

Packed `VariantId` and `FieldId` values derive the owner module and local metadata slot. No program-wide variant owner map is built.

`payload_type_index_by_variant` is representation-neutral in practice:

- envelope mode: exact payload struct index;
- subtype mode: exact final variant subtype index.

The source enum declaration continues to map to the envelope or base type through `type_index_by_declaration`.

## Type dependency planning

Subtype types add an explicit physical dependency on their enum base. The base therefore receives an earlier type index and can be named as the subtype's declared supertype.

Payload field dependencies remain unchanged. A recursive source enum often becomes physically less recursive because payload fields can refer to the already-defined enum base rather than to a payload envelope cycle.

Starshine emission uses explicit subtype metadata:

```moonbit
@lib.SubType::new(false, [], base_struct)
@lib.SubType::new(true, [base_type], variant_struct)
```

Starshine validation confirmed that the first form is non-final and the second form is a final subtype with the declared base.

## Imported pattern evidence

Imported unit, tuple, and struct variant patterns retain exact external `VariantId` values. Pattern instantiation now uses imported generic-parameter and nominal-type recipes instead of assuming every constructor belongs to the consumer module.

Imported named payload fields are resolved through frozen imported field recipes. A dedicated diagnostic retains missing imported field names without mutating the consumer name interner:

```moonbit
MissingImportedPatternField(String, PatternId, UInt64)
```

Imported enum coverage currently remains conservative. Flow analysis treats imported nominal coverage as open rather than claiming exhaustive knowledge without the import interface. This does not prevent lowering or execution; imported-interface-aware exhaustiveness is a later semantic refinement.

## Match lowering

`PlannedMatchExpression` remains representation-neutral.

The initial executable match emitter:

1. evaluates the scrutinee once;
2. stores it in one nullable `eqref` scratch local;
3. reads the enum base/envelope tag;
4. compares tags in source arm order;
5. casts to the exact payload or subtype type;
6. extracts direct tuple or named struct payload bindings;
7. initializes pattern locals;
8. evaluates guards;
9. evaluates the selected arm body;
10. traps through `unreachable` if no arm succeeds.

The scratch local prevents repeated or side-effecting scrutinee evaluation. Casts restore exact nominal types before `struct.get`.

Supported executable pattern forms include:

- unit variants;
- tuple variants with direct binding, wildcard, or rest children;
- struct variants with direct named bindings and rest;
- wildcard and binding catch-all arms;
- guards;
- imported variants and fields.

Nested destructuring and alternative-pattern code generation are implemented. A later bounded tranche now scalarizes proven private body-local unit-only enum values; broader parameter/result and payload representation specialization remains measurement-driven roadmap work.

## Deliberately unoptimized control flow

Matches currently emit a simple source-ordered nested-if chain.

For guarded arms, the remaining fallback chain may appear in both the tag-mismatch and guard-false paths. This can duplicate emitted instruction trees. The behavior is correct and deterministic, but not yet compact.

The duplication is intentionally retained until the full pipeline is assembled. Later IR optimization candidates include:

- shared continuation blocks;
- `br_table` tag dispatch;
- guard continuation factoring;
- redundant cast elimination;
- scratch-local lifetime coalescing;
- payload-load common-subexpression elimination;
- dead fallback removal after frozen exhaustiveness;
- variant shape flattening and type interning.

## Compiler performance

Native release `@bench.T` measurements:

| Workload | Tagged envelope | Subtype family |
|---|---:|---:|
| Stable link merge, 64 enum modules | 56.14 us | 57.97 us |
| Module emission, 32 tuple variants | 9.56 us | 11.28 us |
| Module emission, 32-field struct variant | 10.01 us | 9.66 us |
| Full construction pipeline, 32 tuple variants | 255.14 us | 265.01 us |
| Guarded imported match emission | 6.91 us | 6.93 us |
| Guarded imported match full pipeline | 225.54 us | 226.63 us |

Subtype planning and type emission are somewhat more expensive for many unit/payload variants because every source variant receives a physical subtype. Match emission itself is effectively equal in the current small workload.

A later full 20-workload sweep measured the same relative behavior under a noisier host load:

| Workload | Tagged envelope | Subtype family |
|---|---:|---:|
| Stable enum merge, 64 modules | 57.86 us | 59.14 us |
| Tuple-enum module emission, 32 variants | 9.91 us | 11.77 us |
| Struct-variant module emission, 32 fields | 10.25 us | 9.97 us |
| Guarded match emission | 7.34 us | 7.36 us |
| Guarded match full pipeline | 244.05 us | 246.07 us |
| Construction full pipeline, 32 variants | 282.29 us | 291.57 us |

The adjacent targeted runs remain the cleaner representation comparison; the full sweep confirms that scalar and aggregate workloads remain operational while showing expected machine-wide timing drift.

## Binary and runtime smoke evidence

The same imported guarded `OptionI32` construct-and-match program was compiled through both complete paths. Each module passed Starshine validation before Starshine binary encoding.

Encoded sizes were:

```text
tagged envelope: 359 bytes
subtype family:  346 bytes
```

Binary size is not an optimization objective, but the initial subtype module was not larger for this workload.

Node executed both binaries correctly:

```text
enum-envelope-smoke.wasm: run(21) = 21
enum-subtype-smoke.wasm:  run(21) = 21
```

A provisional host-call microbenchmark used five million exported `run` calls per round, alternating execution order after warmup. The function constructs `Some(value)`, performs a guarded match, extracts the payload, and returns it.

Observed ranges:

```text
tagged envelope: approximately 10.07-10.61 ns/call
subtype family:  approximately  8.27- 8.40 ns/call
```

This suggests an approximately 18-21% advantage for the subtype representation in this V8 workload. The result includes JavaScript-to-Wasm call overhead and is not a substitute for Wago-native server benchmarks, but the repeated alternating result is consistent with eliminating one allocation and one payload indirection.

Temporary binaries and native dump stubs were removed after the measurements.

## Runtime target

The local Wago `wasm3` branch is now integrated through the reusable harness under `tools/wago-enum-bench/`. It measures cold compilation, instantiation, execution, Go allocation volume, and encoded bytes with WebAssembly 3.0 features enabled explicitly.

The Wago branch currently runs general generated WasmGC code with a bounded, collection-disabled throughput heap until native frame roots are available at every helper safepoint. The harness therefore configures an explicit heap and preserves exhaustion as a visible failure.

## Implemented optimization follow-up

The comparison phase was followed by exact subtype-shape sharing, unit-base reuse, recursive exact-shape reuse, dense dispatch, and shared match continuations. Automatic representation selection and envelope-specific cross-enum sharing were then deleted with the envelope implementation.

The distinct-subtype baseline remains available only as a controlled measurement option. Implementation details and updated compiler/Wago measurements are recorded in `docs/research/enum-layout-dispatch-optimization.md`.
