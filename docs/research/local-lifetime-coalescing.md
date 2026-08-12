# Immutable local lifetime coalescing

Date: 2026-08-12

The whole-program optimizer now coalesces a bounded immutable local-alias shape without moving initialization. When an immutable uncaptured local is initialized by a direct read of another immutable uncaptured local, and that initializer is the source local's only read, all alias uses are retargeted to the source local. The alias declaration and its direct read are elided.

The proof requires identical inferred type, physical carrier shape, and nominal evidence. It therefore supports scalar, exact nominal-reference, SIMD, and packed carriers without adding casts or changing reference identity. Mutable locals remain separate because an alias may be a snapshot across later assignment. Shared source reads remain separate because extending the source local's live range is not yet modeled by a general interference planner. Captures, coercions, and non-direct alias expressions also remain conservative.

The rewrite runs on copied body/local/block arenas, so unoptimized lowering remains unchanged. Source initialization remains at its original lexical item and evaluates exactly once. The order-trap snapshot confirms a trapping source initializer remains visible before the elided alias.

`optimization/local-lifetime-coalescing-runtime` covers scalar and exact nominal-reference aliases plus a retained shared-source baseline. Its WAT contains one local for each coalesced path and retains two locals for the shared-source path. It contains no `local.tee`.

`tools/benchmark-local-lifetime-coalescing.py` measured a chain of 64 immutable aliases against mutable aliases over 10,000 warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `local.get` | `local.set` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| immutable coalesced chain | 0.0147 µs | 2 | 1 | 432 |
| mutable retained chain | 0.0146 µs | 66 | 65 | 690 |

The 1.0075x timing ratio is within host-call noise, while coalescing removes 64 local assignments, 64 corresponding reads, and 258 Wasm bytes.

## Remaining boundaries

Broader lifetime coalescing needs explicit live-range and dominance/interference planning for shared-source aliases, branches, loops, and non-adjacent values. Mutable snapshot semantics, captures, and nominal/coercion boundaries remain hard barriers.
