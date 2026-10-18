# Product match and loop scalar box demand

Date: 2026-10-18

## Fault

The native emitter stores a multivalue product match subject in scalar locals,
then boxes its leaves into the canonical product storage array for pattern
matching. Functional product loops use the same storage boundary for their
initial state. The physical linker did not include either boundary in its
scalar-box demand walk.

A function that matched two Boolean scalar parameters as a tuple could therefore
fail emission with `UnsupportedExpression(..., -422)`. An unrelated boxed
product elsewhere could hide the missing demand. The new finite pattern
coverage work exposed this old backend fault; a wildcard fallback reproduces it
without that new feature.

## Change

Physical linking marks scalar box kinds for the match subject and functional
loop initial state when those values have product shape. The existing recursive
leaf walker selects the exact used carriers. It skips Unit and reference leaves
and handles nested products and generic leaves by the same rules as other
product storage boundaries.

The change preserves the product ABI, representation, instruction sequence, and
allocation scheme. It adds only the type declarations required by the emitted
boxes. It does not add a runtime check or a new allocation site. Avoiding product
boxing during pattern matching would be a separate optimization.

The tests use wildcard fallbacks, so this fix can precede the finite product
coverage change. They check Boolean matches, wildcard-only products with F32,
F64, and V128 leaves, and functional loop state with I32 and I64 leaves. Each
case requires only its used scalar box slots and validates the emitted Wasm.

## Validation

- New native demand/emission tests: 0/3 before the fix (8.273 seconds), then 3/3 after it (8.257 seconds). All initial failures identified missing scalar box slots. Green checks also validate complete emitted Wasm.
- Existing `starshine_product_array_wbtest.mbt`: 7/7 (2.214 seconds).
- Native release CLI rebuild: 26.316 seconds.
- Wildcard-fallback runtime probe: compiled in 0.178 seconds, 1,326 Wasm bytes. All four Boolean pairs return the expected 30, 20, 10, and 10. Both I32/I64 loop branches return their expected I64 value.
- The new finite Boolean product match from the coverage work: compiled in 0.163 seconds, 1,051 Wasm bytes. All four pairs and `main()` pass.

The self-host representation differs. `PlannedProductNew` creates exact typed
right-nested pair structs, and product patterns inspect those references. It does
not use native multivalue products or the native erased scalar-box array. Source
inspection found no matching omitted demand boundary.

An existing compiler C checkpoint also compiled the wildcard product and loop
probe in 1.205 seconds. Its exported `main` checks all four Boolean cases and both
loop branches, returning 42 only when every check passes. Node returned 42.
This is a checkpoint runtime check, **not** a fresh build of the current
self-host compiler or a check of its new finite-coverage feature. The checkpoint
SHA-256 is `1b40919b3db9221a9452e1aa8426f6da4fa554af0ce874e406201a5829ce3d0f`.

Raw commands, outputs, timing, runtime assertions, probe sources, and compiler
identities are saved in `/tmp/dewdrop-review-2026-10-18/backend-product` for this
session. No new runtime performance gain is claimed.
