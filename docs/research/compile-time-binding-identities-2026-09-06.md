# Compile-time binding identities

Set's ordinary Dew implementation exposed a second use of the Self/generic ID
collision. During method specialization, the compiler stored the concrete Self
type in the same map as generic parameters. The IDs come from different arenas.
Equal numbers do not mean equal identities.

For `Set<I32>`, this replaced the key parameter `I32` with `Set<I32>`. The nested
Map Hash query then correctly rejected the wrong type with CT-021. Specializing
the physical shape as i32 did not repair the corrupted logical type.

The native compiler now tags each binding key as generic or Self. The self-host
compiler stores the two kinds in separate maps. Query reading, specialization,
concrete method folding, inference rechecking, and physical type demand use the
matching namespace. Signature checking retains its explicit Self override.

Both direct arena tests use numeric ID 42 for Self and a generic parameter. They
must retain `(I64, I32)` without an explicit signature override. The Set execution
tests cover the nested method specialization path that exposed this defect.

Validation: all 931 native tests and 266 integration tests pass. The self-host
suite passes 230 tests, 29 numeric invariant records, and all shared execution
checks, including eight real Set cases. Clean compiler B/C output is identical:
`3fefd2b01aee879f8db1ee13db2d3bef9d047307fd908faa3dec62a0fbb8d0c9`.

The full native run took 126.829 seconds; integration 47.544; hardening 51.548;
and clean bootstrap 159.120. These runs exceed 30 seconds and remain performance
bugs. The semantic native package took 78.813 seconds and backend 36.625.
