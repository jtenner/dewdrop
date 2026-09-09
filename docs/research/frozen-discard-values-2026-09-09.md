# Discard reads use frozen carrier evidence

The emitter's value-discard decision now requires the selected physical body
plan and expression record. It checks module/body ownership, specialization,
known carrier evidence, and agreement between the saved carrier copies.
Unit produces no stack operand. Never produces none either, but must agree
with non-fall-through source flow. Known scalar/reference results need a drop.
The reader no longer calls source-shape, function-name, or first-target recovery.

An absent optional transfer payload uses the exact missing sentinel. The
scheduler now adds no discard task for that payload; it does not pass the
sentinel to a real expression lookup. Other missing expression evidence is
still an invariant failure. Remaining planning-time result-shape helpers are
not removed by this change, and the full shadow-stack task remains open.

Five one-mutation tests failed on the old reader (58.644 seconds). The first
strict-reader run passed those records but exposed optional payload scheduling
in shared programs (55.241 seconds). The scheduler fix has a separate positive
test. Scalar and Unit positives also pass.

Hardening passes 774 tests, 381 exact numeric records, and all shared execution
checks (59.258 seconds). Library checks pass (26.868 seconds); generated-source
and policy checks pass (4.173 seconds). The hardening lane is over the 30-second
budget and remains a timing bug, not hidden successful speed work.

Clean bootstrap passes in 168.506 seconds. B/C raw and linked bytes agree:
`f98957f42e20df0edb6fb9f27340e517dec7f586f38bce47111edd646377c35b`.
This also covers the preceding unused-linker cleanup. Compiler A build and
both compiler executions exceed 30 seconds and are recorded as timing bugs.
