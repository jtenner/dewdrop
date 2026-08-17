#!/usr/bin/env python3
"""Build the checked-in WPSI 0.1 Dew adapter fixture."""

import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "tools/wpsi-adapter.wat"
TARGET = ROOT / "fixtures/wpsi/wpsi-adapter.wasm"


def build(destination: Path) -> None:
    subprocess.run(
        ["wasm-tools", "parse", str(SOURCE), "-o", str(destination)],
        check=True,
        cwd=ROOT,
    )
    subprocess.run(
        ["wasm-tools", "validate", "--features", "all", str(destination)],
        check=True,
        cwd=ROOT,
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        with tempfile.TemporaryDirectory() as directory:
            candidate = Path(directory) / "wpsi-adapter.wasm"
            build(candidate)
            if not TARGET.exists() or TARGET.read_bytes() != candidate.read_bytes():
                raise SystemExit(
                    "fixtures/wpsi/wpsi-adapter.wasm is stale; "
                    "run tools/generate_wpsi_adapter.py"
                )
        print(f"checked {TARGET.relative_to(ROOT)}")
        return
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    build(TARGET)
    print(f"generated {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
