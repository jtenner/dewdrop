#!/usr/bin/env python3
"""Embed the ordinary Option and Result library sources."""

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "src/standard_sources/standard_option_result_sources.mbt"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    source = "\n".join(
        "///|\npub fn standard_" + name + "_source() -> Bytes {\n  b"
        + json.dumps((ROOT / "std" / (name + ".dew")).read_text())
        + "\n}\n"
        for name in ("option", "result")
    )
    if args.check:
        if TARGET.read_text() != source:
            raise SystemExit("stale Option/Result bootstrap source; run tools/generate_option_result_std.py")
        print("checked Option/Result bootstrap source")
    else:
        TARGET.write_text(source)


if __name__ == "__main__":
    main()
