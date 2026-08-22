# Self-host remaining scalar carriers

Date: 2026-08-22

The linked emitter now supports the remaining scalar Wasm carriers:

- signed and unsigned I64/U64 constants and arithmetic;
- signed and unsigned I64/U64 comparisons, division, remainder, and shifts;
- F32 constants, arithmetic, comparisons, and unary negative;
- F64 constants, arithmetic, comparisons, and unary negative;
- mixed scalar local declaration lists in exact logical-local order;
- I32, I64, F32, and F64 function parameters and results.

The smoke module now contains functions with I64, U64, F32, and F64 parameters, locals, results, and operators. The generated module is checked for `i64.add`, `i64.sub`, `i64.gt_u`, `f32.neg`, `f32.add`, and `f64.mul`.

Scalar result branches and scalar match/loop state outside I32 remain to be generalized. SWAR and V128 operations remain builtin lowering work.
