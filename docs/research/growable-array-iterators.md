# Growable Array and explicit collection iterators

## Status

Implemented on August 11, 2026.

This milestone adds the ambient protocols:

```dew
pub trait Iter<t> {
  fn has_next(self) -> Bool
  fn next(self) -> t
}

pub trait IndexedGet<index, value> {
  fn indexed_get(self, index: index) -> value
}

pub trait IndexedSet<index, value> {
  fn indexed_set(self, index: index, value: value) -> Unit
}
```

`IndexedGet` and `IndexedSet` replace the earlier provisional `Index` and
`IndexSet` names. Indexed-setting syntax remains a block item, and receiver,
index, and value are evaluated exactly once in source order.

## `dew.std.array`

`Array<t>` is a mutable reference-identity growable array with these operations:

```dew
Array::new() -> Array<t>
Array::with_capacity(capacity: U32) -> Array<t>
Array<t>.length() -> U32
Array<t>.capacity() -> U32
Array<t>.is_empty() -> Bool
Array<t>.push(value: t) -> Unit
Array<t>.pop() -> Option<t>
Array<t>.get(index: U32) -> Option<t>
Array<t>.get_unchecked(index: U32) -> t
Array<t>.set(index: U32, value: t) -> Bool
Array<t>.set_unchecked(index: U32, value: t) -> Unit
Array<t>.clear() -> Unit
Array<t>.iter() -> ArrayIter<t>
```

Index syntax uses trapping unchecked get/set semantics. Safe `get` returns
`Option::None`; safe `set` returns false. `pop` returns `Option::None` when the
array is empty. Calling an exhausted iterator's `next` traps.

### Physical representation

One compiler-owned WasmGC wrapper stores:

1. the carrier backing array as nullable `eqref`;
2. mutable logical length as `i32`;
3. mutable capacity as `i32`.

Backing storage is specialized across the same six families as `FixedArray`:
`i32`, `i64`, `f32`, `f64`, `v128`, and nullable `eqref`. Scalar and SIMD
payloads remain unboxed.

`new` uses zero capacity. A full push grows zero capacity to four and thereafter
doubles capacity. Growth rejects wrapped or non-increasing capacities, allocates
the new carrier array, copies the live logical prefix iteratively, and only then
publishes the replacement backing and capacity. Push evaluates its receiver and
value before performing growth, preserving call evaluation order. Pop and clear
write null into removed reference slots so dead values are not retained; scalar
slots need no clearing. Pop and clear preserve capacity.

### Iterator representation

`ArrayIter<t>` stores the source array reference plus a mutable `U32` cursor.
Iteration observes the array's current logical length and yields index order.
Aliases share array mutation, while each iterator owns its cursor.

## Map and Set iterators

`Map<key, value>` now exposes:

```dew
map.keys() -> MapKeyIter<key, value>
map.values() -> MapValueIter<key, value>
map.entries() -> MapEntryIter<key, value>
entry.key() -> key
entry.value() -> value
```

`Set<key>` exposes:

```dew
set.iter() -> SetIter<key>
```

All iterator types implement `Iter`. Hash iterators maintain a bucket index and a
prefetched chain entry. Their small state object reuses the private hash bucket
array carrier, so iterator creation is constant-size and iteration allocates no
object per yielded element. `has_next` may advance internal prefetch state.
`next` consumes the prefetched entry and advances through its linked chain before
moving to the next bucket.

Hash traversal order is explicitly unspecified. Programs must not use the
observed bucket/chain order as a stable serialization order. Mutation during
iteration remains unspecified; callers requiring a stable view must avoid
mutating the collection until iteration completes.

## Validation

Coverage includes:

- stable compiler-owned Array and iterator declaration identities;
- direct lowering for constructors, capacity, safe/trapping access, push, pop,
  clear, indexing, and iteration;
- repeated growth through capacities 0, 4, 8, and 16;
- preservation of first, middle, and final values across reallocation;
- alias-visible mutation and capacity preservation after pop/clear;
- `i32`, `i64`, `f32`, `f64`, `v128`, and reference carriers;
- empty pop, safe out-of-range get/set, and exhausted iterator behavior;
- trapping indexed get/set and exhausted `next` snapshots;
- Array index-order iteration;
- Map key/value/entry pairing across collision chains;
- Set key iteration;
- empty Map/Set iterators;
- Node and Wago differential execution with deterministic Wasm/WAT snapshots.

## Budgets and measurements

The checked architecture cases freeze direct WAT budgets for the complete Array,
Map iterator, and Set iterator runtime fixtures. They reject `call_ref`, function
references, globals, and tables and count the emitted `array.*` and `struct.*`
operations so accidental dictionary dispatch or per-element wrapper expansion is
fail-visible.

`tools/benchmark-array-runtime.py` compares ordinary geometric growth against
exact upfront reservation in the same generated push workload. On August 11,
2026, a 256-push, 200-sample Node run measured medians of 3.526 microseconds for
geometric growth and 1.613 microseconds for exact reservation, a 1.914
microsecond / 2.1863x median difference on the development host. These are local
microbenchmarks rather than portable release thresholds; the checked WAT budgets
are the deterministic regression contract.

## Remaining work

- Add bulk reserve, shrink, extend, copy, fill, and slice APIs after their
  evaluation and overlap semantics are specified.
- Add iterator invalidation or mutation-version rules if stable concurrent
  mutation behavior becomes a product requirement.
- Benchmark Array growth and hash traversal against circular buffers, linked
  queues, and ordered tree representations before selecting later collection
  layouts.
