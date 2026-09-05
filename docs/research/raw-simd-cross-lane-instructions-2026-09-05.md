# Cross-lane SIMD instruction contracts

The opcode catalog now includes the 44 distinct cross-lane instructions used by
45 typed library declarations. The two typed swizzle declarations intentionally
share one opcode and signature. Narrowing, widening, pairwise addition, widening
multiplication, dot products, swizzle, and vector numeric conversion use exact
Wasm opcode names. The alias-only backend table is removed; git retains its
history. The shared opcode emitter now covers all 194 immediate-free operations.

The catalog keeps canonical Wasm text distinct from Starshine API spelling.
For example, `i8x16.narrow_i16x8_s` calls the single Starshine instruction
`i8x16_narrow_i16x8s`. Neither the library declaration name nor module path is
used as physical evidence. Duplicate opcode entries must have identical
instruction and input/result contracts.

Native tests pass all 194 positive opcode cases and all one-slot input/result
mutations. The routine lane passes 789 tests in 69.273 seconds; backend rebuild
time exceeds 30 seconds and remains a performance bug. The library lane passes
302 tests and all existing value matrices in 17.035 seconds. Six added cases
cover signed and unsigned saturation, widened signed arithmetic, swizzle bounds,
and saturating float conversion including NaN. Self-host validation passes all
194 opcodes and six matching raw-opcode execution probes. The complete hardening
lane passes in 16.227 seconds after the initial rebuild.

The first self-host attempt exposed 44 missing FFI declarations. They are now
selected from the unchanged pinned provider. The generated binding manifest and
compiler fingerprint include these exact signatures. Consumer generation now
checks compiler `StarshineFfi` references against selected declarations and
reports the source file, line, and missing symbol before the compiler build.
A one-reference negative test checks this diagnostic. There is no new provider
runtime or custom compiler intrinsic.

Complete generated-source checks pass after the FFI update.

These numeric lane conversions retain explicit names. They must not replace
the existing peer `Into` implementations, which promise equal-carrier bit
reinterpretation and already have their own complete conversion matrix.
Fixed lane indices, shuffle immediates, and partial memory instructions remain
open work.
