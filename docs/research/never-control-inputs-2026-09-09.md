# Non-returning control inputs

Standalone valid programs expose three self-host failures. An `if` whose Bool
condition calls a function with a Never argument reports BOD-601 for its unused
I32 branches. A `match` with a Never subject has the same failure. A `while`
with a Never initial value reports BOD-610 for its unused state scratch.
These failures do not require reference casts or library modules.

The planner must not propagate the parent Never carrier into branches that
cannot run. It now uses the condition/subject flow fact to stop those transfer
rules. An unused loop scratch uses the initial expression's verified Never
fact and the existing marker-storage rule, not unresolved loop-state evidence.
The emitter schedules only the non-returning input. It does not emit an if,
match, or loop after that input.

The regression corpus has standalone planner checks and shared runtime cases
for all three forms. Runtime checks require an explicit Wasm unreachable trap.
The normal returning-input cases remain in the same shared corpus. The
self-host hardening run passes 821 tests, 414 exact numeric records, and all
27 shared branch checks in 85.047 seconds. The reference-cast runtime cases
also pass after this fix. The native library lane passes, including all 27
branch checks, in 29.453 seconds. Runs over
30 seconds remain timing defects; speed work is outside this batch.
