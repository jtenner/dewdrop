# Keep dead expressions distinct from poison

The Array migration exposed this fault during a clean bootstrap. An intermediate
implementation reused query sensitivity to retain Map key identity, making more
callers run branch pruning. The flow pass removed unreachable typed returns,
including the final Result error return after an exhaustive returning match in
`self_host_compile_request_semantic_plan`. Runtime key retention must remain
separate from query sensitivity; the dead-state fix applies to real type queries.

Previously, pruning replaced these expressions with `PlannedPoisonExpression`
while retaining their logical type and nominal owner. The lowering verifier
correctly rejected a typed poison value, but the value was not an inference
error: flow analysis had proved it unreachable.

`PlannedDeadExpression` now records this proof separately. Its type and source
context remain available for diagnostics. It creates no specialization request
or physical type demand. Reaching it during branch traversal or emission reports
`BOD-610`; it cannot be repaired as a missing constructor. Genuine poison keeps
the existing lowering diagnostic. Lowering diagnostics now include the callable
name as well as its declaration ID.

The regression builds a concrete type-query branch with nominal values, checks
normal lowering, then changes one live constructor to poison. That mutation must
produce the exact typed-poison diagnostic. The fixture also checks collection
and import diagnostics so an invalid source fixture cannot appear to pass.

Validation in the combined worktree with the Array migration: 225 hardening
tests and 29 invariant records pass in 53.420 seconds. Clean bootstrap passes
in 179.043 seconds, with matching compiler B/C core and linked bytes. Both
durations exceed the 30-second limit and remain performance bugs.
