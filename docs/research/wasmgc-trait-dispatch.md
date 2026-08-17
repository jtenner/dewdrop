# WasmGC trait dispatch strategy

Date: 2026-07-28

## Requirements

- Statically selected methods should compile to direct calls.
- Dynamic trait-object calls need runtime method selection.
- Primitive values should remain unboxed outside explicit type-erasure boundaries.
- Generated Wasm size should remain controlled.

## Relevant backend support

The pinned `starshine-mb/` submodule supports all of the relevant low-level mechanisms:

- `Instruction::call_ref` and `Instruction::return_call_ref` in `starshine-mb/src/lib/types.mbt`.
- `hot_build_call_ref` and `hot_build_return_call_ref` in `starshine-mb/src/ir/hot_builders.mbt`.
- `Instruction::struct_get` in `starshine-mb/src/lib/types.mbt`.
- `call_indirect` and `br_table` are also represented and lowered by Starshine.

The WebAssembly core specification defines `call_ref` as invoking a typed function reference operand. It defines `call_indirect` in terms of a table lookup, a reference cast, and `call_ref`.

Official references:

- https://webassembly.github.io/spec/core/bikeshed/index.html
- https://webassembly.github.io/gc/core/syntax/instructions.html

## Recommended default

Use direct calls whenever semantic analysis selects a concrete method. For a dynamic trait object, use an immutable per-implementation dictionary/vtable represented as a WasmGC struct whose method fields are typed function references.

Conceptually:

```text
TraitVTable = struct {
  method_0: ref Method0Signature
  method_1: ref Method1Signature
}

TraitObject = {
  receiver
  vtable: ref TraitVTable
}
```

Dynamic dispatch becomes:

1. Load the dictionary/vtable reference.
2. Load the typed function reference with `struct.get`.
3. Invoke it with `call_ref`.

Store the implementation function directly when its ABI already matches the trait slot. Generate a trampoline only when receiver casting or ABI adaptation is required.

## Why not `br_table` by default?

A `br_table` dispatcher requires an explicit implementation discriminator and a centralized branch body. It couples all implementations to one dispatch function and may increase code size as implementations grow. It can remain an optimization for small sealed implementation sets if benchmarks show an advantage, but it should not define trait-object semantics.

## Primitive trait objects

WebAssembly `anyref` abbreviates a nullable reference to the `any` heap type; numeric and vector types are separate value types and are not references. Therefore, a trait-object payload represented as `(ref any)` cannot directly contain `i32`, `i64`, `f32`, `f64`, or `v128` values.

Recommended policy:

- Keep scalar receivers unboxed for statically selected calls.
- Keep scalars unboxed in generic dictionary calls by specializing generic ABIs by Wasm representation shape.
- Allocate a small WasmGC scalar box only when a value actually crosses into an erased runtime trait-object representation.
- Use a non-null `(ref any)` payload after successful coercion.
- Let directization plus escape analysis/scalar replacement remove temporary boxes that do not escape.

Directizing only the eventual call is insufficient if a trait object has already escaped into an array, field, return value, closure, or unknown call. In those cases the box is semantically required by the chosen uniform representation.

WebAssembly also provides `i31ref`, which can carry a 31-bit integer in the reference hierarchy. This can be a later optimization for values whose semantics fit 31 bits, but it is not a transparent representation for full-width Dew `I32` or `I64` values.

Potential semantic issues to settle include mutation of boxed scalar receivers, whether trait-object reference identity is observable, and whether coercion to an allocation-producing erased trait object is implicit or explicit.
