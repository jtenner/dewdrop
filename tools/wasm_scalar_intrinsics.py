"""Core Wasm numeric instructions, excluding constants and memory access.

Each row is (opcode, Starshine method, input carriers, result carrier).
Keep reference, memory, and SIMD contracts in their own tables.
"""

SCALAR_INSTRUCTIONS: list[tuple[str, str, tuple[str, ...], str]] = []


def add(name: str, inputs: tuple[str, ...], result: str) -> None:
    import re

    instruction = re.sub(r"(?<=\d)_([su])$", r"\1", name.replace(".", "_"))
    SCALAR_INSTRUCTIONS.append((name, instruction, inputs, result))


for carrier in ("i32", "i64"):
    for operation in ("eqz", "clz", "ctz", "popcnt"):
        add(f"{carrier}.{operation}", (carrier,), "i32" if operation == "eqz" else carrier)
    for operation in (
        "add", "sub", "mul", "div_s", "div_u", "rem_s", "rem_u",
        "and", "or", "xor", "shl", "shr_s", "shr_u", "rotl", "rotr",
    ):
        add(f"{carrier}.{operation}", (carrier, carrier), carrier)
    for operation in ("eq", "ne", "lt_s", "lt_u", "gt_s", "gt_u", "le_s", "le_u", "ge_s", "ge_u"):
        add(f"{carrier}.{operation}", (carrier, carrier), "i32")
    for bits in ((8, 16) if carrier == "i32" else (8, 16, 32)):
        add(f"{carrier}.extend{bits}_s", (carrier,), carrier)

for carrier in ("f32", "f64"):
    for operation in ("abs", "neg", "ceil", "floor", "trunc", "nearest", "sqrt"):
        add(f"{carrier}.{operation}", (carrier,), carrier)
    for operation in ("add", "sub", "mul", "div", "min", "max", "copysign"):
        add(f"{carrier}.{operation}", (carrier, carrier), carrier)
    for operation in ("eq", "ne", "lt", "gt", "le", "ge"):
        add(f"{carrier}.{operation}", (carrier, carrier), "i32")

add("i32.wrap_i64", ("i64",), "i32")
for sign in ("s", "u"):
    add(f"i64.extend_i32_{sign}", ("i32",), "i64")
for integer in ("i32", "i64"):
    for floating in ("f32", "f64"):
        for sign in ("s", "u"):
            add(f"{floating}.convert_{integer}_{sign}", (integer,), floating)
            add(f"{integer}.trunc_{floating}_{sign}", (floating,), integer)
            add(f"{integer}.trunc_sat_{floating}_{sign}", (floating,), integer)
add("f32.demote_f64", ("f64",), "f32")
add("f64.promote_f32", ("f32",), "f64")
for integer, floating in (("i32", "f32"), ("i64", "f64")):
    add(f"{integer}.reinterpret_{floating}", (floating,), integer)
    add(f"{floating}.reinterpret_{integer}", (integer,), floating)

assert len(SCALAR_INSTRUCTIONS) == 136
assert len({row[0] for row in SCALAR_INSTRUCTIONS}) == 136

CONVERSION_INSTRUCTIONS = [
    row for row in SCALAR_INSTRUCTIONS
    if any(part in row[0] for part in (".extend", ".wrap", ".convert", ".trunc_", ".demote", ".promote"))
]
NUMERIC_INSTRUCTIONS = [row for row in SCALAR_INSTRUCTIONS if row not in CONVERSION_INSTRUCTIONS]
