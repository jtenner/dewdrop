# String SIMD access in Dew

`wasm_string_load_u8x16` is now an ordinary Dew function. It converts the String
through the existing checked representation path and calls the shared Bytes
storage load. Its public name and signature remain unchanged. The compiler
does not synthesize a separate String SIMD body or select a runtime by this
function's name.

The native text dispatcher, native text-runtime admission list, intrinsic
generator, and pinned provider no longer contain the `dew_string_load_u8x16`
operation. The generator emits the ordinary wrapper and its embedded bootstrap
source. The Bytes SIMD storage bridge and the unchecked String-to-Bytes
representation conversion still require their separate storage migration.
This change does not claim that text storage is fully library-owned or that
the existing provider conversion is allocation-free.

The shared String corpus now has 19 cases. New checks cover aligned/unaligned
loads from a nonzero-start logical view, once-only source-order argument
effects, a returned function value, empty input, insufficient remaining bytes,
and a maximum-U32 index. The same corpus is used by native and self-host builds.
Compilation or validation failure cannot count as a runtime bounds trap.

## Validation

Source/dispatch policy tests failed before migration (0.038 seconds) and pass
after migration. The provider's runtime boundary test failed before removal
(20 passed, 1 failed; 6.658 seconds) and all 21 tests pass after removal
(9.195 seconds). Provider commit: `49d90a728`.

All final checks pass:

- Native: 1,216 tests (200.575 seconds).
- Integration: 268 tests (60.946 seconds).
- Library: 326 tests and all shared corpora, including 19 String cases
  (44.372 seconds).
- Provider: all 10,994 tests (290.956 seconds).
- Self-host: 521 tests, 184 exact records, and all shared corpora
  (170.560 seconds).
- Generated checks (14.581 seconds) and all 15 stress tests (0.354 seconds).
- Clean bootstrap (218.353 seconds): B/C raw and linked SHA-256 hashes match:
  `20e30288c71866b56ca2a33c82ee5af60490eb0715e277ed5c5e120e03483d59`.

The provider rebuild first stopped at the expected stale-consumer check
(22.352 seconds). Consumer regeneration took 4.433 seconds. All 469 typed
bindings and their signatures remain unchanged; only the provider revision,
binary hash, and fingerprints change. Final self-host runs use these refreshed
files. Runs above 30 seconds remain timing defects. No speed work is included.
