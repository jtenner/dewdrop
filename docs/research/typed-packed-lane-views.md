# Typed packed-lane views

## Status

The concrete zero-wrapper lane families described here are implemented as compiler-known primitive identities. Their standard declarations are generated into one file per type under `std/`, embedded deterministically for the current bootstrap compiler, and accepted through imports such as:

```dew
open dew.std.f32x4
open dew.std.i8x8
```

The module graph treats these embedded standard imports as compiler-owned until the package driver loads and caches their real interfaces.

## Decision

Dew exposes concrete packed-lane types in addition to the raw `V128`, `Swar64`, and `Swar32` bit carriers.

The lane type is semantic information, not a different physical representation. A value such as `I32x4` remains a native Wasm `v128`; `I32x2` remains an allocation-free `i64`; and `I16x2` remains an allocation-free `i32`.

## Motivation

Raw carrier methods such as:

```dew
value.add_i32(other)
value.lt_s_i16(other)
```

are useful as a compiler bring-up API, but they allow accidental reinterpretation at every call. Concrete lane types move the interpretation into the type system:

```dew
fn add(left: I32x4, right: I32x4) -> I32x4 {
  left + right
}
```

This provides:

- static rejection of mixed lane shapes;
- ordinary homogeneous operator traits;
- shorter method names;
- type-directed signed versus unsigned comparisons, shifts, min/max, saturation, and conversion selection;
- exact lane shape in frozen semantic evidence;
- no runtime overhead.

## Initial type families

### Native 128-bit vectors

```text
I8x16   U8x16
I16x8   U16x8
I32x4   U32x4
I64x2   U64x2
F32x4   F64x2
```

All use the Wasm `v128` carrier in parameters, results, locals, memory, and aggregate fields.

### Allocation-free 64-bit packed scalars

```text
I8x8    U8x8
I16x4   U16x4
I32x2   U32x2
```

All use the Wasm `i64` carrier. Dew intentionally does not define `F32x2`: its non-native scalar emulation surface, floating edge semantics, and limited server/string-processing value do not justify another primitive identity.

### Allocation-free 32-bit packed scalars

```text
I8x4    U8x4
I16x2   U16x2
```

All use the Wasm `i32` carrier.

One-lane aliases such as `I32x1` add little value and should not be introduced.

## Conversion taxonomy

The API must distinguish three operations that are often conflated:

1. **Bit reinterpretation** preserves every bit and emits no instruction.
2. **Lane conversion** converts values numerically and may widen, narrow, saturate, truncate, or trap.
3. **Lane rearrangement** changes ordering or lane count through shuffle, extension, narrowing, concatenation, or extraction.

Same-width bit reinterpretation should therefore be explicit rather than ordinary `Into<t>`:

```dew
bits.reinterpret_as_i32x4()
values.reinterpret_as_f32x4()
values.as_unsigned()
values.as_v128()
```

Examples of zero-instruction reinterpretations include:

```text
I32x4 <-> U32x4 <-> F32x4 <-> V128
I32x2 <-> U32x2 <-> Swar64
I16x2 <-> U16x2 <-> Swar32
```

`I32x4 -> F32x4` numeric conversion is not the same operation and must use a separately named conversion API backed by `f32x4.convert_i32x4_s` or `f32x4.convert_i32x4_u`.

## Raw carriers

`V128`, `Swar64`, and `Swar32` remain public escape hatches for:

- serialization and hashing;
- arbitrary masks;
- dynamic interpretation;
- bitselect;
- low-level ABI boundaries;
- algorithms whose lane shape changes frequently.

Typed views should not allocate wrappers. Their carrier conversion is semantic-only and must disappear during lowering.

## Operators

Concrete lane types should implement homogeneous traits where semantics are unambiguous:

- integer wrapping `Add`, `Sub`, and `Mul`;
- floating `Add`, `Sub`, `Mul`, and `Div`;
- bitwise traits for every lane view;
- shifts for integer views;
- equality and ordering methods returning the same-width mask type.

Comparisons should return a vector mask with the same physical width and lane shape. Scalar whole-vector equality, if exposed, needs a different name such as `all_equal`.

Saturating arithmetic, average, narrowing, extension, dot products, and relaxed operations should remain explicit methods because ordinary scalar operator traits do not communicate their semantics.

## Implemented operation surface

The 128-bit family currently includes:

- zero-instruction reinterpretation among every ordered pair of same-carrier lane types and raw `V128`;
- bitwise operations, `not`, `andnot`, bitselect, memory load/store, and `any_true`;
- splat, fixed-immediate extraction/replacement, scalar splat loads, and fixed lane loads/stores for every lane;
- integer wrapping arithmetic, signed/unsigned comparisons, min/max, shifts, saturation, averages, masks, and reductions where Wasm defines them;
- floating arithmetic, comparisons, min/max and pseudo-min/max, absolute value, negation, square root, ceil, floor, truncation, and nearest rounding;
- signed/unsigned narrowing, extension, pairwise extension-add, extension-multiply, and signed dot products;
- integer/float vector conversions, saturating float truncation, float promotion/demotion, byte swizzle, widening memory loads, and zero-extending partial loads;
- deterministic byte rearrangement defaults for string processing: reverse, low/high zip, even/odd unzip, and `concat_shift_1` through `concat_shift_15`.

The 32-bit and 64-bit scalar-packed families currently include:

- zero-instruction reinterpretation among every same-carrier typed view and raw SWAR carrier;
- bitwise and typed memory operations;
- splat, dynamic extract/replace, add/subtract, and signed/unsigned shifts for integer lanes;
- full `i8`, `i16`, and `i32` wrapping multiply, signed/unsigned min/max and comparison masks, signed abs/neg, saturating arithmetic, unsigned rounded average, bitmask, and reductions;
- byte population count where useful for string/classification algorithms;
- 61,000 executable Node/Wasm parity comparisons over deterministic edge and random inputs.

Dew deliberately uses fixed named byte shuffles plus dynamic swizzle rather than introducing a special arbitrary-immediate expression syntax. Relaxed SIMD is also excluded from the default surface because its implementation-dependent results conflict with Dew's deterministic execution policy. The remaining compiler task is selective cached loading of imported standard interfaces rather than further lane-schema expansion.

## Current compilation cost

The expanded lane surface increases the release primitive benchmark to approximately:

```text
primitive code emission:                         37.35 µs
primitive Starshine validation + binary encode:  72.94 ms
primitive full frontend/semantic/fragment plan:   38.98 ms
```

The compiler scans leading imports, collects only selected compiler-owned lane modules, freezes each interface once for the program, and resolves user methods through imported impl evidence. Lane declarations no longer enter user module arenas, and dead lane signatures/runtime types are removed before final linking. Generated source tables remain only as a portable bootstrap source provider until installed package lookup is available.

## Standard-interface constraint

Primitive identities, ABI shapes, and core instructions remain compiler-described data, while selected generated lane sources are collected as independent compiler-owned modules and frozen once per program. User modules see only imported interfaces and impl evidence. The remaining source-provider work is installed package lookup and persistent interface caching, not a change to semantic ownership or linking.
