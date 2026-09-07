# String pattern emission

The shared runtime fixture declares its own `Eq` for String. That implementation
counts calls and always returns false. It cannot pass by using standard text
equality. Five checks cover flat patterns, nested patterns, a discarded result,
an `is` pattern, and a failed parent pattern. The first check also proves that
the subject is evaluated once.

Before the emission change, the native fixture returned 10001 instead of 10207:
the subject ran once, but the selected equality implementation did not run.

Native emission now uses the declaration and type arguments retained on the
literal, with an exact call-site specialization or a plain non-generic target.
It checks the two reference parameters and one i32 result before emitting the
selected call. Invalid signatures have a dedicated diagnostic carrying the
body, expression, declaration, and parameter/result types.

Self-host emission uses the frozen physical recipe and runs its checker again
at the emission boundary. Top-level and nested patterns use the same checker.
Failures store numeric invariant records with phase 7 and caller context.

The first self-host implementation incorrectly subtracted the two planning
imports from the frozen physical target. The runtime fixture caught the wrong
call ABI. The common emitter expects that physical index, not a logical index.
It now receives the target unchanged, with an explicit ABI-701 regression check.

The legacy path for patterns without selected trait evidence still exists during
this step. Removing that path and moving `string_equals` into Dew is next.

The optional optimizer now follows the checked pattern edges and accounts for
the selected equality method's effects. Its arm traversal also uses the stored
arm-child IDs. A regression with an equality method that traps failed before
this change: flat matches were incorrectly classified as discardable. Both flat
and nested matches must retain that effect; a separate pure function remains
discardable.

## Validation

- Native baseline failed with the expected wrong-value check (10001 vs 10207).
- Native selected-call fixture: five checks pass (9.624 seconds to build;
  0.033 seconds to run).
- Self-host exact-target hardening passes 236 tests, 29 invariant records, all
  shared probes, and the five new String pattern cases (65.751 seconds). This
  exceeds the 30-second limit and remains a performance bug.
- Effect-summary regression: failed before the fix (10.243 seconds), passes
  after it (10.001 seconds).
- All 55 optional optimizer integration tests pass (7.519 seconds).
- Native stdlib and shared runtime lane passes, including all five String pattern
  cases (24.758 seconds). Generated checks pass (17.233 seconds).
