# Loop divergence at the outer Wasm block

The receiver type-head rewrite exposed a self-host emission defect during
bootstrap. The 111.638-second run built compiler B, but Wasm validation rejected
function 4292, `self_host_linked_body_primitive_rank`: expected i32 but nothing
was on the stack. Its source loop has no fall-through path.

The loop emitter already appends `unreachable` inside the outer loop block.
Wasm does not propagate that inner stack state beyond the end of a void block.
The surrounding function therefore still needs a value or unreachable state.
The match emitter already handles this distinction.

Two small shared source fixtures reproduce the issue. An infinite-loop export
fails module validation in 41.595 seconds. A return-only loop fails in 41.084
seconds with the same missing result-stack error. The return-only form can also
be executed: its result must equal its input for every shared I64 test value.
The infinite form is validation-only and is never called.

For proven non-fall-through loops, the emitter now schedules `unreachable`
after the outer loop block. It does not add it to loops with a reachable break.
Source evaluation order and the frozen result/flow plan remain unchanged.

Combined hardening with the receiver type-head change passes 910 tests, 473
exact records, 324 callback checks, and the other emission/library and semantic
probes in 105.182 seconds. Native fixture generation takes 0.477 seconds; all
324 native callback checks pass in 0.033 seconds. Generated-source and policy
checks pass in 5.339 seconds. Fresh combined bootstrap passes in 194.293
seconds. Compiler B/C core and linked bytes match with SHA-256
`4debc1eaeeb082b6457424102718449be883a1f0b7761fee8470a7fda59777b8`.

This is a control emission fix, not a complete shadow-stack proof. Runs over
30 seconds remain timing defects; speed work is deferred.
