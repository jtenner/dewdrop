# Native specialization retains structural shape evidence

Three regressions failed before this change: Generic/Error normalization,
nested product normalization, and distinct product ABI keys. The native compiler
mapped missing and erroneous shapes to Ref, did not normalize nested fields,
and named every product shape `error` in its specialization key.

Normalization now preserves missing and erroneous evidence and visits product
fields with an explicit work stack. Keys encode the complete product nesting
and canonical field carriers. An equal key must also pass structural shape
comparison before an existing specialization can be reused.

SPC-301 validates each physical request before key lookup or mutation. The
diagnostic includes the declaration, argument index, and invalid evidence kind.
The specialization-to-linker handoff checks stored request shapes too. Generic
and Error do not produce a valid physical scalar/reference signature. Request
span validation uses subtraction and cannot overflow its end calculation.

The stricter rule exposed an unscoped scan of generic function references. It
visited references inside generic bodies without their caller substitution.
All function references now use the existing body/specialization scan, including
references with no trait prerequisites. The extra whole-module reference scan
is gone. The existing singleton-function-reference integration test passes
without manufacturing a reference specialization from a Generic shape.

A separate inference fix, documented in `block-expression-type-sharing-2026-09-05.md`,
was needed for Unit fields in a generic product.

## Regression coverage

- Missing and erroneous evidence remain distinct from references.
- Nested normalization is idempotent and preserves empty products.
- Product keys distinguish field order and nesting; narrow carriers canonicalize.
- Direct and nested invalid requests report the exact SPC-301 message.
- Negative and overflowing spans fail validation before arena access.
- A one-field mutation of a valid stored request fails at the linker handoff.
- Native execution covers both mixed I32/I64 orders, both nested orders, and
  erased Unit product fields. The fixture uses recursion so an identity-call
  optimization cannot remove the ABI boundary.

A valid-source indirect generic callback regression also exposed a separate
missing signature: lowering only searches existing declared function types for
an inferred function type. That needs a module-local inferred signature pool;
it must not mutate frozen interfaces or pick an unrelated signature. This is
the next bounded correction, not a reason to relax specialization checks.

Broader unspecialized fragment layout fallbacks and the remaining standard
library builtin migrations are still open. This does not close the full audit.

## Validation

- The normalization/inference batch passed 780 native and 266 full integration
  tests before the new indirect-callback regression above was added.
- 296 library tests and all scalar (750), memory (201), arithmetic (1,332), math
  (238), and recursive product (30) execution checks passed in 3.831 seconds.
  The product fixture's standalone compile/execution took 0.263/0.025 seconds.
- 114 self-host hardening tests, 20 exact invariant records, 21 existing emission
  probes, and all self-host scalar/memory/arithmetic/math execution matrices passed.
- Generated-source, Facet, and CLI checks passed in 10.300 seconds.
- Clean B/C bootstrap passed with identical SHA-256
  `0dec9760338f084c70afa592ea20ef7339eee6e20ed2ec86b88efdef8ccf7c9d`.

Measured performance bugs: cold hardening generation took 92.490 seconds;
compiler A build took 36.224 seconds and B/C generation took 59.434/61.023 seconds.
