# Deque collection

Date: 2026-08-11

`dew.std.collections.deque` is a growable double-ended queue over the carrier-specialized circular-buffer runtime. Pushes at either end are O(1) amortized; pops and peeks are O(1). Front movement preserves the growable-mode bit while wrapping the head modulo capacity. Back access computes `(head + length - 1) % capacity`.

The API includes construction, reservation, length/capacity, emptiness, push/pop/peek at both ends, clear, and logical front-to-back iteration. Empty pops and peeks return `Option::None`. Growth normalizes wrapped values before continuing, and removed reference slots are cleared.

Runtime coverage exercises empty boundaries, front/back growth from both directions, wraparound, interleaved end operations, logical iteration order, non-mutating peeks, and capacity-preserving clear.
