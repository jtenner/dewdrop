# First-class intrinsic functions

## Reproduction

A direct raw builtin call worked. A self-host local function reference had no
physical target (BOD-607). The larger native test also failed when a factory
returned `i32.add` as a function value: `MissingFunction`, despite clean source
diagnostics. A local reference alone was not a sufficient native regression;
that use can become a direct call.

## Contract

Both planners now distinguish inline instructions from address-taken intrinsic
functions. The latter have an explicit outlined fragment, signature, and linked
index. Their wrapper loads the physical parameters and emits the declared Wasm
instruction. They do not acquire host imports or library-name dispatch. Direct
calls keep their existing instruction path. Compile-time queries remain
signature-only and cannot acquire a runtime wrapper.

Self-host wrapper checks validate parameter/result spans, operand count, scalar
types, and result type before emission. Failures retain all nine numeric fields.
`unsafe.bitcast` retains its scalar-only, equal-carrier rule. No reference layout
is inferred from `eqref`. An unreachable instruction has a polymorphic result.
The fragment codec remains version 1 and retains the new outlined kind.

The shared execution corpus covers I32, I64, F32, F64, SIMD, memory loads/stores,
unsafe bitcasts, generic bitcasts returned by a factory, and an unreachable
function. Compile and validation failures are not accepted as the expected
runtime unreachable trap. The corpus also exposed missing `f32.neg`/`f64.neg`
instruction entries; both now have matching native/self-host contracts and
emitters.

The expanded self-host test first failed validation at a Never-valued match
arm. Function-reference dispatch used a void `call_ref` signature without
restoring unreachable flow. A Never-result dispatch now appends `unreachable`
after its void Wasm block. A real Unit result still falls through normally.

Parameterized heap instructions still require an exact typed wrapper recipe;
this work does not prove those layouts or complete all closure evidence recipes.

## Validation

- Native factory regression: failed before the change (10.037 seconds), passed
  after the change (9.116 seconds).
- Expanded native execution: 10 checks passed; compilation 9.022 seconds,
  execution 0.021 seconds.
- Self-host hardening: 473 tests, 146 exact nine-field failure records, all
  execution corpora passed (146.580 seconds). The ten new builtin execution
  cases passed in 0.148 seconds. The previous run exposed the Never bug in
  148.461 seconds; it was not counted as success.
- Final source, including the declaration-order fix it exposed: native 1,154
  tests (168.824 seconds), integration 268 tests (57.860 seconds), library 326
  tests and all shared corpora (42.437 seconds), hardening 473 tests/146 exact
  records and all corpora (149.935 seconds), generated checks (8.883 seconds).
- Clean bootstrap passed (167.524 seconds). B/C core and linked SHA-256:
  `969b9933b45cba2bfcb5c0e63efc2847be09d621fd5b9415c4f92dd0b90274f6`.
- Stress: all 15 tests passed (0.337 seconds). Provider `b3542f114` is unchanged;
  its last full lane passed all 10,994 tests.

Runs above 30 seconds remain recorded speed issues. No speed work is included.
