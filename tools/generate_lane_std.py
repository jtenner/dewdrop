#!/usr/bin/env python3
"""Generate Dew packed-lane modules and the portable compiler source provider."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "std"
EMBEDDED = ROOT / "src" / "standard_sources" / "standard_lane_sources.mbt"
TYPED_PARITY = ROOT / "tools" / "swar-parity" / "typed_lane_parity.dew"
V128_LANE_BACKEND = ROOT / "src" / "backend" / "starshine_v128_lane_builtins.mbt"
V128_CROSS_BACKEND = ROOT / "src" / "backend" / "starshine_v128_cross_builtins.mbt"
V128_MEMORY_BACKEND = ROOT / "src" / "backend" / "starshine_v128_memory_builtins.mbt"
V128_SHUFFLE_BACKEND = ROOT / "src" / "backend" / "starshine_v128_shuffle_builtins.mbt"

V128_TYPES = [
    ("I8x16", "I8", "i8", "signed"),
    ("U8x16", "U8", "i8", "unsigned"),
    ("I16x8", "I16", "i16", "signed"),
    ("U16x8", "U16", "i16", "unsigned"),
    ("I32x4", "I32", "i32", "signed"),
    ("U32x4", "U32", "i32", "unsigned"),
    ("I64x2", "I64", "i64", "signed"),
    ("U64x2", "U64", "i64", "unsigned"),
    ("F32x4", "F32", "f32", "float"),
    ("F64x2", "F64", "f64", "float"),
]
SWAR64_TYPES = [
    ("I8x8", "I8", "i8", "signed"),
    ("U8x8", "U8", "i8", "unsigned"),
    ("I16x4", "I16", "i16", "signed"),
    ("U16x4", "U16", "i16", "unsigned"),
    ("I32x2", "I32", "i32", "signed"),
    ("U32x2", "U32", "i32", "unsigned"),
]
SWAR32_TYPES = [
    ("I8x4", "I8", "i8", "signed"),
    ("U8x4", "U8", "i8", "unsigned"),
    ("I16x2", "I16", "i16", "signed"),
    ("U16x2", "U16", "i16", "unsigned"),
]

# (result type, Dew function suffix, parameters, Starshine instruction)
V128_BYTE_SHUFFLES = {
    "reverse": list(reversed(range(16))),
    "zip_low": [item for index in range(8) for item in (index, 16 + index)],
    "zip_high": [item for index in range(8, 16) for item in (index, 16 + index)],
    "unzip_even": list(range(0, 16, 2)) + list(range(16, 32, 2)),
    "unzip_odd": list(range(1, 16, 2)) + list(range(17, 32, 2)),
}
for _shift in range(1, 16):
    V128_BYTE_SHUFFLES[f"concat_shift_{_shift}"] = list(range(_shift, 16)) + list(range(16, 16 + _shift))

# (result type, Dew function suffix, parameters, Starshine instruction)
V128_SPECIAL_MEMORY = [
    ("I16x8", "load_extend_i8x8_s", "v128_load8x8s", 3),
    ("U16x8", "load_extend_u8x8_u", "v128_load8x8u", 3),
    ("I32x4", "load_extend_i16x4_s", "v128_load16x4s", 3),
    ("U32x4", "load_extend_u16x4_u", "v128_load16x4u", 3),
    ("I64x2", "load_extend_i32x2_s", "v128_load32x2s", 3),
    ("U64x2", "load_extend_u32x2_u", "v128_load32x2u", 3),
    ("I32x4", "load_zero", "v128_load32_zero", 2),
    ("U32x4", "load_zero", "v128_load32_zero", 2),
    ("F32x4", "load_zero", "v128_load32_zero", 2),
    ("I64x2", "load_zero", "v128_load64_zero", 3),
    ("U64x2", "load_zero", "v128_load64_zero", 3),
    ("F64x2", "load_zero", "v128_load64_zero", 3),
]

# (result type, Dew function suffix, parameters, Starshine instruction)
V128_CROSS_OPS = [
    ("I8x16", "narrow_i16x8_s", "low: I16x8, high: I16x8", "i8x16_narrow_i16x8s"),
    ("U8x16", "narrow_i16x8_u", "low: U16x8, high: U16x8", "i8x16_narrow_i16x8u"),
    ("I8x16", "swizzle", "value: I8x16, indices: U8x16", "i8x16_swizzle"),
    ("U8x16", "swizzle", "value: U8x16, indices: U8x16", "i8x16_swizzle"),
    ("I16x8", "narrow_i32x4_s", "low: I32x4, high: I32x4", "i16x8_narrow_i32x4s"),
    ("U16x8", "narrow_i32x4_u", "low: U32x4, high: U32x4", "i16x8_narrow_i32x4u"),
    ("I16x8", "extend_low_i8x16_s", "value: I8x16", "i16x8_extend_low_i8x16s"),
    ("I16x8", "extend_high_i8x16_s", "value: I8x16", "i16x8_extend_high_i8x16s"),
    ("U16x8", "extend_low_i8x16_u", "value: U8x16", "i16x8_extend_low_i8x16u"),
    ("U16x8", "extend_high_i8x16_u", "value: U8x16", "i16x8_extend_high_i8x16u"),
    ("I16x8", "extadd_pairwise_i8x16_s", "value: I8x16", "i16x8_extadd_pairwise_i8x16s"),
    ("U16x8", "extadd_pairwise_i8x16_u", "value: U8x16", "i16x8_extadd_pairwise_i8x16u"),
    ("I16x8", "extmul_low_i8x16_s", "left: I8x16, right: I8x16", "i16x8_extmul_low_i8x16s"),
    ("I16x8", "extmul_high_i8x16_s", "left: I8x16, right: I8x16", "i16x8_extmul_high_i8x16s"),
    ("U16x8", "extmul_low_i8x16_u", "left: U8x16, right: U8x16", "i16x8_extmul_low_i8x16u"),
    ("U16x8", "extmul_high_i8x16_u", "left: U8x16, right: U8x16", "i16x8_extmul_high_i8x16u"),
    ("I32x4", "extend_low_i16x8_s", "value: I16x8", "i32x4_extend_low_i16x8s"),
    ("I32x4", "extend_high_i16x8_s", "value: I16x8", "i32x4_extend_high_i16x8s"),
    ("U32x4", "extend_low_i16x8_u", "value: U16x8", "i32x4_extend_low_i16x8u"),
    ("U32x4", "extend_high_i16x8_u", "value: U16x8", "i32x4_extend_high_i16x8u"),
    ("I32x4", "extadd_pairwise_i16x8_s", "value: I16x8", "i32x4_extadd_pairwise_i16x8s"),
    ("U32x4", "extadd_pairwise_i16x8_u", "value: U16x8", "i32x4_extadd_pairwise_i16x8u"),
    ("I32x4", "extmul_low_i16x8_s", "left: I16x8, right: I16x8", "i32x4_extmul_low_i16x8s"),
    ("I32x4", "extmul_high_i16x8_s", "left: I16x8, right: I16x8", "i32x4_extmul_high_i16x8s"),
    ("U32x4", "extmul_low_i16x8_u", "left: U16x8, right: U16x8", "i32x4_extmul_low_i16x8u"),
    ("U32x4", "extmul_high_i16x8_u", "left: U16x8, right: U16x8", "i32x4_extmul_high_i16x8u"),
    ("I32x4", "dot_i16x8_s", "left: I16x8, right: I16x8", "i32x4_dot_i16x8s"),
    ("I64x2", "extend_low_i32x4_s", "value: I32x4", "i64x2_extend_low_i32x4s"),
    ("I64x2", "extend_high_i32x4_s", "value: I32x4", "i64x2_extend_high_i32x4s"),
    ("U64x2", "extend_low_i32x4_u", "value: U32x4", "i64x2_extend_low_i32x4u"),
    ("U64x2", "extend_high_i32x4_u", "value: U32x4", "i64x2_extend_high_i32x4u"),
    ("I64x2", "extmul_low_i32x4_s", "left: I32x4, right: I32x4", "i64x2_extmul_low_i32x4s"),
    ("I64x2", "extmul_high_i32x4_s", "left: I32x4, right: I32x4", "i64x2_extmul_high_i32x4s"),
    ("U64x2", "extmul_low_i32x4_u", "left: U32x4, right: U32x4", "i64x2_extmul_low_i32x4u"),
    ("U64x2", "extmul_high_i32x4_u", "left: U32x4, right: U32x4", "i64x2_extmul_high_i32x4u"),
    ("F32x4", "convert_i32x4_s", "value: I32x4", "f32x4_convert_i32x4s"),
    ("F32x4", "convert_i32x4_u", "value: U32x4", "f32x4_convert_i32x4u"),
    ("F32x4", "demote_f64x2_zero", "value: F64x2", "f32x4_demote_f64x2_zero"),
    ("F64x2", "convert_low_i32x4_s", "value: I32x4", "f64x2_convert_low_i32x4s"),
    ("F64x2", "convert_low_i32x4_u", "value: U32x4", "f64x2_convert_low_i32x4u"),
    ("F64x2", "promote_low_f32x4", "value: F32x4", "f64x2_promote_low_f32x4"),
    ("I32x4", "trunc_sat_f32x4_s", "value: F32x4", "i32x4_trunc_sat_f32x4s"),
    ("U32x4", "trunc_sat_f32x4_u", "value: F32x4", "i32x4_trunc_sat_f32x4u"),
    ("I32x4", "trunc_sat_f64x2_s_zero", "value: F64x2", "i32x4_trunc_sat_f64x2s_zero"),
    ("U32x4", "trunc_sat_f64x2_u_zero", "value: F64x2", "i32x4_trunc_sat_f64x2u_zero"),
]


def builtin(name: str, params: str, result: str, target: str) -> str:
    return f'builtin {name}({params}) -> {result} = "{target}"\n'


def carrier_helpers(type_name: str, carrier: str, family: list) -> str:
    """Library-only casts, loads, stores, and bitwise carrier operations."""
    prefix = type_name.lower()
    raw = {"Swar32": "U32", "Swar64": "U64", "V128": "V128"}[carrier]

    def cast(expression: str, source: str, target: str) -> str:
        if source == target:
            return expression
        return f"unsafe_bitcast::<{source}, {target}>({expression})"

    def function(name: str, params: str, result: str, body: str) -> str:
        return f"fn {name}({params}) -> {result} {{\n  {body}\n}}\n"

    output = [
        function(f"{prefix}_from_{carrier.lower()}", f"value: {carrier}", type_name, cast("value", carrier, type_name)),
        function(f"{prefix}_to_{carrier.lower()}", f"value: {type_name}", carrier, cast("value", type_name, carrier)),
    ]
    for target, *_ in family:
        if target != type_name:
            output.append(function(f"{prefix}_reinterpret_as_{target.lower()}", f"value: {type_name}", target, cast("value", type_name, target)))
    output.append(function(f"{prefix}_load", "address: U32", type_name, cast(f"{raw.lower()}_load(address)", raw, type_name)))
    output.append(function(f"{prefix}_store", f"address: U32, value: {type_name}", "Unit", f"{raw.lower()}_store(address, {cast('value', type_name, raw)})"))
    for operation in ["and", "or", "xor"]:
        operands = ", ".join(cast(name, type_name, raw) for name in ["left", "right"])
        body = cast(f"{raw.lower()}_{operation}({operands})", raw, type_name)
        output.append(function(f"{prefix}_{operation}", f"left: {type_name}, right: {type_name}", type_name, body))
    return "".join(output)


def method(name: str, params: str, result: str, call: str) -> str:
    return f"  fn {name}(self{params}) -> {result} {{\n    {call}\n  }}\n"


def trait_impl(trait: str, type_name: str, method_name: str, call_name: str) -> str:
    return (
        f"impl {trait} for {type_name} {{\n"
        f"  fn {method_name}(self, right: {type_name}) -> {type_name} {{\n"
        f"    {call_name}(self, right)\n"
        f"  }}\n"
        f"}}\n"
    )


def v128_source(type_name: str, scalar: str, lane: str, kind: str) -> str:
    p = type_name.lower()
    out = [carrier_helpers(type_name, "V128", V128_TYPES)]
    reinterpretations = [target for target, _, _, _ in V128_TYPES if target != type_name]
    out.append(builtin(f"{p}_not", f"value: {type_name}", type_name, "dew_v128_not"))
    out.append(builtin(f"{p}_andnot", f"left: {type_name}, right: {type_name}", type_name, "dew_v128_andnot"))
    out.append(builtin(f"{p}_bitselect", f"yes: {type_name}, no: {type_name}, mask: {type_name}", type_name, "dew_v128_bitselect"))
    out.append(builtin(f"{p}_any_true", f"value: {type_name}", "Bool", "dew_v128_any_true"))
    out.append(builtin(f"{p}_splat", f"value: {scalar}", type_name, f"dew_v128_splat_{lane}"))
    lane_count = int(type_name.split("x", 1)[1])
    out.append(builtin(f"{p}_load_splat", "address: U32", type_name, f"dew_{p}_load_splat"))
    for result, suffix, _, _ in V128_SPECIAL_MEMORY:
        if result == type_name:
            out.append(builtin(f"{p}_{suffix}", "address: U32", type_name, f"dew_{p}_{suffix}"))
    for index in range(lane_count):
        out.append(builtin(f"{p}_extract_{index}", f"value: {type_name}", scalar, f"dew_{p}_extract_{index}"))
        out.append(builtin(f"{p}_replace_{index}", f"value: {type_name}, lane: {scalar}", type_name, f"dew_{p}_replace_{index}"))
        out.append(builtin(f"{p}_load_lane_{index}", f"address: U32, value: {type_name}", type_name, f"dew_{p}_load_lane_{index}"))
        out.append(builtin(f"{p}_store_lane_{index}", f"address: U32, value: {type_name}", "Unit", f"dew_{p}_store_lane_{index}"))
    if lane == "i8":
        for shuffle in V128_BYTE_SHUFFLES:
            if shuffle == "reverse":
                out.append(builtin(f"{p}_reverse_raw", f"left: {type_name}, right: {type_name}", type_name, f"dew_{p}_reverse"))
                out.append(f"fn {p}_reverse(value: {type_name}) -> {type_name} {{\n  {p}_reverse_raw(value, value)\n}}\n")
            else:
                out.append(builtin(f"{p}_{shuffle}", f"left: {type_name}, right: {type_name}", type_name, f"dew_{p}_{shuffle}"))
    for result, suffix, params, _ in V128_CROSS_OPS:
        if result == type_name:
            out.append(builtin(f"{p}_{suffix}", params, type_name, f"dew_{p}_{suffix}"))

    binary = []
    unary = []
    comparisons = []
    reductions = []
    shifts = []
    if kind == "float":
        binary = ["add", "sub", "mul", "div", "min", "max", "pmin", "pmax"]
        unary = ["abs", "neg", "sqrt", "ceil", "floor", "trunc", "nearest"]
        comparisons = ["eq", "ne", "lt", "le", "gt", "ge"]
    else:
        binary = ["add", "sub"]
        if lane != "i8":
            binary.append("mul")
        if kind == "signed":
            if lane != "i64":
                binary += ["min_s", "max_s"]
            unary += ["abs", "neg"]
            comparisons = ["eq", "ne", "lt_s", "le_s", "gt_s", "ge_s"]
            if lane in ("i8", "i16"):
                binary += ["add_sat_s", "sub_sat_s"]
        else:
            if lane != "i64":
                binary += ["min_u", "max_u"]
            comparisons = ["eq", "ne"]
            if lane != "i64":
                comparisons += ["lt_u", "le_u", "gt_u", "ge_u"]
            if lane in ("i8", "i16"):
                binary += ["avgr_u", "add_sat_u", "sub_sat_u"]
        if lane == "i8":
            unary.append("popcnt")
        reductions = ["all_true", "bitmask"]
        shifts = ["shl", "shr_s" if kind == "signed" else "shr_u"]

    for op in binary + comparisons:
        out.append(builtin(f"{p}_{op}", f"left: {type_name}, right: {type_name}", type_name, f"dew_v128_{op}_{lane}"))
    for op in unary:
        out.append(builtin(f"{p}_{op}", f"value: {type_name}", type_name, f"dew_v128_{op}_{lane}"))
    for op in reductions:
        result = "Bool" if op == "all_true" else "U32"
        out.append(builtin(f"{p}_{op}", f"value: {type_name}", result, f"dew_v128_{op}_{lane}"))
    for op in shifts:
        out.append(builtin(f"{p}_{op}", f"value: {type_name}, count: U32", type_name, f"dew_v128_{op}_{lane}"))

    out.append(f"impl {type_name} {{\n")
    out.append(method("to_v128", "", "V128", f"{p}_to_v128(self)"))
    for target in reinterpretations:
        out.append(method(f"reinterpret_as_{target.lower()}", "", target, f"{p}_reinterpret_as_{target.lower()}(self)"))
    out.append(method("not", "", type_name, f"{p}_not(self)"))
    out.append(method("andnot", f", right: {type_name}", type_name, f"{p}_andnot(self, right)"))
    out.append(method("bitselect", f", no: {type_name}, mask: {type_name}", type_name, f"{p}_bitselect(self, no, mask)"))
    out.append(method("any_true", "", "Bool", f"{p}_any_true(self)"))
    for index in range(lane_count):
        out.append(method(f"extract_{index}", "", scalar, f"{p}_extract_{index}(self)"))
        out.append(method(f"replace_{index}", f", lane: {scalar}", type_name, f"{p}_replace_{index}(self, lane)"))
        out.append(method(f"load_lane_{index}", ", address: U32", type_name, f"{p}_load_lane_{index}(address, self)"))
        out.append(method(f"store_lane_{index}", ", address: U32", "Unit", f"{p}_store_lane_{index}(address, self)"))
    if lane == "i8":
        for shuffle in V128_BYTE_SHUFFLES:
            if shuffle == "reverse":
                out.append(method(shuffle, "", type_name, f"{p}_{shuffle}(self)"))
            else:
                out.append(method(shuffle, f", right: {type_name}", type_name, f"{p}_{shuffle}(self, right)"))
    for op in binary + comparisons:
        out.append(method(op.removesuffix("_s").removesuffix("_u"), f", right: {type_name}", type_name, f"{p}_{op}(self, right)"))
    for op in unary:
        out.append(method(op, "", type_name, f"{p}_{op}(self)"))
    for op in reductions:
        result = "Bool" if op == "all_true" else "U32"
        out.append(method(op, "", result, f"{p}_{op}(self)"))
    for op in shifts:
        public_name = "shr" if op.startswith("shr") else op
        out.append(method(public_name, ", count: U32", type_name, f"{p}_{op}(self, count)"))
    out.append("}\n")

    out.append(trait_impl("BitAnd", type_name, "bit_and", f"{p}_and"))
    out.append(trait_impl("BitOr", type_name, "bit_or", f"{p}_or"))
    out.append(trait_impl("BitXor", type_name, "bit_xor", f"{p}_xor"))
    if "add" in binary:
        out.append(trait_impl("Add", type_name, "add", f"{p}_add"))
    if "sub" in binary:
        out.append(trait_impl("Sub", type_name, "sub", f"{p}_sub"))
    if "mul" in binary:
        out.append(trait_impl("Mul", type_name, "mul", f"{p}_mul"))
    if "div" in binary:
        out.append(trait_impl("Div", type_name, "div", f"{p}_div"))
    return "".join(out)


def swar_i8_extended(type_name: str, kind: str, width: int) -> tuple[str, list[str], list[str]]:
    p = type_name.lower()
    raw = f"swar{width}"
    word = f"U{width}"
    suffix = f"u{width}"
    ones = (1 << width) - 1
    high = int.from_bytes(bytes([0x80]) * (width // 8), "little")
    low = int.from_bytes(bytes([0x7F]) * (width // 8), "little")
    one = int.from_bytes(bytes([0x01]) * (width // 8), "little")
    ff = int.from_bytes(bytes([0xFF]) * (width // 8), "little")
    nibble_lo = int.from_bytes(bytes([0x0F]) * (width // 8), "little")
    nibble_hi = int.from_bytes(bytes([0xF0]) * (width // 8), "little")
    nibble_carry = int.from_bytes(bytes([0x10]) * (width // 8), "little")
    even = int.from_bytes(bytes([0xFF, 0x00]) * (width // 16), "little")
    even_carry = int.from_bytes(bytes([0x00, 0x01]) * (width // 16), "little")
    dlo_high = int.from_bytes(bytes([0x80, 0x00]) * (width // 16), "little")
    dlo_low = int.from_bytes(bytes([0x7F, 0x00]) * (width // 16), "little")
    dhi_high = int.from_bytes(bytes([0x00, 0x80]) * (width // 16), "little")
    dhi_low = int.from_bytes(bytes([0x00, 0x7F]) * (width // 16), "little")

    def bits(expr: str) -> str:
        return f"{raw}_to_bits({p}_to_{raw}({expr}))"

    def wrap(expr: str) -> str:
        return f"{p}_from_{raw}({raw}_from_bits({expr}))"

    out: list[str] = []
    binary: list[str] = ["mul"]
    unary: list[str] = []
    lane_count = width // 8
    terms = []
    for index in range(lane_count):
        shift = index * 8
        left = f"((a >> {shift}{suffix}) & 255{suffix})" if shift else f"(a & 255{suffix})"
        right = f"((b >> {shift}{suffix}) & 255{suffix})" if shift else f"(b & 255{suffix})"
        product = f"(({left} * {right}) & 255{suffix})"
        terms.append(f"({product} << {shift}{suffix})" if shift else product)
    out.append(
        f"fn {p}_mul(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
        f"  {wrap(' | '.join(terms))}\n}}\n"
    )
    eq_bits = bits(f"{p}_eq(left, right)")
    out.append(
        f"fn {p}_ne(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  {wrap(f'{eq_bits} ^ {ones}{suffix}')}\n}}\n"
    )
    binary.append("ne")

    sign_adjust = f"a ^ {high}{suffix}" if kind == "signed" else "a"
    sign_adjust_b = f"b ^ {high}{suffix}" if kind == "signed" else "b"
    out.append(
        f"fn {p}_lt(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
        f"  let ax = {sign_adjust}\n  let bx = {sign_adjust_b}\n"
        f"  let d = ((ax | {high}{suffix}) - (bx & {low}{suffix})) ^ ((ax ^ (bx ^ {ones}{suffix})) & {high}{suffix})\n"
        f"  let mask = (((((ax ^ {ones}{suffix}) & bx) | (((ax ^ bx) ^ {ones}{suffix}) & d)) & {high}{suffix}) >> 7{suffix}) * 255{suffix}\n"
        f"  {wrap('mask')}\n}}\n"
    )
    reverse_lt_bits = bits(f"{p}_lt(right, left)")
    out.append(
        f"fn {p}_le(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  {wrap(f'{reverse_lt_bits} ^ {ones}{suffix}')}\n}}\n"
    )
    out.append(f"fn {p}_gt(left: {type_name}, right: {type_name}) -> {type_name} {{\n  {p}_lt(right, left)\n}}\n")
    forward_lt_bits = bits(f"{p}_lt(left, right)")
    out.append(
        f"fn {p}_ge(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  {wrap(f'{forward_lt_bits} ^ {ones}{suffix}')}\n}}\n"
    )
    for op in ("lt", "le", "gt", "ge"):
        binary.append(op)
    out.append(
        f"fn {p}_min(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let a = {bits('left')}\n  let b = {bits('right')}\n  let mask = {bits(f'{p}_lt(left, right)')}\n"
        f"  {wrap('b ^ ((a ^ b) & mask)')}\n}}\n"
    )
    out.append(
        f"fn {p}_max(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let a = {bits('left')}\n  let b = {bits('right')}\n  let mask = {bits(f'{p}_lt(left, right)')}\n"
        f"  {wrap('a ^ ((a ^ b) & mask)')}\n}}\n"
    )
    binary += ["min", "max"]

    if kind == "signed":
        out.append(
            f"fn {p}_abs(value: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('value')}\n  let mask = ((a & {high}{suffix}) >> 7{suffix}) * 255{suffix}\n"
            f"  let x = a ^ mask\n  let carry = mask & {one}{suffix}\n"
            f"  let lo = (x & {nibble_lo}{suffix}) + (carry & {nibble_lo}{suffix})\n"
            f"  let hi = (x & {nibble_hi}{suffix}) + (carry & {nibble_hi}{suffix}) + (lo & {nibble_carry}{suffix})\n"
            f"  {wrap(f'(lo & {nibble_lo}{suffix}) | (hi & {nibble_hi}{suffix})')}\n}}\n"
        )
        out.append(
            f"fn {p}_neg(value: {type_name}) -> {type_name} {{\n  let a = {bits('value')}\n"
            f"  {wrap(f'({high}{suffix} - (a & {low}{suffix})) ^ ((a ^ {ones}{suffix}) & {high}{suffix})')}\n}}\n"
        )
        unary += ["abs", "neg"]
        out.append(
            f"fn {p}_add_sat(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
            f"  let sum = ((a & {low}{suffix}) + (b & {low}{suffix})) ^ ((a ^ b) & {high}{suffix})\n"
            f"  let overflow = (((a ^ b) ^ {ones}{suffix}) & (a ^ sum) & {high}{suffix}) >> 7{suffix}\n"
            f"  let mask = overflow * 255{suffix}\n  let limit = (((a & {high}{suffix}) >> 7{suffix}) * 255{suffix}) ^ {low}{suffix}\n"
            f"  {wrap(f'(sum & (mask ^ {ones}{suffix})) | (limit & mask)')}\n}}\n"
        )
        out.append(
            f"fn {p}_sub_sat(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
            f"  let dlo = ((a | {dlo_high}{suffix}) - (b & {dlo_low}{suffix})) ^ ((a ^ (b ^ {ones}{suffix})) & {dlo_high}{suffix})\n"
            f"  let dhi = ((a | {dhi_high}{suffix}) - (b & {dhi_low}{suffix})) ^ ((a ^ (b ^ {ones}{suffix})) & {dhi_high}{suffix})\n"
            f"  let diff = (dlo & {even}{suffix}) | (dhi & {even ^ ones}{suffix})\n"
            f"  let overflow = ((a ^ b) & (a ^ diff) & {high}{suffix}) >> 7{suffix}\n  let mask = overflow * 255{suffix}\n"
            f"  let limit = (((a & {high}{suffix}) >> 7{suffix}) * 255{suffix}) ^ {low}{suffix}\n"
            f"  {wrap(f'(diff & (mask ^ {ones}{suffix})) | (limit & mask)')}\n}}\n"
        )
        binary += ["add_sat", "sub_sat"]
    else:
        no_low_bits = int.from_bytes(bytes([0xFE]) * (width // 8), "little")
        out.append(
            f"fn {p}_avgr(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
            f"  {wrap(f'(a | b) - (((a ^ b) & {no_low_bits}{suffix}) >> 1{suffix})')}\n}}\n"
        )
        out.append(
            f"fn {p}_add_sat(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
            f"  let lo = (a & {even}{suffix}) + (b & {even}{suffix})\n  let hi = ((a >> 8{suffix}) & {even}{suffix}) + ((b >> 8{suffix}) & {even}{suffix})\n"
            f"  let lo_carry = lo & {even_carry}{suffix}\n  let hi_carry = hi & {even_carry}{suffix}\n"
            f"  let lo_mask = lo_carry - (lo_carry >> 8{suffix})\n  let hi_mask = hi_carry * 255{suffix}\n"
            f"  {wrap(f'(lo & {even}{suffix}) | ((hi & {even}{suffix}) << 8{suffix}) | lo_mask | hi_mask')}\n}}\n"
        )
        out.append(
            f"fn {p}_sub_sat(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
            f"  let diff = ((a | {high}{suffix}) - (b & {low}{suffix})) ^ ((a ^ (b ^ {ones}{suffix})) & {high}{suffix})\n"
            f"  let mask = (((((a ^ {ones}{suffix}) & b) | (((a ^ b) ^ {ones}{suffix}) & diff)) & {high}{suffix}) >> 7{suffix}) * 255{suffix}\n"
            f"  {wrap(f'diff & (mask ^ {ones}{suffix})')}\n}}\n"
        )
        binary += ["avgr", "add_sat", "sub_sat"]
    return "".join(out), binary, unary


def swar_wide_extended(
    type_name: str,
    kind: str,
    width: int,
    lane_width: int,
) -> tuple[str, list[str], list[str]]:
    """Generate allocation-free packed i16/i32 operations over i32/i64 carriers."""
    p = type_name.lower()
    raw = f"swar{width}"
    suffix = f"u{width}"
    ones = (1 << width) - 1
    lane_mask = (1 << lane_width) - 1
    lane_count = width // lane_width

    def repeated(value: int) -> int:
        result = 0
        for index in range(lane_count):
            result |= value << (index * lane_width)
        return result

    high = repeated(1 << (lane_width - 1))
    low = repeated((1 << (lane_width - 1)) - 1)
    one = repeated(1)
    no_low_bit = repeated(lane_mask ^ 1)

    def bits(expr: str) -> str:
        return f"{raw}_to_bits({p}_to_{raw}({expr}))"

    def wrap(expr: str) -> str:
        return f"{p}_from_{raw}({raw}_from_bits({expr}))"

    def less_mask(left: str, right: str, signed: bool) -> str:
        ax = f"({left} ^ {high}{suffix})" if signed else left
        bx = f"({right} ^ {high}{suffix})" if signed else right
        d = (
            f"(({ax} | {high}{suffix}) - ({bx} & {low}{suffix})) ^ "
            f"(({ax} ^ ({bx} ^ {ones}{suffix})) & {high}{suffix})"
        )
        return (
            f"(((((({ax} ^ {ones}{suffix}) & {bx}) | "
            f"((({ax} ^ {bx}) ^ {ones}{suffix}) & ({d}))) & {high}{suffix}) >> "
            f"{lane_width - 1}{suffix}) * {lane_mask}{suffix})"
        )

    def packed_add(left: str, right: str) -> str:
        return (
            f"((({left} & {low}{suffix}) + ({right} & {low}{suffix})) ^ "
            f"(({left} ^ {right}) & {high}{suffix}))"
        )

    def packed_sub(left: str, right: str) -> str:
        return (
            f"((({left} | {high}{suffix}) - ({right} & {low}{suffix})) ^ "
            f"(({left} ^ ({right} ^ {ones}{suffix})) & {high}{suffix}))"
        )

    out: list[str] = []
    binary = ["mul", "ne", "lt", "le", "gt", "ge", "min", "max"]
    unary: list[str] = []

    terms = []
    for index in range(lane_count):
        shift = index * lane_width
        left = f"((a >> {shift}{suffix}) & {lane_mask}{suffix})" if shift else f"(a & {lane_mask}{suffix})"
        right = f"((b >> {shift}{suffix}) & {lane_mask}{suffix})" if shift else f"(b & {lane_mask}{suffix})"
        product = f"(({left} * {right}) & {lane_mask}{suffix})"
        terms.append(f"({product} << {shift}{suffix})" if shift else product)
    out.append(
        f"fn {p}_mul(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
        f"  {wrap(' | '.join(terms))}\n}}\n"
    )

    out.append(
        f"fn {p}_eq(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let x = {bits('left')} ^ {bits('right')}\n"
        f"  let nonzero = ((((x & {low}{suffix}) + {low}{suffix}) | x) & {high}{suffix})\n"
        f"  {wrap(f'(((nonzero >> {lane_width - 1}{suffix}) * {lane_mask}{suffix}) ^ {ones}{suffix})')}\n}}\n"
    )
    out.append(
        f"fn {p}_ne(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let equal = {bits(f'{p}_eq(left, right)')}\n"
        f"  {wrap(f'equal ^ {ones}{suffix}')}\n}}\n"
    )
    signed = kind == "signed"
    out.append(
        f"fn {p}_lt(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
        f"  {wrap(less_mask('a', 'b', signed))}\n}}\n"
    )
    out.append(
        f"fn {p}_le(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let greater = {bits(f'{p}_lt(right, left)')}\n"
        f"  {wrap(f'greater ^ {ones}{suffix}')}\n}}\n"
    )
    out.append(f"fn {p}_gt(left: {type_name}, right: {type_name}) -> {type_name} {{\n  {p}_lt(right, left)\n}}\n")
    out.append(
        f"fn {p}_ge(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let less = {bits(f'{p}_lt(left, right)')}\n"
        f"  {wrap(f'less ^ {ones}{suffix}')}\n}}\n"
    )
    out.append(
        f"fn {p}_min(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let a = {bits('left')}\n  let b = {bits('right')}\n  let mask = {bits(f'{p}_lt(left, right)')}\n"
        f"  {wrap('b ^ ((a ^ b) & mask)')}\n}}\n"
    )
    out.append(
        f"fn {p}_max(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
        f"  let a = {bits('left')}\n  let b = {bits('right')}\n  let mask = {bits(f'{p}_lt(left, right)')}\n"
        f"  {wrap('a ^ ((a ^ b) & mask)')}\n}}\n"
    )

    if kind == "signed":
        out.append(
            f"fn {p}_neg(value: {type_name}) -> {type_name} {{\n  let a = {bits('value')}\n"
            f"  {wrap(f'({high}{suffix} - (a & {low}{suffix})) ^ ((a ^ {ones}{suffix}) & {high}{suffix})')}\n}}\n"
        )
        out.append(
            f"fn {p}_abs(value: {type_name}) -> {type_name} {{\n  let a = {bits('value')}\n"
            f"  let mask = ((a & {high}{suffix}) >> {lane_width - 1}{suffix}) * {lane_mask}{suffix}\n"
            f"  let x = a ^ mask\n  let carry = mask & {one}{suffix}\n"
            f"  {wrap(packed_add('x', 'carry'))}\n}}\n"
        )
        unary += ["abs", "neg"]
        sum_expr = packed_add("a", "b")
        diff_expr = packed_sub("a", "b")
        out.append(
            f"fn {p}_add_sat(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n  let sum = {sum_expr}\n"
            f"  let overflow = ((((a ^ b) ^ {ones}{suffix}) & (a ^ sum) & {high}{suffix}) >> {lane_width - 1}{suffix}) * {lane_mask}{suffix}\n"
            f"  let limit = (((a & {high}{suffix}) >> {lane_width - 1}{suffix}) * {lane_mask}{suffix}) ^ {low}{suffix}\n"
            f"  {wrap(f'(sum & (overflow ^ {ones}{suffix})) | (limit & overflow)')}\n}}\n"
        )
        out.append(
            f"fn {p}_sub_sat(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n  let diff = {diff_expr}\n"
            f"  let overflow = (((a ^ b) & (a ^ diff) & {high}{suffix}) >> {lane_width - 1}{suffix}) * {lane_mask}{suffix}\n"
            f"  let limit = (((a & {high}{suffix}) >> {lane_width - 1}{suffix}) * {lane_mask}{suffix}) ^ {low}{suffix}\n"
            f"  {wrap(f'(diff & (overflow ^ {ones}{suffix})) | (limit & overflow)')}\n}}\n"
        )
        binary += ["add_sat", "sub_sat"]
    else:
        out.append(
            f"fn {p}_avgr(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n"
            f"  {wrap(f'(a | b) - (((a ^ b) & {no_low_bit}{suffix}) >> 1{suffix})')}\n}}\n"
        )
        sum_expr = packed_add("a", "b")
        diff_expr = packed_sub("a", "b")
        out.append(
            f"fn {p}_add_sat(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n  let sum = {sum_expr}\n"
            f"  let overflow = {less_mask('sum', 'a', False)}\n"
            f"  {wrap('sum | overflow')}\n}}\n"
        )
        out.append(
            f"fn {p}_sub_sat(left: {type_name}, right: {type_name}) -> {type_name} {{\n"
            f"  let a = {bits('left')}\n  let b = {bits('right')}\n  let diff = {diff_expr}\n"
            f"  let underflow = {less_mask('a', 'b', False)}\n"
            f"  {wrap(f'diff & (underflow ^ {ones}{suffix})')}\n}}\n"
        )
        binary += ["avgr", "add_sat", "sub_sat"]

    bit_terms = []
    for index in range(lane_count):
        source_shift = index * lane_width + lane_width - 1
        term = f"((a >> {source_shift}{suffix}) & 1{suffix})"
        if index:
            term = f"({term} << {index}{suffix})"
        bit_terms.append(term)
    out.append(
        f"fn {p}_bitmask(value: {type_name}) -> U32 {{\n  let a = {bits('value')}\n"
        f"  {suffix}_into_u32({' | '.join(bit_terms)})\n}}\n"
    )
    out.append(
        f"fn {p}_all_true(value: {type_name}) -> Bool {{\n"
        f"  {bits(f'{p}_eq(value, {p}_from_{raw}({raw}_from_bits(0{suffix})))')} == 0{suffix}\n}}\n"
    )
    return "".join(out), binary, unary


def swar_source(type_name: str, scalar: str, lane: str, kind: str, width: int) -> str:
    p = type_name.lower()
    carrier = f"Swar{width}"
    raw = f"swar{width}"
    family = SWAR32_TYPES if width == 32 else SWAR64_TYPES
    reinterpretations = [target for target, _, _, _ in family if target != type_name]
    out = [carrier_helpers(type_name, carrier, family)]
    extended_binary: list[str] = []
    extended_unary: list[str] = []

    if kind != "float":
        raw_lane = "I" + lane[1:]
        splat_argument = f"{scalar.lower()}_into_{raw_lane.lower()}(value)" if kind == "unsigned" else "value"
        out.append(f"fn {p}_splat(value: {scalar}) -> {type_name} {{\n  {p}_from_{raw}({raw}_splat_{lane}({splat_argument}))\n}}\n")
        signed_suffix = "s" if kind == "signed" else "u"
        out.append(f"fn {p}_extract(value: {type_name}, index: U8) -> {scalar} {{\n  {raw}_extract_{lane}_{signed_suffix}({p}_to_{raw}(value), index)\n}}\n")
        replace_lane = scalar
        lane_argument = f"{scalar.lower()}_into_{raw_lane.lower()}(lane)" if kind == "unsigned" else "lane"
        out.append(f"fn {p}_replace(value: {type_name}, index: U8, lane: {replace_lane}) -> {type_name} {{\n  {p}_from_{raw}({raw}_replace_{lane}({p}_to_{raw}(value), index, {lane_argument}))\n}}\n")
        for op in ("add", "sub"):
            out.append(f"fn {p}_{op}(left: {type_name}, right: {type_name}) -> {type_name} {{\n  {p}_from_{raw}({raw}_{op}_{lane}({p}_to_{raw}(left), {p}_to_{raw}(right)))\n}}\n")
        out.append(f"fn {p}_shl(value: {type_name}, count: U8) -> {type_name} {{\n  {p}_from_{raw}({raw}_shl_{lane}({p}_to_{raw}(value), count))\n}}\n")
        out.append(f"fn {p}_shr(value: {type_name}, count: U8) -> {type_name} {{\n  {p}_from_{raw}({raw}_shr_{lane}_{signed_suffix}({p}_to_{raw}(value), count))\n}}\n")
        if lane == "i8":
            out.append(f"fn {p}_popcnt(value: {type_name}) -> {type_name} {{\n  {p}_from_{raw}({raw}_popcnt_i8({p}_to_{raw}(value)))\n}}\n")
            out.append(f"fn {p}_bitmask(value: {type_name}) -> U32 {{\n  {raw}_bitmask_i8({p}_to_{raw}(value))\n}}\n")
            out.append(f"fn {p}_all_true(value: {type_name}) -> Bool {{\n  {raw}_all_true_i8({p}_to_{raw}(value))\n}}\n")
            out.append(f"fn {p}_eq(left: {type_name}, right: {type_name}) -> {type_name} {{\n  {p}_from_{raw}({raw}_eq_i8({p}_to_{raw}(left), {p}_to_{raw}(right)))\n}}\n")
            extended_source, extended_binary, extended_unary = swar_i8_extended(
                type_name,
                kind,
                width,
            )
            out.append(extended_source)
        else:
            lane_width = int(lane[1:])
            extended_source, extended_binary, extended_unary = swar_wide_extended(
                type_name,
                kind,
                width,
                lane_width,
            )
            out.append(extended_source)

    out.append(f"impl {type_name} {{\n")
    out.append(method(f"to_{raw}", "", carrier, f"{p}_to_{raw}(self)"))
    for target in reinterpretations:
        out.append(method(f"reinterpret_as_{target.lower()}", "", target, f"{p}_reinterpret_as_{target.lower()}(self)"))
    if kind != "float":
        out.append(method("extract", ", index: U8", scalar, f"{p}_extract(self, index)"))
        replace_lane = scalar
        out.append(method("replace", f", index: U8, lane: {replace_lane}", type_name, f"{p}_replace(self, index, lane)"))
        out.append(method("shl", ", count: U8", type_name, f"{p}_shl(self, count)"))
        out.append(method("shr", ", count: U8", type_name, f"{p}_shr(self, count)"))
        if lane == "i8":
            out.append(method("popcnt", "", type_name, f"{p}_popcnt(self)"))
        out.append(method("bitmask", "", "U32", f"{p}_bitmask(self)"))
        out.append(method("all_true", "", "Bool", f"{p}_all_true(self)"))
        out.append(method("eq_mask", f", right: {type_name}", type_name, f"{p}_eq(self, right)"))
        for op in extended_binary:
            out.append(method(op + "_mask" if op in ("ne", "lt", "le", "gt", "ge") else op, f", right: {type_name}", type_name, f"{p}_{op}(self, right)"))
        for op in extended_unary:
            out.append(method(op, "", type_name, f"{p}_{op}(self)"))
    out.append("}\n")
    out.append(trait_impl("BitAnd", type_name, "bit_and", f"{p}_and"))
    out.append(trait_impl("BitOr", type_name, "bit_or", f"{p}_or"))
    out.append(trait_impl("BitXor", type_name, "bit_xor", f"{p}_xor"))
    if kind != "float":
        out.append(trait_impl("Add", type_name, "add", f"{p}_add"))
        out.append(trait_impl("Sub", type_name, "sub", f"{p}_sub"))
        if "mul" in extended_binary:
            out.append(trait_impl("Mul", type_name, "mul", f"{p}_mul"))
    return "".join(out)


def lane_index(index: int) -> str:
    return f"@lib.LaneIdx::new(b'\\x{index:02X}')"


def v128_memory_backend_source() -> str:
    branches: list[str] = []
    first = True
    widths = {"i8": ("8", 0), "i16": ("16", 1), "i32": ("32", 2), "f32": ("32", 2), "i64": ("64", 3), "f64": ("64", 3)}
    for type_name, _, lane, _ in V128_TYPES:
        prefix = type_name.lower()
        bits, align = widths[lane]
        keyword = "if" if first else "else if"
        first = False
        branches.append(
            f"  {keyword} name == b\"dew_{prefix}_load_splat\" {{\n"
            f"    Some([@lib.Instruction::v128_load{bits}_splat(starshine_memory_argument({align}U))])\n"
            f"  }} "
        )
        for index in range(int(type_name.split("x", 1)[1])):
            branches.append(
                f"else if name == b\"dew_{prefix}_load_lane_{index}\" {{\n"
                f"    Some([@lib.Instruction::v128_load{bits}_lane(starshine_memory_argument({align}U), {lane_index(index)})])\n"
                f"  }} else if name == b\"dew_{prefix}_store_lane_{index}\" {{\n"
                f"    Some([@lib.Instruction::v128_store{bits}_lane(starshine_memory_argument({align}U), {lane_index(index)})])\n"
                f"  }} "
            )
    for type_name, suffix, instruction, align in V128_SPECIAL_MEMORY:
        prefix = type_name.lower()
        branches.append(
            f"else if name == b\"dew_{prefix}_{suffix}\" {{\n"
            f"    Some([@lib.Instruction::{instruction}(starshine_memory_argument({align}U))])\n"
            f"  }} "
        )
    return (
        "///|\nfn starshine_v128_memory_builtin_instructions(name : Bytes) -> Array[@lib.Instruction]? {\n"
        + "".join(branches)
        + "else {\n    None\n  }\n}\n"
    )


def v128_shuffle_backend_source() -> str:
    branches: list[str] = []
    first = True
    for type_name in ("I8x16", "U8x16"):
        prefix = type_name.lower()
        for name, indices in V128_BYTE_SHUFFLES.items():
            keyword = "if" if first else "else if"
            first = False
            args = ", ".join(lane_index(index) for index in indices)
            branches.append(
                f"  {keyword} name == b\"dew_{prefix}_{name}\" {{\n"
                f"    Some([@lib.Instruction::i8x16_shuffle({args})])\n"
                f"  }} "
            )
    return (
        "///|\nfn starshine_v128_shuffle_builtin_instructions(name : Bytes) -> Array[@lib.Instruction]? {\n"
        + "".join(branches)
        + "else {\n    None\n  }\n}\n"
    )


def v128_cross_backend_source() -> str:
    branches: list[str] = []
    for index, (result, suffix, _, instruction) in enumerate(V128_CROSS_OPS):
        prefix = result.lower()
        keyword = "if" if index == 0 else "else if"
        branches.append(
            f"  {keyword} name == b\"dew_{prefix}_{suffix}\" {{\n"
            f"    Some([@lib.Instruction::{instruction}()])\n"
            f"  }} "
        )
    return (
        "///|\n"
        "fn starshine_v128_cross_builtin_instructions(\n"
        "  name : Bytes,\n"
        ") -> Array[@lib.Instruction]? {\n"
        + "".join(branches)
        + "else {\n    None\n  }\n}\n"
    )


def v128_lane_backend_source() -> str:
    branches: list[str] = []
    instruction = {
        "I8x16": "i8x16_extract_lane_s",
        "U8x16": "i8x16_extract_lane_u",
        "I16x8": "i16x8_extract_lane_s",
        "U16x8": "i16x8_extract_lane_u",
        "I32x4": "i32x4_extract_lane",
        "U32x4": "i32x4_extract_lane",
        "I64x2": "i64x2_extract_lane",
        "U64x2": "i64x2_extract_lane",
        "F32x4": "f32x4_extract_lane",
        "F64x2": "f64x2_extract_lane",
    }
    replace = {
        "i8": "i8x16_replace_lane",
        "i16": "i16x8_replace_lane",
        "i32": "i32x4_replace_lane",
        "i64": "i64x2_replace_lane",
        "f32": "f32x4_replace_lane",
        "f64": "f64x2_replace_lane",
    }
    first = True
    for type_name, _, lane, _ in V128_TYPES:
        prefix = type_name.lower()
        lane_count = int(type_name.split("x", 1)[1])
        for index in range(lane_count):
            keyword = "if" if first else "else if"
            first = False
            index_value = lane_index(index)
            branches.append(
                f"  {keyword} name == b\"dew_{prefix}_extract_{index}\" {{\n"
                f"    Some([@lib.Instruction::{instruction[type_name]}({index_value})])\n"
                f"  }} "
            )
            branches.append(
                f"else if name == b\"dew_{prefix}_replace_{index}\" {{\n"
                f"    Some([@lib.Instruction::{replace[lane]}({index_value})])\n"
                f"  }} "
            )
    return (
        "///|\n"
        "fn starshine_v128_lane_builtin_instructions(\n"
        "  name : Bytes,\n"
        ") -> Array[@lib.Instruction]? {\n"
        + "".join(branches)
        + "else {\n    None\n  }\n}\n"
    )


def typed_parity_source() -> str:
    families = [
        (32, "I8x4", "i8x4", "signed"),
        (32, "U8x4", "u8x4", "unsigned"),
        (32, "I16x2", "i16x2", "signed"),
        (32, "U16x2", "u16x2", "unsigned"),
        (64, "I8x8", "i8x8", "signed"),
        (64, "U8x8", "u8x8", "unsigned"),
        (64, "I16x4", "i16x4", "signed"),
        (64, "U16x4", "u16x4", "unsigned"),
        (64, "I32x2", "i32x2", "signed"),
        (64, "U32x2", "u32x2", "unsigned"),
    ]
    out = [
        "".join(f"open dew.std.{prefix}\n" for _, _, prefix, _ in families),
        "\n",
    ]
    for width, type_name, prefix, kind in families:
        raw = f"swar{width}"
        word = f"U{width}"
        to_value = lambda name: f"{prefix}_from_{raw}({raw}_from_bits({name}))"
        to_bits = lambda expression: f"{raw}_to_bits({prefix}_to_{raw}({expression}))"
        binary = ["eq", "mul", "ne", "lt", "le", "gt", "ge", "min", "max", "add_sat", "sub_sat"]
        if kind == "unsigned":
            binary.append("avgr")
        for op in binary:
            operation = f"{prefix}_{op}({to_value('left')}, {to_value('right')})"
            out.append(
                f"pub fn t_{prefix}_{op}(left: {word}, right: {word}) -> {word} {{\n"
                f"  {to_bits(operation)}\n"
                f"}}\n"
            )
        if kind == "signed":
            for op in ("abs", "neg"):
                operation = f"{prefix}_{op}({to_value('value')})"
                out.append(
                    f"pub fn t_{prefix}_{op}(value: {word}) -> {word} {{\n"
                    f"  {to_bits(operation)}\n"
                    f"}}\n"
                )
        out.append(
            f"pub fn t_{prefix}_bitmask(value: {word}) -> U32 {{\n"
            f"  {prefix}_bitmask({to_value('value')})\n"
            f"}}\n"
        )
        out.append(
            f"pub fn t_{prefix}_all_true(value: {word}) -> Bool {{\n"
            f"  {prefix}_all_true({to_value('value')})\n"
            f"}}\n"
        )
    return "".join(out)


def main() -> None:
    check = sys.argv[1:] == ["--check"]
    if sys.argv[1:] not in ([], ["--check"]):
        raise SystemExit("usage: generate_lane_std.py [--check]")
    generated: list[tuple[str, str]] = []
    for args in SWAR32_TYPES:
        generated.append((args[0].lower(), swar_source(*args, 32)))
    for args in SWAR64_TYPES:
        generated.append((args[0].lower(), swar_source(*args, 64)))
    for args in V128_TYPES:
        generated.append((args[0].lower(), v128_source(*args)))
    entries = ",\n    ".join(f'b{json.dumps(source)}' for _, source in generated)
    embedded = (
        "///|\n"
        "pub fn standard_lane_sources() -> Array[Bytes] {\n"
        f"  [\n    {entries},\n  ]\n"
        "}\n"
    )
    outputs = [(OUT / f"{name}.dew", source) for name, source in generated]
    outputs.extend(
        [
            (EMBEDDED, embedded),
            (TYPED_PARITY, typed_parity_source()),
            (V128_LANE_BACKEND, v128_lane_backend_source()),
            (V128_CROSS_BACKEND, v128_cross_backend_source()),
            (V128_MEMORY_BACKEND, v128_memory_backend_source()),
            (V128_SHUFFLE_BACKEND, v128_shuffle_backend_source()),
        ]
    )
    if check:
        # MoonBit formats generated backend dispatch tables after generation.
        # Check source modules and bootstrap providers byte-for-byte here; the
        # project-wide formatter check covers the generated MoonBit backends.
        check_outputs = outputs[: len(generated) + 2]
        stale = [
            path.relative_to(ROOT).as_posix()
            for path, source in check_outputs
            if not path.exists() or path.read_text(encoding="utf-8") != source
        ]
        if stale:
            for path in stale:
                print(f"out of date: {path}")
            raise SystemExit(1)
        print(f"checked {len(generated)} lane modules and bootstrap sources")
        return
    OUT.mkdir(parents=True, exist_ok=True)
    for path, source in outputs:
        path.write_text(source, encoding="utf-8")
    print(f"generated {len(generated)} lane modules")


if __name__ == "__main__":
    main()
