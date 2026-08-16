# Growable Array and explicit collection iterators

## Status

Implemented on August 11, 2026. The complete TypeScript-inspired Array API,
bulk runtime operations, stable sorting, tests, and per-method benchmarks were
added on August 16, 2026; see
[`array-api-and-performance-2026-08-16.md`](array-api-and-performance-2026-08-16.md).

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

`Array<t>` is a mutable reference-identity growable array. Its original
constructor, capacity, access, push/pop, clear, index, and value-iterator surface
now also includes make/reserve/shrink/truncate/copy/extend, deque-like mutation,
strict bulk ranges, immutable variants, splice, search, structural equality,
callbacks, stable sorting, flattening, and key/entry iterators. The exact API and
semantics are listed in
[`array-api-and-performance-2026-08-16.md`](array-api-and-performance-2026-08-16.md).

Index syntax uses trapping unchecked get/set semantics. Safe `get` returns
`Option::None`; safe `set` returns false. `pop`, `shift`, search, and signed `at`
return `Option`. Calling an exhausted iterator's `next` traps.

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
the new carrier array, copies the live logical prefix with one WasmGC
`array.copy`, and only then publishes the replacement backing and capacity. The
bulk copy has non-overlapping source and destination arrays and copies exactly the
logical length, including the valid zero-length case. Push evaluates its receiver
and value before performing growth, preserving call evaluation order. Pop and clear
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
microsecond / 2.1863x median difference on the development host.

The August 13, 2026 bulk-growth follow-up is reproducible through
`tools/benchmark-array-copy-growth.py`. Seven rounds of 101 paired samples on
Node 26.3.0 compared the former scalar copy loop with WasmGC `array.copy` for
`I32` and `String` arrays. At 32, 64, and 512 pushed elements, bulk copying
improved `I32` construction by 1.94%, 7.35%, and 19.33%, and `String`
construction by 4.52%, 6.06%, and 14.29%. Sixteen-element results were within
0.3%; four-element construction regressed 4.10% and 5.14%. Every generated
microbenchmark module was 26 bytes smaller.

Thresholded scalar/bulk dispatch at 8, 16, and 32 elements was rejected. It
retained both implementations, added 50 bytes relative to the scalar module and
76 bytes relative to the bulk-only module, did not eliminate the first-growth
cost consistently, and slightly reduced medium-copy gains. A zero-length skip
also failed to improve the four-element case consistently. Dew therefore keeps
the smaller unconditional bulk-copy lowering: the first 0-to-4 growth remains a
small fixed cost, while geometric growth benefits increasingly after 32 values.
The benchmark tools serialize their temporary backend rewrites with a shared
file lock so concurrent runs cannot cross-contaminate variants.

`tools/benchmark-json-array-copy.py` checks a representative recursive consumer.
Across the three pinned JSON fixtures, most parse, validation, stringify, and
round-trip changes remained within roughly plus or minus 1.3%, except the small
canonical round trip at 2.68% slower. JSON modules were 78 bytes smaller. This is
recorded as neutral application-level evidence rather than a claimed JSON speed
improvement; the retained change is justified by direct medium and large Array
growth, simpler generated code, and smaller modules.

These are local microbenchmarks rather than portable release thresholds; checked
WAT budgets require one `array.copy` per carrier-specialized growth site, and the
Node/Wago snapshots remain the deterministic correctness contract.

## Remaining work

- Keep cross-engine Array benchmarks as measurements rather than fixed release
  thresholds until more production workloads exist.
- Add a dedicated compiler-local signed `Arena<t>` facade when the Dew compiler
  port begins; do not weaken the public U32 Array boundary.
- Circular-buffer queues, hash collections, heaps, and ordered-tree
  representations are implemented and benchmarked; linked/persistent sequence
  alternatives remain measurement-driven.
