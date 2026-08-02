#!/usr/bin/env python3
"""Compile and run explicitly ordered self-describing Dew test files."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def logical_path(path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(ROOT).as_posix()
    except ValueError as error:
        raise SystemExit(f"test source is outside the workspace: {path}") from error


def main() -> None:
    parser = argparse.ArgumentParser(prog="dew test")
    parser.add_argument("--module", default="main", help="logical test module")
    parser.add_argument("--file", dest="filter_file", help="exact logical-file filter")
    parser.add_argument("--name", help="exact display-name filter")
    parser.add_argument("--filter", help="identity substring filter")
    parser.add_argument("--list", action="store_true", help="list selected identities")
    parser.add_argument("sources", nargs="+", help="manifest-ordered Dew source files")
    args = parser.parse_args()

    paths = [Path(source) for source in args.sources]
    if not any(path.name.endswith("_test.dew") for path in paths):
        raise SystemExit("dew test requires at least one path ending in _test.dew")
    for path in paths:
        if not path.is_file():
            raise SystemExit(f"cannot read test source: {path}")

    temp = ROOT / ".tmp"
    temp.mkdir(exist_ok=True)
    stem = f"dew-test-{os.getpid()}"
    wasm = temp / f"{stem}.wasm"
    compile_command = [
        "moon",
        "run",
        "--target",
        "native",
        "--release",
        "src/dew_test_gen",
        "--",
        str(wasm),
        args.module,
    ]
    for path in paths:
        compile_command.extend(
            (args.module, logical_path(path), str(path.resolve()))
        )

    run_command = [
        "node",
        "tools/dew-test/run.mjs",
        "--wasm",
        str(wasm),
        "--label",
        "Dew tests",
    ]
    if args.filter_file is not None:
        run_command.extend(("--file", args.filter_file))
    if args.name is not None:
        run_command.extend(("--name", args.name))
    if args.filter is not None:
        run_command.extend(("--filter", args.filter))
    if args.list:
        run_command.append("--list")

    try:
        compiled = subprocess.run(compile_command, cwd=ROOT, check=False)
        if compiled.returncode != 0:
            sys.exit(compiled.returncode)
        executed = subprocess.run(run_command, cwd=ROOT, check=False)
        if executed.returncode != 0:
            sys.exit(executed.returncode)
    finally:
        wasm.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
