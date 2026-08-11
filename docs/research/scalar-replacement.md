# Fresh and sole-use local struct scalar replacement

Date: 2026-08-11

The whole-program optimizer replaces a supported scalar field read directly from fresh struct construction with a source-ordered `PlannedParameterSelect`. Every field initializer still evaluates exactly once in source order; unselected values are discarded and the selected initializer becomes the result. The now-unreachable `PlannedStructNew` is consumed, removing both the aggregate allocation and its subsequent field load.

The same rewrite covers an immutable, uncaptured struct local when its only use is a later direct field read in the same lexical block. The local declaration and sole local read are elided. An adjacent use always qualifies. A non-adjacent use qualifies only when every constructor initializer and every intervening expression is proven total/discardable by the existing callable-effect summaries, so moving the initializer cannot cross a mutation, trap, allocation, or other observable effect. Copied block-item, expression, and child arenas keep the unoptimized lowering unchanged.

A further bounded case handles two or more reads of the same supported scalar field from one immutable, uncaptured fresh-struct local. Instead of introducing component scratch storage, the optimizer changes the existing aggregate local to the selected scalar carrier. The declaration becomes a source-ordered `PlannedParameterSelect`, every repeated field read becomes a direct read of that local, and each obsolete aggregate base read is consumed. Because initialization stays at the original declaration, effectful initializers and intervening operations need not move. Any mixed-field read, direct aggregate use, trait coercion, capture, or mutation rejects the rewrite.

The initial shape set is I32/U32/I64/U64, F32/F64, Swar32/Swar64, and V128. Narrow integer fields remain unchanged because packed storage performs truncation/extension that direct selection must not bypass. Reference and generic fields remain unchanged until nominal cast, identity, and escape policies are explicit. Trait-coerced constructor bases, variants, captured/mutable locals, multiple uses, cross-block uses, effectful gaps, and escaping values are also excluded.

The success snapshot uses a pure intervening local and contains no `struct.new` or `struct.get`. A separate trap snapshot gives the first field an `unreachable` trap and the selected second field an integer divide-by-zero trap; Node and Wago both observe `unreachable`, proving that scalar replacement preserves complete source-order initializer evaluation rather than evaluating only the selected field.

`tools/benchmark-scalar-replacement.py` measured 10,000 calculations over 2,000 alternating warmed Node 26.3.0 samples in batches of 20 calls:

| Form | Median | `struct.new` sites | Wasm bytes |
| --- | ---: | ---: | ---: |
| pure-gap immutable sole use | 3.776 µs | 0 | 505 |
| aggregate passed to escaping helper | 4.309 µs | 1 | 509 |

The allocation-free form measured 0.8763x the escaping runtime, about 12.4% faster, and reduced the module by 4 bytes. A second benchmark, `tools/benchmark-repeated-field-scalar-replacement.py`, measured 64 projections over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `struct.new` | `struct.get` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| repeated same field | 0.0180 µs | 0 | 0 | 623 |
| alternating distinct fields | 0.0179 µs | 1 | 64 | 1,080 |

The runtime ratio was 1.0056x at this very small call boundary, effectively tied within timer noise, while repeated-field replacement removed 457 Wasm bytes and all aggregate operations. Extending this result to distinct fields or across control-flow joins still requires component-local planning and dominance-aware escape analysis.
