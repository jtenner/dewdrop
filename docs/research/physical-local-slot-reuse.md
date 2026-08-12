# Deterministic physical local-slot reuse

Date: 2026-08-12

The Starshine backend now reuses physical Wasm locals for a bounded class of proven noninterfering source locals. The first tranche is deliberately linear: the body must have one root block and no nested block, `if`, match, functional loop, `break`, or `continue` expression. Eligible locals are immutable, uncaptured `let` bindings with exactly one declaration, no assignment, and at least one read. Mutable locals, pattern locals, capture cells, expression-root bodies, and every non-linear control-flow body keep distinct physical slots.

The backend computes deterministic statement positions from root-block source order. Every expression emitted for one root item receives that item's position. A local remains live through the position of its last read. First-fit allocation scans existing slots in physical order and reuses the first slot whose prior value is dead no later than the candidate initializer. Initializers remain in source order and every `local.set`/`local.get` remains unchanged; only logical-to-physical local indices change.

Compatibility is stricter than raw Wasm value-type equality. Scalar and SIMD carriers group by exact Wasm carrier. Exact nominal references require the same physical type index. Nominal-unknown references use the shared nullable `eqref` carrier. Erased generic locals require the same inferred generic body type. Capture-cell slots are classified separately and are not eligible in this tranche. This prevents accidental reuse across nominal cast boundaries or unrelated erased generic values.

`optimization/physical-local-reuse-runtime` covers a three-stage scalar chain, an overlapping pair that must retain two slots, sequential exact nominal references, and an erased-generic chain. `optimization/physical-local-reuse-order-trap` preserves a trapping later initializer after an earlier value is retained. The WAT budget confirms four functions with body locals: the scalar chain, exact-reference chain, and generic chain use one slot each while the overlapping scalar pair uses two; no `local.tee`, dynamic call, function reference, global, table, branch table, loop, or conditional appears in the focused budget.

`tools/benchmark-physical-local-reuse.py` compared 64 sequential immutable scalar locals with the same source written using mutable locals over 10,000 warmed Node samples in batches of 100 calls. The reused form used 1 physical local instead of 64. The latest run measured 0.0144 µs versus 0.0143 µs (1.0070x), which is host-call-scale noise. Both artifacts were 875 bytes because all indices remained single-byte LEB values; a 192-local probe reduced the artifact from 1,902 to 1,771 bytes by avoiding multi-byte local indices (0.0140 µs versus 0.0137 µs, 1.0211x, also timing noise). The accepted contract is deterministic peak-local and large-body byte reduction without changing instruction count or source semantics.

Across the existing snapshot corpus, 18 unrelated but eligible linear fixtures accepted deterministic local-index renumbering and reduced their combined physical-local count from 557 to 522. The largest WAT diffs are index-only rewrites in collection and text bodies; runtime output, traps, instruction counts, and architecture budgets remain unchanged.

## Remaining boundary

This is not general graph coloring. Branch joins, match arms, loops/backedges, nested blocks, pattern lifetimes, mutable snapshots, and scratch-local interference remain conservative. Extending reuse requires an explicit control-flow graph with dominance and interference sets rather than expression-arena or root-item intervals.
