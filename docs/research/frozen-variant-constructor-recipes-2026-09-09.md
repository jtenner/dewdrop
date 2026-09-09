# Frozen tuple-variant construction

## Contract

Every selected tuple-variant call retains its exact source expression,
declaration, selected physical subtype, argument span, and complete operand
span before verification. Each operand retains its source expression and
ordinal, declared variant identity, physical field index, storage type, scalar
box, Unit marker, and reference cast.

The planner checks body ownership before subtraction, argument and field spans,
linked table identity, subtype declaration, field-role identity, stored field
declaration, and exact source/physical positions. It takes operand carriers
from the completed body plan. Unknown, conflicting, or Never carriers cannot
pass a scalar/storage check. Generic scalar boxing and Unit markers require
the existing declared payload certificates.

Declared tuple layouts have one field per source payload, including Unit
markers. Therefore the verified source evaluation order and physical field
order coincide. Emission schedules each retained expression once in that
order, followed by its stored adapter. Non-returning constructions are already
lowered to their evaluation prefix; they do not create allocation recipes.
This is not the same erasure rule as Unit function parameters.

Verification independently rebuilds and compares every recipe field. Freeze
copies both array containers. After freeze, every changed target, identity,
span, field position, storage type, box, Unit marker, or reference cast reports
BOD-605 with the complete numeric context. Missing and duplicate emission
recipes report BOD-610 at the constructor expression.

## Emission cleanup

The emitter intercepts selected tuple constructors and uses only the saved
recipe. It does not resolve targets, search fields, recompute carrier evidence,
or choose boxes/casts. The old scheduler, three later target-selection paths,
and poisoned zero-arity recovery are removed. Ordinary zero-field construction
continues to use the frozen object constructor recipe.

Full heap/nullability assignability, collection representation, and remaining
non-constructor recovery are separate tasks. The saved reference cast preserves
the existing declared field contract; it is not a proof of all Wasm reference
relations.

## Tests and timing

The first draft had an incorrect pattern arity in the new call classifier
(19.333 seconds); it was corrected before behavioral checks. With recipes
present but freeze comparison disconnected, the target-change and removed-
operand tests both fail as intended: 707 pass, two fail (67.568 seconds).

Connecting verification/freeze and using recipes in emission passes all 709
tests and shared corpora (67.752 seconds). The expanded corpus passes 727
tests (65.776 seconds). Twenty one-field or one-entry mutations check complete
records for every stored field, recipe removal, pre-freeze target mismatch,
and missing/duplicate emission recipes. All 348 numeric record checks pass.

The final hardening lane passes all 727 tests, 348 full numeric records, and
all shared corpora (63.206 seconds). Native library checks pass
(27.710 seconds), and generated-file checks pass (4.417 seconds).
Clean Node bootstrap passes (180.291 seconds), including compiler B semantic
probes. Compiler B and C raw and linked outputs share SHA-256
`0cba1e0ab8473afd2f7e87747c0e5804ca3fb2e4f74fc2aa87ca51707b8cbea1`.
Runs above 30 seconds remain timing bugs; no speed claim is made.
