# Frozen binary operand width

## Cause

Self-host binary emission read the correct frozen operand carriers, then
replaced the left shape with a source loop, match, declaration, or parameter
hint. For nested enum bindings in a product pattern, the match hint could be
`I32` while the frozen carrier and Wasm local were `I64`.

The new transform interpreter exposed this with
`(Number(a, kind), Number(b, other))` in `ct_binary`. Compiler A compiled from
native source was valid. When A compiled compiler B, it emitted `i32.add` and
other 32-bit operators for the two `U64` payload locals. Starshine rejected the
module with `expected=I32 actual=I64`.

## Fix

Binary emission now selects the operand width from the frozen expression
carriers. It does not replace that width with source pattern hints. The existing
integer sign proof still selects signed or unsigned instructions from logical
operand types.

The change removes repeated loop, match, declaration, and parameter scans from
binary emission. It adds no arrays, locals, or generated-program allocations.
No measured speed or memory gain is claimed yet.

## Tests

The existing product-pattern runtime fixture now has ten additional checks for
nested `Number(U64, String)` payloads: add, subtract, multiply, three bit
operations, equality, unsigned comparison, division, and remainder. The inputs
use bits above bit 31. The unsigned comparison also checks bit 63.

The shared JavaScript check now requires all 27 product-pattern results. The
native and self-host runtime lanes use the same fixture and checks.

`semantic_product_patterns_test.dew` also requires successful self-host emission
of a nested numeric product addition.

## Evidence

- Saved compiler A reproduced the exact invalid operator in the runtime fixture
  before the fix: 1.428 s.
- Native fixture generation passed in 0.254 s. All 27 native runtime checks passed
  in 0.033 s. Raw output: `.tmp/transforms/wide-product-native.log`.
- Rebuilt compiler A generated the fixture in 1.473 s. All 27 runtime checks on
  that self-host output passed in 0.039 s. Raw output:
  `.tmp/transforms/wide-product-green.log`.
- Raw failure: `.tmp/transforms/wide-product-red.log`.
- Request: `.tmp/transforms/wide-product.request.bin`.
- Request source: `tools/dew-test/product_patterns.dew`.
- Bootstrap failure before the fix: `.tmp/transforms/bootstrap.log`.

The fresh A/B/C bootstrap passed in `.tmp/transforms/bootstrap-2.log`. Compiler
A compiled B in 17.588 s, and B compiled C in 17.553 s. B and C have the same
SHA-256 hash:
`1c1eea6a9ce70416ad267342b935dbdc3cb2ac9f9d0c8b51ef4805ae646f1228`.
The direct emission test is also part of the self-host hardening lane.
No format or version change is needed.
