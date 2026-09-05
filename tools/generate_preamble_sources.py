#!/usr/bin/env python3
"""Embed the checked-in Dew preamble without maintaining a second source copy."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GROUPS = {
    "core": [
        ("standard_preamble_builtins_source", "00-builtins"),
        ("standard_preamble_traits_source", "10-traits"),
        ("standard_debug_preamble_source", "110-debug"),
        ("standard_preamble_i32_source", "20-i32"),
        ("standard_preamble_packed_source", "30-packed"),
    ],
    "numeric": [
        ("standard_numeric_builtins_source", "40-numeric-builtins"),
        ("standard_numeric_impls_source", "50-numeric-impls"),
    ],
    "memory": [("standard_memory_preamble_source", "60-memory")],
    "into": [
        ("standard_into_builtins_source", "70-into-builtins"),
        ("standard_into_impls_source", "80-into-impls"),
    ],
    "swar": [("standard_swar_preamble_source", "90-swar-core")],
    "v128": [("standard_v128_preamble_source", "100-v128")],
}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    for group, entries in GROUPS.items():
        functions = []
        for function, source in entries:
            text = (ROOT / f"std/preamble/{source}.dew").read_text()
            if not text.isascii():
                raise ValueError(f"non-ASCII preamble needs byte escaping: {source}")
            functions.append(
                f"///|\npub fn {function}() -> Bytes {{\n  b{json.dumps(text)}\n}}\n"
            )
        output = ROOT / f"src/standard_sources/standard_{group}_preamble.mbt"
        expected = "\n".join(functions)
        if args.check:
            if output.read_text() != expected:
                raise SystemExit(f"stale {output.relative_to(ROOT)}")
        else:
            output.write_text(expected)


if __name__ == "__main__":
    main()
