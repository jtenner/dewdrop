# Typed reference casts

Raw `ref.cast` retains its target from the resolved result type. It does not
guess a heap from the source function name or erase a missing target to Ref.
The initial result domain is concrete declared structs and the existing
primitive text/builder heaps. Generic result owners, arrays, functions, and
scalar results remain rejected. This is a raw unsafe representation operation,
not UTF-8 validation or a new high-level conversion algorithm.

Inline and outlined heap functions now share a `RawHeapInstruction` recipe.
The two operations are struct field reads and reference casts. They share
checked owner lookup, while keeping their operand/result contracts separate.
The native version-1 codec retains the operation and exact owner; no format
version is increased. Existing scalar struct reads still reject packed and
reference fields.

The self-host plan retains the operand expression, selected cast heap, and
result heap. Seeding only fills missing result facts; known disagreement is
left for the verifier. Both planning and emission check the same contract.
A Never operand is evaluated but no cast is emitted. This does not complete
the general reference-subtyping or emission-shadow-stack tasks.

The baseline native run has three intended failures (8.703 seconds); all three
forms import an unsupported operation. The baseline self-host run has three
intended emission failures (83.951 seconds), including an outlined function.
Native checking passes in 3.479 seconds. The first native raw-test run passes
26 tests in 39.810 seconds. Self-host generation then rejects a nested
exhaustiveness match (41.253 seconds). Splitting the Result and heap matches
preserves explicit coverage without a catch-all recovery branch.

Further checks cover direct and returned casts, declared heaps, byte-preserving
text round trips, empty values, evaluation order, incompatible runtime heaps,
Never operands, invalid declarations, codec round trips, and three exact
one-mutation failure records. Generic source result variables are rejected by
native source diagnostics before emission; the regression checks the exact
message, file, and offset rather than accepting any failure.

The shared Never-input cast case exposed a separate control-flow defect. The
fix and its three standalone control forms are recorded in
[the control-input log](never-control-inputs-2026-09-09.md). With that fix,
the first complete native raw lane passes 38 tests in 42.614 seconds, the
native library lane passes in 29.453 seconds, and the self-host lane passes
821 tests, 414 exact failure records, and all 18 raw heap execution checks in
85.047 seconds. Scoped API generation passes in 3.560 seconds.

A further negative test exposed discarded generic result arguments:
`Box<I32>` was reduced to the Box declaration ID alone. A standalone self-host
probe incorrectly compiled (0.164 seconds); the native negative test also
failed as intended (9.384 seconds). Cast recipes now reject applied result
types until they can retain a complete specialized heap identity. This does
not pretend that a declaration ID proves a generic heap representation.

The final native raw lane passes 38 tests in 55.741 seconds. Self-host hardening
passes 821 tests, 414 numeric records, and the shared runtime corpus in 105.671
seconds. Generated checks pass in 22.975 seconds. Clean bootstrap passes in
214.260 seconds: B and C have identical raw and linked bytes with SHA-256
`f6df57461d2211579730c1bfecd135a70cbe8734240ad35a822848948bacca96`.
Runs over 30 seconds remain timing defects; speed work is deferred.
