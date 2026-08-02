# Native scalar, SWAR, V128, and memory primitives

## Scope

This slice extends Dew's executable primitive surface from the original `I32` subset to:

- `I8`, `I16`, `I32`, `I64`;
- `U8`, `U16`, `U32`, `U64`;
- `F32`, `F64`;
- `Swar32`, `Swar64`, and `V128`;
- executable `String` and `Bytes` constants;
- a complete scalar numeric `Into<t>` matrix;
- typed memory-zero load/store intrinsics.

The implementation retains one logical primitive identity per source type even where Wasm shares a carrier.

## Physical shapes

| Dew type | Wasm value carrier | Aggregate storage |
|---|---|---|
| `I8` | `i32`, sign canonical | packed `i8`, signed get |
| `U8` | `i32`, zero canonical | packed `i8`, unsigned get |
| `I16` | `i32`, sign canonical | packed `i16`, signed get |
| `U16` | `i32`, zero canonical | packed `i16`, unsigned get |
| `I32`, `U32`, `Swar32` | `i32` | `i32` |
| `I64`, `U64`, `Swar64` | `i64` | `i64` |
| `F32` | `f32` | `f32` |
| `F64` | `f64` | `f64` |
| `V128` | `v128` | `v128` |
| `String`, `Bytes` | nullable `eqref` ABI carrying distinct runtime structs | immutable struct field containing the same runtime reference |

`String` and `Bytes` are distinct WasmGC struct identities backed by zero-padded `array<v128>` chunks and exact byte length. `String` is strict UTF-8; arbitrary or malformed data requires `Bytes`.

## Literals

Canonical explicit suffixes are:

```dew
1i8
1i16
1i32
1i64
1u8
1u16
1u32
1u64
1.0f32
1.0f64
```

Legacy `U`, `L`, `UL`, and `F` spellings remain accepted. Unsuffixed integers default to `I32`; unsuffixed dotted numbers default to `F64`.

The lexer rejects magnitudes beyond the storage boundary. The semantic phase permits the signed `max + 1` magnitude only as the immediate operand of unary negation, allowing minimum signed values without accepting the same positive spelling.

Byte literals use `b"..."`, preserve exact escape bytes, and retain non-ASCII source text as its WTF-8/UTF-8 byte sequence.

## Scalar operators

Canonical preamble traits now cover arithmetic, comparison, bitwise, and shifts. Primitive wrappers retain exact builtin names, and lowering freezes the selected declaration before Starshine emission.

Small integer results are normalized after operations:

- signed `I8`/`I16` use Wasm sign-extension instructions;
- unsigned `U8`/`U16` mask to their logical width;
- small shift counts are masked by the logical target width.

## Numeric conversions

`Into<t>` is implemented for every ordered pair of the ten scalar numeric types.

- Integer-to-integer conversion preserves the source value while widening, wraps while narrowing, then canonicalizes the target.
- Integer-to-float uses the matching signed or unsigned Wasm conversion.
- Float promotion and demotion use native Wasm operations.
- Float-to-integer truncates toward zero and traps for NaN or values outside the target range.
- Narrow float-to-integer conversions reserve one shared `i32` scratch local per function and emit explicit post-truncation range guards.

Identity and same-carrier reinterpretations emit no instruction.

## Linear-memory operations

The preamble exposes typed free functions such as:

```dew
i8_load(address)
i8_store(address, value)
v128_load(address)
v128_store(address, value)
```

Addresses are `U32`, target memory zero, use offset zero and natural alignment hints, follow Wasm little-endian behavior, and trap on out-of-bounds access. A one-page memory is emitted only when reachable code calls a memory intrinsic.

## V128

`V128` has native Wasm signatures, aggregate fields, memory operations, bitwise operations, splats, integer and floating lane arithmetic, comparisons, shifts, min/max, saturation where Wasm provides it, reductions, and packed masks. Lane-immediate extraction, replacement, and shuffle syntax remain to be frozen because Wasm requires immediate lane indices.

## SWAR

`Swar32` and `Swar64` are allocation-free bit carriers over `i32` and `i64`. They are semantically distinct from `U32` and `U64`; `from_bits` and `to_bits` are zero-instruction conversions.

The current core ports the reference packed-scalar formulas for:

- `i8`/`i16` splat and extraction at both widths;
- `i32` splat and extraction at 64 bits;
- wrapping per-lane add/subtract;
- dynamic replacement;
- signed and unsigned per-lane shifts;
- any/all reductions;
- `i8` bitmask, equality masks, and per-lane population count.

The formulas are derived from Jairus Tanaka's `JairusSW/as-simd` project. Its MIT notice is retained in `THIRD_PARTY_NOTICES.md`.

Remaining parity work includes multiplication, min/max, saturating arithmetic, rounded averages, full comparison families, narrowing/extension, dot/extmul operations, shuffles, and differential execution tests.

## Reachability

The expanded compiler-owned preamble contains many helper bodies. Fragment planning now performs deterministic iterative reachability for compiler-owned definitions only:

- all user definitions remain roots;
- public definitions remain roots;
- selected helper/operator/method calls add exact declaration edges;
- unreachable compiler-owned bodies receive no function index and emit no code.

This keeps the expanded API from inflating generated modules while preserving user code semantics.

## Validation and benchmarking

Starshine remains the sole compiler validator. New tests cover module and program-link validation/encoding for scalar constants, strings, bytes, numeric operators, conversions, memory operations, packed aggregate fields, SWAR helpers, and native V128 operations.

The release semantic benchmark matrix remains clean. Representative primitive backend measurements are:

```text
primitive code emission:                         23.66 µs
primitive Starshine validation + binary encode:   8.06 ms
primitive full frontend/semantic/fragment plan:    8.77 ms
```

The expanded embedded preamble materially increases manifest-level compilation work. Current measurements include approximately 39.73 ms for 64-module fragment planning, 20.67 ms for stable linking, 30.65 ms for module emission, and 7.35 s for the existing 32-module full linked semantic/backend benchmark. This is not an acceptable final compilation architecture; it reinforces the roadmap requirement to compile and cache the real `dew.std.preamble` interface once rather than injecting and reanalyzing its source in every module.
