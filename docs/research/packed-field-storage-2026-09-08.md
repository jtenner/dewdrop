# Packed field storage

## Reproduction

A user-defined struct with an `I8` field initialized from an explicit unsafe
bitcast of `511i32` returned `-1` under native compilation and `511` under
self-host compilation. The small self-host probe failed in 0.180 seconds.
The native shared corpus compiled in 0.413 seconds.

The self-host fragment planner erased all small integer field storage to i32.
This is correct for function operands, but not for packed struct fields.

## Changes

- Retain four field storage kinds: signed/unsigned i8 and signed/unsigned i16.
  Their operand carrier remains i32. Storage identity checks retain width and
  signedness. Existing numeric storage codes are unchanged; new codes are 7–10.
- Emit packed Wasm field types and select `struct.get_s` or `struct.get_u`
  from the selected physical field metadata. This covers struct fields, enum
  payloads, and immutable closure captures. A missing source field reports
  FRG-403 with an exact numeric-record test.
- Keep mutable capture cells full-width. They replace local slots, so capturing
  a local must not change the value retained by a write. This matches native
  compilation and differs deliberately from immutable packed captures.
- Compare constructor operands by stack carrier, not storage width. An i32
  operand is valid for a packed field; the store performs truncation.
- Exclude selected enum constructors from builtin-function verification.
  Variant and function IDs come from different arenas and can have the same
  number. The new enum test exposed a false `unsafe.bitcast` diagnostic when
  those IDs collided. Source selection kind is required before function lookup.

The consumer selects two existing provider exports, `Instruction::struct_get_s`
and `Instruction::struct_get_u`. No provider implementation changes are needed.
The generated consumer has 476 selected signatures.

## Tests and remaining work

The shared native/self-host corpus has 20 executable cases: four widths each
for construction, field mutation, enum payload reads, immutable captures, and
mutable capture cells. The mutable cases check preservation of the full local
value. Internal tests check storage round trips, rejection of different widths
and signedness, i32 stack carriers, and the exact missing-field record.

The initial full self-host run failed at the constructor/function identity
collision (60.964 seconds). The first storage patch still exposed that failure
(61.340 seconds). After the identity check, the constructor matcher exposed its
storage-versus-stack comparison (61.121 seconds). The corrected 20-case suite
passed (61.361 seconds). All failures remained visible; no arbitrary trap was
accepted as success.

Final hardening passes: 528 compiler tests, 185 exact invariant trap records,
and all 20 shared field cases (61.171 seconds). The library lane passes all
326 tests and shared probes (28.216 seconds). Generated-file checks pass
(4.290 seconds); FFI generation took 4.132 seconds.

The clean bootstrap passes (201.489 seconds). Compiler B and C raw and linked
outputs share SHA-256
`27a2734ee671cab90d01f68d9a162cace42de028658beeaa4a6243ba5b8d4e80`.

Declared-field error fallbacks are removed by the subsequent
[declared storage checks](declared-storage-types-2026-09-08.md). Synthetic runtime
type recipes, complete reference assignability, and other expression/signature
fallbacks remain separate open tasks.
Runs above 30 seconds remain recorded performance bugs, outside this stint.
