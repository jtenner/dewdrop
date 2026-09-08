# Exact constructor field recipes

## Reproduction

Start with two structs that each have a field named `value`. Compile a valid
constructor for the first struct, then change only its retained object-field
ID to the second struct's field ID. The self-host emitter still accepted it.
Replacing the ID with the missing sentinel was accepted too. The emitter used
matching field names and tentative source shapes to repair both states.

The first fixture had two setup errors: a Bytes method name, then an entry
point named `run` instead of `main`. The exact numeric-record harness rejected
the unrelated assertion trap (18.161 and 66.116 seconds). These runs did not
prove the source defect. With the valid fixture, both tests failed because no
trap occurred (68.429 seconds).

## Change

Object constructor emission now builds an explicit map from physical field
order to source evaluation order. Each source field must have one present,
exact physical declaration ID, and no physical field can be filled twice.
The source and physical spans are checked before lookup. Names and inferred
carrier guesses no longer select fields in this emission path.

The existing evaluation schedule is unchanged: every source expression is
evaluated once, in source order, into its existing scratch local. The recipe
then loads those values in physical field order. Existing frozen-carrier and
explicit Unit/erased-field adapter checks remain in place.

Missing, different, duplicate, or incomplete fields report BOD-608. Span errors
report ARN-101. Records include phase 7, module, caller declaration, body, and
constructor expression. Identity errors also retain the physical type index,
actual source field ID, and source object-field slot. Six negative tests check
complete numeric records; a reversed-order fixture checks the exact map.

## Validation and remaining work

The first fixed lane passed 537 compiler tests, 191 exact trap records, and all
shared probes (67.593 seconds).
The expanded physical-span fixture first assumed an unused closure field was
present. The exact-record harness rejected that unrelated assertion failure
(75.519 seconds); the fixture now checks the actual two-field table.
Final hardening passes 541 tests, 195 exact trap records, and all shared probes
(67.171 seconds). The library lane passes 326 tests and all shared probes
(30.330 seconds); generated-file checks pass (5.102 seconds).
Clean bootstrap passes (210.309 seconds). B/C raw and linked outputs share
SHA-256 `1577c647ed3641ac84fc6635e85d015aa5adab7956c7597be70e9aad642093ba`.
The prior native baseline remains 1,221 routine tests, 268 integration tests,
and 15 stress tests; the last stress run took 0.623 seconds. This change does
not modify native compiler code.

Constructor nominal-type recovery elsewhere still uses name/shape heuristics.
The complete constructor recipe and scratch-local layout still need to be
stored in the frozen physical plan. This change removes the field-identity
repair during emission; it does not claim those larger tasks are complete.
Runs above 30 seconds remain speed bugs, outside this stint.
