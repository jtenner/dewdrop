# Escape analysis and wrapper elimination

Date: 2026-08-11

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

A match over direct fresh tuple-variant construction now eliminates the enum allocation and dispatch when its first arm is unguarded, matches the exact constructor, and directly returns one top-level payload binding. The match expression becomes a `PlannedParameterSelect` over the constructor arguments. Every payload argument still evaluates once in source order, the selected scalar/reference/generic carrier is forwarded directly, and all other arms remain unevaluated.

The success snapshot covers scalar and nominal-reference payloads. A separate two-payload trap fixture selects the second binding but gives the first payload an `unreachable` trap and the second an integer divide-by-zero trap; Node and Wago both observe `unreachable`, proving complete payload evaluation order. The success WAT contains no enum construction, constructor test, or payload extraction operation.

`tools/benchmark-enum-payload-escape.py` measured direct fresh projection against a variant passed through a reference-returning helper over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `struct.new` | `struct.get` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: |
| direct fresh payload | 0.0161 µs | 0 | 0 | 440 |
| retained variant | 0.0180 µs | 1 | 2 | 522 |

Payload elimination measured 0.8946x the retained runtime, about 10.5% faster, and removed 82 Wasm bytes.

## Exact trait-object flow audit

The existing exact-flow analysis was promoted to an explicit optimization contract. `optimization/trait-object-escape-runtime` sends an `I32` through erased identity and invocation wrappers; the final 255-byte WAT contains only one scalar identity helper and its caller. It contains no struct allocation/access, cast/test, dictionary global, table, adapter root, `ref.func`, or `call_ref`. Node and Wago return the same value.

`tools/benchmark-trait-object-escape.py` compares a nominal receiver passing through exact erased identity/invocation wrappers with direct static dispatch over 10,000 alternating warmed Node 26.3.0 samples in batches of 100 calls:

| Form | Median | `struct.new` | `call_ref` | `ref.func` | Wasm bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| exact erased flow | 0.0192 µs | 1 | 0 | 0 | 448 |
| direct static flow | 0.0188 µs | 1 | 0 | 0 | 448 |

The exact erased path is byte-identical in size and has the same allocation/dispatch instruction counts as direct static dispatch; the 1.0212x timing ratio is within the noise floor of this host-call-scale benchmark. Conflicting evidence joins, captures, unknown assignments/calls, and externally demanded fallback bodies continue to retain dynamic representation.

## Remaining boundaries

Let-bound variants, struct-variant payloads, nested bindings, guards, and broader arm-order proofs remain conservative.
