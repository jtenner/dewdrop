# Nested numeric literal patterns — 2026-10-18

A fresh source-Bytes compiler rejected `Option::Some(-2147483648i32)` and
`Option::Some(-9223372036854775808i64)` patterns during emission. The diagnostic
was `nested literal pattern has no physical comparison recipe`. Positive U32
and String controls compiled. The checker accepted the negative patterns, but
the nested emitter handled only direct integer constants, Bool, and String.
It did not handle their unary sign node or direct F32/F64 constants.

`semantic_nested_pattern_emit.dew` now checks one numeric unary `+` or `-`, then
emits a constant and the matching Wasm equality instruction. Integer negation
wraps before conversion. Small integer constants are masked and sign extended
as required by their declared type. Thus `-1u8` matches 255 and `-1u16` matches
65535. Float negation preserves signed zero. Existing Bool and selected String
equality paths remain intact. Dew unary signs are primitive syntax; they do not
select user `Neg` or `Pos` traits.

The change adds scalar compiler locals, with no new arrays or retained index.
Emitted predicates need no runtime negation or added function call. Inspection
of all 20 numeric/struct predicates confirms constant-plus-equality emission
with no function call or float negation. This is a code-shape check, not a
runtime speed or allocation benchmark.

`semantic_nested_literal_carriers_test.dew` adds three emission regressions and
a runtime probe. They cover signed minima at each width, unsigned maxima,
small unsigned negative wrapping, unary plus, F32/F64 signs, direct constants,
signed zero equality, and fields nested below an enum guard. Each carrier has
a wrong-value control; enum cases also test a wrong tag. Trapping custom
`Neg`/`Pos` implementations verify that signs use primitive semantics. The
existing hardening script includes the file and runs its emitted program.

With the old emitter, all three tests failed at the exact missing-recipe error.
With the final emitter, all three pass: generation 4.714 seconds, linking 1.146
seconds, execution 0.266 seconds. The emitted 4,255-byte matrix returns 42. The
same source through the native CLI also returns 42 (compile 0.187 seconds;
execution process 0.032 seconds). These small timing samples establish bounded
validation work; they do not establish a speed gain.

A patched C compiler built from the fresh C source request with only this file
and the prior lambda-result repair changed. Generation took 15.875 seconds and
provider linking 0.996 seconds. It passed both repaired stages on the unchanged
full feature probe. It then exposed a separate fault in generic `iter_fold`:
a loop block expected a reference but its break supplied I32. This record does
not claim that the full feature probe passed or that a final A/B/C fixed point
passed. Those checks follow the generic-loop repair.

Exact outputs, timings, source and compiler hashes, emitted-code inspection,
and the following full-probe error are in
[`data/nested-numeric-patterns-2026-10-18/validation.json`](data/nested-numeric-patterns-2026-10-18/validation.json).
The same directory has the runtime source and its runner. The runner reads a
focused compiler test module that includes the small temporary byte-access
bridge; normal hardening uses its existing byte-access exports.
