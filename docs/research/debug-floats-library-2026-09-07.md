# Floating-point Debug migration

## Contract and baseline

Preserve the existing `f32(0x........)` and `f64(0x................)` output,
with lowercase fixed-width hexadecimal digits. Preserve every input bit,
including signed zero and NaN payloads. Formatting must use ordinary Dew code,
bounded scratch, and the integer migration's checked foreign-write loop.
Bit extraction itself uses the one-to-one WebAssembly reinterpret instructions.

The shared test corpus has 18 exact outputs: positive/negative zero, one,
positive/negative infinity, a positive NaN payload, the smallest subnormal, and
the largest finite value for each width, plus generic negative-NaN cases. Three
invalid-host checks require one exact host call followed by a trap. The common
host stub forces three-byte partial writes and rejects unexpected host calls.

The first fixture incorrectly used `unsafe.bitcast` across different scalar
carriers. The compiler rejected its i32-to-f32 signature in 0.395 seconds; this
was not accepted as a test result. The fixture now uses the declared raw Wasm
reinterpret operations. The original implementation passes all 21 checks:
compilation 0.398 seconds, execution 0.023 seconds.

New source-policy tests fail before migration (eight subtest failures,
0.034 seconds).

## Implementation

F32 and F64 formatting now runs in `std/preamble/110-debug.dew`. Two private
builtins map exactly to `i32.reinterpret_f32` and `i64.reinterpret_f64`. Ordinary
Dew functions write the prefix, fixed-width digits, and suffix, then use the
integer migration's checked foreign-output loop. No GC allocation or floating
arithmetic is needed. The shared digit helper checks its scratch span before
adding offsets and accepts at most 16 digits.

The native backend and pinned Starshine bridge no longer contain the float
builder or its runtime dispatch entries. The self-host classifier no longer
accepts those entries. The public bridge interface is unchanged. Integer and
float corpora now share the same strict host-output test stub.

The new Dew code passes all 21 native checks: compilation 10.055 seconds,
execution 0.023 seconds. The bridge removal test fails before removal in
7.004 seconds. All 12 bridge tests pass after removal in 7.070 seconds.
The bridge change is committed as `c020d7f1d`. Both shared output corpora still
pass after extracting the common host stub (integer 0.023, float 0.022 seconds).
Provider rebuild: 10.725 seconds; consumer regeneration after the bridge
commit: 4.049 seconds. The full hardening lane passes in 79.189 seconds:
325 tests, 75 exact failure records, and all shared execution corpora, including
21 float cases (1.297 seconds) and 24 integer cases (0.987 seconds).
All 1,024 routine native tests pass in 150.000 seconds. All 268 integration
tests pass in 57.097 seconds. The full library lane passes in 28.304 seconds:
326 tests and all shared corpora, including the 21 float and 24 integer cases.
The first generated-source check found stale public intrinsic aliases in
1.053 seconds. Regeneration exposed private double-underscore helpers as public
`wasm_` aliases. A new regression fails for that leak (0.048 seconds). The
generator now keeps internal helper names out of its public alias surface;
opcode coverage still requires public declarations. No new public aliases or
Wasm instructions are needed for Debug. Generated files return to their previous
contents. The final generated-source lane passes in 17.797 seconds.

The clean bootstrap passes in 165.713 seconds. Compiler A build: 39.455 seconds;
A execution: 44.549 seconds; B execution: 56.923 seconds. B/C core bytes and
linked Wasm bytes match. Their linked SHA-256 is
`ff857bc9d28e4d328db4b014745152dabce59989b8f8f4b52c60069ff5a681bf`.
Runs above 30 seconds remain speed bugs; no speed work is included.
