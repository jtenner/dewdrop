# Body planning cannot repair a call target from carriers

The body planner could replace a selected specialization after comparing the
receiver's physical carriers. It could also select a missing method from a
receiver name/nominal search or from the last argument carrier. These operations
do not prove logical specialization identity. Two query instances can have the
same physical signature and different bodies.

The receiver-refinement scan and both worklist recovery scans are removed,
together with the seed's receiver-name fallback and the now-unused initializer
search. More than 400 lines of recovery code are gone. Target selection remains
in inference/specialization; the body seed uses the retained call map. A missing
target is still checked at the call boundary. This does not remove all older
selection heuristics elsewhere in specialization, linking, or emission.

The policy test fails for all four old recovery helpers before removal (0.040
seconds). The first full hardening run passes all existing 523 tests, 184 exact
trap records, and execution probes (60.007 seconds).

A new one-field mutation starts with a valid generic method link and physical
plan, removes the caller's exact mapping, and checks that seeding leaves the
target missing even though a unique receiver-compatible function remains.
Argument verification returns exactly BOD-607 with the caller, expression,
source offset, physical caller identity, and missing evidence intact. The
shared query-order corpus also adds signed/unsigned receivers whose scalar
carriers agree but whose selected method bodies return different results.

The first expanded runtime fixture misspelled the query opcode as
`types.is_signed`; the actual builtin is `types.is_signed_integer`. That run
failed (60.272 seconds) and is not a production regression or a passing check.
After fixing the fixture, hardening passes 524 tests, 184 exact trap records,
and all probes (60.383 seconds), including all six query-order checks. The
library lane passes 326 tests and all shared checks (27.675 seconds). Generated
checks pass (4.334 seconds).

Clean bootstrap passes (185.809 seconds), with matching B/C raw and linked
SHA-256 `e932931a10e7d2c858b8a5846c393c4f76716c033232464d8662d86dab881aa4`.
Provider and FFI files are unchanged. Runs over 30 seconds remain speed bugs;
no speed work is included.
