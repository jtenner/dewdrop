# Self-host 32-bit scalar carriers

Date: 2026-08-22

The linked scalar emitter now handles all integer values carried by Wasm `i32`:

- `I8`, `I16`, and `I32` constants;
- `U8`, `U16`, and `U32` constants;
- signed and unsigned comparisons;
- signed and unsigned division and remainder;
- signed and unsigned right shift;
- short-circuit logical `and` and `or`.

Short-circuit operators use result-producing Wasm `if` instructions. They do not evaluate the unused operand.

The smoke module includes a `U32` comparison above `I32::MAX` and checks for `i32.gt_u`. It also includes a short-circuit condition and an early return.

I64, U64, F32, F64, SWAR, and V128 carriers remain.
