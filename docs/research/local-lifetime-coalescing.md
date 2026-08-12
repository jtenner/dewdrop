# Immutable local lifetime coalescing

Date: 2026-08-12

The whole-program optimizer now coalesces a bounded immutable local-alias shape without moving initialization. When an immutable uncaptured local is initialized by a direct read of another immutable uncaptured local, all alias uses are retargeted to the source local. The alias declaration and its direct read are elided. Scalar, SIMD, and packed carriers may be coalesced even when other reads of the immutable source remain; reference and erased-generic carriers still require the alias initializer to be the source's only read.

The proof requires identical inferred type, physical carrier shape, and nominal evidence. Exact nominal references are therefore coalesced only in the sole-use case, without adding casts or changing reference identity. Shared-source reference and generic aliases remain separate until a general live-range/interference plan can bound retention pressure in reference-heavy generated code. Mutable source or alias locals remain separate because an alias may represent a snapshot across later assignment. Captures, coercions, and non-direct alias expressions also remain conservative.

The rewrite runs on copied body/local/block arenas, so unoptimized lowering remains unchanged. Source initialization remains at its original lexical item and evaluates exactly once. The order-trap snapshot confirms a trapping source initializer remains visible before the elided alias.

`optimization/local-lifetime-coalescing-runtime` covers sole-use scalar and exact nominal-reference aliases plus a shared-source scalar path. Its WAT contains one local for each path because the shared scalar alias is also coalesced. It contains no `local.tee`. The semantic test separately retains a shared-source exact nominal-reference alias as the bounded carrier-policy contract.

`tools/benchmark-local-lifetime-coalescing.py` measured a chain of 64 immutable aliases against mutable aliases over 10,000 warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `local.get` | `local.set` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| immutable coalesced chain | 0.0146 µs | 2 | 1 | 432 |
| mutable retained chain | 0.0145 µs | 66 | 65 | 690 |

The latest 1.0062x timing ratio is within host-call noise, while coalescing removes 64 local assignments, 64 corresponding reads, and 258 Wasm bytes. The runtime snapshot's shared-source path now also coalesces its alias, removing one additional local assignment/read from the contractual WAT.

## Remaining boundaries

Broader lifetime coalescing needs explicit dominance/interference planning for shared reference/generic sources, branches, loops, phi-like joins, and non-direct values. Mutable snapshot semantics, captures, and nominal/coercion boundaries remain hard barriers.
