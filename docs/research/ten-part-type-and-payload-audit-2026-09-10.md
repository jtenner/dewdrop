# Ten bounded type and payload audit tasks

This batch tracks T10-1 through T10-10 in `agent-todo.md`. These are parts of
the open audit, not a claim that ten whole compiler subsystems are complete.

## T10-1 through T10-5: specialization graph closure

The caller-shape work queue previously visited products and application bases,
but skipped application arguments, function signatures, and projection owners.
An Error child could become Ref, and a structural cycle could be ignored.

The first new fixture had syntax errors (35.509 seconds). The corrected
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

## Scope adjustment

An old exact call-payload helper was only called by tests. T10-6 removes this
unused name recovery and moves coverage to the live payload readers.
T10-7 through T10-9 harden the active declared-variant and physical-field
readers. T10-10 removes method-name result recovery in the active constructor
and variant payload paths.

All runs above 30 seconds are timing defects. Speed work remains deferred.

The T10-10 negative test restores an unresolved method call, then changes only
its logical result type to Error. The live payload helper incorrectly recovers
I64 from the method name. The baseline has 927 passing tests and this one
expected failure in 90.126 seconds. Existing exact records still pass.

## T10-6 and T10-10: call result evidence

Removed the unused exact-call payload helper and its method-name fallback.
The live unresolved-call payload path now reads the inferred expression type
with caller specialization. Error remains Error; method names do not supply
replacement result types. The two former helper-only assertions are replaced
by shared execution fixtures for `Envelope<a>` and `Result<b, a>` generic calls.

## T10-7 through T10-9: live payload readers

A shared selected-payload reader checks module identities, parallel arrays,
payload spans, and the complete declared type graph. It retains declared generic
parameters for explicit erased-field adapters, but rejects Error, nested Error,
and cycles with phase-7 numeric records. Both the parameter reader and the shape
reader use this check. Physical-field reads check selected linked and physical
type IDs, module and fragment bounds, field spans, field positions, and stored
variant declaration IDs. Optional absent positions still return None.

Twenty new payload tests start with valid entries. Nineteen then mutate one
selected field or edge. A separate method-result regression checks that a
valid-looking method cannot hide Error. All 948 hardening tests and shared
execution probes pass in 89.000 seconds, including 336 callback checks. All
504 exact numeric records pass in 0.827 seconds. Generated and policy checks
pass in 4.983 seconds. Routine native tests pass: 1,327 tests in 285.564
seconds. The semantic lane takes 181.393 seconds and the backend lane takes
89.807 seconds; both remain timing defects. The shared callback fixture also
passes all 336 checks with the native compiler (build 0.462 seconds, execution
0.031 seconds). Final clean bootstrap passes in 196.376 seconds. Compiler A
build takes 42.446 seconds; A and B execution take 55.975 and 77.713 seconds.
These stages remain timing defects; no speed work was included.

Compiler B and C pass validation and have identical raw and linked output:
`b6a32929e7dd3e8dd3abf00bee0e8f756fe4b19482d26745bc757273ffa1549b`.

All ten bounded tasks are complete. The broader compiler audit remains open.
No FFI bindings or provider files changed in this batch.
