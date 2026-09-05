# Verify the selected lambda body

A lambda and its parent share the root body ID. Physical verification tried the
ordinary body lookup first and consulted the lambda ID only when that failed.
It therefore checked the parent's root and locals against the lambda's plan.

Body lookup now dispatches on the plan's explicit lambda identity. A lambda must
match both its own ID and root body ID; it cannot fall back to a named body.
The method-call and emitted-local verification passes use the same helper.
A missing source body produces BOD-610. A missing root expression remains
unresolved rather than becoming Unit. Planning a linked defined function with
no source body records BOD-610 before it can silently omit the function.

The regression uses I32 and I64 lambdas inside functions returning closures.
It first checks both plans, then removes only the second lambda and requires one
BOD-610 diagnostic. A separate missing-named-body mutation checks the full numeric
record in the host harness.

Hardening passes 120 tests and 22 exact crash records. Existing emitted probes
and scalar/memory/arithmetic/math matrices pass. Generation took 2.483 seconds,
linking 4.863 seconds, and the whole lane 15.654 seconds.

The differential callback source now passes body verification. It next fails in
emission because generic function values have no recorded specialized target and
are represented as unresolved module-value reads. Explicit function-reference
selection and specialization are the next correctness boundary to repair.
