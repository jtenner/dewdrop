# Fresh-struct scalar replacement

Date: 2026-08-11

The whole-program optimizer now replaces a supported scalar field read directly from a fresh struct construction with a source-ordered `PlannedParameterSelect`. Every field initializer still evaluates exactly once in source order; unselected values are discarded and the selected initializer becomes the result. The now-unreachable `PlannedStructNew` is consumed, removing both the aggregate allocation and its subsequent field load.

The initial shape set is I32/U32/I64/U64, F32/F64, Swar32/Swar64, and V128. Narrow integer fields remain unchanged because packed storage performs truncation/extension that direct selection must not bypass. Reference and generic fields remain unchanged until nominal cast, identity, and escape policies are explicit. Trait-coerced constructor bases, variants, let-bound aggregates, and escaping values are also excluded.

The success snapshot contains no `struct.new` or `struct.get`. A separate trap snapshot gives the first field an `unreachable` trap and the selected second field an integer divide-by-zero trap; Node and Wago both observe `unreachable`, proving that scalar replacement preserves complete source-order initializer evaluation rather than evaluating only the selected field.

`tools/benchmark-scalar-replacement.py` measured 10,000 calculations over 2,000 alternating warmed Node 26.3.0 samples in batches of 20 calls:

| Form | Median | `struct.new` sites | Wasm bytes |
| --- | ---: | ---: | ---: |
| direct fresh-field projection | 3.489 µs | 0 | 480 |
| equivalent let-bound aggregate | 6.642 µs | 1 | 502 |

The allocation-free form measured 0.5252x the let-bound runtime, about 47.5% faster, and reduced the module by 22 bytes. Extending this result to let-bound aggregates requires explicit non-escape and alias analysis rather than syntax-only rewriting.
