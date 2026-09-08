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
        ("simd-memory-operations", "app.simd_memory"),
        ("arithmetic_operations", "dew.std.arithmetic"),
        ("math_operations", "dew.std.math_probes"),
        ("specialization_products", "app.specialization_probes"),
        ("specialization_callbacks", "app.callback_probes"),
        ("member_calls", "app.member_probes"),
        ("debug_dispatch", "app.debug_probes"),
        ("debug_integers", "app.debug_integers"),
        ("debug_floats", "app.debug_floats"),
        ("debug_vectors", "app.debug_vectors"),
        ("debug_swar", "app.debug_swar"),
        ("debug_unit", "app.debug_unit"),
        ("debug_bool", "app.debug_bool"),
        ("wasi_bytes", "app.wasi_bytes"),
        ("product_patterns", "app.product_patterns"),
        ("constructor_evaluations", "app.constructor_probes"),
        ("raw_gc_storage", "app.raw_gc"),
        ("raw_gc_unit", "app.raw_gc_unit"),
        ("fixed_array_operations", "app.fixed_array_probes"),
        ("raw_array_contracts", "app.raw_array_contracts"),
        ("array_operations", "app.array_probes"),
        ("ring_operations", "app.ring_probes"),
        ("map_operations", "app.map_probes"),
        ("set_operations", "app.set_probes"),
        ("bytes_operations", "app.bytes_probes"),
        ("string_view_operations", "app.string_view_probes"),
        ("string_operations", "app.string_probes"),
        ("string_patterns", "app.string_patterns"),
        ("type_queries", "app.type_queries"),
    ]:
        subprocess.run(
            [
                "moon", "run", "--target", "native", "src/dew_test_gen", "--",
                f"tools/dew-test/{fixture}.wasm", module,
                module, f"tools/dew-test/{fixture}.dew",
                str(ROOT / f"tools/dew-test/{fixture}.dew"),
            ],
            cwd=ROOT,
            check=True,
        )

    subprocess.run(
        [
            "moon", "run", "--target", "native", "src/dew_test_gen", "--",
            "tools/dew-test/wasi_foreign.wasm", "app.wasi_probes",
            "app.wasi_probes", "wasi-preview1-runtime.dew",
            "tests/module-snapshots/wasm/wasi-preview1-runtime.dew",
        ],
        cwd=ROOT,
        check=True,
    )


if __name__ == "__main__":
    main()
