# Declared storage type graphs

## Defect and scope

Self-host field and payload planning replaced a declared Error shape with the
retained inference shape. Native storage conversion returned a reference for
ErrorType. Both paths could also hide an erroneous type argument or callback
result behind an otherwise valid reference shape.

Four self-host one-mutation tests confirmed these defects: none trapped before
the fix. The red hardening run took 63.025 seconds. Each test starts with valid
source and changes one resolved type entry; the retained field/payload shape
remains concrete. Native contract tests also began with three failing negative
tests (14.054 seconds), before implementing the checked graph walk.

## Implementation

Both compilers now check the complete declared type graph before selecting
struct-field, named variant-field, or tuple payload storage. The walk is
iterative, checks child spans before indexing, and keeps active/done states.
Shared structural children are valid. A structural cycle is ARN-108, not
ordinary missing evidence. Nominal references remain leaves, so recursive
nominal types are not structural cycles.

SPC-301 distinguishes ErrorType (actual=1), unresolved member projections
(actual=2), and compile-time type values in runtime fields (actual=3). Type and
child-arena failures use ARN-101. Records retain phase 4, module and field or
variant identity, plus both the root and offending type IDs in `detail`.

Declared generic parameters still use the existing explicit erased-storage
adapter. This check does not assign them a concrete specialization. It also
does not traverse nominal definitions or prove full Wasm reference subtyping.

Self-host storage no longer falls back from a declared error to an inferred
shape. Native ErrorType no longer converts to reference storage. The native
caller verifies the declared graph before selecting either erased or ordinary
field storage.

## Validation

The first fixed self-host lane passed 532 tests (62.639 seconds). Four new trap
records were inspected in 0.074 seconds and added to the exact-record harness.
Further tests cover products, projections, compile-time values, structural
cycles, and child bounds. The final focused native tests pass: 5 tests in
14.380 seconds. Routine native tests pass: 1,221 tests (201.728 seconds).
Integration tests pass: 268 tests (63.979 seconds). The library lane passes
326 tests and all shared probes (37.458 seconds).

Final self-host hardening passes 535 tests, 189 exact trap records, and all
shared probes (176.809 seconds, including a cold native test-compiler build).
Generated-file checks pass (22.116 seconds). Clean bootstrap passes
(344.867 seconds); B/C raw and linked outputs share SHA-256
`f1acea2ea01b636feb9447a6d1f5f6ba8dcc309596c5070fe2ef4acafeaf20b5`.

The remaining physical-boundary task still includes other expression and
signature fallbacks and full reference evidence. Runs over 30 seconds remain
performance bugs; this change does not attempt speed work.
