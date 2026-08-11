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

A `FixedArray<t>` value is one compiler-owned nominal WasmGC wrapper containing its carrier array as nullable `eqref`. The backing array is selected statically from six unboxed physical families:

```text
i32
 i64
 f32
 f64
 v128
 nullable eqref
```

The wrapper keeps one stable nominal identity while scalar elements remain unboxed. Compiler-known make/get/set operations cast the private backing reference to the selected carrier array before using `array.new`, `array.len`, `array.get`, or `array.set`.

`get` evaluates the receiver and index once, checks the exact fixed backing length, and constructs `Option::Some` using the existing erased generic-enum carrier field or `Option::None` without reading the array. Indexed get and set lower directly to trapping WasmGC operations.

## Validation

Coverage includes:

- parser acceptance of indexed setting only as a block item;
- deterministic rejection of non-index setting targets;
- local user-defined `IndexedGet` and `IndexedSet` implementations;
- exact semantic selections and mechanical direct calls;
- stable compiler-owned FixedArray identities;
- static and instance FixedArray method inference;
- scalar `i32`, `i64`, `f32`, and `f64` carrier execution;
- reference-carrier construction and mutation;
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
