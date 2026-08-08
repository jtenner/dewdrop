#!/usr/bin/env python3
"""Run deterministic compile-pass, compile-fail, and run-pass CLI fixtures."""

from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TESTS = ROOT / "tests"


class FixtureFailure(RuntimeError):
    pass


def fixtures(directory: str) -> list[Path]:
    return sorted((TESTS / directory).rglob("*.dew"))


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )


def expected_text(source: Path, suffix: str) -> str:
    expectation = source.with_suffix(suffix)
    if not expectation.is_file():
        raise FixtureFailure(f"missing expectation {relative(expectation)}")
    return expectation.read_text(encoding="utf-8")


def main() -> int:
    checked = 0
    for source in fixtures("compile-pass"):
        process = run(["tools/dew", "check", relative(source)])
        if process.returncode != 0:
            raise FixtureFailure(
                f"compile-pass fixture failed: {relative(source)}\n{process.stdout}"
            )
        checked += 1

    for source in fixtures("compile-fail"):
        process = run(["tools/dew", "check", relative(source)])
        if process.returncode == 0:
            raise FixtureFailure(
                f"compile-fail fixture succeeded: {relative(source)}"
            )
        expected = expected_text(source, ".txt")
        if process.stdout != expected:
            raise FixtureFailure(
                f"compile-fail output mismatch: {relative(source)}\n"
                f"expected:\n{expected}\nactual:\n{process.stdout}"
            )
        checked += 1

    for source in fixtures("run-pass"):
        with tempfile.TemporaryDirectory(prefix="dew-run-pass-") as directory:
            wasm = Path(directory) / "fixture.wasm"
            compiled = run(
                ["tools/dew", "build", relative(source), "-o", str(wasm)]
            )
            if compiled.returncode != 0:
                raise FixtureFailure(
                    f"run-pass fixture did not compile: {relative(source)}\n"
                    f"{compiled.stdout}"
                )
            executed = run(["node", "tools/dew-run.mjs", str(wasm)])
            if executed.returncode != 0:
                raise FixtureFailure(
                    f"run-pass fixture failed: {relative(source)}\n{executed.stdout}"
                )
            expected = expected_text(source, ".txt")
            if executed.stdout != expected:
                raise FixtureFailure(
                    f"run-pass output mismatch: {relative(source)}\n"
                    f"expected:\n{expected}\nactual:\n{executed.stdout}"
                )
        checked += 1

    print(f"CLI fixtures passed: {checked}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except FixtureFailure as error:
        print(error)
        raise SystemExit(1) from error
