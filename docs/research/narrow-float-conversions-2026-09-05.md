# Narrow float conversions belong to the library

## Confirmed defect

The self-host numeric builtin generator kept only the first instruction of eight
float-to-I8/I16/U8/U16 conversions. This removed their range checks. An emitted
program accepted `f32_into_i8(-129)` instead of trapping. The failing execution
test reported `Missing expected exception (RuntimeError)` before this change.

## Implementation

All eight conversions are now ordinary Dew functions. They truncate to I32/U32,
check the narrow range, then use a checked equal-carrier unsafe cast. Range checks
apply after truncation: signed fractional edge values and unsigned -0.75 remain
valid. NaN and infinities trap in the full-width Wasm truncation instruction.

Removed the native implementations, their scratch-local allocation and call
emission plumbing, the generated self-host implementations, and eight obsolete
raw compatibility declarations. No compiler-owned replacement was introduced.
The generator now supports a read-only stale-output check.

The self-host execution harness uploads the actual library source through a
test-only source builder. It validates and instantiates the emitted module before
checking expected runtime traps, so missing exports or compilation failures cannot
count as a successful negative test.

## Validation

- 768 native tests and 266 compiler/backend integration tests passed.
- 296 library runtime tests passed; 16 new exported invalid-range probes trap.
- 103 self-host hardening tests, 16 numeric failure records, and 21 existing
  emitted execution probes passed.
- 72 new self-host checks cover both float widths, all four narrow destinations,
  valid values, bounds, NaN, and both infinities (0.041 seconds).
- Generated preamble, raw compatibility surface, numeric emission, and scalar
  policy checks passed. The compatibility surface has 1,183 declarations for
  803 backend inline targets; it remains a migration surface, not a finished
  instruction-only inventory.
- Clean A/B/C bootstrap passed. B and C SHA-256:
  `9919b3afaf6c12ca7204773be2ec9544c60e890f370c34fa068b571fd872e62e`.

Measured performance bugs remain: hardening generation 91.474 seconds, compiler
A build 36.444 seconds, and B/C compilation 60.629/62.772 seconds. These do not
replace the remaining correctness work. The other 92 scalar conversion builtins
and the library families in the migration worklist still require migration.
