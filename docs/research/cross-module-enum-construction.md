# Cross-module enum construction

## Scope

This phase added frozen imported enum evidence and executable non-generic enum construction. Match lowering and a second subtype-family representation are now implemented and documented in `docs/research/dual-wasmgc-enum-representations.md`.

Supported construction forms are:

```dew
Message::Idle
Message::Number(value)
Message::Move {
  x: x
  y: y
}
```

The enum declaration and variants may be owned by an imported dependency module.

## Frozen imported evidence

`ResolvedModuleImports` now stores consumer-local imported variant recipes:

```moonbit
pub struct ResolvedImportedVariant {
  variant : VariantId
  declaration : DeclId
  kind : CollectedVariantKind
  name : String
  payload_types : HirSpan
}
```

The accompanying flat arenas are:

```moonbit
variants : Array[ResolvedImportedVariant]
variant_payload_types : Array[ResolvedTypeId]
variant_spans : Map[DeclId, HirSpan]
```

Payload type recipes are translated lazily through `InterfaceTypeImporter`. Exact external `VariantId` and `DeclId` values remain unchanged.

Variants are grouped by owner declaration. Import construction walks the frozen source-ordered variant stream once with a cursor rather than rescanning every variant for every exported enum. This avoids quadratic behavior in interfaces containing many enums.

## Inference

Qualified construction first resolves the imported type declaration through the existing type namespace. Variant lookup then uses the declaration-local imported variant span.

The three construction paths validate:

- unit payload kind;
- tuple payload kind and arity;
- struct payload kind, field names, duplicates, omissions, and field types.

Selections reuse the existing immutable evidence:

```moonbit
UnitVariantValueSelection(VariantId, type_arguments)
VariantConstructionSelection(VariantId, type_arguments)
```

No foreign-expression wrapper or backend-specific identity is introduced.

## Compact fragment metadata

Program emission needs the enum declaration and source-order tag even for unit variants, which have no payload physical type.

A global `VariantId` map would duplicate ownership already encoded in packed IDs. Instead every module fragment freezes compact local arrays:

```moonbit
variant_declarations : Array[DeclId]
variant_tags : Array[Int]
payload_type_index_by_variant : Array[Int]
```

Emission derives the owner module from `semantic_id_module(variant)`, resolves that module through the existing program module lookup, then indexes these arrays with `semantic_id_local(variant)`.

This keeps final program linking free of per-variant hash-map insertion.

## Physical representation

The active representation is one optimized subtype family per enum:

```text
non-final EnumBase {
  tag: i32
}

final VariantSubtype <: EnumBase {
  tag: i32
  ...direct payload fields
}
```

### Unit variant

Physically empty unit variants reuse the base directly:

```text
i32.const <tag>
struct.new <base-type>
```

### Tuple variant

Physical tuple fields are emitted according to `WasmTuplePayloadField(variant, source_index)`. Fields whose Dew shape consumes no Wasm slot are omitted by the physical plan.

Emission produces one allocation:

```text
i32.const <tag>
<payload operands>
struct.new <variant-subtype>
```

### Struct-style variant

Named fields are reordered into physical declaration order before the single subtype allocation. The same threshold policy used by ordinary structs applies:

- at most eight physical fields: allocation-free scans;
- more than eight fields: one temporary `FieldId -> ExprId` map.

## Determinism

The phase preserves deterministic ordering at every boundary:

- interface variants remain in source order;
- translated variants remain grouped by declaration and source order;
- source-order tags are frozen in layout planning;
- payload types retain module-local physical indices;
- the program merge rebases them by dependency-SCC and manifest order;
- construction operands follow physical field order;
- no identity depends on allocation addresses or map iteration.

## Validation

Tests cover:

- imported unit variant selection;
- imported tuple variant selection;
- imported struct-style variant selection;
- exact external variant IDs;
- wide imported enum interfaces;
- dependency-owned enum base and subtype indices;
- source fields reordered for struct payloads;
- complete Starshine validation;
- Starshine binary encoding.

Starshine remains the sole compiler-side Wasm validator.

## Performance

Native release `@bench.T` measurements:

| Workload | Mean |
|---|---:|
| Stable enum link merge, 64 modules | 55.61 us |
| Imported tuple enum module emission, 32 payload variants | 9.35 us |
| Imported struct-variant module emission, 32 fields | 9.99 us |
| Imported enum full pipeline, 32 payload variants | 262.18 us |
| Imported enum evidence, 64 enums x 8 variants | 21.98 us |

The stable-link baseline before adding construction metadata was 56.84 us. The post-change 55.61 us result is within normal host variance and shows no serial-link regression.

The first imported enum full-pipeline measurement was 257.69 us. Subsequent measurements ranged from approximately 257 to 263 us, so the source-ordered import cursor cannot be evaluated from the one-enum workload. The dedicated 512-variant evidence workload measures the resulting linear path directly at 21.98 us.

## Remaining boundary

Direct unit, tuple, and struct-variant matching, payload binding, catch-all arms, and guards are executable in both physical representations. Remaining pattern/backend work includes nested destructuring, alternative-pattern code generation, imported-interface-aware exhaustiveness, dense tag dispatch, and control-flow optimization.
