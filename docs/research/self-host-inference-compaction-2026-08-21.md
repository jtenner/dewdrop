# Self-host inference result compaction

Date: 2026-08-21

The Dew semantic port now compacts each basic body inference arena.

Implemented behavior:

- iterative reachability marking from every published type root;
- product, application, and function child traversal;
- deterministic old-ID to compact-ID mapping;
- compact type-argument rebuilding;
- remapping of root, expression, local, block, pattern, control, call, construction, and pattern type arguments;
- module-wide body compaction in body order;
- removal of unreachable candidate and rollback terms.

Bodies carrying solver type diagnostics are kept in their original arena. This conservative path preserves diagnostic type IDs and avoids a known compiler aggregate-code generation hazard in nested diagnostic rebuilding. Successful bodies, which are the fixed-point path, are fully compacted.

Focused tests verify dead solver terms are removed and every published positive expression type remains in range.
