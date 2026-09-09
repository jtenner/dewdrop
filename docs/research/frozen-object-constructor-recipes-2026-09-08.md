# Frozen object constructor recipes

## Scope

Object construction needs a retained physical target and a field recipe before
emission. Source evaluation order and physical field order are separate. Each
physical field retains its exact source declaration, source expression, source
ordinal, storage type, and explicit boxing or Unit-marker operation.

The existing source-order scratch records remain the local-storage certificate.
Constructor recipes are copied into the body freeze witness. Emission consumes
that recipe instead of selecting another nominal type or rebuilding a field map
from source names. Verification rebuilds only the small recipe tables; it does
not copy the rest of the physical body.

This batch covers `PlannedConstruct` object expressions. Tuple-style variant
calls, closure construction, full reference assignability, and remaining Array
runtime adapters are separate open work. A passing object recipe test does not
close those obligations.

## Test record

The first test build stopped on a draft's single-line Dew block (19.585 seconds).
That syntax error is corrected; it is not evidence of the intended defect.
The positive fixture requires one recipe for a reversed-order three-field
constructor, with an explicit Unit field. It fails as intended when the tables
are empty: 663 existing tests pass, 1 new test fails (72.810 seconds).

The first implementation passes all 664 internal tests but rejects the existing
empty-Option runtime adapter in shared library probes (70.030 seconds). That
adapter has no ordinary source fragment. It now has an explicit zero-operand
recipe from its declaration certificate, with exact target and arity checks.
No source-name recovery is restored. All 664 tests and shared corpora then pass
(74.575 seconds). The obsolete object emission path and name-based constructor
helper are removed: 875 old lines, replaced by the plan-driven path.

The missing-target mutation exposes another fallback: the retained result heap
type can replace a removed selected constructor target. That test fails with
675 others passing (69.370 seconds). Planning now requires the selected target
itself; result-heap evidence cannot repair its absence. Twelve new negative
tests check all nine numeric fields for missing/duplicate records, target
agreement, field order, source expression, storage, boxing, and Unit markers.
Final hardening passes all 676 tests, 306 exact numeric records, and every
shared execution corpus (78.705 seconds). Generated checks pass (4.902 seconds).
Clean bootstrap passes (233.610 seconds). B/C raw and linked outputs match:
`5886b9b99c0838ec7dd8754897a26cb3b6918d9a7296e6401ebc6952559a29e4`.
Native compiler, integration, stdlib, stress, and provider code are unchanged
from the validated `6de4b36` batch; this batch changes the Dew compiler only.

Runs above 30 seconds remain timing defects. No speed work is included.
