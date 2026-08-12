# Private scalar unit-enum specialization

Date: 2026-08-12

The whole-program optimizer now specializes a first conservative enum representation: immutable body-local values of a private, non-generic, unit-only enum may use their stable source-order `I32` tags instead of WasmGC subtype references.

The proof is intentionally local and closed:

- the enum declaration is module-visible rather than public;
- the enum has at least two variants, no generic parameters, and only unit payloads;
- the candidate is one immutable uncaptured `let` local;
- its initializer is a bounded tree of unit constructors, block tails, and `if` results for that exact enum;
- every read of the local is the direct scrutinee of an unguarded match;
- every arm is an exact constructor arm for the same enum;
- no binding/catchall, capture, mutation, return, call argument, field, module value, or other escaping use is accepted.

The optimizer preflights the complete initializer and all local uses before mutation. It then rewrites unit constructors to their frozen source tags, changes the initializer/control-flow/local/scrutinee carriers to `I32`, and marks the exact constructor patterns as scalar. The backend compares the scalar scratch local directly with each frozen tag. It emits no enum construction, tag-field load, reference cast, reference test, or scalar-enum physical type for the fully specialized private case.

Source behavior remains unchanged. Initializer conditions and any preceding block effects remain in place and execute exactly once. Match arm order and exhaustiveness traps remain deterministic. The order-trap snapshot confirms that a trapping initializer condition occurs before any tag dispatch.

Public enums retain the subtype-family ABI. Generic, payload-bearing, guarded, captured, escaping, mutable, catchall, alternative, and otherwise non-direct cases remain reference-backed. This avoids adapters and preserves ABI identity while the representation experiment is limited to values that cannot cross a body-local boundary.

`optimization/scalar-unit-enum-runtime` covers two repeated matches over one scalarized local. `optimization/scalar-unit-enum-budget` is allocation-free and contains no enum struct type, `struct.new`, `struct.get`, `ref.cast`, `ref.test`, `br_table`, globals, tables, indirect calls, or `local.tee`.

`tools/benchmark-scalar-unit-enum.py` compares 64 calls through a private scalarized enum with the same source shape made public so the subtype-family representation is retained. Over 10,000 warmed Node 26.3.0 samples in batches of 100 calls, the private scalar form measured 0.1394 µs versus 0.1749 µs, or 0.7967x. It reduced the binary from 1,024 to 995 bytes and removed two `struct.new`, one `struct.get`, and two `ref.cast` instructions.

## Remaining boundaries

Direct private unit-enum parameters/results and one bounded packed single-`I32`-payload parameter/result ABI are now implemented in separate measured tranches. Broader joins across aliases still need control-flow-sensitive representation propagation, while public, generic, function-value, imported, method, multi-field, nested, and non-`I32` payload boundaries require deterministic adapters or ABI versioning.
