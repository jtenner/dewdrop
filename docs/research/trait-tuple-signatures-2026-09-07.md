# Trait method tuple signatures

Native implementation matching did not traverse `ProductType` fields. A valid
`Convert<I32>` implementation with `(I32, I64)` parameters and results was
rejected against the trait's `(t, I64)` signature. The new source regression
failed with two diagnostics before the fix (9.766 seconds).

The native matcher now compares ordered tuple fields through the same generic
and `Self` substitution contexts as other signature types. An erroneous field
only suppresses comparison of that field; it cannot hide a later concrete
mismatch. A one-field mutation checks this recovery boundary.

All 15 native implementation-index tests pass in 8.759 seconds. The self-host
source regression checks the same valid signature and the exact parameter and
result mismatches after changing the second tuple field to Bool. Recursive
search limits and cycle handling remain separate work.

The hardening lane passes 281 self-host tests, 61 exact failure records, and all
shared execution probes in 59.094 seconds. An initial test-fixture parse error
was corrected before this run. No speed changes are included.

The full routine native lane also passes: 961 tests in 122.234 seconds.
