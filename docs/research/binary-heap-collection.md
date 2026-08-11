# Binary heap collection

Date: 2026-08-11

`dew.std.collections.binary_heap` provides mutable `BinaryHeap<t, c>` storage with an immutable comparator value and explicit minimum/maximum policy selected at construction. The comparator is retained by the heap, so every mutation uses the same ordering evidence. Comparator implementations must be deterministic and total.

The heap uses carrier-specialized `Array<t>` backing. Push performs upward sifting in O(log n), peek is O(1), and pop replaces the root with the final value before downward sifting in O(log n). Pop and clear reuse Array's dead-reference clearing. Empty peek and pop return `Option::None`. Equal elements are not stable.

`binary_heap_from_array` copies the source into private storage and applies bottom-up Floyd heapification in O(n), preventing later source aliases from violating heap invariants. Heap iterators expose internal level/layout order, not sorted order; sorted traversal requires popping a separate heap.

The implementation also hardened generic collection wrappers in the backend. Carrier selection now specializes Array construction, safe get, pop, clear, iteration, and mutation from the relevant generic element type. Nested Array operations defer outer scratch storage until nested arguments finish, preserving source order without clobbering the outer wrapper. Generic Option payload extraction now inserts precise nominal casts before binding locals.

A 128-element, 100-sample Node benchmark measured repeated push-and-drain at 14.998 microseconds median and Floyd-build-and-drain at 14.377 microseconds median (`0.9586x`). The benchmark is intended as a regression signal rather than a universal performance claim.
