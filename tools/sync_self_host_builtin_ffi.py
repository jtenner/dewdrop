#!/usr/bin/env python3
"""Add Starshine instruction constructors required by self-host builtin tables."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
USED = ROOT / "self_host/starshine/ffi-used.json"
SOURCES = [
    ROOT / "src/backend/starshine_numeric_builtins.mbt",
    ROOT / "src/backend/starshine_conversion_builtins.mbt",
    ROOT / "src/backend/starshine_v128_builtins.mbt",
]


def main() -> None:
    document = json.loads(USED.read_text())
    exports: list[str] = document["exports"]
    present = set(exports)
    required: set[str] = set()
    for source in SOURCES:
        for name in re.findall(r"@lib\.Instruction::([A-Za-z0-9_]+)\(", source.read_text()):
            required.add(f"Instruction::{name}")
    for name in sorted(required):
        if name not in present and name != "Instruction::if_":
            exports.append(name)
            present.add(name)
    USED.write_text(json.dumps(document, indent=2) + "\n")


if __name__ == "__main__":
    main()
