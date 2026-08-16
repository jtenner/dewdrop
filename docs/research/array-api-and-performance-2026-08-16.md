# Array API, tests, and performance — August 16, 2026

## Status

Implemented.

Dew's growable `Array<t>` now has a broad TypeScript-inspired surface while
keeping Dew's explicit types, dense storage, strict ranges, and `Option` results.
The work also fixes the old `is_empty()` builtin mapping, which had incorrectly
lowered the method as `length()` instead of evaluating `length() == 0`.

## Public surface

### Construction and capacity

```dew
Array::new()
Array::with_capacity(capacity)
Array::make(length, value)
array.length()
array.capacity()
array.is_empty()
array.reserve(additional)
array.shrink_to_fit()
array.truncate(length)
array.clear()
```

### Access and mutation

```dew
array.get(index)
array.get_unchecked(index)
array.set(index, value)
array.set_unchecked(index, value)
array[index]
array[index] = value
array.first()
array.last()
array.at(signed_index)
array.swap(left, right)
array.push(value)
array.push_all(source)
array.pop()
array.shift()
array.unshift(value)
array.insert(index, value)
array.remove(index)
```

`at(I32)` supports negative positions. `-1` is the last item. Values outside the
live range return `Option::None`.

### Bulk operations

```dew
array.copy()
array.clone()
array.extend(source)
array.fill(value, start, end)
array.copy_within(target, start, end)
array.slice(start, end)
array.concat(other)
array.reverse()
array.to_reversed()
array.splice(start, delete_count, items)
array.to_spliced(start, delete_count, items)
```

Ranges are U32, end-exclusive, and strict. Reversed or out-of-bounds ranges trap.
`copy_within` has memmove overlap behavior. `slice`, `copy`, `clone`, `concat`,
`to_reversed`, and `to_spliced` return independent storage. `extend` and `splice`
snapshot source values correctly when the source aliases the destination.

### Search and equality

```dew
array.includes(value)
array.index_of(value)
array.index_of_from(value, start)
array.last_index_of(value)
array.last_index_of_before(value, end)
array.equals(other)
```

`Array<t>` implements structural `Eq` and `Ne` when `t: Eq`. Equality checks
length, order, and values. It does not use reference identity.

### Callbacks

```dew
array.for_each(action)
array.for_each_indexed(action)
array.map(mapper)
array.map_indexed(mapper)
array.filter(predicate)
array.filter_indexed(predicate)
array.flat_map(mapper)
array.every(predicate)
array.every_indexed(predicate)
array.some(predicate)
array.some_indexed(predicate)
array.find(predicate)
array.find_index(predicate)
array.find_last(predicate)
array.find_last_index(predicate)
array.reduce(initial, reducer)
array.reduce_indexed(initial, reducer)
array.reduce_right(initial, reducer)
```

Method-form `map`, `flat_map`, and `reduce` keep the element type. Cross-type
forms are explicit top-level generic functions:

```dew
array_map_to(values, mapper)
array_map_to_indexed(values, mapper)
array_flat_map_to(values, mapper)
array_reduce_into(values, initial, reducer)
array_reduce_right_into(values, initial, reducer)
```

Callback operations capture the initial length. Appended values are not visited.
If a callback removes pending positions, those positions are skipped instead of
trapping. Values still live when their position is reached are read immediately
before the callback, so prior mutation is visible.

### Sorting

```dew
array.sort()
array.to_sorted()
array_sort_by(array, comparator)
array_to_sorted_by(array, comparator)
```

Natural sorting requires `t: Lt`. Custom sorting uses `ArrayComparator<t>`.
Both forms use deterministic stable bottom-up merge sort. Equal values retain
source order. Sorting allocates one exact-length scratch Array and performs no
per-comparison allocation.

### Flattening and iteration

```dew
array.flat()
array.iter()
array.keys()
array.entries()
entry.index()
entry.value()
```

Value, key, and entry iterators observe current live length. Each iterator owns
its cursor. Entry values are read when `next()` is called.

## Runtime optimization

Eight bulk operations lower directly through compiler-known Array operations:

- `make` uses one WasmGC `array.new`;
- `reserve` uses geometric capacity selection and one `array.copy` when growth is
  required;
- `shrink_to_fit` uses one exact allocation and one `array.copy`;
- `truncate` updates logical length directly and uses `array.fill` to clear dead
  reference slots;
- `copy` and `slice` use exact allocation plus one `array.copy`;
- `fill` uses WasmGC `array.fill`;
- `copy_within` uses overlap-safe WasmGC `array.copy`;
- `extend` uses one exact allocation and two `array.copy` operations, publishing
  only after both copies complete.

`extend` is alias-safe because the destination wrapper is not published until
both old backing arrays have been read. Overflow checks happen before allocation.
Removed reference values are cleared so arrays do not retain dead objects.

## Test coverage

The test design follows edge-case themes used by V8's mjsunit Array tests:
empty and singleton arrays, both overlap directions, exact boundaries, source
mutation during callbacks, stable equal-key sorting, aliasing, self-extension,
self-splice, and failure paths.

Coverage is split across deterministic Node/Wago fixtures so callback and generic
specializations remain small and diagnostic:

- `tests/module-snapshots/collections/array-methods-runtime.dew`
- `tests/module-snapshots/collections/array-callbacks-runtime.dew`
- `tests/module-snapshots/collections/array-transforms-runtime.dew`
- `tests/module-snapshots/collections/array-filter-runtime.dew`
- `tests/module-snapshots/collections/array-flat-map-runtime.dew`
- `tests/module-snapshots/collections/array-generic-transform-runtime.dew`
- `tests/module-snapshots/collections/array-predicates-runtime.dew`
- `tests/module-snapshots/collections/array-reducers-runtime.dew`
- `tests/module-snapshots/collections/array-callback-mutation-runtime.dew`
- `tests/module-snapshots/collections/array-comparator-runtime.dew`
- `tests/module-snapshots/collections/array-iterators-runtime.dew`
- `tests/module-snapshots/collections/array-entries-runtime.dew`
- `tests/module-snapshots/collections/array-carriers-runtime.dew`

Dedicated trap fixtures cover invalid truncate, fill, slice, copy-within, swap,
and exhausted key/entry iterators. Every fixture has checked JSON and exact WAT.
The WAT snapshots make `array.new`, `array.copy`, and `array.fill` regressions
visible.

## Performance baseline and retained optimizations

`tools/benchmark-array-methods.py` builds one isolated Wasm module for each
method. This avoids cross-method callback specialization and gives every method a
repeatable median. The complete raw report is checked in at:

- `docs/research/array-method-performance-2026-08-16.json`

The pinned run used Node 26.3.0, 1,000 method invocations per sample, 31 samples
per round, five rounds, and ten warmups.

| Bulk method | Scalar baseline | Optimized | Speedup | Change |
|---|---:|---:|---:|---:|
| `make` | 187.63 ns | 66.56 ns | 2.819x | -64.53% |
| `copy` | 401.17 ns | 208.19 ns | 1.927x | -48.10% |
| `slice` | 324.48 ns | 183.15 ns | 1.772x | -43.56% |
| `extend` | 601.39 ns | 411.79 ns | 1.460x | -31.53% |
| `truncate` | 244.32 ns | 182.43 ns | 1.339x | -25.33% |
| `copy_within` | 193.89 ns | 165.22 ns | 1.174x | -14.79% |
| `fill` | 194.61 ns | 177.16 ns | 1.098x | -8.97% |

The report also records medians and Wasm sizes for construction, capacity,
access, deque-like mutation, immutable variants, splice, search, equality,
callbacks, reduction, sorting, flattening, and all iterator forms.

These are local microbenchmarks, not release thresholds. The retained choices are
supported by both measured wins and simpler generated Wasm. Future changes must
rerun this tool and the Node/Wago WAT fixtures.
