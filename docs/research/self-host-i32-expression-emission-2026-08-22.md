# Self-host I32 expression emission

Date: 2026-08-22

The linked root emitter now walks lowered expressions with an explicit task stack and emits real Starshine instructions instead of accepting only one constant node.

The current instruction subset includes:

- `I32` and Boolean constants;
- unary positive, negative, and logical-not;
- integer add, subtract, multiply, divide, and remainder;
- bitwise and/or/xor;
- shifts;
- equality and ordered comparisons.

The Starshine FFI contract grew from 32 to 56 exact exports. The provider fingerprint and generated bindings changed with that reviewed interface.

Expression traversal is iterative. Left and right operands retain source evaluation order. Unsupported logical-short-circuit, exponentiation, calls, locals, aggregates, and control flow return an explicit emitter error instead of producing malformed Wasm.
