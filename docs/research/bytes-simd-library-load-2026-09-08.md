# Bytes SIMD loading in Dew

`wasm_bytes_load_u8x16` now has an ordinary Dew body. It validates the logical
range with subtraction after checking `start <= length`, reads exactly sixteen
logical bytes, and assembles the result with one-to-one SIMD lane instructions.
The name and public signature stay unchanged. String loading calls this same
Dew function after its existing Bytes conversion.

Both native and provider copies of the old generated load body and its runtime
dispatch entry are removed. The provider boundary test requires the old name
to leave the function table unchanged. Core vector loads and lane operations
remain available. The intrinsic generator produces both the Dew function and
the embedded bootstrap source.

This moves the load algorithm, not the underlying Bytes storage accessors or
builders. It performs sixteen byte reads rather than the provider's chunk-load
sequence. No speed equivalence is claimed; storage primitives and speed work
remain separate obligations.

## Tests and measurements

- Policy checks failed four assertions before migration, then pass in 0.032
  seconds. Generation takes 0.048 seconds.
- The provider boundary fails before removal: 20 pass, 1 fail, 6.001 seconds.
  After removal all 21 pass, 6.057 seconds. Provider commit `e475444e7`.
- The shared Bytes corpus grows from 14 to 21 cases. The new cases check all
  sixteen lanes over nested views and all alignments, once-only argument order,
  returned function calls, empty and short ranges, view-local bounds, and U32
  maximum offsets. Baseline native compilation takes 0.304 seconds; all 21
  baseline cases pass in 0.022 seconds.
- The first self-host lane failed visibly (153.263 seconds): the request
  fixture's explicit standard-module subset does not include `dew.std.u8x16`.
  Its method imports therefore cannot supply lane methods, and missing method
  results also leave `.into()` ambiguous. The shared fixture now uses explicit
  lane instructions and `u32_into_u8`, as the String SIMD fixture does. This
  does not change or relax runtime bounds assertions.
- Native library tests pass: 326 tests and all shared corpora, including the
  21 Bytes checks (42.378 seconds). Provider build takes 9.693 seconds and
  consumer refresh 3.956 seconds; all 476 selected signatures are unchanged.

- Final self-host tests pass: 663 tests, 294 exact numeric records, all shared
  corpora including 21 Bytes cases (60.350 seconds).
- Native: 1,268 tests pass (205.703 seconds). Integration: 268 tests pass
  (60.815 seconds). Generated checks pass (19.258 seconds).
- The current pinned provider passes all 10,994 tests (345.898 seconds).
- Final native compilation of the shared Bytes fixture takes 0.371 seconds;
  all 21 cases pass in 0.033 seconds. All 15 stress tests pass (0.441 seconds).
- Clean bootstrap passes (223.531 seconds). B/C raw and linked bytes match:
  `da15e4dd39e239a3f916359f32a4ead18fb26104ad0090caca09be261e41f0fc`.

Compilation failure is never counted as an expected runtime bounds trap.
Compiler runs above 30 seconds remain speed defects.
