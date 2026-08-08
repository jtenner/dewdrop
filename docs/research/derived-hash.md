# Derived hashing

## Surface and prerequisites

Structs and enums may request postfix `derive(Hash)`. Expansion synthesizes one
ordinary implementation of the ambient trait:

```dew
trait Hash {
  fn hash(self) -> U64
  fn hash_eq(self, right: Self) -> Bool
}
```

For a generic nominal, every owner parameter referenced anywhere in a field or
variant payload type gains one `Hash` prerequisite unless that bound is already
present. Source-declared bounds are preserved and phantom parameters remain
unconstrained. Concrete field and payload types are checked by ordinary method
selection while inferring the generated bodies. Missing evidence therefore
remains visible at the exact `Hash` derive-request offset.

## Deterministic algorithm

A struct starts from the 64-bit FNV offset basis
`14695981039346656037`. Each field is visited in source order and mixed as:

```text
state = (state xor field.hash()) * 1099511628211
```

Arithmetic uses Dew's ordinary wrapping `U64` operations. An enum first mixes
its zero-based source variant ordinal and then mixes tuple or named payloads in
source order. Variant names and field names do not enter the runtime hash.

`hash_eq` is structural and collision-safe. Struct fields call their selected
`Hash.hash_eq` methods in source order with short-circuiting `&&`. Enum values
must select the same variant before payload equality is tested. Consequently the
derived implementation preserves the required contract that values accepted by
`hash_eq` produce the same derived hash, assuming each field implementation
satisfies that contract.

## Compiler path

The parser owns the synthetic implementation factory. Generated methods pass
through normal collection, trait signature checking, coherence, generic-body
symbolic evidence selection, recursive evidence freezing, evidence-aware
specialization, reachability, lowering, and WasmGC emission. There is no
Map-specific or backend-only derived-hash path.

## Performance and size

A release-native collection benchmark on August 8, 2026 measured 128 one-field
structs with `derive(Hash)` at 589.79 us ± 19.71 us. The nested generic struct and
enum runtime fixture is 685 WAT lines and 17,219 bytes. These are development
observations rather than regression budgets.

## Validation

Coverage includes generic and non-generic structs, unit/tuple/named enum
variants, nested derived values, deterministic hash equality, unequal values,
variant discrimination, field-referenced generic prerequisites, phantom
parameters, missing concrete field evidence, deterministic WAT, and identical
Node/Wago execution.
