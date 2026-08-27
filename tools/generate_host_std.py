#!/usr/bin/env python3
"""Embed path, host-adapter, and grouped Facet standard modules."""

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCES = [
    ("standard_path_source", ROOT / "std/path.dew"),
    ("standard_fs_source", ROOT / "std/fs.dew"),
    ("standard_process_source", ROOT / "std/process.dew"),
    ("standard_fs_wasi_source", ROOT / "std/fs/wasi.dew"),
    ("standard_process_wasi_source", ROOT / "std/process/wasi.dew"),
    ("standard_facet_source", ROOT / "std/facet.dew"),
    ("standard_facet_imports_source", ROOT / "std/facet/imports.dew"),
    ("standard_facet_core_source", ROOT / "std/facet/core.dew"),
    ("standard_facet_fs_source", ROOT / "std/facet/fs.dew"),
    ("standard_facet_process_source", ROOT / "std/facet/process.dew"),
    ("standard_facet_clock_source", ROOT / "std/facet/clock.dew"),
    ("standard_facet_random_source", ROOT / "std/facet/random.dew"),
    ("standard_facet_poll_source", ROOT / "std/facet/poll.dew"),
    ("standard_facet_net_source", ROOT / "std/facet/net.dew"),
]
TARGET = ROOT / "src/standard_sources/standard_host_sources.mbt"


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
    blocks: list[str] = []
    for function, source in SOURCES:
        blocks.append(
            "///|\n"
            f"pub fn {function}() -> Bytes {{\n"
            f"  {moonbit_bytes_literal(source.read_bytes())}\n"
            "}\n"
        )
    return "\n".join(blocks)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    rendered = rendered_source()
    if args.check:
        if not TARGET.exists() or TARGET.read_text(encoding="utf-8") != rendered:
            raise SystemExit(f"{TARGET.relative_to(ROOT)} is stale; run tools/generate_host_std.py")
        print(f"checked {TARGET.relative_to(ROOT)}")
        return
    TARGET.write_text(rendered, encoding="utf-8")
    print(f"generated {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
