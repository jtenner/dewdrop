#!/usr/bin/env python3
"""Generate Dew self-host numeric builtin emission from the native backend table."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "src/backend/starshine_numeric_builtins.mbt"
CONVERSION_SOURCE = ROOT / "src/backend/starshine_conversion_builtins.mbt"
V128_SOURCE = ROOT / "src/backend/starshine_v128_builtins.mbt"
OUTPUT = ROOT / "self_host/compiler/starshine_builtin_emit.dew"

BRANCH = re.compile(
    r'(?:if|else if) name == b"([^"]+)" \{\n\s+Some\(\[(.*?)\]\)\n\s+\}',
    re.S,
)
INSTRUCTION = re.compile(r"@lib\.Instruction::([A-Za-z0-9_]+)\(\)")
CONST = re.compile(
    r"@lib\.Instruction::([A-Za-z0-9_]+)\(@lib\.(I32|I64)::new\((-?[0-9]+)\)\)"
)


def split_instructions(value: str) -> list[str]:
    result: list[str] = []
    depth = 0
    start = 0
    for index, char in enumerate(value):
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
        elif char == "," and depth == 0:
            part = value[start:index].strip()
            if part:
                result.append(part)
            start = index + 1
    part = value[start:].strip()
    if part:
        result.append(part)
    return result


def translate_instruction(value: str) -> str:
    match = INSTRUCTION.fullmatch(value)
    if match:
        return f"StarshineFfi.ffi_lib_Instruction_{match.group(1)}()"
    match = CONST.fullmatch(value)
    if match:
        instruction, carrier, literal = match.groups()
        suffix = "i32" if carrier == "I32" else "i64"
        return (
            f"StarshineFfi.ffi_lib_Instruction_{instruction}("
            f"StarshineFfi.ffi_lib_{carrier}_new({literal}{suffix}),"
            ")"
        )
    raise ValueError(f"unsupported numeric instruction: {value}")


def emit_push(expression: str) -> list[str]:
    return [
        "    StarshineFfi.ffi_ffi_bridge_instructions_push(",
        "      destination,",
        f"      {expression},",
        "    )",
    ]


def main() -> None:
    source = SOURCE.read_text()
    branches = BRANCH.findall(source)
    if len(branches) != 162:
        raise SystemExit(f"expected 162 numeric builtin branches, found {len(branches)}")
    conversion_branches = BRANCH.findall(CONVERSION_SOURCE.read_text())
    if len(conversion_branches) != 100:
        raise SystemExit(
            f"expected 100 conversion builtin branches, found {len(conversion_branches)}"
        )
    v128_branches = BRANCH.findall(V128_SOURCE.read_text())
    if len(v128_branches) != 150:
        raise SystemExit(f"expected 150 V128 builtin branches, found {len(v128_branches)}")

    aliases: list[tuple[str, list[str]]] = [
        ("i32_add", ["StarshineFfi.ffi_lib_Instruction_i32_add()"]),
        ("i32_sub", ["StarshineFfi.ffi_lib_Instruction_i32_sub()"]),
        ("i32_lt", ["StarshineFfi.ffi_lib_Instruction_i32_lt_s()"]),
        ("i32_lte", ["StarshineFfi.ffi_lib_Instruction_i32_le_s()"]),
        ("dew_debug_ignore", ["StarshineFfi.ffi_lib_Instruction_drop()"]),
        ("dew_debug_dispatch", ["StarshineFfi.ffi_lib_Instruction_drop()"]),
        ("dew_unreachable", ["StarshineFfi.ffi_lib_Instruction_unreachable_()"]),
        ("dew_i8_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(0i32)"]),
        ("dew_i8_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(1i32)"]),
        ("dew_u8_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(2i32)"]),
        ("dew_u8_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(1i32)"]),
        ("dew_i16_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(3i32)"]),
        ("dew_i16_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(4i32)"]),
        ("dew_u16_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(5i32)"]),
        ("dew_u16_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(4i32)"]),
        ("dew_i32_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(6i32)"]),
        ("dew_u32_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(6i32)"]),
        ("dew_swar32_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(6i32)"]),
        ("dew_i32_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(7i32)"]),
        ("dew_u32_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(7i32)"]),
        ("dew_swar32_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(7i32)"]),
        ("dew_i64_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(8i32)"]),
        ("dew_u64_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(8i32)"]),
        ("dew_swar64_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(8i32)"]),
        ("dew_i64_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(9i32)"]),
        ("dew_u64_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(9i32)"]),
        ("dew_swar64_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(9i32)"]),
        ("dew_f32_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(10i32)"]),
        ("dew_f32_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(11i32)"]),
        ("dew_f64_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(12i32)"]),
        ("dew_f64_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(13i32)"]),
        ("dew_v128_load", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(14i32)"]),
        ("dew_v128_store", ["StarshineFfi.ffi_ffi_bridge_instruction_memory_builtin(15i32)"]),
        ("swar32_and", ["StarshineFfi.ffi_lib_Instruction_i32_and()"]),
        ("swar32_or", ["StarshineFfi.ffi_lib_Instruction_i32_or()"]),
        ("swar32_xor", ["StarshineFfi.ffi_lib_Instruction_i32_xor()"]),
        ("swar64_and", ["StarshineFfi.ffi_lib_Instruction_i64_and()"]),
        ("swar64_or", ["StarshineFfi.ffi_lib_Instruction_i64_or()"]),
        ("swar64_xor", ["StarshineFfi.ffi_lib_Instruction_i64_xor()"]),
        ("v128_and", ["StarshineFfi.ffi_lib_Instruction_v128_and()"]),
        ("v128_or", ["StarshineFfi.ffi_lib_Instruction_v128_or()"]),
        ("v128_xor", ["StarshineFfi.ffi_lib_Instruction_v128_xor()"]),
    ]
    identities = {
        "unsafe.bitcast",
        "swar32_from_bits",
        "swar32_to_bits",
        "swar64_from_bits",
        "swar64_to_bits",
        "dew_reinterpret",
    }

    lines = [
        "// Generated by tools/generate_self_host_numeric_builtins.py.",
        "// Keep this table synchronized with src/backend/starshine_numeric_builtins.mbt.",
        "",
        "fn self_host_emit_linked_builtin(",
        "  name: Bytes,",
        "  destination: StarshineInstructions,",
        ") -> Bool {",
    ]

    lines.extend(
        [
            "  if name.equals(b\"dew_assert\") {",
            "    StarshineFfi.ffi_ffi_bridge_instructions_push(",
            "      destination,",
            "      StarshineFfi.ffi_lib_Instruction_drop(),",
            "    )",
            "    StarshineFfi.ffi_ffi_bridge_instructions_push(",
            "      destination,",
            "      StarshineFfi.ffi_lib_Instruction_i32_eqz(),",
            "    )",
            "    let consequent = StarshineFfi.ffi_ffi_bridge_instructions_new()",
            "    let alternative = StarshineFfi.ffi_ffi_bridge_instructions_new()",
            "    StarshineFfi.ffi_ffi_bridge_instructions_push(",
            "      consequent,",
            "      StarshineFfi.ffi_lib_Instruction_unreachable_(),",
            "    )",
            "    StarshineFfi.ffi_ffi_bridge_instructions_push(",
            "      destination,",
            "      StarshineFfi.ffi_ffi_bridge_instruction_if(",
            "        StarshineFfi.ffi_lib_BlockType_void_(),",
            "        consequent,",
            "        alternative,",
            "      ),",
            "    )",
        ]
    )
    first = False
    for name, instructions in aliases:
        lines.append(f"  {'if' if first else '} else if'} name.equals(b\"{name}\") {{")
        first = False
        for instruction in instructions:
            lines.extend(emit_push(instruction))
    for name in sorted(identities):
        lines.append(f"  }} else if name.equals(b\"{name}\") {{")
    for name, body in branches:
        lines.append(f"  }} else if name.equals(b\"{name}\") {{")
        for instruction in split_instructions(body):
            lines.extend(emit_push(translate_instruction(instruction)))
    narrow_float_conversions = {
        "dew_f32_into_i8",
        "dew_f32_into_i16",
        "dew_f32_into_u8",
        "dew_f32_into_u16",
        "dew_f64_into_i8",
        "dew_f64_into_i16",
        "dew_f64_into_u8",
        "dew_f64_into_u16",
    }
    for name, body in conversion_branches:
        lines.append(f"  }} else if name.equals(b\"{name}\") {{")
        instructions = split_instructions(body)
        if name in narrow_float_conversions:
            instructions = instructions[:1]
        for instruction in instructions:
            lines.extend(emit_push(translate_instruction(instruction)))
    for name, body in v128_branches:
        lines.append(f"  }} else if name.equals(b\"{name}\") {{")
        for instruction in split_instructions(body):
            lines.extend(emit_push(translate_instruction(instruction)))
    lines.extend(
        [
            "  } else {",
            "    return false",
            "  }",
            "  true",
            "}",
            "",
        ]
    )
    OUTPUT.write_text("\n".join(lines))


if __name__ == "__main__":
    main()
