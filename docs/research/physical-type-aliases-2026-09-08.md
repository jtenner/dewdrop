# Physical reference and alias checks

The native type-table boundary now checks the contents of field references,
not just table positions. Local heap references must be inside the source type
arena. Recursive references must belong to the field owner's recursive group.
Function references must select a function type, not a struct with an in-range
index. Raw-array references require one of the eight declared storage carriers.
External heap targets and relocated function signatures must be present.

These checks extend the existing source-fragment preflight and final link and
emission checks. They return the same nine-field numeric record. New detail
roles 49–67 identify the reference, field, or signature operand. Source records
retain phase 5; emission records retain phase 7.

## Shared physical types

Cross-module closure and trait aliases now compare their field count, field
identity, mutability, and full relocated Wasm storage type. Equal source names
or trait IDs alone are not a layout certificate.

Every physical function-signature alias now compares its ordered parameters
and results with the emitted representative. This includes function types,
named functions, and trait method signatures in recursive groups. A signature
that exists but differs is an error, not a reason to select another signature.

The storage certificate is an injective numeric encoding of the emitted Wasm
storage type, not a hash. It preserves scalar/packed type, heap index, and
nullability. Packed signed/unsigned fields have the same Wasm storage type;
their load instruction still determines extension. Module-local and external
references to the same linked heap compare equally.

## Tests and limits

The first five bad-reference tests all failed on the old checker (9.751
seconds). All five passed after the checks were added (10.054 seconds). Three
alias mutations also failed on the old boundary (10.272 seconds), then passed
after the alias checks were connected (10.543 seconds).

The reference suite now has six cases. The alias suite covers closure field
count, identity, mutability, storage, source signature operands, heap identity,
nullability, and imported trait vtables. Each mutation starts with a valid
checked source plan. Backend tests validate the original module and compare
the complete phase-7 record after mutation.

Fixture development exposed two test setup issues: an unused nominal type was
correctly omitted, and independent named signatures were not aliases. The
fixtures now retain the second type through a real public function and create
the signature pool through a returned function value. Neither an arbitrary
trap nor an absent alias counts as a passing negative test.

This closes native canonical field/signature agreement in the linked prefix.
It does not freeze all mutable tables, replace the late adapter/text type
planning, or prove call/local/branch reference subtyping. Those tasks remain
open. Self-host production source and the pinned provider are unchanged.

## Validation

- Focused reference tests: 6 passed (1.084 seconds).
- Focused alias and trait tests: 8 passed (17.138 seconds).
- Focused backend tests: 2 passed (13.529 seconds).
- Intermediate full integration: 268 passed (80.406 seconds).
- Final native: 1,191 tests passed (229.467 seconds).
- Final integration: all 268 tests passed (77.210 seconds).
- Library: 326 tests and all shared execution corpora passed (50.277 seconds).
- Hardening: 473 tests, 146 exact invariant records, and all shared emission
  corpora passed (231.516 seconds).
- Generated checks passed (23.716 seconds).
- Clean bootstrap passed (274.580 seconds). Compiler B and C have identical
  core and linked bytes, SHA-256
  `969b9933b45cba2bfcb5c0e63efc2847be09d621fd5b9415c4f92dd0b90274f6`.
- All 15 stress tests passed (0.486 seconds).

Runs above 30 seconds remain speed bugs. This batch contains no speed work.
