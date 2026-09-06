# Queue collection design

Date: 2026-08-11

## Public API

`dew.std.queue` provides mutable `Queue<t>` and `QueueIter<t>` aliases over `CircularBuffer<t>` and `CircularBufferIter<t>`. The public operations are `queue_new`, `queue_with_capacity`, `queue_length`, `queue_is_empty`, `queue_enqueue`, optional `queue_dequeue`, optional non-mutating `queue_peek`, `queue_clear`, `queue_iter`, `queue_iter_has_next`, and `queue_iter_next`.

FIFO order is deterministic. Empty dequeue and peek return `Option::None`; aliases observe all mutations; iteration traverses front-to-back.

## Current representation

Queue now uses the growable circular-buffer runtime. Enqueue appends at the logical tail, dequeue advances the wrapped head, and peek reads the logical front. Growth normalizes the live ring into a doubled backing array. All three primary operations are O(1) amortized while preserving carrier-specialized storage and reference-slot clearing.

As of September 6, Queue retains its public API but uses normal Dew calls to the
circular-buffer library. Queue-specific semantic operation dispatch is removed.
See the [migration log](queue-library-entry-points-2026-09-06.md). The measurements
below describe the older compiler-owned ring implementation.

## Measurement

On August 11, 2026, `tools/benchmark-queue-runtime.py --count 128 --samples 100` measured Node medians:

- contiguous FIFO enqueue-and-drain: 32.216 microseconds;
- Array-backed LIFO enqueue-and-drain baseline: 2.735 microseconds;
- FIFO overhead ratio: 11.7792x.

That result rejected contiguous shifting as the final representation. After rebasing on the ring runtime, the same 128-element benchmark measured 8.957 microseconds for Queue and 2.575 microseconds for the LIFO baseline, reducing the ratio to 3.4783x while changing dequeue from O(n) to O(1). The remaining ratio includes FIFO ring arithmetic and the benchmark's fully unrolled call surface.

## Validation

Semantic tests cover module selection, frozen-interface imports, stable declaration IDs, and lowering. Runtime snapshots cover FIFO dequeue, non-mutating peek, alias-visible enqueue, interleaved enqueue/dequeue, front-to-back iteration, clear, empty results, deterministic Wasm, and Node execution. Wago remains blocked by the installed Wago source mismatch recorded in the roadmap context.
