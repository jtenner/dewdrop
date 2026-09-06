# Query metadata needs real operator evidence

The compiler-B type-query probe found that equal `Bytes` literals compared
unequal. The generated compiler used reference identity for a binary expression
whose `Eq` implementation was imported. This made valid type-returning builtin
metadata fail the runtime-storage check with CT-037.

Two defects preceded that result:

- Manifest collection assigned standard modules ordinary sequential IDs. Frozen
  interface ownership checks therefore omitted their primitive implementations.
  A generated, version-1 identity registry now matches the native package IDs.
  This is semantic package identity, not physical ABI selection by source name.
- Binary operator inference searched only local traits. Concrete reference
  operands now use the imported trait declaration and a unique viable method.
  Local implementations of imported traits join the same candidate set. Scalar
  primitive operations keep their existing direct instruction path. Generic
  receiver obligations still require the separate deferred-evidence work.

The newly accurate package identities also exposed dead library functions in
physical fragments. Specialization had not visited them, but linking still
included them. Plain fragments now use the specialization reachability set.
No missing-target diagnostic was removed or weakened.

The shared query fixture has 41 execution checks, including exact and near-miss
metadata byte strings. Compiler B has a dedicated type-query semantic probe;
failure remains visible before it attempts the full compiler-C build.

Measured development hardening: 29.294 seconds total; test generation 7.599,
linking 8.912, emission checks 7.137. All 187 tests, 29 invariant records, 41 query
checks, library probes, and five semantic probes passed before the added package
identity unit tests.

Full `tools/check-self-host-bootstrap.sh --fast` passed in 146.996 seconds.
Compiler A built in 35.905 seconds; A emitted B in 44.873 seconds; B emitted C in
47.410 seconds. These three phases exceed the 30-second budget. B's five semantic
probes passed. Both raw and linked B/C Wasm compare byte-for-byte equal, with
linked SHA-256 `f8272e106f7b24236fa81ee14f90ceeac41b42a42d6eb45a81d34378a54e6c02`.
This is a fixed-point check, not a claim that deferred generic branch checking
or every query TODO is complete.

With the four new package/operator tests included, hardening passes 191 tests
in 29.348 seconds. Native execution passes the same 41 query checks (0.024
seconds after a 0.662-second cached build); the native package registry check
also passes (0.098 seconds).
