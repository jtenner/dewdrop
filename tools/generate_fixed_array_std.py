#!/usr/bin/env python3
"""Embed std/fixed_array.dew as the compiler-owned bootstrap source."""

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "std/fixed_array.dew"
TARGET = ROOT / "src/standard_sources/standard_fixed_array_sources.mbt"


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


def rendered_source() -> str:
    literal = moonbit_bytes_literal(SOURCE.read_bytes())
    return (
        "///|\n"
        "pub fn standard_fixed_array_source() -> Bytes {\n"
        f"  {literal}\n"
        "}\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check", action="store_true", help="fail if the bootstrap source is stale",
    )
    args = parser.parse_args()
    rendered = rendered_source()
    if args.check:
        if not TARGET.exists() or TARGET.read_text(encoding="utf-8") != rendered:
            raise SystemExit(
                "src/standard_sources/standard_fixed_array_sources.mbt is stale; "
                "run tools/generate_fixed_array_std.py"
            )
        print(f"checked {TARGET.relative_to(ROOT)}")
        return
    TARGET.write_text(rendered, encoding="utf-8")
    print(f"generated {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
