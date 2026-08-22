# Self-host I32 matches

Date: 2026-08-22

The linked emitter now lowers scalar `match` expressions.

Added support:

- deterministic scratch locals for match subjects;
- Boolean and 32-bit integer literal patterns;
- wildcard patterns;
- binding patterns and pattern-local writes;
- guarded catch-all arms;
- nested result-producing Wasm `if` chains;
- explicit unreachable fallback paths after the final tested arm.

The smoke module now emits an exhaustive Boolean match. Starshine validates the nested branch tree and its scratch-local indexes.

Aggregate, enum, tuple, struct, and alternative patterns remain with WasmGC object emission.
