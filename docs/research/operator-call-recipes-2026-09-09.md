# Operator call operand recipes

`PlannedOperatorCall` stores its left/right source expression IDs separately
from its generic type-argument span. The old call planner and dependency graph
read that type span as expression children. A concrete operator therefore had
an empty saved operand recipe, while emission bypassed the recipe and pushed
both inputs directly. Result-only verification missed the mismatch.

The planner now records the left value as its receiver and the right value as
its explicit argument. Both retain source evaluation order. The work graph
depends on the two expressions, not the type-argument arena. Operator calls
run the same argument verifier and frozen call scheduler as ordinary selected
calls. Unit erasure and non-returning evaluations use that shared scheduler.

The main direct-call path also reports BOD-607 with its complete numeric
caller context when neither a saved target nor an explicit builtin declaration
is present. It no longer emits an empty sequence for that missing target.

Tests inspect a concrete operator recipe independently and execute an operator
with visible left/right side effects at six 64-bit boundary values in both
compiler lanes. Policy checks forbid direct operand emission for operators.

The first test fixture incorrectly declared a local Eq trait while using
integer equality without an implementation. That test failed at inference,
not at the intended recipe assertion (65.118 seconds). The corrected fixture
and implementation passed 745 hardening tests and all then-current shared
checks in 67.806 seconds. No claim is made that the initial failing fixture
was a valid witness of the recipe defect.

Full reference assignability, all hidden-argument families, and non-call
operator carrier propagation remain separate work. Runs above 30 seconds
remain recorded timing bugs; speed work is deferred.

Final checks passed: 746 hardening tests, 360 complete numeric records, and
all shared source checks (72.404 seconds). The native stdlib lane passed,
including the six new operator cases (28.676 seconds). Generated and policy
checks passed (4.682 seconds). Clean bootstrap passed (201.299 seconds), with
identical B/C raw and linked SHA-256:
`23fb48f7a0519cdcd7c2d8f33f9278b7bad0ac8fe2abf0f3f532f0dbf9f1b8ff`.
