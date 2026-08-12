# Private scalar-payload enum specialization

Date: 2026-08-12

The whole-program optimizer now extends private enum scalarization to a bounded payload ABI. A module-visible, non-generic enum may use one packed `i64` value across proven private direct parameter and result boundaries when every variant is either unit or has exactly one `I32` tuple payload and at least one variant carries a payload.

The representation is deterministic:

- bits 0 through 31 contain the frozen nonnegative source-order variant tag;
- bits 32 through 63 contain the exact `I32` payload bits;
- unit variants use a zero payload field;
- matching extracts the low tag with `i32.wrap_i64` and a bound payload with `i64.shr_u 32` followed by `i32.wrap_i64`.

This layout preserves every signed and unsigned `I32` bit pattern without allocation. Payload expressions execute exactly once before packing, branch conditions and block effects stay in source order, and match scrutinees still evaluate once into the existing scratch local.

Parameter specialization requires:

- a module-visible receiver-free non-generic local function;
- an uncaptured enum parameter read only as the direct scrutinee of unguarded exact-constructor matches;
- only direct or tail call references without receiver or type arguments;
- a complete bounded argument tree of exact constructors, block tails, and `if` results for the same enum at every call site.

Result specialization requires the same callable restrictions, a complete constructor/block/`if` body result tree, and exactly one direct unguarded exact-constructor match consumer for every direct or tail call result.

All preflight completes before mutation. Accepted constructors, control-flow joins, parameters/results, locals, calls, scrutinees, and root patterns change together to the `I64` lowering carrier. Fragment planning emits distinct private `i64` signatures when the resolved source function type still names the enum. Type reachability ignores scalarized constructors and patterns, so the private enum physical subtype family is omitted when no retained value requires it.

Public enums and callables, generic enums/functions, methods, function references, cross-module boundaries, struct-style payloads, zero or multiple tuple payload fields, non-`I32` payloads, nested/refutable payload patterns, guards, alternatives, catchalls, captures, escaping parameter reads, and stored/aliased/duplicated result consumers remain reference-backed. Local-only payload scalar replacement remains a separate optimization and can remove allocations without changing an ABI.

`optimization/scalar-payload-enum-runtime` covers packed parameter and result paths for unit and payload variants. `optimization/scalar-payload-enum-order-trap` proves a trapping payload executes before call dispatch. `optimization/scalar-payload-enum-budget` contains no enum physical type, `struct.new`, `struct.get`, `ref.cast`, `ref.test`, table, global, indirect call, `local.tee`, or `br_table`; it locks in two packed constructors, two payload extractions, and private `i64` parameter/result signatures.

`tools/benchmark-scalar-payload-enum-abi.py` compares 64 private parameter calls plus 64 private result calls against the same source shape made public so the subtype-family ABI is retained. Over 10,000 warmed Node samples in batches of 100, the packed form measured 0.1644 µs versus 0.2983 µs, or 0.5512x. It reduced Wasm from 5,848 to 5,405 bytes and removed 65 `struct.new`, 130 `struct.get`, and 131 `ref.cast` instructions, replacing them with 65 shifts/ors for packing and 65 shifts for payload extraction. Exact host timing is not a universal runtime claim; allocation removal and bounded encoded-size reduction are the stable contract.

## Remaining boundaries

A general scalar-payload ABI still requires deterministic multi-carrier or multi-value representation, adapter/versioning rules, and complete propagation through public, generic, function-value, method, imported, nested-payload, stored-result, and cross-module boundaries. Those cases remain deliberately deferred.
