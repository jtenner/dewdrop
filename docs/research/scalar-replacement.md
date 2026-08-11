# Fresh and adjacent-local struct scalar replacement

Date: 2026-08-11

The whole-program optimizer replaces a supported scalar field read directly from fresh struct construction with a source-ordered `PlannedParameterSelect`. Every field initializer still evaluates exactly once in source order; unselected values are discarded and the selected initializer becomes the result. The now-unreachable `PlannedStructNew` is consumed, removing both the aggregate allocation and its subsequent field load.

The same rewrite now covers an immutable, uncaptured struct local when its only use is an immediately following direct field read. The local declaration and sole local read are elided, while the constructor initializers move to the next item with no intervening operation and preserve their original order. The optimizer copies block items as well as expressions and child arenas, so the unoptimized lowering remains unchanged.

The initial shape set is I32/U32/I64/U64, F32/F64, Swar32/Swar64, and V128. Narrow integer fields remain unchanged because packed storage performs truncation/extension that direct selection must not bypass. Reference and generic fields remain unchanged until nominal cast, identity, and escape policies are explicit. Trait-coerced constructor bases, variants, captured/mutable locals, multiple uses, non-adjacent uses, and escaping values are also excluded.

The success snapshot uses the adjacent local form and contains no `struct.new` or `struct.get`. A separate trap snapshot gives the first field an `unreachable` trap and the selected second field an integer divide-by-zero trap; Node and Wago both observe `unreachable`, proving that scalar replacement preserves complete source-order initializer evaluation rather than evaluating only the selected field.

`tools/benchmark-scalar-replacement.py` measured 10,000 calculations over 2,000 alternating warmed Node 26.3.0 samples in batches of 20 calls:

| Form | Median | `struct.new` sites | Wasm bytes |
| --- | ---: | ---: | ---: |
| adjacent immutable local | 3.523 µs | 0 | 502 |
| aggregate passed to escaping helper | 3.854 µs | 1 | 506 |

The allocation-free form measured 0.9142x the escaping runtime, about 8.6% faster, and reduced the module by 4 bytes. Extending this result beyond an adjacent sole use requires control-flow-aware non-escape and alias analysis rather than syntax-only rewriting.
