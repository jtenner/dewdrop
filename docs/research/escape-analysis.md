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

## Remaining boundaries

Fresh enum payload projection is the next allocation boundary. Exact-flow trait-object escape analysis already removes envelopes, scalar/SIMD boxes, dictionaries, adapters, globals, `ref.func`, and `call_ref` when every use remains exact and nonescaping; a separate audit and contractual benchmark will close that roadmap item explicitly.
