# Result uses its declared enum storage

## Change

The self-host compiler now uses the ordinary source fragments for
`Result<t, e>`. It no longer builds six private Ok types, six private Err
types, or a private base type. Err no longer receives an extra I32 identity
field that is absent from its Dew declaration.

The Option/Result adapter registry and standard-module scan are deleted.
Their former body payload seeding and emission carrier recovery are removed.
The shared source-variant rules handle generic scalar boxes, reference payloads,
and Unit storage markers. Scalar box and packed-array bases follow the smaller
runtime prefix through named dependencies.

Old Ok/Err spelling and suffix recovery is removed from physical target,
operand, nominal, and pattern selection. Where a pattern needs an owner type
argument, lookup now requires the selected variant's declared payload position
and its exact generic parameter ID. Concrete payloads and missing positions
do not become generic slot zero. Recovery of expected constructor nominal
types from Ok/Err names is deleted; frozen source operands and field plans
retain the actual evidence.

This does not complete collection representation migration, frozen tuple-call
recipes, full Wasm reference checks, or removal of all remaining local recovery.
Native scalarization and allocation parity are separate speed work.

## Tests

The changed imported Result test requires exact source fragment identity.
Before implementation it fails with 704 tests passing (67.912 seconds).
Switching target selection to source fragments passes (70.974 seconds).
Removing runtime types, registry, and seeding passes (71.473 seconds).
Removing remaining Result spelling recovery passes (65.317 seconds).

The shared standalone callback fixture declares the same two-variant Result
shape; it intentionally has no standard-module imports. The imported-fragment
test above and clean compiler bootstrap also cover the standard declaration.
The callback corpus adds both alternatives with distinct I32/I64 type
arguments, nested Results, Unit with observable effects, object and function
references, V128, both floating widths, and a user enum with Ok/Err payload
parameters in the opposite order. Each case runs at six I64 boundary values.
An internal test checks mixed concrete and reordered generic payload slots.

The first draft used unsupported local type annotation syntax (64.456 seconds
in hardening; 7.384 seconds in the native library lane). After fixing that,
the standalone fixture exposed its missing Result declaration as SPC-301
instead of inventing a reference signature. Adding the explicit fixture
declaration makes the focused Err probe pass (0.174 seconds).

The corrected expanded hardening suite passes all 706 tests, 328 complete
numeric records, and 252 callback checks (71.152 seconds). The real-library
array, ring, Map, Set, Bytes, String, and FixedArray checks pass too.
Native library checks pass (29.455 seconds), including all 252 callback checks.
Generated-file checks pass (4.296 seconds), with policies that reject private
Result types, the old registry, and physical name dispatch. Clean Node bootstrap
passes (190.366 seconds), including compiler B semantic probes. Compiler B and
C raw and linked outputs share SHA-256
`68178ac876200c37cc1d591357c1a4818e31d216d788dd697a76290bf86b15bc`.
Runs over 30 seconds remain timing bugs, not a reason to hide test failures.
