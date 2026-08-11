# Queue collection design

Date: 2026-08-11

## Public API

`dew.std.queue` provides mutable `Queue<t>` and `QueueIter<t>` aliases over the carrier-specialized Array runtime. The public operations are `queue_new`, `queue_with_capacity`, `queue_length`, `queue_is_empty`, `queue_enqueue`, optional `queue_dequeue`, optional non-mutating `queue_peek`, `queue_clear`, `queue_iter`, `queue_iter_has_next`, and `queue_iter_next`.

FIFO order is deterministic. Empty dequeue and peek return `Option::None`; aliases observe all mutations; iteration traverses front-to-back.

## Current representation

The first executable representation is a contiguous Array queue. Enqueue appends geometrically. Peek reads index zero. Dequeue reads index zero, shifts the remaining live prefix left once, clears the dead reference slot when necessary, and decrements length. This keeps one allocation-free backing object and carrier-specialized storage, but dequeue is O(n).

The compiler maps most Queue builtins to existing Array plans. Dedicated `PlannedQueuePeek` and `PlannedQueueDequeue` operations emit front access and deterministic shifting. Standard module slot 15 owns stable Queue builtin identities.

## Measurement

On August 11, 2026, `tools/benchmark-queue-runtime.py --count 128 --samples 100` measured Node medians:

- contiguous FIFO enqueue-and-drain: 32.216 microseconds;
- Array-backed LIFO enqueue-and-drain baseline: 2.735 microseconds;
- FIFO overhead ratio: 11.7792x.

The result rejects contiguous shifting as the final high-performance representation. The API is intentionally representation-independent so the next circular-buffer milestone can replace dequeue shifting with deterministic wraparound and amortized O(1) operations without changing callers.

## Validation

Semantic tests cover module selection, frozen-interface imports, stable declaration IDs, and lowering. Runtime snapshots cover FIFO dequeue, non-mutating peek, alias-visible enqueue, interleaved enqueue/dequeue, front-to-back iteration, clear, empty results, deterministic Wasm, and Node execution. Wago remains blocked by the installed Wago source mismatch recorded in the roadmap context.
