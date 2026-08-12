# Iterator combinators

## Status

Implemented on August 12, 2026.

## Surface

`dew.std.iter` provides five eager consuming helpers over the minimal ambient
`Iter<t>` protocol:

- `iter_for_each(iter, action) -> Unit`
- `iter_fold(iter, initial, folder) -> state`
- `iter_any(iter, predicate) -> Bool`
- `iter_all(iter, predicate) -> Bool`
- `iter_find(iter, predicate) -> Option<t>`

The module introduces no new ambient evidence. Each helper advances the supplied
mutable iterator directly, performs no collection allocation, and preserves the
iterator implementation's traversal order. `any`, `all`, and `find` short-circuit;
the iterator remains positioned immediately after the decisive element.

## Backend findings

The first end-to-end fixture exposed two existing generic-control gaps rather
than an iterator-library representation issue:

1. generic `ArrayIter<t>.has_next()` bodies did not reserve the reference scratch
   local required by the array runtime emitter;
2. functional-loop state and result locals were allocated from unspecialized
   `GenericPlannedValueShape` values, so scalar specializations could receive an
   `eqref` local and fail Wasm validation.

The backend now reserves iterator scratch for both `has_next` and `next`, and
specializes functional-loop state/result shapes before selecting physical local
types. The library uses catchall exhausted arms because Bool catchall lowering is
the established total functional-loop form; iterator exhaustion remains checked
through `has_next`, so `next` retains its deterministic trap contract when called
directly after exhaustion.

## Validation

`collections/iter-combinators-runtime` exercises every helper over `Array<I32>`.
The fixture compiles twice to byte-identical Wasm and executes identically in
Node and Wago. The backend suite additionally covers validation of the generic
array iterator implementation.
