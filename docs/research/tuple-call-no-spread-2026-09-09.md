# Tuple call arguments do not spread implicitly

The self-host physical signature maps a product parameter to one nullable
reference. Call planning and emission formerly split a product expression
into fields when an argument/parameter count heuristic suggested two slots.
That could hide a bad argument count or change a tuple receiver's stack shape.
The planner's receiver-adjusted heuristic also differed from emission's rule.

Both heuristics are removed. A tuple argument stays one evaluation and one
operand; its normal constructor creates the reference. Unit arguments are
still evaluated without an operand. Non-returning arguments still stop the
evaluation schedule. This does not change the native compiler's separate
multi-value product representation.

Call evaluation now requires the saved body plan. The old missing-plan helper
that rebuilt arguments from source syntax, including tuple spreading, is
deleted. BOD-610 records the complete caller identity before the trap.

The first tuple fixture used unsupported numeric field syntax and failed
parsing (60.516 seconds). After using a tuple binding, both intended red tests
failed: the tuple was spread and a missing plan returned success (60.003
seconds). The final tuple test checks that the operand points to the product
expression, not either field. The missing-plan test checks all nine numeric
fields. Existing shared product and callback corpora check runtime behavior.

Full reference assignability and remaining local/target recovery helpers are
separate work. Compiler lanes above 30 seconds remain timing bugs; no speed
work is included.

The hardening lane passed 748 tests and 361 complete numeric records in
60.950 seconds. The native stdlib lane passed in 26.778 seconds, and generated
checks passed in 4.228 seconds. The subsequent clean bootstrap with the
[frozen-local cleanup](frozen-local-declarations-2026-09-09.md) passed in
170.262 seconds with identical B/C raw and linked output.
