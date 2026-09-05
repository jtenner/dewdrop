# Specialization shapes retain missing and erroneous evidence

The self-host canonicalizer no longer maps Generic or Error to Ref. This also
applies to nested products. Structural equality keeps all three states distinct.
Physical request insertion checks every candidate, including nested fields,
before lookup or mutation. A prior reference request cannot absorb an invalid
request. SPC-301 records the target declaration, caller module/body/expression,
type argument index, and whether the invalid evidence is Generic (1) or Error (2).
All five production insertion paths supply their call context.

Generic substitution now requires the exact declared generic slot. Having one
caller type argument is not proof that an unrelated missing or erroneous type
means that argument. Normalization and equality also check their work stacks;
missing tasks cannot become fabricated logical shapes.

Logical generic field declarations are different from physical call requests.
Erased struct fields must have their existing explicit boxing metadata and
reference storage. Runtime variant templates must have their recorded adapter
identity and reference storage. Neither exception applies to Error, ordinary
function signatures, or specialization requests. The general storage comparison
does not accept Generic. These checks preserve the existing mixed I32/I64 Box
execution test without making generic evidence into a reference certificate.

## Regression evidence

Before the fix, normalization erased Generic and four invalid request tests did
not trap. All five failed visibly. The numeric host probes now check all nine
SPC-301 context fields. Positive tests check nested products, canonical request
deduplication, idempotence, and missing field boxing metadata.

The stricter boundary also caught a test that continued a known inference error
through physical planning. The test now inspects lowering diagnostics directly;
it still requires the contradictory explicit type to produce a type error.

## Validation

- 773 native tests, 266 full integration tests, and all generated-source,
  Facet, and CLI checks passed. Generated checks took 3.096 seconds.
- 114 hardening tests and 20 exact numeric failure-record checks passed.
- All 21 existing emission probes passed, along with the narrow-float (72),
  scalar conversion (750), memory (201), arithmetic (1,332), and math (238)
  execution matrices.
- Clean B/C bootstrap passed with identical SHA-256
  `0dec9760338f084c70afa592ea20ef7339eee6e20ed2ec86b88efdef8ccf7c9d`.

Measured performance bugs remain: compiler A build took 31.797 seconds;
compiler B/C generation took 61.422 and 61.492 seconds. Hardening generation
took 2.477 seconds, linking 4.761 seconds, and emission probes 4.069 seconds.

## Remaining scope

This batch hardens self-host specialization requests and their shared
normalization consumers. Native specialization and broader function/field
fragment boundaries still have legacy missing-evidence fallbacks. They remain
separate work items; passing this batch does not close the entire physical ABI
audit or standard-library migration.
