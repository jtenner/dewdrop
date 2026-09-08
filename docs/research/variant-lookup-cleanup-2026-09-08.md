# Variant lookup cleanup

Three global name-based physical variant searches remained in the self-host
emitter. The unsuffixed search had no callers. The other two served unreachable
fallback tails and two diagnostic-only guesses. User variants already returned
through their selected declaration before those tails. This is cleanup, not
evidence that those dead tails caused the current ABI errors.

Both runtime adapter selectors now match the typed adapter enum directly.
Pattern selection no longer depends on finding a source name in the name arena.
Constructor selection no longer converts adapter identities to strings. Missing
pattern diagnostics report the selected declaration instead of guessing a
physical type by name. All three obsolete searches are removed.

The source policy failed with four findings in 0.054 seconds before the change.
Existing hardening tests cover user Some/None declarations, unqualified Option
patterns, and constructor ambiguity. The first hardening run caught an invalid
match-alternative separator in this patch (116.345 seconds). Replacing the pipe
with Dew's comma separator fixes that syntax error; no checks were removed.
The green run passes all 360 tests, 108 exact records, and shared execution
corpora in 57.807 seconds. The source policy passes in 0.038 seconds. Generated
checks pass in 4.233 seconds. Bootstrap passes in 180.096 seconds. Compiler B
and C raw and linked hashes all match:
`abd1d4eb4a8ae7097d0dcc7329bcbe5097dbb45b5d600812b4f42cd4a06f1e4b`.
Runs above 30 seconds remain recorded speed bugs.

Runtime Option/Result layouts and unresolved payload defaults remain separate
work. No speed changes are included.
