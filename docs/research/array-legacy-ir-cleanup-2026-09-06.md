# Array legacy native IR cleanup

This is a bounded part of the standard-library migration. Array algorithms now
run in Dew. The native compiler no longer needs separate operation nodes or
emitters for them.

## Changes

- Remove every `PlannedArray*` operation except `PlannedArrayLiteral`.
- Rename the remaining ring length node to `PlannedCircularBufferLength`.
- Remove unused Array specialization roots, scratch locals, and emitters.
- Reject removed emitter operation codes with the exact
  `UnsupportedExpression(body, -409)` diagnostic, before any layout lookup.
- Keep ring and string-array literal code until its owning data type is migrated.

The next Queue execution tests exposed two ring constructors (operation codes
20 and 21) incorrectly classified as dead. Their capacity-aware allocation is
restored. A direct emitter test now emits both bounded and growable constructors
against a valid Array wrapper plan (3 backend tests passed in 12.599 seconds).
Removed Array-only allocation codes 1 and 2 still fail with the exact diagnostic.
End-to-end Queue tests also expose old generic ring scratch-type and missing
wrapper-demand defects. Those are not solved by restoring allocation; the
circular-buffer migration must remove the old ring representation altogether.

The source-policy test first failed with the legacy nodes present. It now passes.
The negative emitter test checks the diagnostic, not just an error or a trap.
The 28 shared Array execution checks still cover the library algorithms.

## Measured checks

| Check | Result | Seconds |
| --- | --- | ---: |
| Array policy | 9 passed | 0.068 |
| Focused native Array tests after emitter removal | passed | 23.911 |
| Full native | 921 passed | 109.076 |
| Integration | 266 passed | 48.306 |
| Stdlib and shared execution | 319 stdlib tests and shared corpora passed | 21.176 |
| Generated checks | passed | 17.589 |
| Self-host hardening | passed, including 29 exact invariant records | 53.503 |
| Clean A/B/C bootstrap | identical B/C linked bytes | 175.774 |

B/C linked SHA-256:
`fa623c142fb5ef67692fbbeff7e519e605bad8495c2aa200d296283d03ceb6c2`.

Runs above 30 seconds remain performance bugs. No slow check was skipped.

## Remaining Array work

Literal construction and shared runtime producers still use the old wrapper
recipe. They must use declared fields and exact planned targets. This cleanup
does not claim that the Array layout migration or the wider compiler audit is
complete.
