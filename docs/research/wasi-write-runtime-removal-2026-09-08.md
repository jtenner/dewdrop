# Remove the old Bytes write runtime

Bytes I/O and test assertions now call ordinary Dew functions. Remove the private
Debug write declaration and the
native/provider write body builders, dispatch cases, and hidden reachability
rules. The provider's unused private assertion body is removed as well.

The provider constructor retains its write-function index for the two remaining
Debug text formatters. Text formatting and benchmark-only staging builders are
separate work; this batch does not claim to remove all runtime algorithms.

Red checks:

- Native removed-operation boundary: one failure, 8.055 seconds.
- Provider removed-operation boundary: one failure, 6.322 seconds.
- Source policy: three findings, 0.034 seconds.

These old operation names are intentionally unsupported after migration. The
positive shared WASI corpus checks real Dew writes, including empty input,
partial progress, multiple scratch windows, and invalid host results. Test
assertion output retains its separate exact-message CLI check.

All 18 provider bridge tests pass in 6.320 seconds. Provider commit `e41ef6fde`
removes the write dispatcher/body and unused assertion copy; its build passes
in 10.245 seconds with 4,188 public exports. Consumer regeneration passes in
4.552 seconds and retains all 469 selected signatures.

Three native write/assertion checks pass in 10.909 seconds. The expanded source
policy passes in 0.035 seconds. Preamble and builtin registry regeneration take
0.029 and 0.028 seconds. The old self-host runtime classification is removed too.
All verification lanes run in order. No speed work is included.

The first full native run stops at one semantic test failure in 108.114 seconds:
derived Debug still generated three calls to the removed helper. Hardening had
passed 363 tests and 108 records in 153.659 seconds but lacked an executed derive
corpus. The separate [derive fix](derived-debug-literal-output-2026-09-08.md)
adds that corpus and replaces both generated callers before this removal lands.

With the derive, bound-call, and Unit fixes in place, the root verification
passes 1,065 native tests (162.971 seconds), 268 integration tests (59.527),
326 library tests and all shared execution corpora (30.679), generated checks
(18.559), and 15 stress tests (0.413). Hardening passes 365 tests, 108 records,
and all execution corpora in 57.726 seconds. The four source policy checks pass
in 0.034 seconds. Clean bootstrap passes in 172.547 seconds: compiler B/C raw
and linked SHA-256 are both
`11af19f322bcdf073be04e3598f7857dcd54e176fcceac4597f8a5c5c35f2da1`.

The full pinned Starshine lane completes after the removal commit: all 10,991
tests pass in 303.270 seconds. Provider source and bindings remain unchanged
during that run. All eight lanes pass. Its printed invalid-module diagnostic
comes from a negative provider check; the complete suite reports zero failures.
