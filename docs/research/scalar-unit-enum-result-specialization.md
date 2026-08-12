# Private scalar unit-enum result specialization

Date: 2026-08-12

The whole-program optimizer now extends private unit-enum tag representation across a second bounded ABI boundary: the result of a module-visible receiver-free non-generic function may use its stable source-order `I32` tag when the complete return path and every result consumer are proven compatible.

The proof requires:

- the callable result is a module-visible, non-generic enum with at least two unit-only variants;
- the callable has a local function body, is not compiler-owned or a test entry, and has no receiver or generic parameters;
- the body result is a bounded tree of exact unit constructors, block tails, and `if` results for that enum;
- every reference to the callable is a direct or tail call with no receiver or type arguments;
- every call result is consumed exactly once as the direct scrutinee of one unguarded exact-constructor match for the same enum;
- no function reference, method/operator/index use, unmatched call result, duplicate direct match consumer, or missing call is accepted.

Preflight completes before mutation. The optimizer rewrites the complete result tree to tags, changes the callable/body result carrier and every accepted call/scrutinee/pattern carrier to `I32`, and leaves parameters and unrelated expressions unchanged. Fragment planning derives the private function result from the optimized shape, emits a distinct physical signature when the resolved source function type still names the enum, and omits the enum type when no other reachable value needs it.

Public functions, function references, methods, generic functions, payload-bearing enums, escaping or stored results, block/alias consumers, guarded/catchall/alternative matches, unsupported return trees, and incomplete consumer evidence remain reference-backed. Tail-call result chains are conservative unless every intermediate callable independently satisfies the same closed result proof.

`optimization/scalar-unit-enum-result-runtime` covers repeated direct consumers. `optimization/scalar-unit-enum-result-order-trap` confirms a trapping result condition remains before match dispatch. `optimization/scalar-unit-enum-result-budget` has no enum struct type, construction, tag load, cast, reference test, table, indirect call, `br_table`, or `local.tee`.

`tools/benchmark-scalar-unit-enum-results.py` compares 64 private result calls consumed directly by matches with the same enum made public so the reference ABI remains. Over 10,000 warmed Node samples in batches of 100 calls, the scalar result form measured 0.0371 µs versus 0.1455 µs, or 0.2548x. It reduced the binary from 4,046 to 3,263 bytes and removed two `struct.new`, 64 `struct.get`, and 65 `ref.cast` instructions. The exact timing is host-scale evidence rather than a universal runtime claim; allocation, extraction, cast, and binary reductions are the stable contract.

## Remaining boundaries

Scalar payload enums need a tag-plus-payload or multi-value representation with exactly-once payload evaluation, compatible joins, and complete ABI propagation. Public/generic signatures, function values, cross-module calls, stored results, and adapter generation remain separate work.
