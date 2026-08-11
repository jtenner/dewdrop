# Ordered set collection

Date: 2026-08-11

`dew.std.collections.ordered_set` wraps the shared red-black tree core as `OrderedSet<key, comparator>`. The internal tree uses a Boolean placeholder value, preserving one balancing, lookup, removal, bounds, and traversal implementation for ordered maps and sets.

Insertion is idempotent and reports whether a new comparator-distinct key was added. The API includes membership, removal, length, emptiness, clear, extrema, predecessor/successor, lower/upper bounds, deterministic in-order iteration, and optional inclusive/exclusive ranges.

Set iterators unwrap tree entries and yield keys directly. Equal comparator keys are one set element even if their source representation differs. Exhausted `next` calls trap. Mutation during iteration remains unspecified until collection-wide iterator invalidation rules are finalized.
