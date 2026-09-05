# Raw Wasm builtin migration

## Contract

A builtin denotes one WebAssembly instruction with explicit immediates, or an
explicit unsafe cast. Packed-value convenience functions belong in Dew. Merely
copying library builtin declarations into `std/wasm/intrinsics.dew` is not a
migration. Native and self-host emission must check the same physical contract.

## Equal-carrier casts

`unsafe.bitcast` takes exactly one physical operand and produces exactly one
physical result of the same non-reference Wasm type. It emits no instruction.
It supports integer, floating-point, and vector carriers, but does not turn
`f32` into `i32`: that requires the actual Wasm reinterpret instruction. Reference
casts need heap-type and nullability proofs and are not accepted by this operation.
Unit, Never, missing carriers, and conflicting carriers are not cast certificates.

Native generic inline cast calls now receive concrete specialized signatures.
Previously the specialization planner accepted only functions with Dew bodies.
Native emission reports `InvalidBuiltinSignature` with input and output types.
Self-host emission checks the frozen expression plans before scheduling the cast.
Neither check depends on the Dew function name or on a standard module path.

The preamble exposes `unsafe_bitcast<source, target>`. Its embedded native copy
is generated from Dew by `tools/generate_preamble_sources.py`; all preamble
source copies are now checked by `tools/check-generated.sh`.

## Verification

The initial native cast tests pass (10.218 seconds). They include packed 32-bit,
64-bit, and vector carriers and reject a changed width before Wasm validation.
The first self-host run passed all existing hardening tests and the new executable
packed-cast probe. Test generation took 102.143 seconds, including the native
release C build: this remains a performance bug. The cast execution probe took
0.220 seconds. Additional reference, erased-value, and negative self-host tests
are tracked with the implementation.

The final cast run passed 761 native tests, 94 self-host hardening tests,
16 invariant records, and 15 emitted execution probes. It includes the negative
self-host width test and native reference, floating-point/integer, and Unit
rejections. Logs: `/tmp/dewdrop-cast-native-final.log` and
`/tmp/dewdrop-cast-final-hardening.log`. Native semantic/backend lanes took
17.761/16.287 seconds. The tokenizer lane waited 39.958 seconds while another
native build was active; avoid concurrent native build lanes. Hardening test
generation took 97.650 seconds including the native C rebuild.

## Remaining migration

Replace the packed aliases and their emitter handlers with shared raw operations.
Audit scalar normalization, conversions, SIMD, memory, and math as well as the
collection and text runtimes. The existing intrinsic generator still copies
opaque operations; it must be replaced with an explicit operation inventory.
Array, Map, Set, ring-buffer, text, and host-call migrations are not complete.
