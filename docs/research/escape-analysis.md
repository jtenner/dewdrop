# Escape analysis and wrapper elimination

Date: 2026-08-12

## Single-field boxes

Fresh single-field structs whose only observable operation is immediate projection no longer allocate when the projected carrier is a reference or an erased generic value. The existing fresh-struct scalar-replacement proof already establishes that the wrapper does not escape: the constructor is the direct field-read base, or an immutable uncaptured adjacent sole-use local. For one-field wrappers, removing the wrapper preserves the exact child reference/generic carrier, evaluates the initializer once, and cannot expose wrapper identity because no wrapper value survives.

The broader reference-field case remains conservative. Multi-field reference aggregates, repeated reference projections, coercions, captures, calls, and other escaping uses retain allocation until identity and component-lifetime proofs cover them. Narrow fields also remain excluded because packed store/load normalization must not be bypassed.

The `optimization/box-escape-runtime` snapshot covers both a nominal reference box and a generic box. Its WAT contains only the one application `Token` allocation and two `Token.value` reads; neither wrapper type is materialized. Node and Wago execute the same output.

`tools/benchmark-box-escape.py` measured direct projection against a wrapper passed through a reference-returning helper over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `struct.new` | `struct.get` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| nonescaping wrapper | 0.0171 µs | 1 | 1 | 434 |
| retained wrapper | 0.0182 µs | 2 | 2 | 464 |

Wrapper elimination measured 0.9397x the retained runtime, about 6.0% faster, and removed one allocation, one field read, and 30 Wasm bytes.

## Fresh tuple-variant payloads

A match over direct fresh tuple-variant construction now eliminates the enum allocation and dispatch when the selected arm is unguarded, matches the exact constructor, and directly returns one payload binding. Preceding exact arms for different constructors are proven disjoint and skipped without evaluating their guards. An alternative arm is also accepted when frozen constructor evidence proves exactly one alternative can match the known variant and every sibling is constructor-disjoint. Matching-constructor guards are accepted when deterministic folding has reduced them to exact Boolean constants: false arms are skipped and true arms select normally. A bounded nonconstant Boolean tree of local/capture reads, exact integer/Boolean constants, logical negation, conjunction/disjunction, and compiler-preamble integer comparisons is also removable for tuple and struct variants when every possible constructor-compatible fallthrough arm returns the identical direct payload component. This includes guards over payload bindings: either guard outcome has the same result, so the guard tree is discardable. Struct component equality is resolved through frozen field layout/name identity; user-defined operator calls remain conservative. Guard-false skipping occurs before constructor relation analysis, so preceding wildcard and binding catchalls can also be proven non-intercepting without materializing the known scrutinee. An unguarded or constant-true wildcard/binding catchall is now selected when its result is an independent supported scalar constant: every known variant initializer is retained as a source-ordered discarded selector argument before the constant result. A direct binding catchall may also return the exact bound variant unchanged; the match becomes an identity selector around the original constructor, preserving allocation and reference identity while deleting dispatch and unreachable arms. If the catchall body is a nested match whose scrutinee is exactly the binding, the existing fresh-payload proof runs on that inner match and its scalar selector replaces the outer match, eliminating both dispatches and the variant. Direct fresh tuple or struct constructor arms may also feed one bounded exact scalar transform containing primitive sign/logical operations, bitwise operations, comparisons, addition, subtraction, or multiplication with constants. Exactly one payload binding may appear; the binding read becomes the source-ordered selector before the transform. Trapping arithmetic, multiple payload bindings, arbitrary transforms, and nonconstant catchall guards remain barriers. The match expression becomes a `PlannedParameterSelect` over the constructor arguments. Every payload argument still evaluates once in source order, the selected scalar/reference/generic carrier is forwarded directly, and all other arms remain unevaluated. The same proof follows an immutable uncaptured sole-use local when its only read is the match scrutinee: the constructor declaration and local read are elided without moving the selector from the original match location.

The success snapshots cover tuple scalar/reference payloads and direct plus let-bound struct-variant fields. Struct patterns resolve the returned binding to the constructor field through frozen layout identity/name, then append every constructor initializer to the same source-ordered selector plan. This proof now recurses through nested fresh struct and tuple-struct patterns: each inner aggregate is converted to its own source-ordered selector before the outer variant selector forwards the final scalar. Separate tuple, struct, and nested trap fixtures select the second binding but give the first payload an `unreachable` trap and the second an integer divide-by-zero trap; Node and Wago both observe `unreachable`, proving complete payload evaluation order. The success WAT contains no enum or nested aggregate construction, constructor test, cast, or payload extraction operation.

`tools/benchmark-enum-payload-escape.py` measured direct fresh projection against a variant passed through a reference-returning helper over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `struct.new` | `struct.get` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| direct tuple payload | 0.0164 µs | 0 | 0 | 440 |
| constructor-disjoint preceding arm | 0.0156 µs | 0 | 0 | 440 |
| constructor-resolved alternative | 0.0154 µs | 0 | 0 | 440 |
| exact constant guards | 0.0216 µs | 0 | 0 | 440 |
| stable nonconstant guard | 0.0168 µs | 0 | 0 | 455 |
| stable composite guard | 0.0239 µs | 0 | 0 | 462 |
| payload-dependent stable guard | 0.0166 µs | 0 | 0 | 448 |
| exact tuple payload scalar transform | 0.0165 µs | 0 | 0 | 455 |
| exact struct payload scalar transform | 0.0168 µs | 0 | 0 | 455 |
| false wildcard/binding catchalls | 0.0164 µs | 0 | 0 | 443 |
| selected constant catchall | 0.0161 µs | 0 | 0 | 451 |
| exact binding-forward catchall | 0.0167 µs | 1 | 2 | 516 |
| nested binding projection | 0.0162 µs | 0 | 0 | 451 |
| immutable tuple local | 0.0161 µs | 0 | 0 | 440 |
| retained tuple variant | 0.0167 µs | 1 | 2 | 522 |
| direct struct field | 0.0165 µs | 0 | 0 | 448 |
| stable-guard struct field | 0.0164 µs | 0 | 0 | 455 |
| retained struct variant | 0.0173 µs | 1 | 3 | 540 |
| nested aggregate payload | 0.0172 µs | 0 | 0 | 453 |
| retained nested payload | 0.0174 µs | 2 | 6 | 587 |

Direct, reordered-arm, alternative-arm, constant-guard, stable-guard, composite-guard, payload-guard, scalar-transform, false-catchall, selected-catchall, binding-forward, nested binding-projection, and let-bound tuple paths measured 0.9536x, 0.8955x, 0.9124x, 0.9826x, 0.9594x, 0.9652x, 0.9652x, 0.9652x, 0.9768x, 0.9594x, 1.0058x, 0.9710x, and 0.9768x the retained runtime on the latest run. Binding forwarding is tied but removes six Wasm bytes and the first match's dispatch while intentionally retaining the one live variant; nested projection removes every variant operation. Direct struct, stable-guard struct, struct-transform, and nested elimination measured 0.9654x, 0.9596x, 0.9711x, and 0.9173x. Nested elimination removed 134 Wasm bytes, two allocations, and six aggregate reads.

## Exact trait-object flow audit

The existing exact-flow analysis was promoted to an explicit optimization contract. `optimization/trait-object-escape-runtime` sends an `I32` through erased identity and invocation wrappers; the final 255-byte WAT contains only one scalar identity helper and its caller. It contains no struct allocation/access, cast/test, dictionary global, table, adapter root, `ref.func`, or `call_ref`. Node and Wago return the same value.

`tools/benchmark-trait-object-escape.py` compares a nominal receiver passing through exact erased identity/invocation wrappers with direct static dispatch over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `struct.new` | `call_ref` | `ref.func` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| exact erased flow | 0.0192 µs | 1 | 0 | 0 | 448 |
| direct static flow | 0.0188 µs | 1 | 0 | 0 | 448 |

The exact erased path is byte-identical in size and has the same allocation/dispatch instruction counts as direct static dispatch; the 1.0212x timing ratio is within the noise floor of this host-call-scale benchmark. Conflicting evidence joins, captures, unknown assignments/calls, and externally demanded fallback bodies continue to retain dynamic representation.

## Remaining boundaries

Transforms with multiple bindings or trapping/unsupported operations, effectful or user-defined operator guards, and guards whose outcomes differ remain conservative. Alternative arms require exactly one constructor-compatible branch, and nested paths are limited to fresh struct and tuple-struct constructors with one unambiguous scalar binding.
