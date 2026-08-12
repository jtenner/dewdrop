# Immutable local lifetime coalescing

Date: 2026-08-12

The whole-program optimizer coalesces immutable local aliases without moving initialization. When an immutable uncaptured local is initialized by a direct read of another immutable uncaptured local, all alias uses are retargeted to the source local. The alias declaration and its direct read are elided. Scalar, SIMD, packed, exact-reference, and erased-generic carriers may now share a source when an explicit local live-range plan proves that both locals are write-free, the source is live through the alias initialization, and alias reads occur only afterward. This covers overlapping reads, sequential handoff, branch-local reads, loop-local reads, and generic specialized/fallback bodies.

The proof requires identical inferred type, physical carrier shape, and nominal evidence. The optimizer computes deterministic first/last read positions plus read/write counts for each candidate local, treats overlapping intervals as interference, and allows overlap only because a direct immutable alias carries the exact same value and eliminating its duplicate storage cannot extend the source lifetime. Exact nominal references preserve identity and casts; erased generics preserve the same carrier/type evidence. Mutable source or alias locals remain separate because an alias may represent a snapshot across later assignment. Captures, coercions, non-direct alias expressions, source reads that begin after alias initialization, and alias reads before initialization remain conservative.

The rewrite runs on copied body/local/block arenas, so unoptimized lowering remains unchanged. Source initialization remains at its original lexical item and evaluates exactly once. The order-trap snapshot confirms a trapping source initializer remains visible before the elided alias.

`optimization/local-lifetime-coalescing-runtime` retains the original sole-use scalar/reference and shared scalar contracts. `optimization/local-live-range-runtime` adds shared, sequential, branch, loop, and erased-generic paths. The focused WAT has no alias-only locals, `local.tee`, dynamic calls, function references, globals, or tables; its order-trap fixture preserves the trapping source initializer before every rewritten read.

`tools/benchmark-local-lifetime-coalescing.py` measured a chain of 64 immutable aliases against mutable aliases over 10,000 warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `local.get` | `local.set` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| immutable coalesced chain | 0.0146 µs | 2 | 1 | 432 |
| mutable retained chain | 0.0145 µs | 66 | 65 | 690 |

The latest chain rerun measured 0.0177 µs versus 0.0179 µs (0.9894x) while coalescing removed 64 local assignments, 64 corresponding reads, and 258 Wasm bytes. The shared-reference case measured 0.0179 µs versus 0.0186 µs (0.9619x) and removed one assignment, one read, and 33 Wasm bytes. The shared erased-generic case measured 0.0179 µs versus 0.0178 µs (1.0050x) and removed one assignment, one read, and 4 Wasm bytes. These host-call-scale timing differences are within noise; the accepted contract is the bounded static reduction without longer source lifetimes.

## Remaining boundaries

The current model is expression-arena interval planning, not physical Wasm slot coloring. Broader reuse still needs control-flow-sensitive dominance and interference sets for unrelated values, phi-like joins, loop backedges, and backend local-type grouping. Mutable snapshot semantics, captures, non-direct values, and nominal/coercion boundaries remain hard barriers.
