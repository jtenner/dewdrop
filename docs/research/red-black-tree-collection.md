# Red-black tree collection

Date: 2026-08-11

`dew.std.collections.red_black_tree` implements a mutable comparator-driven red-black tree with insertion/replacement, lookup, removal, minimum/maximum, predecessor/successor, lower/upper bounds, deterministic in-order traversal, bounded range iteration, clear, and a public invariant checker.

The implementation uses structure-of-arrays storage. Keys, values, parent/left/right indices, colors, and liveness flags occupy carrier-specialized Arrays. Root and live length use one-element mutable scalar Arrays because ordinary Dew struct fields are immutable. Node indices remain stable; removal leaves tombstoned storage rather than relocating other nodes. Clear releases all retained key/value references and resets the root and logical length.

Insertion and deletion follow the standard red-black recoloring and rotation cases. Missing children are represented by index `-1` and treated as black leaves. Delete fixup carries an explicit parent hint while its replacement is a missing leaf, avoiding a mutable sentinel object.

`red_black_tree_validate` checks a black root, red-parent rules, equal black height, parent links, live-node count, and strict comparator order after mutations. Iterators advance through parent-linked successors and produce `TreeEntry` values in deterministic key order. Range iterators support optional lower and upper bounds with independent inclusive/exclusive policies. Exhausted `next` calls trap consistently with Dew's ambient iterator convention.

The structure intentionally favors unboxed carrier arrays and stable indices over node-per-link allocation. Tombstoned capacity can grow under repeated remove/reinsert workloads; compaction should be added only with explicit iterator-invalidation semantics and benchmark evidence.
