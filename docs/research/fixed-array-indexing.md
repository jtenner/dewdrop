# FixedArray and trait-extensible indexed mutation

## Status

Implemented for compiler-owned `dew.std.fixed_array` and user-defined indexing traits.

Dew's ambient preamble now declares:

```dew
pub trait IndexedGet<key, value> {
  fn indexed_get(self, key: key) -> value
}

pub trait IndexedSet<key, value> {
  fn indexed_set(self, key: key, value: value) -> Unit
}
```

`container[key]` selects exact `IndexedGet` evidence. `container[key] = value` is parsed as a dedicated block item, lowered to an internal `HirIndexSetExpr`, and selects exact `IndexedSet` evidence. `=` remains absent from the expression precedence table: indexed setting cannot be nested, returned, passed as an argument, or used as a tail value. Receiver, key, and value are evaluated once in that order.

## FixedArray API

`dew.std.fixed_array` defines generic `FixedArray<t>` with:

```dew
FixedArray::make(length: U32, value: t) -> FixedArray<t>
FixedArray<t>.length() -> U32
FixedArray<t>.get(index: U32) -> Option<t>
FixedArray<t>.get_unchecked(index: U32) -> t
FixedArray<t>.set(index: U32, value: t) -> Unit
FixedArray<t>.set_unchecked(index: U32, value: t) -> Unit
```

`get` is the only optional bounds operation. `IndexedGet::indexed_get`, `IndexedSet::indexed_set`, `set`, `get_unchecked`, and `set_unchecked` trap on out-of-bounds indices. WasmGC retains its own array bounds trap even for the operations named `unchecked`; the name means Dew emits no optional-result branch or additional source-level check.

The standard `assert(condition, message)` function remains ambient through `dew.std.preamble` and is used by the runtime collection fixtures.

## Representation

A `FixedArray<t>` value is the carrier WasmGC array itself. There is no outer struct and no `eqref`-typed wrapper field. The compiler selects one of eight exact mutable array types:

```text
packed i8   for I8 and U8
packed i16  for I16 and U16
i32
i64
f32
f64
v128
nullable eqref
```

All four compiler intrinsics are declared in `dew.std.wasm.intrinsics`: `wasm_array_new`, `wasm_array_len`, `wasm_array_get`, and `wasm_array_set`. Each maps directly to a WasmGC array instruction. `wasm_array_get` selects `array.get_s` or `array.get_u` for packed signed or unsigned elements. `dew.std.fixed_array` declares no builtins; its public type, methods, `get` bounds check, and `Option::Some`/`Option::None` construction are ordinary Dew source.

Exact packed carriers are part of the static-link ABI. A Dew `FixedArray<U16>` and a MoonBit mutable `array<i16>` are coalesced to one Core Wasm type during linking, so the call needs no copy adapter and no unsafe reference cast.

## Validation

Coverage includes:

- parser acceptance of indexed setting only as a block item;
- deterministic rejection of non-index setting targets;
- local user-defined `IndexedGet` and `IndexedSet` implementations;
- exact semantic selections and mechanical direct calls;
- stable compiler-owned FixedArray identities;
- static and instance FixedArray method inference;
- packed `i8`/`i16` signed and unsigned reads;
- scalar `i32`, `i64`, `f32`, and `f64` carrier execution;
- reference-carrier construction and mutation;
- direct packed-array type coalescing at a foreign Core Wasm boundary;
- zero-length arrays;
- first/final valid indices;
- alias-visible mutation;
- safe in-range and out-of-range `Option` access;
- Node/Wago differential execution;
- explicit indexed-get and indexed-set array-out-of-bounds traps.

The snapshot harness recognizes `array-out-of-bounds` separately from linear-memory `memory-out-of-bounds`. Wago currently reports GC array bounds failures through generic `builtin.trap executed`, `cast failure`, or `stack fence breached` text depending on the optimized execution path, so the dedicated differential runner normalizes those runtime-specific spellings to the array category. Dew has no source-level cast-trap category yet; this mapping must be split if one is introduced.

## Deferred work

- Enforce the functional dependency `(Self, key) -> value` across all visible `IndexedGet` implementations.
- Add array literals.
- Add compound indexed updates only after place evaluation can be frozen exactly once.
- Benchmark optional `get` construction against trapping/unchecked access.
- Add bulk copy/fill operations. Growable `Array<t>` and iterator integration are implemented and documented in `docs/research/growable-array-iterators.md`.
