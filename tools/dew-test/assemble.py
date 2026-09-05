#!/usr/bin/env python3
"""Compile deterministic self-describing Dew test modules."""

from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main() -> None:
    paths = sorted((ROOT / "std/tests").glob("*_test.dew"))
    if not paths:
        raise SystemExit("no std/tests/*_test.dew tests found")
    command = [
        "moon",
        "run",
        "--target",
        "native",
        "src/dew_test_gen",
        "--",
        "tools/dew-test/stdlib_tests.wasm",
        "dew.std",
    ]
    for path in paths:
        logical = path.relative_to(ROOT).as_posix()
        if "\t" in logical or "\n" in logical or "\r" in logical:
            raise SystemExit(f"unsupported test path: {logical!r}")
        command.extend(("dew.std", logical, str(path)))
    subprocess.run(command, cwd=ROOT, check=True)
    (ROOT / ".tmp").mkdir(exist_ok=True)
    repeat_output = ROOT / ".tmp/stdlib_tests_repeat.wasm"
    repeat_command = command.copy()
    repeat_command[6] = str(repeat_output)
    subprocess.run(repeat_command, cwd=ROOT, check=True)
    if (ROOT / "tools/dew-test/stdlib_tests.wasm").read_bytes() != repeat_output.read_bytes():
        raise SystemExit("repeated Dew test compilation produced different Wasm bytes")
    repeat_output.unlink()
    subprocess.run(
        [
            "moon",
            "run",
            "--target",
            "native",
            "src/dew_test_gen",
            "--",
            "tools/dew-test/builtin_traps.wasm",
            "dew.std.traps",
            "dew.std.traps",
            "tools/dew-test/builtin_traps_test.dew",
            str(ROOT / "tools/dew-test/builtin_traps.dew"),
        ],
        cwd=ROOT,
        check=True,
    )
    print(
        f"compiled {len(paths)} manifest-ordered Dew test files deterministically and builtin traps"
    )
    for fixture, module in [
        ("scalar_conversions", "dew.std.conversions"),
        ("memory_operations", "dew.std.memory"),
        ("arithmetic_operations", "dew.std.arithmetic"),
        ("math_operations", "dew.std.math_probes"),
    ]:
        subprocess.run(
            [
                "moon", "run", "--target", "native", "src/dew_test_gen", "--",
                f"tools/dew-test/{fixture}.wasm", module,
                module, f"tools/dew-test/{fixture}_test.dew",
                str(ROOT / f"tools/dew-test/{fixture}.dew"),
            ],
            cwd=ROOT,
            check=True,
        )


if __name__ == "__main__":
    main()
