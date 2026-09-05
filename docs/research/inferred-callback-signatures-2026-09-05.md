# Inferred callback signatures

## Defects

Valid source using `let callback = reader::<(I32, I64)>()` inferred its
function type, but lowering could not find that concrete signature in the frozen
interface. It emitted a function-value call with type ID -1. Function references
inside generic bodies also lacked caller-specific target records and could be
resolved again using their unspecialized shapes.

## Change

Lowering now materializes inferred function signatures in a private type pool.
The frozen interface remains unchanged. The pool interns nested products,
applications, and functions with structural checks after hash lookup. Missing
and error children do not form signatures. Fragment discovery consumes this
lowering-owned pool and includes function-reference signatures.

Every specialized function reference records its exact caller/body/expression
target. Generic bodies use singleton objects keyed by that physical function.
Concrete references retain their existing precise-reference adapters. A cache
keyed only by declaration cannot merge references with different physical ABIs.

## Checks

- Three type-pool tests pass, including hash collision and error-child tests.
- The valid-source inferred-product callback emission test passes.
- All 45 program-link backend tests pass after retaining the concrete adapter
  singleton path; an intermediate run exposed and then removed a duplicate raw
  singleton beside its adapter.
- 36 runtime checks pass: scalar, mixed-width tuple, nested tuple, and erased
  Unit fields, including I64 limits. The recursive-product lane shares its
  30-case oracle with the callback lane.
- The formerly malformed generic callback integration fixture now uses legal
  explicit type arguments and checks collection, resolution, and inference.
- Measured focused emission: 12.498 seconds; program-link checks: 13.007
  seconds; callback compile: 8.944 seconds; execution: 0.028 seconds.

This batch does not claim completion of reference callback ABI adaptation. A
follow-up runtime case, `reader::<Item>()`, exposed an illegal function-reference
cast between the erased generic callback and its nominal callback signature.
That boundary needs its own regression and fix. Full bootstrap validation also
remains required after the callback changes.
