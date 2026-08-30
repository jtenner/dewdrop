#!/usr/bin/env python3

import argparse
import pathlib
import subprocess
import tempfile


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Export memory 0 from a Wasm module for exact host adapters."
    )
    parser.add_argument("input")
    parser.add_argument("output")
    args = parser.parse_args()

    source = pathlib.Path(args.input)
    output = pathlib.Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    text = subprocess.run(
        ["wasm-tools", "print", str(source)],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    ).stdout
    if '(export "memory" (memory 0))' not in text:
        lines = text.splitlines(keepends=True)
        memory_lines = [
            index
            for index, line in enumerate(lines)
            if line.startswith("  (memory (;0;)")
        ]
        if len(memory_lines) != 1:
            raise SystemExit(
                f"expected one memory 0 declaration, found {len(memory_lines)}"
            )
        lines.insert(memory_lines[0] + 1, '  (export "memory" (memory 0))\n')
        text = "".join(lines)

    with tempfile.NamedTemporaryFile(
        mode="w",
        suffix=".wat",
        dir=output.parent,
        delete=False,
    ) as temporary:
        temporary.write(text)
        temporary_path = pathlib.Path(temporary.name)
    staged = output.with_name(f".{output.name}.tmp")
    try:
        subprocess.run(
            ["wasm-tools", "parse", str(temporary_path), "-o", str(staged)],
            check=True,
        )
        subprocess.run(
            ["wasm-tools", "validate", "--features", "all", str(staged)],
            check=True,
        )
        staged.replace(output)
    finally:
        temporary_path.unlink(missing_ok=True)
        staged.unlink(missing_ok=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
