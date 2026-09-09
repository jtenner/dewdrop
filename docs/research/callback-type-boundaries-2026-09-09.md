# Callback signature type boundaries

An empty parameter span previously bypassed bounds checks in both the resolved
and inferred callback signature builders. Signature types came from the target,
but the emitted branch's result metadata came from a separate source/name recovery
helper. A one-field result-shape mutation could therefore make the call's branch
type disagree with its own function type.

Both parameter spans now use the subtraction-safe span predicate before a loop,
including empty lists. Resolved type IDs must fit the signed encoding and belong
to the type arena. Each parameter/result is normalized and checked once before
appending the same shape to the direct and closure-entry signatures. Generic and
Error shapes report SPC-301 with the source call and parameter/result position.

The builders return their actual result shape. The caller uses it for both
signature metadata and emission; a falling-through call whose planned carrier
differs reports ABI-709 before publishing the signature. Diverging evaluation is
separate flow information. The old result recovery helper is removed. Numeric
context replaces the last anonymous assertion in this signature module.

Seven one-mutation negative cases check result disagreement, both empty span
arenas, a nonempty out-of-range span, Error/Generic result evidence, and signed
type-ID overflow. Every probe checks all nine fields. The original baseline
passes 844 tests and fails the three missing-trap cases in 86.911 seconds.
The first fix passes 847 semantic tests in 84.496 seconds; the host expectation
for the inferred argument arena was one instead of its actual zero entries.
That expectation is corrected. Final hardening passes 850 tests, 440 exact
records, and all shared execution probes in 91.560 seconds. Generated checks,
including the new callback signature policy tests, pass in 4.792 seconds.
Clean bootstrap passes in 196.061 seconds. Raw and linked compiler B/C outputs
share SHA-256 `596d25501c47174308442b679a3a2e36647d99571ba82f0f51ea1c4c64c38a20`.

This is carrier-level result agreement, not full Wasm heap/nullability agreement.
Deep type-graph validity inside reference-valued callback parameters and complete
physical call operand recipes remain separate work. Runs over 30 seconds remain
timing defects; speed work is excluded.
