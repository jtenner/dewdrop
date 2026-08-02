#!/usr/bin/env python3
"""Generate portable compiler source providers for standard text and sums."""

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OPTION_SOURCE = ROOT / "std/option.dew"
RESULT_SOURCE = ROOT / "std/result.dew"
SOURCES = (
    ROOT / "std/text_runtime.dew",
    ROOT / "std/string.dew",
    ROOT / "std/string_builder.dew",
    ROOT / "std/bytes_builder.dew",
    ROOT / "std/bytes.dew",
)
TARGET = ROOT / "src/semantic/standard_text_sources.mbt"
OPTION_RESULT_TARGET = ROOT / "src/semantic/standard_option_result_sources.mbt"
OLD_TARGET = ROOT / "src/semantic/standard_string_preamble.mbt"


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
    literals = ",\n    ".join(
        moonbit_bytes_literal(source.read_bytes()) for source in SOURCES
    )
    return (
        "///|\n"
        "fn standard_text_sources() -> Array[Bytes] {\n"
        "  [\n"
        f"    {literals},\n"
        "  ]\n"
        "}\n"
    )


def rendered_option_result_source() -> str:
    option = moonbit_bytes_literal(OPTION_SOURCE.read_bytes())
    result = moonbit_bytes_literal(RESULT_SOURCE.read_bytes())
    return (
        "///|\n"
        "fn standard_option_source() -> Bytes {\n"
        f"  {option}\n"
        "}\n\n"
        "///|\n"
        "fn standard_result_source() -> Bytes {\n"
        f"  {result}\n"
        "}\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check", action="store_true", help="fail if bootstrap sources are stale",
    )
    args = parser.parse_args()
    rendered = rendered_source()
    option_result_rendered = rendered_option_result_source()
    if args.check:
        if not TARGET.exists() or TARGET.read_text(encoding="utf-8") != rendered:
            raise SystemExit(
                "src/semantic/standard_text_sources.mbt is stale; "
                "run tools/generate_string_std.py"
            )
        if not OPTION_RESULT_TARGET.exists() or OPTION_RESULT_TARGET.read_text(encoding="utf-8") != option_result_rendered:
            raise SystemExit(
                "src/semantic/standard_option_result_sources.mbt is stale; "
                "run tools/generate_string_std.py"
            )
        if OLD_TARGET.exists():
            raise SystemExit(
                "obsolete src/semantic/standard_string_preamble.mbt still exists"
            )
        print(
            f"checked {TARGET.relative_to(ROOT)} and "
            f"{OPTION_RESULT_TARGET.relative_to(ROOT)}"
        )
        return
    TARGET.write_text(rendered, encoding="utf-8")
    OPTION_RESULT_TARGET.write_text(option_result_rendered, encoding="utf-8")
    OLD_TARGET.unlink(missing_ok=True)
    print(
        f"generated {TARGET.relative_to(ROOT)} and "
        f"{OPTION_RESULT_TARGET.relative_to(ROOT)}"
    )


if __name__ == "__main__":
    main()
