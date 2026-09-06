#!/usr/bin/env python3
"""Embed the ordinary dew.std.types declarations for bootstrap loading."""

import argparse
from pathlib import Path

from generate_fixed_array_std import moonbit_bytes_literal

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "std/types.dew"
TARGET = ROOT / "src/standard_sources/standard_types_sources.mbt"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    rendered = (
        "///|\n"
        "pub fn standard_types_source() -> Bytes {\n"
        f"  {moonbit_bytes_literal(SOURCE.read_bytes())}\n"
        "}\n"
    )
    if args.check:
        if not TARGET.exists() or TARGET.read_text(encoding="utf-8") != rendered:
            raise SystemExit("types source is stale; run tools/generate_types_std.py")
        print(f"checked {TARGET.relative_to(ROOT)}")
    else:
        TARGET.write_text(rendered, encoding="utf-8")
        print(f"generated {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
