# Deterministic constant folding

Date: 2026-08-11

The whole-program optimization pass now folds exact primitive operations after overload/operator selection and after copying the immutable lowering plan. The unoptimized plan remains byte-for-byte structurally unchanged for diagnostics, tests, and future comparison.

The initial fold domain covers Bool logical/equality operations plus I32, U32, I64, and U64 unary positive/negative where valid, bitwise operations, wrapping add/subtract/multiply, equality, and signed/unsigned comparisons. Folding iterates to a deterministic fixed point so nested constant trees collapse regardless of expression allocation order. Exact selected primitive `PlannedOperatorCall` nodes and structural Boolean `PlannedBinaryExpression` nodes share the same evaluator.

Potentially trapping division/remainder, shifts, exponentiation, packed integers, and floating-point operations are intentionally not folded yet. This avoids changing trap timing, NaN payloads, signed-zero behavior, or narrowing semantics before those policies have dedicated parity tests.

For the checked-in arithmetic/comparison/wrapping fixture, folding reduced the emitted Wasm from 590 to 564 bytes and the rendered WAT from 1,906 to 1,642 bytes. The architecture case forbids the eliminated add/multiply/subtract/signed-less-than and i64 multiply/equality instructions while preserving runtime assertions and deterministic output.
