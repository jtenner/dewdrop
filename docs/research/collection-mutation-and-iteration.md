# Collection mutation and iteration contract

Date: 2026-08-11

Dew's current Array, Map, Set, Stack, Queue, CircularBuffer, Deque, BinaryHeap, PriorityQueue, RedBlackTree, OrderedMap, and OrderedSet values are mutable reference objects. Assigning one to another variable creates an alias; it does not copy storage or create a persistent version. Mutation through any alias is visible through every alias. APIs that promise copying, such as BinaryHeap's Floyd constructor from Array, state that behavior explicitly.

A **structural mutation** changes logical membership, length, or traversal topology. Successful insertion of a new item, push/enqueue, successful pop/dequeue/removal, and clearing a nonempty collection are structural. A no-op operation is not structural: failed removal, duplicate set insertion, and clearing an already empty collection do not invalidate anything. Capacity-only reservation is nonstructural.

A **replacement mutation** preserves logical shape. Array indexed assignment, Map/OrderedMap replacement of an existing key's value, and RedBlackTree replacement of an existing comparator-equal key's value are replacement mutations.

An iterator is valid from construction until its source collection receives a structural mutation. Structural mutation invalidates all outstanding iterators for that collection. Calling `has_next` or `next` on an invalidated iterator has unspecified traversal results, but remains subject to WasmGC memory and type safety. Dew does not currently pay an epoch counter and branch on every iterator operation to force a deterministic invalidation trap.

Replacement mutations do not invalidate iterators. An item not yet yielded is observed with the value stored when it is reached; already yielded scalar values and immutable entry snapshots do not change retroactively. Iterators retain their source collection strongly for their own lifetime. Exhausted valid iterators trap on `next`; callers use `has_next` at non-trapping boundaries.

No current mutable collection provides persistence, snapshot isolation, concurrent mutation guarantees, or thread-safe synchronization. A future persistent collection must use a distinct nominal type and API rather than silently changing these alias semantics.

## Ordered versus hash workload measurement

`tools/benchmark-ordered-collections.py` builds equivalent insert, lookup/membership, and reverse-removal workloads for 128 deterministic integer keys. On x86-64 Node 26.3.0, 200 warmed samples produced these medians:

| Workload | Median |
| --- | ---: |
| Hash Map | 6.152 µs |
| OrderedMap | 32.356 µs |
| Hash Set | 6.292 µs |
| OrderedSet | 28.408 µs |

OrderedMap measured 5.2594x the Hash Map runtime and OrderedSet measured 4.5150x the Hash Set runtime for this workload. The generated Wasm sizes were 109,492 bytes for Hash Map, 18,922 bytes for OrderedMap, 107,768 bytes for Hash Set, and 12,451 bytes for OrderedSet. The size result reflects current compiler-known hash operation expansion versus reusable Dew tree functions; it is not a claim that tree storage is intrinsically smaller.

Use hash collections when deterministic order and ordered queries are unnecessary. Use ordered collections for comparator-defined traversal, ranges, bounds, predecessor/successor, or adversarial cases where the current hash policy is unsuitable. These measurements are a baseline, not a universal crossover point.
