# Circular buffer collection

Date: 2026-08-11

September 6 update: the hidden Array representation described below is removed.
Storage and algorithms now use declared Dew structs and raw Wasm instructions.
See the [current design and tests](circular-buffer-library-storage-2026-09-06.md).

`dew.std.collections.circular_buffer` provides bounded and growable mutable ring buffers over the six Array carrier families. The Array wrapper's third i32 stores a growable-mode high bit and a 31-bit head index; capacity comes from the backing WasmGC array length and logical length remains the second field. This shares Array physical types without adding per-instance allocations.

Bounded push returns false when full. Growable push expands zero capacity to four and otherwise doubles, copying live values from logical front to index zero before appending. Pop and peek use the head index, wrap modulo capacity, and return `Option::None` when empty. Pop and clear null removed reference slots. Iterators retain the buffer and map their cursor through the captured ring head without per-yield allocation.

Runtime coverage exercises bounded-full rejection, wraparound after pop, growable wraparound followed by reallocation, FIFO order, capacity doubling, clear, and logical-order iteration. The implementation is intended to replace Queue's measured O(n) shifting representation in the next bounded Queue representation commit.
