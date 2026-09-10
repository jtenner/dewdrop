# Ten bounded type and payload audit tasks

This batch tracks T10-1 through T10-10 in `agent-todo.md`. These are parts of
the open audit, not a claim that ten whole compiler subsystems are complete.

## T10-1 through T10-5: specialization graph closure

The caller-shape work queue previously visited products and application bases,
but skipped application arguments, function signatures, and projection owners.
An Error child could become Ref, and a structural cycle could be ignored.

The first new fixture has syntax errors (35.509 seconds). The corrected
baseline passes 912 tests and fails nine in 92.246 seconds. Four applied/function
cycle probes do not trap and four Error-child probes return a reference.
The projection setup also incorrectly expects Error: pending projections are
Generic at this inference stage. That setup is corrected; the original
projection traps were not valid evidence of cycle detection.

The queue now visits every child edge in both arenas. It checks spans, indices,
and signed encoding before reads. Active nodes detect cycles; completed nodes
preserve sharing. An error flag travels with each cached shape, avoiding repeated
walks through shared product shapes. Products preserve their fields; application
and function reference shapes cannot hide an erroneous child. Pending generic
arguments still permit a known outer reference carrier. This is not a full
physical signature certificate: existing concrete-type checks remain required.

Initial hardening passes 921 tests in 89.201 seconds. Expanded coverage checks
parameter spans and function result cycles: 927 tests and all shared probes pass
in 87.469 seconds. Twelve new exact numeric records cover both arenas, including
projection-owner cycles. Existing 128-level shared product tests remain green.
All 485 exact records pass in 0.815 seconds. Generated checks pass in 4.987
seconds. Clean bootstrap passes in 170.745 seconds, including semantic probes
and matching B/C output: `ce72f54cb31999443654639b3268c2192f867050b4be5c9d2de3d8d29e1b230c`.

## Remaining tasks

An old exact call-payload helper is only called by tests. T10-6 will remove this
unused name recovery and move those assertions to the live payload readers.
T10-7 through T10-9 will harden the active declared-variant and physical-field
readers. T10-10 removes method-name result recovery in the active constructor
and variant payload paths.

All runs above 30 seconds are timing defects. Speed work remains deferred.
