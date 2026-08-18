#!/usr/bin/env python3
"""Build the checked-in Facet 0.1 Dew adapter fixture."""

import argparse
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "tools/facet-adapter.wat"
TARGET = ROOT / "fixtures/facet/facet-adapter.wasm"
FACET_SPEC_REVISION = "c6014e7f086f3d3d7ff5e1e7d65a7e6f24e1dcab"
EXPECTED_IMPORT_SIGNATURES = {
    "abi_version": "(result i32)",
    "handle_close": "(param i32) (result i32)",
    "fs_preopen_get": "(param i32) (result i32 i32)",
    "fd_stat": "(param i32) (result i32 i32 i64 i64 i32 i64 i32 i64 i32 i32)",
    "fd_read_array_i8": "(param i32 (ref array) i64 i64) (result i64 i32)",
    "fd_write_array_i8": "(param i32 (ref array) i64 i64) (result i64 i32)",
    "fd_sync": "(param i32) (result i32)",
    "path_open_array_i8": "(param i32 (ref array) i32 i32 i32 i32 i64) (result i32 i32)",
    "path_stat_array_i8": "(param i32 (ref array) i32 i32 i32 i32) (result i32 i32 i64 i64 i32 i64 i32 i64 i32 i32)",
    "path_create_dir_array_i8": "(param i32 (ref array) i32 i32 i32) (result i32)",
    "path_remove_array_i8": "(param i32 (ref array) i32 i32 i32 i32) (result i32)",
    "path_rename_array_i8": "(param i32 (ref array) i32 i32 i32 i32 (ref array) i32 i32 i32 i32) (result i32)",
    "args_count": "(result i32 i32)",
    "args_len_i8": "(param i32 i32) (result i64 i32)",
    "args_read_into_array_i8": "(param i32 i32 (ref array) i32 i32) (result i64 i32)",
    "env_count": "(result i32 i32)",
    "env_len_i8": "(param i32 i32 i32) (result i64 i32)",
    "env_read_into_array_i8": "(param i32 i32 i32 (ref array) i32 i32) (result i64 i32)",
    "stdio_stdout": "(result i32 i32)",
    "stdio_stderr": "(result i32 i32)",
    "proc_exit": "(param i32)",
}


def source_import_signatures() -> dict[str, str]:
    signatures: dict[str, str] = {}
    for line in SOURCE.read_text(encoding="utf-8").splitlines():
        stripped = " ".join(line.split())
        if not stripped.startswith('(import "'):
            continue
        match = re.fullmatch(
            r'\(import "([^"]+)" "([^"]+)" \(func \$[^ )]+(.*)\)\)',
            stripped,
        )
        if match is None:
            raise SystemExit(f"unsupported Facet import declaration: {stripped}")
        module, name, signature = match.groups()
        if module != "facet":
            raise SystemExit(f"Facet adapter imports unexpected module {module!r}")
        if name in signatures:
            raise SystemExit(f"duplicate Facet adapter import {name!r}")
        signatures[name] = signature.strip()
    return signatures


def audit_source() -> None:
    actual = source_import_signatures()
    if actual != EXPECTED_IMPORT_SIGNATURES:
        missing = sorted(EXPECTED_IMPORT_SIGNATURES.keys() - actual.keys())
        extra = sorted(actual.keys() - EXPECTED_IMPORT_SIGNATURES.keys())
        mismatched = sorted(
            name
            for name in actual.keys() & EXPECTED_IMPORT_SIGNATURES.keys()
            if actual[name] != EXPECTED_IMPORT_SIGNATURES[name]
        )
        raise SystemExit(
            "Facet adapter imports differ from facet-spec "
            + FACET_SPEC_REVISION
            + f"; missing={missing}, extra={extra}, mismatched={mismatched}"
        )


def build(destination: Path) -> None:
    audit_source()
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
            candidate = Path(directory) / "facet-adapter.wasm"
            build(candidate)
            if not TARGET.exists() or TARGET.read_bytes() != candidate.read_bytes():
                raise SystemExit(
                    "fixtures/facet/facet-adapter.wasm is stale; "
                    "run tools/generate_facet_adapter.py"
                )
        print(f"checked {TARGET.relative_to(ROOT)}")
        return
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    build(TARGET)
    print(f"generated {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
