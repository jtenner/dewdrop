#!/usr/bin/env python3
"""Embed package-format standard modules."""

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCES = [
    ("standard_encode_source", ROOT / "std/encode.dew"),
    ("standard_decode_source", ROOT / "std/decode.dew"),
    ("standard_format_source", ROOT / "std/format.dew"),
    ("standard_semver_source", ROOT / "std/semver.dew"),
    ("standard_package_source", ROOT / "std/package.dew"),
    ("standard_package_artifact_source", ROOT / "std/package/artifact.dew"),
]
TARGET = ROOT / "src/standard_sources/standard_package_sources.mbt"


def literal(data: bytes) -> str:
    out = []
    for byte in data:
        if byte == 10: out.append("\\n")
        elif byte == 13: out.append("\\r")
        elif byte == 9: out.append("\\t")
        elif byte == 34: out.append('\\"')
        elif byte == 92: out.append("\\\\")
        elif 32 <= byte <= 126: out.append(chr(byte))
        else: out.append(f"\\x{byte:02X}")
    return 'b"' + "".join(out) + '"'


def render() -> str:
    return "\n".join(
        f"///|\npub fn {name}() -> Bytes {{\n  {literal(path.read_bytes())}\n}}\n"
        for name, path in SOURCES
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = render()
    if args.check:
        if not TARGET.exists() or TARGET.read_text() != expected:
            raise SystemExit(f"{TARGET.relative_to(ROOT)} is stale; run tools/generate_package_std.py")
        print(f"checked {TARGET.relative_to(ROOT)}")
    else:
        TARGET.write_text(expected)
        print(f"generated {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
