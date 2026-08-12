# Private scalar unit-enum parameter specialization

Date: 2026-08-12

The whole-program optimizer now extends private unit-enum tag representation across one bounded ABI boundary: a module-visible, receiver-free, non-generic function parameter may use its stable source-order `I32` tag when every use and every program call site is proven compatible.

The proof requires:

- the parameter's nominal declaration is a module-visible, non-generic enum with at least two unit-only variants;
- the callable has a local function body, is not compiler-owned or a test entry, and has no receiver or generic parameters;
- the parameter local is uncaptured and every read is the direct scrutinee of an unguarded exact-constructor match for that enum;
- every reference to the callable is a direct or tail call with no receiver or type arguments;
- every argument at the selected position is a bounded tree of exact unit constructors, block tails, and `if` results for the same enum;
- at least one complete call site exists.

Preflight completes before mutation. The optimizer then rewrites all accepted argument trees to tags, changes the parameter/local/read/pattern carriers to `I32`, and leaves unrelated parameters and callable results unchanged. Fragment planning derives the private function's physical parameter from the optimized shape, emits a distinct physical signature when the resolved source function type still names the enum, and omits the enum type when no other reachable value needs it.

Public functions, function references, methods, generic functions, payload-bearing enums, guarded/catchall/alternative parameter matches, captured parameters, escaping reads, cross-module call sites, and unsupported argument trees remain reference-backed. Private results are handled by the separate result-specialization tranche documented in `scalar-unit-enum-result-specialization.md`.

`optimization/scalar-unit-enum-parameter-runtime` covers direct and conditional constructor arguments. `optimization/scalar-unit-enum-parameter-order-trap` confirms an argument condition still traps before call dispatch. `optimization/scalar-unit-enum-parameter-budget` has no enum struct type, construction, tag load, cast, reference test, table, indirect call, or `local.tee`.

`tools/benchmark-scalar-unit-enum-parameters.py` compares 64 private direct calls with the same enum made public so the reference ABI remains. Over 10,000 warmed Node samples in batches of 100 calls, the scalar parameter form measured 0.0694 µs versus 0.1834 µs, or 0.3785x. It reduced the binary from 1,000 to 791 bytes and removed 64 `struct.new`, one `struct.get`, and one `ref.cast` instruction. The exact timing is host-scale evidence rather than a universal runtime claim; allocation and binary reductions are the stable contract.

## Remaining boundaries

Scalar payload enums need a tag-plus-payload or multi-value ABI plan with exactly-once payload evaluation. Public/generic signatures and function-value boundaries still require adapters and ABI versioning.
