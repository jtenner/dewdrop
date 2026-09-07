# String equality in Dew

`string_equals` now calls the ordinary Bytes equality function through the
explicit String-to-Bytes reference cast. The compiler no longer provides a
String equality algorithm or roots a runtime function by its builtin name.
Compiler source helpers use the ordinary String method too.

String literal patterns require their selected Eq target. Both emitters use
the retained target and reject missing evidence. The self-host physical checker
reports BOD-607 for a literal pattern with no comparison recipe. The literal
still has a String carrier; only the comparison produces Bool.

The optimizer treats a missing comparison target as non-discardable. A test
without an Eq declaration failed before this change because the match was
marked discardable (9.669 seconds). This preserves the later diagnostic rather
than allowing optional optimization to hide invalid state.

The old standalone solver probe no longer contains a separate String-pattern
fixture tied to the deleted builtin. Its solver checks remain. Five shared
String-pattern execution cases cover ordinary/custom equality, nested patterns,
source evaluation order, and retained effects in both compilers.

## Validation

- Source policy: three checks pass (0.038 seconds).
- Native standard-library and shared runtime tests pass (30.338 seconds).
- Self-host hardening: 237 tests, 29 numeric failure records, and all shared
  runtime checks pass (62.546 seconds).
- The first full native run found two exhaustive test matches that lacked the
  new `InvalidPatternEqualitySignature` error. Both now report its full data.
- Native tokenizer (36), parser (289), semantic (501), and backend (93) tests
  pass. The semantic lane takes 80.485 seconds and the backend lane 37.949
  seconds. The missing-evidence effect test passes in the semantic lane.
  The remaining loader (17) and driver (2) tests pass in 3.692 and 8.487
  seconds. All 938 routine native tests pass across these serialized runs.
- All 268 integration tests pass (49.107 seconds). Generated checks pass
  (15.795 seconds).
- Clean bootstrap passes (167.239 seconds). Compiler B and C raw and linked
  bytes all have SHA-256
  `6e9f635801b58f329cc6be273eaccf337ad99faa7d592eb94812beecd72ad7b5`.
  Compiler A build takes 40.188 seconds; A and B compilation takes 43.924 and
  58.516 seconds. Each is still above the performance limit.

Runs above 30 seconds remain performance bugs. Text storage, views, builders,
and their remaining runtime operations are not complete in this commit.
