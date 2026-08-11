# Ordered map collection

Date: 2026-08-11

`dew.std.collections.ordered_map` wraps the shared red-black tree core as `OrderedMap<key, value, comparator>`. It provides insertion/replacement, set, optional get, membership, removal, clear, extrema, lower/upper bounds, predecessor/successor, deterministic in-order iteration, and optional inclusive/exclusive range bounds.

The comparator is retained by the underlying tree. `ordered_map_insert` returns `true` only for a new key and replaces the value with `false` for an existing comparator-equal key. `ordered_map_set` discards that distinction. Empty and missing boundaries use `Option::None`.

`OrderedMapEntry` keeps key/value pairing and is an alias of the tree core's immutable entry snapshot. Iterators advance in comparator order and exhausted `next` calls trap. Range iteration does not copy the map; mutation during iteration remains intentionally unspecified until collection-wide iterator invalidation rules are finalized.
