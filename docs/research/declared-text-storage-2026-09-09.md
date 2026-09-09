# Declared raw-array fields for text storage

The shared raw GC probe now tests ordinary Dew structs with the same storage
as text and builders: a non-null V128 array and two I32 fields. These cases
check casts in both directions, nested views, shared mutable builder storage,
and a returned cast function. They do not change the standard library yet.

## Native defects

Raw array heap types were emitted after cross-module recursive nominal groups.
A struct field could therefore refer to an array type that did not yet exist.
The new recursive A/B fixture exposes this. Raw arrays now form a fixed prefix
before nominal types. Physical indices include the prefix; spans into the
nominal node table remain relative to that table. Schedule and alias checks use
the same distinction. Two one-field negative tests check all nine numeric
failure fields for a moved prefix and an unshifted recursive group index.

A second fixture declares a raw-array field without any allocation or call.
The old dependency scan omitted this field-only heap dependency. Physical field
storage now also seeds raw-array reachability. This applies to user modules and
does not inspect a standard module name.

Focused backend tests pass: 3 cases in 10.024 seconds. Physical type invariant
tests pass: 23 in 13.217 seconds. Alias invariant tests pass: 8 in 1.601 seconds.
The native shared probe passes all 26 cases; compilation takes 8.905 seconds
and execution takes 0.023 seconds.

The full routine native lane passes all 1,288 tests in 193.349 seconds.
The integration lane passes all 270 tests in 63.115 seconds. The standard-sources package
reports no tests; that empty package is not counted as test evidence.
Generated checks pass in 19.209 seconds. Clean bootstrap passes in 207.243
seconds. Compiler B/C raw and linked hashes match at
`650f2870aa58d8ad4695612d8265a23601e94d27cdca43dec11d6b8b7b250b60`.

## Open self-host defect

The same shared probe fails with an illegal cast in the self-host output.
Its declared raw-array fields still have nullable eqref storage, unlike the
runtime's exact non-null array field. This is not a valid storage certificate.
The failing cases remain active. Exact array field fragments, ordered heap
dependencies, and checked constructor operand casts are needed before moving
text storage algorithms into Dew.

The failing hardening run still passes 869 self-host tests and 454 exact
failure records. Total time is 93.347 seconds. Runs over 30 seconds are timing
defects; speed work remains out of scope.
