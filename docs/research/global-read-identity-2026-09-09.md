# Global reads retain initializer identity

## Defect

The global-read emitter checked physical carrier and slot bounds but accepted
an initializer whose declaration differed from the source read. A one-field
mutation of the declaration, with the same I64 shape and valid slot, emitted
without a diagnostic. The regression fails as intended before the change:
727 tests pass, one fails (60.571 seconds).

The module-value emission branch also treated a missing initializer as an
opportunity to emit a function reference. Its helper first scanned functions
by declaration, then searched by source name. Neither operation can prove that
a module-value read denotes a function.

## Change

Global-read lookup checks body membership before reading the source expression,
requires a module-value expression, and selects exactly one initializer for its
declaration. Missing or duplicate records report BOD-610. An independently
supplied initializer with another declaration reports ARN-106 before emission.
Existing shape, carrier, erased-value, and physical slot checks remain.

The function-reference fallback and its lookup helper are deleted. Function
references use their existing explicit expression kind and frozen closure
recipe. They cannot replace a missing module-value initializer.

## Checks

One positive test checks the exact declaration and physical slot. Six negative
tests cover a changed initializer declaration, missing and duplicate records,
a source read changed to a present function's ID, a non-global expression kind,
and an expression outside the caller body. Each checks the full numeric record.
All 734 hardening tests, 354 complete numeric records, and shared corpora pass
(59.683 seconds). The generated lane also rejects the deleted fallback.

Native library checks pass (26.210 seconds), and generated-file checks pass
(4.264 seconds). Clean Node bootstrap passes (175.815 seconds), including
compiler B semantic probes. Compiler B and C raw and linked outputs share
SHA-256 `e8f5d637604bb20745b94814dcc194c9ffccb15a12994adad8d5de71210cf294`.
Runs above 30 seconds remain timing bugs. This closes the global-to-function
fallback, not the other callable name searches or full linked-program freeze.
