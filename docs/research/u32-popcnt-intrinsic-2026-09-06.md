# U32 population count

`dew.std.wasm.intrinsics.wasm_u32_popcnt` maps one U32 input to one U32 result
with exactly one `i32.popcnt` instruction. The native and self-host signature
tables, emission tables, generated intrinsic module, and typed Starshine
consumer agree. No runtime algorithm or special standard-module call is added.

The native opcode test compares the exact instruction. Signature mutation tests
reject I64 inputs and results in both compilers. Library tests cover zero, all
32 set bits, both edge bits, and alternating bits. The next StringView change
uses the instruction to count SIMD lane masks.

The provider already exports `Instruction::i32_popcnt`. Only the consumer's
selected export list, typed binding, and fingerprint change; the pinned
Starshine submodule is unchanged.

The native signature test passes in 9.207 seconds and the exact opcode test in
0.024 seconds. The combined StringView/self-host validation also passes the new
wrong-input and wrong-result tests. The full stdlib lane passes all 326 tests
and all shared execution probes in 13.124 seconds.
