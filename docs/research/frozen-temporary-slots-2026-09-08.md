# Frozen temporary slot selection

## Defect and regression

Temporary slot lookup counted source expression kinds again during emission.
It returned the same apparently valid slot when the physical temporary record
was missing, duplicated, or the whole body plan was absent. Three new negative
tests demonstrated all three failures: 563 tests passed and three failed
(75.258 seconds). The numeric record checker also rejected the missing trap.

## Change

The frozen temporary array now defines slot offsets and the temporary count.
Lookup requires exactly one record for the expression and ordinal. Its base
uses the frozen physical source-local count and the lambda environment flag.
Missing or duplicate records report BOD-610; wrong module/body identity reports
ARN-106; a slot that reaches the missing sentinel reports ABI-710. Arithmetic
is checked before U32 addition. Each failure retains all nine numeric fields.

Constructor field loads and stores look up each source ordinal, not just the
first slot plus an offset. Empty constructors do not request a temporary.
Capture-cell bases use the frozen expression-temporary count. The unused old
declared-local counter and both source-expression counting scans are removed.

An initial build found two invalid single-line Dew blocks (19.090 seconds).
After the syntax correction, 566 compiler tests, 213 numeric records, and all
shared probes passed (76.521 seconds). Further tests check real lambda slots,
all constructor ordinals, wrong plan identities, and the missing slot sentinel.
The expanded hardening lane passes 571 compiler tests, 216 exact numeric
records, and all shared probes (77.649 seconds). The library lane passes 326
tests and all shared probes (32.195 seconds). Generated-file checks pass
(4.843 seconds). The clean bootstrap passes (220.212 seconds). Compiler B and
C have identical raw and linked SHA-256 hashes:
`6baa39da53e40095c4d0bc973c1317836125a23471931f41c2b5f6b99f68e341`.

## Scope still open

This is not a complete local-layout proof. Several nonconstructor temporary
types are still selected during emission. Their allocation order is still
derived from source expression order, which is also the planner's record
construction order. Capture-cell records and slots are not yet frozen. Full
heap-type/nullability checks are separate open work. Runs above 30 seconds
remain speed bugs; no speed work is included here.
