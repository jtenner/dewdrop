#!/usr/bin/env python3
"""Generate the scalar dew.std.math module and its bootstrap source."""

from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "std/math.dew"
TARGET = ROOT / "src/standard_sources/standard_math_sources.mbt"

SIGNED = [
    ("i8", "I8", "-128i8"),
    ("i16", "I16", "-32768i16"),
    ("i32", "I32", "-2147483648i32"),
    ("i64", "I64", "-9223372036854775808i64"),
]

UNSIGNED = [
    ("u8", "U8", "255u8"),
    ("u16", "U16", "65535u16"),
    ("u32", "U32", "4294967295u32"),
    ("u64", "U64", "18446744073709551615u64"),
]


def integer_common(stem: str, type_: str) -> str:
    zero = f"0{stem}"
    return f'''pub fn {stem}_min(left: {type_}, right: {type_}) -> {type_} {{
  if left < right {{
    left
  }} else {{
    right
  }}
}}

pub fn {stem}_max(left: {type_}, right: {type_}) -> {type_} {{
  if left > right {{
    left
  }} else {{
    right
  }}
}}

pub fn {stem}_clamp(value: {type_}, lower: {type_}, upper: {type_}) -> {type_} {{
  if lower > upper {{
    unreachable()
  }} else if value < lower {{
    lower
  }} else if value > upper {{
    upper
  }} else {{
    value
  }}
}}

pub fn {stem}_wrapping_add(left: {type_}, right: {type_}) -> {type_} {{
  left + right
}}

pub fn {stem}_wrapping_sub(left: {type_}, right: {type_}) -> {type_} {{
  left - right
}}

pub fn {stem}_wrapping_mul(left: {type_}, right: {type_}) -> {type_} {{
  left * right
}}

'''


def signed_source(stem: str, type_: str, minimum: str) -> str:
    zero = f"0{stem}"
    one = f"1{stem}"
    neg_one = f"-1{stem}"
    return integer_common(stem, type_) + f'''pub fn {stem}_wrapping_abs(value: {type_}) -> {type_} {{
  if value < {zero} {{
    -value
  }} else {{
    value
  }}
}}

pub fn {stem}_abs(value: {type_}) -> {type_} {{
  if value == {minimum} {{
    unreachable()
  }} else {{
    {stem}_wrapping_abs(value)
  }}
}}

pub fn {stem}_checked_add(left: {type_}, right: {type_}) -> Option<{type_}> {{
  let result = left + right
  if ((left ^ result) & (right ^ result)) < {zero} {{
    Option::None
  }} else {{
    Option::Some(result)
  }}
}}

pub fn {stem}_checked_sub(left: {type_}, right: {type_}) -> Option<{type_}> {{
  let result = left - right
  if ((left ^ right) & (left ^ result)) < {zero} {{
    Option::None
  }} else {{
    Option::Some(result)
  }}
}}

pub fn {stem}_checked_mul(left: {type_}, right: {type_}) -> Option<{type_}> {{
  if left == {zero} || right == {zero} {{
    Option::Some({zero})
  }} else if (left == {minimum} && right == {neg_one}) ||
    (right == {minimum} && left == {neg_one}) {{
    Option::None
  }} else {{
    let result = left * right
    if result / right == left {{
      Option::Some(result)
    }} else {{
      Option::None
    }}
  }}
}}

pub fn {stem}_checked_div(left: {type_}, right: {type_}) -> Option<{type_}> {{
  if right == {zero} || (left == {minimum} && right == {neg_one}) {{
    Option::None
  }} else {{
    Option::Some(left / right)
  }}
}}

pub fn {stem}_checked_rem(left: {type_}, right: {type_}) -> Option<{type_}> {{
  if right == {zero} {{
    Option::None
  }} else if left == {minimum} && right == {neg_one} {{
    Option::Some({zero})
  }} else {{
    Option::Some(left % right)
  }}
}}

'''


def unsigned_source(stem: str, type_: str, maximum: str) -> str:
    zero = f"0{stem}"
    return integer_common(stem, type_) + f'''pub fn {stem}_checked_add(left: {type_}, right: {type_}) -> Option<{type_}> {{
  let result = left + right
  if result < left {{
    Option::None
  }} else {{
    Option::Some(result)
  }}
}}

pub fn {stem}_checked_sub(left: {type_}, right: {type_}) -> Option<{type_}> {{
  if left < right {{
    Option::None
  }} else {{
    Option::Some(left - right)
  }}
}}

pub fn {stem}_checked_mul(left: {type_}, right: {type_}) -> Option<{type_}> {{
  if right != {zero} && left > {maximum} / right {{
    Option::None
  }} else {{
    Option::Some(left * right)
  }}
}}

pub fn {stem}_checked_div(left: {type_}, right: {type_}) -> Option<{type_}> {{
  if right == {zero} {{
    Option::None
  }} else {{
    Option::Some(left / right)
  }}
}}

pub fn {stem}_checked_rem(left: {type_}, right: {type_}) -> Option<{type_}> {{
  if right == {zero} {{
    Option::None
  }} else {{
    Option::Some(left % right)
  }}
}}

'''


def float_source(
    stem: str,
    type_: str,
    bits: str,
    sign_mask: str,
    magnitude_mask: str,
    exponent_mask: str,
) -> str:
    zero = f"0.0{stem}"
    integer = f"i{type_[1:]}"
    return f'''pub builtin {stem}_to_bits(value: {type_}) -> {bits} = "{integer}.reinterpret_{stem}"
pub builtin {stem}_from_bits(value: {bits}) -> {type_} = "{stem}.reinterpret_{integer}"
pub builtin {stem}_abs(value: {type_}) -> {type_} = "{stem}.abs"
pub builtin {stem}_sqrt(value: {type_}) -> {type_} = "{stem}.sqrt"
pub builtin {stem}_ceil(value: {type_}) -> {type_} = "{stem}.ceil"
pub builtin {stem}_floor(value: {type_}) -> {type_} = "{stem}.floor"
pub builtin {stem}_trunc(value: {type_}) -> {type_} = "{stem}.trunc"
pub builtin {stem}_nearest(value: {type_}) -> {type_} = "{stem}.nearest"

pub fn {stem}_is_nan(value: {type_}) -> Bool {{
  value != value
}}

pub fn {stem}_is_infinite(value: {type_}) -> Bool {{
  ({stem}_to_bits(value) & {magnitude_mask}) == {exponent_mask}
}}

pub fn {stem}_is_finite(value: {type_}) -> Bool {{
  ({stem}_to_bits(value) & {magnitude_mask}) < {exponent_mask}
}}

pub fn {stem}_is_sign_negative(value: {type_}) -> Bool {{
  ({stem}_to_bits(value) & {sign_mask}) != 0{bits.lower()}
}}

pub fn {stem}_copysign(magnitude: {type_}, sign: {type_}) -> {type_} {{
  {stem}_from_bits(
    ({stem}_to_bits(magnitude) & {magnitude_mask}) |
    ({stem}_to_bits(sign) & {sign_mask})
  )
}}

pub fn {stem}_min(left: {type_}, right: {type_}) -> {type_} {{
  if {stem}_is_nan(left) {{
    left
  }} else if {stem}_is_nan(right) {{
    right
  }} else if left < right {{
    left
  }} else if right < left {{
    right
  }} else if left == {zero} && right == {zero} {{
    if {stem}_is_sign_negative(left) {{
      left
    }} else {{
      right
    }}
  }} else {{
    left
  }}
}}

pub fn {stem}_max(left: {type_}, right: {type_}) -> {type_} {{
  if {stem}_is_nan(left) {{
    left
  }} else if {stem}_is_nan(right) {{
    right
  }} else if left > right {{
    left
  }} else if right > left {{
    right
  }} else if left == {zero} && right == {zero} {{
    if {stem}_is_sign_negative(left) {{
      right
    }} else {{
      left
    }}
  }} else {{
    left
  }}
}}

pub fn {stem}_clamp(value: {type_}, lower: {type_}, upper: {type_}) -> {type_} {{
  if {stem}_is_nan(lower) || {stem}_is_nan(upper) || lower > upper {{
    unreachable()
  }} else if {stem}_is_nan(value) {{
    value
  }} else if value < lower {{
    lower
  }} else if value > upper {{
    upper
  }} else {{
    value
  }}
}}

'''


def source_text() -> str:
    out = [
        "// Generated by tools/generate_math_std.py.\n"
        "// Integer operators are explicitly named wrapping operations; checked operations return Option.\n"
        "// Float min/max preserve the first NaN operand and define -0/+0 selection.\n\n"
    ]
    for row in SIGNED:
        out.append(signed_source(*row))
    for row in UNSIGNED:
        out.append(unsigned_source(*row))
    out.append(
        float_source(
            "f32", "F32", "U32", "2147483648u32", "2147483647u32",
            "2139095040u32",
        )
    )
    out.append(
        float_source(
            "f64", "F64", "U64", "9223372036854775808u64",
            "9223372036854775807u64", "9218868437227405312u64",
        )
    )
    return "".join(out).rstrip() + "\n"


def moonbit_bytes_literal(data: bytes) -> str:
    pieces: list[str] = []
    for byte in data:
        if byte == 0x0A:
            pieces.append("\\n")
        elif byte == 0x0D:
            pieces.append("\\r")
        elif byte == 0x09:
            pieces.append("\\t")
        elif byte == 0x22:
            pieces.append('\\"')
        elif byte == 0x5C:
            pieces.append("\\\\")
        elif 0x20 <= byte <= 0x7E:
            pieces.append(chr(byte))
        else:
            pieces.append(f"\\x{byte:02X}")
    return 'b"' + "".join(pieces) + '"'


def embedded_text(source: str) -> str:
    return (
        "///|\n"
        "pub fn standard_math_source() -> Bytes {\n"
        f"  {moonbit_bytes_literal(source.encode())}\n"
        "}\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    source = source_text()
    embedded = embedded_text(source)
    stale: list[Path] = []
    if not SOURCE.exists() or SOURCE.read_text(encoding="utf-8") != source:
        stale.append(SOURCE)
    if not TARGET.exists() or TARGET.read_text(encoding="utf-8") != embedded:
        stale.append(TARGET)
    if args.check:
        if stale:
            names = ", ".join(str(path.relative_to(ROOT)) for path in stale)
            raise SystemExit(f"{names} stale; run tools/generate_math_std.py")
        print(f"checked {SOURCE.relative_to(ROOT)} and {TARGET.relative_to(ROOT)}")
        return
    SOURCE.write_text(source, encoding="utf-8")
    TARGET.write_text(embedded, encoding="utf-8")
    print(f"generated {SOURCE.relative_to(ROOT)} and {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
