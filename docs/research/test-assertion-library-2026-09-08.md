# Test assertion output in Dew

The test generator currently injects an opaque dew_test_assert builtin. Native
planning secretly adds String-to-Bytes and WASI-write dependencies, and native
emission redirects ordinary assertion intrinsics to that hidden body.

Replace the injected declaration with an ordinary module-local assert function.
It must evaluate the condition and dynamic message once, write through the Dew
WASI Bytes loop on failure, then execute the one-to-one unreachable intrinsic.
Normal name resolution must select this function. Production assertion behavior
is a separate change; test compilation must not require emitter redirection.

Remove the test-assertion body builder, runtime classification, hidden dependency
roots, and inline target override. The existing visible-message CLI fixture and
backend validation test will remain, with checked partial/invalid write behavior
provided by the ordinary WASI library. Do not delete that visible diagnostic test.

The policy red run reports seven findings in 0.041 seconds. The two existing
backend tests pass before changes in 0.909 seconds. Replacing their runtime
fixture with the ordinary Dew function passes in 9.719 seconds before removal
of the old compiler support.

The generator now injects the ordinary function. The old native body, runtime
classification, hidden dependency roots, and target override are removed. The
policy passes in 0.041 seconds. The native test checks the exact selected
assertion declaration is a defined Dew function, with no old assertion or write
runtime. Eight focused backend tests pass in 11.681 seconds; the exact named
declaration check passes in 9.431 seconds. The real CLI negative fixture exits
with status 1 and the exact dynamic message
`assertion failed: visible assertion λ` in 95.547 seconds, including a native
tool rebuild. This is the expected
failure, not a passing test accepted after an unrelated trap.

Hardening passes 363 tests, 108 exact failure records, and all shared corpora in
55.065 seconds. All 1,061 native tests pass in 151.746 seconds, and all 268
integration tests pass in 58.267 seconds. The library passes 326 tests and all
shared corpora in 31.035 seconds. Generated checks pass in 17.249 seconds;
15 stress tests pass in 0.350 seconds. Bootstrap passes in 164.353 seconds,
with identical compiler B/C raw and linked hashes:
`a4a18d0530f75ac40527b82a942784f30783815dc22784c786e9c47b3a0708fa`.
Runs above 30 seconds remain speed bugs.

Old Debug/write transport and production assertions remain separate work and
must not be marked complete by this batch. The provider also has an unused
private copy of the old assertion body (no dispatcher or export calls it);
that copy is removed by the subsequent
[provider transport cleanup](wasi-write-runtime-removal-2026-09-08.md).
