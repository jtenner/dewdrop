# Priority queue collection

Date: 2026-08-11

`dew.std.collections.priority_queue` is a thin generic wrapper over `BinaryHeap`. `PriorityQueue<t, p, c>` retains a comparator over priorities and a minimum/maximum policy through its internal heap. Enqueue constructs one `PriorityItem<t, p>` and performs O(log n) heap insertion; peek is O(1), and dequeue is O(log n).

`PriorityItem` keeps the value and priority paired. Accessor functions expose both without making representation fields part of the imported API. Empty peek/dequeue return `Option::None`. Equal-priority order is intentionally unspecified; a stable queue would require an explicit sequence-number policy and additional storage.

Iteration exposes internal heap layout through `PriorityQueueIter`, not priority-sorted order. Clear preserves capacity and clears retained reference carriers through BinaryHeap and Array behavior. Aliases observe mutation.

Implementing the wrapper also extended whole-program generic-call validation. Calls whose nominal/reference type arguments contain generic parameters are now recognized as symbolic even when their immediate Wasm carrier shape is `eqref`; unreachable generic wrappers no longer produce false `UnsupportedProgramGenericCall` diagnostics, while concrete unsupported calls remain fail-visible.
