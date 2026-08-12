# Fresh and sole-use local struct scalar replacement

Date: 2026-08-12

The whole-program optimizer replaces a supported scalar field read directly from fresh struct construction with a source-ordered `PlannedParameterSelect`. Every field initializer still evaluates exactly once in source order; unselected values are discarded and the selected initializer becomes the result. The now-unreachable `PlannedStructNew` is consumed, removing both the aggregate allocation and its subsequent field load.

The same rewrite covers an immutable, uncaptured struct local when its only use is a later direct field read in the same lexical block. The local declaration and sole local read are elided. An adjacent use always qualifies. A non-adjacent use qualifies only when every constructor initializer and every intervening expression is proven total/discardable by the existing callable-effect summaries, so moving the initializer cannot cross a mutation, trap, allocation, or other observable effect. Copied body, local, block, block-item, expression, and child arenas keep the unoptimized lowering unchanged.

A further bounded case handles two or more reads of the same supported scalar field from one immutable, uncaptured fresh-struct local. Instead of introducing component scratch storage, the optimizer changes the existing aggregate local to the selected scalar carrier. The declaration becomes a source-ordered `PlannedParameterSelect`, every repeated field read becomes a direct read of that local, and each obsolete aggregate base read is consumed. Because initialization stays at the original declaration, effectful initializers and intervening operations need not move. Any direct aggregate use, trait coercion, capture, or mutation rejects the repeated-field rewrite; distinct direct scalar reads are handled by synthesized components.

Distinct scalar fields can also reuse locals already required by source. When a fresh aggregate declaration is followed immediately by immutable direct aliases for every field, aliases may appear in any source order: the optimizer maps them by frozen field identity and schedules the existing locals in constructor order. Exactly one field may be missing; its initializer remains an expression item while the other fields initialize their aliases. The dead aggregate local becomes carrier-free.

A separate synthesized-component path handles an immutable uncaptured aggregate with two or more distinct direct scalar field reads and any number of unobserved fields. The optimizer appends a copied body-local arena with one compiler-owned local per observed field, appends a rebuilt block-item sequence, and repoints the body and block spans. The original declaration expands into constructor-order component `let` items and expression items for unobserved initializers; all field reads become local reads. This preserves every initializer exactly once at the original declaration and introduces no `local.tee`. Exact nominal-reference fields also qualify when their constructor initializer directly reads an immutable local carrying matching nonzero nominal evidence, constructs a fresh nominal struct, or reads a module value with explicit nominal evidence. The synthesized component retains that nominal declaration, preserving backend casts and reference identity while eliminating only the outer aggregate; fresh inner allocations remain at the original declaration in source order. Generic fields qualify when the initializer is a direct read of an existing `GenericPlannedValueShape` local with the same inferred type and no coercion; specialized scalar instantiations then remove the aggregate without erased boxes, while fallback generic carriers remain unchanged. Mixed source alias/direct use is supported in one block: immutable direct aliases supply their existing local, while direct fields receive compiler locals. Alias initializer items remain expression items after retargeting so backend local discovery does not incorrectly erase a reused local. Direct aggregate uses, duplicate/mutable/nonlocal aliases, fresh/erased/generic reference constructors, coercions, and captures remain conservative.

Sole-use projections now cross bounded `if` and match joins when every reachable branch or arm recursively ends in fresh construction of the same struct field. The optimizer preflights the complete control-flow result tree before mutation, then converts each constructor to a source-ordered selector and changes intervening block, `if`/match, and existing local carriers to the selected scalar. Conditions, scrutinees, guards, and nonselected paths remain untouched. A call-returned, coerced, escaping, or otherwise non-fresh result rejects the entire rewrite without partial mutation.

The initial shape set is I32/U32/I64/U64, F32/F64, Swar32/Swar64, and V128. Narrow integer fields remain unchanged because packed storage performs truncation/extension that direct selection must not bypass. Reference and generic fields remain unchanged until nominal cast, identity, and escape policies are explicit. Trait-coerced constructor bases, variants, captured/mutable locals, direct aggregate uses, source-alias/direct-use mixtures, and escaping values are also excluded.

The success snapshot uses a pure intervening local and contains no `struct.new` or `struct.get`. A separate trap snapshot gives the first field an `unreachable` trap and the selected second field an integer divide-by-zero trap; Node and Wago both observe `unreachable`, proving that scalar replacement preserves complete source-order initializer evaluation rather than evaluating only the selected field.

`tools/benchmark-scalar-replacement.py` measured 10,000 calculations over 2,000 alternating warmed Node 26.3.0 samples in batches of 20 calls:

| Form | Median | `struct.new` sites | Wasm bytes |
| --- | ---: | ---: | ---: |
| pure-gap immutable sole use | 3.776 µs | 0 | 505 |
| aggregate passed to escaping helper | 4.309 µs | 1 | 509 |

The allocation-free form measured 0.8763x the escaping runtime, about 12.4% faster, and reduced the module by 4 bytes. A second benchmark, `tools/benchmark-repeated-field-scalar-replacement.py`, measured 64 projections over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `struct.new` | `struct.get` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| repeated same field | 0.0170 µs | 0 | 0 | 623 |
| synthesized alternating fields | 0.0170 µs | 0 | 0 | 624 |

The forms were tied at this host-call-scale boundary. Repeated reads reuse one source local, while alternating distinct reads use two synthesized component locals; both remove every aggregate operation.

`tools/benchmark-component-scalar-replacement.py` measured 32 distinct fields over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `struct.new` | `struct.get` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| constructor-order aliases | 0.0177 µs | 0 | 0 | 693 |
| reverse-order aliases | 0.0177 µs | 0 | 0 | 693 |
| one missing alias | 0.0178 µs | 0 | 0 | 689 |
| retained alias aggregate | 0.0177 µs | 1 | 32 | 1,073 |
| 16 synthesized direct components | 0.0178 µs | 0 | 0 | 629 |
| retained direct aggregate | 0.0170 µs | 1 | 16 | 783 |
| mixed alias/direct components | 0.0143 µs | 0 | 0 | 445 |
| retained mixed aggregate | 0.0141 µs | 1 | 2 | 489 |
| synthesized generic components | 0.0143 µs | 0 | 0 | 473 |
| retained generic aggregate | 0.0156 µs | 1 | 2 | 590 |
| fresh nominal-reference components | 0.0137 µs | 2 | 2 | 480 |
| retained fresh outer aggregate | 0.0161 µs | 3 | 4 | 515 |
| local nominal-reference components | 0.0139 µs | 2 | 2 | 482 |
| retained local outer aggregate | 0.0150 µs | 3 | 4 | 517 |

Scalar and mixed forms were effectively tied within timer noise. Mixed replacement removed 44 Wasm bytes, one allocation, and two field reads. Generic splitting measured 0.9162x and removed 117 bytes plus every aggregate operation. Source-local reuse removed 380–384 bytes; synthesized direct scalars removed 154 bytes, one allocation, and 16 field reads. Fresh and local nominal-reference splitting measured 0.8512x and 0.9261x their retained baselines, removing the outer aggregate allocation, two outer field reads, and 35 Wasm bytes while retaining both inner objects.

`tools/benchmark-join-scalar-replacement.py` measured fresh two-branch `if` and match joins against baselines whose selected path passes the aggregate through a reference-returning helper, over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `struct.new` | `struct.get` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| fresh `if` join | 0.0146 µs | 0 | 0 | 458 |
| retained `if` branch | 0.0153 µs | 2 | 1 | 498 |
| fresh match join | 0.0154 µs | 2 | 1 | 529 |
| retained match arm | 0.0161 µs | 4 | 2 | 567 |

The allocation-free `if` and match joins measured 0.9550x and 0.9566x their retained baselines, roughly 4.4–4.5% faster, and removed 38–40 Wasm bytes. The match fixture's remaining struct operations belong to the matched `Choice` enum rather than `Pair`. Duplicate/mutable/nonlocal aliases and coerced or nominal-unknown reference/generic components still require broader identity-aware planning.
