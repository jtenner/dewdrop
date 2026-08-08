#!/usr/bin/env python3
"""Run convention-based Dew compiler fixtures and compare their snapshots."""

from __future__ import annotations

import argparse
import difflib
import json
import os
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
FIXTURES = ROOT / "tests/module-snapshots"
PINNED_VERSION = ROOT / "tools/module-snapshots/WASM_TOOLS_VERSION"
WAGO_RUNNER = ROOT / "tools/module-snapshots/wago-runner"


class SnapshotError(RuntimeError):
    pass


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def check_wasm_tools_version() -> None:
    expected = PINNED_VERSION.read_text(encoding="utf-8").strip()
    actual = run(["wasm-tools", "--version"], capture=True).stdout.decode().strip()
    if actual != expected:
        raise SnapshotError(
            "wasm-tools version mismatch:\n"
            f"  expected: {expected}\n"
            f"  actual:   {actual}\n"
            "Update the pin and snapshots intentionally."
        )


def build_snapshot_compiler() -> Path:
    run(["moon", "build", "--target", "native", "--release", "src/module_snapshot_gen"])
    module_name = None
    for line in (ROOT / "moon.mod").read_text(encoding="utf-8").splitlines():
        if line.startswith("name = "):
            module_name = json.loads(line.removeprefix("name = "))
            break
    if not isinstance(module_name, str) or not module_name:
        raise SnapshotError("moon.mod does not contain a valid module name")
    compiler = (
        ROOT
        / "_build/native/release/build"
        / module_name
        / "module_snapshot_gen/module_snapshot_gen.exe"
    )
    if not compiler.is_file():
        raise SnapshotError(
            f"native snapshot compiler was not built at {compiler.relative_to(ROOT)}"
        )
    return compiler


HOST_KEYS = {
    "stdin_hex",
    "write_limit",
    "read_limit",
    "write_errno",
    "read_errno",
    "write_zero",
    "write_overreport",
    "read_overreport",
}


def expectation_path(source: Path) -> Path:
    return source.with_suffix(".json")


def valid_output(value: Any) -> bool:
    if value is None:
        return True
    if isinstance(value, list):
        return all(isinstance(line, str) for line in value)
    return (
        isinstance(value, dict)
        and set(value) == {"trap", "stdout"}
        and isinstance(value["trap"], str)
        and isinstance(value["stdout"], list)
        and all(isinstance(line, str) for line in value["stdout"])
    )


def validate_host(path: Path, host: Any) -> None:
    if not isinstance(host, dict) or not set(host) <= HOST_KEYS:
        raise SnapshotError(f"{path.relative_to(ROOT)} host contains unsupported fields")
    for name in ("write_limit", "read_limit"):
        if name in host and (type(host[name]) is not int or host[name] <= 0):
            raise SnapshotError(f"{path.relative_to(ROOT)} {name} must be a positive integer")
    for name in ("write_errno", "read_errno"):
        if name in host and (type(host[name]) is not int or not 0 <= host[name] <= 65535):
            raise SnapshotError(f"{path.relative_to(ROOT)} {name} must be an integer from 0 through 65535")
    for name in ("write_zero", "write_overreport", "read_overreport"):
        if name in host and type(host[name]) is not bool:
            raise SnapshotError(f"{path.relative_to(ROOT)} {name} must be a boolean")
    if "stdin_hex" in host:
        value = host["stdin_hex"]
        if not isinstance(value, str) or len(value) % 2 != 0:
            raise SnapshotError(f"{path.relative_to(ROOT)} stdin_hex must have even length")
        try:
            bytes.fromhex(value)
        except ValueError as error:
            raise SnapshotError(f"{path.relative_to(ROOT)} stdin_hex must be hexadecimal") from error


def load_expectation(source: Path) -> dict[str, Any]:
    path = expectation_path(source)
    if not path.is_file():
        raise SnapshotError(f"missing {path.relative_to(ROOT)}")
    try:
        expected = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise SnapshotError(f"invalid {path.relative_to(ROOT)}: {error}") from error
    if not isinstance(expected, dict):
        raise SnapshotError(f"{path.relative_to(ROOT)} must contain an object")
    if not {"errors", "warnings", "output"} <= set(expected) or not set(expected) <= {
        "errors", "warnings", "output", "host"
    }:
        raise SnapshotError(
            f"{path.relative_to(ROOT)} must contain errors, warnings, output, and optional host"
        )
    errors = expected["errors"]
    warnings = expected["warnings"]
    output = expected["output"]
    if not isinstance(errors, list) or not all(isinstance(error, str) for error in errors):
        raise SnapshotError(f"{path.relative_to(ROOT)} errors must be strings")
    if not isinstance(warnings, list) or not all(isinstance(warning, str) for warning in warnings):
        raise SnapshotError(f"{path.relative_to(ROOT)} warnings must be strings")
    if not valid_output(output):
        raise SnapshotError(
            f"{path.relative_to(ROOT)} output must be strings, a trap object, or null"
        )
    if "host" in expected:
        validate_host(path, expected["host"])
    return expected


def write_expectation(source: Path, expected: dict[str, Any]) -> None:
    expectation_path(source).write_text(
        json.dumps(expected, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def compiler_diagnostics(output: str) -> tuple[list[str], list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    internals: list[str] = []
    active: list[str] | None = None
    active_target: list[str] | None = None
    for line in output.splitlines():
        if line == "DEW_ERROR":
            active = []
            active_target = errors
        elif line == "DEW_WARNING":
            active = []
            active_target = warnings
        elif line == "DEW_END":
            if active is None or active_target is None:
                internals.append("unexpected compiler diagnostic terminator")
            else:
                active_target.append("\n".join(active))
            active = None
            active_target = None
        elif active is not None:
            active.append(line)
        elif line.startswith("DEW_ERROR "):
            errors.append(line.removeprefix("DEW_ERROR "))
        elif line.startswith("DEW_WARNING "):
            warnings.append(line.removeprefix("DEW_WARNING "))
        elif line.startswith("DEW_INTERNAL "):
            internals.append(line.removeprefix("DEW_INTERNAL "))
    if active is not None:
        internals.append("unterminated compiler diagnostic")
    return errors, warnings, internals


def fixture_mode(source: Path) -> str:
    return "test" if source.with_suffix(".tests").is_dir() else "production"


def fixture_sources(source: Path) -> list[tuple[str, str, Path]]:
    sources = [("snapshot.main", "fixture.dew", source)]
    files = source.with_suffix(".files")
    if files.exists() and not files.is_dir():
        raise SnapshotError(f"{files.relative_to(ROOT)} must be a directory")
    if files.is_dir():
        for path in sorted(files.rglob("*.dew")):
            sources.append(("snapshot.main", path.relative_to(files).as_posix(), path))
    tests = source.with_suffix(".tests")
    if tests.exists() and not tests.is_dir():
        raise SnapshotError(f"{tests.relative_to(ROOT)} must be a directory")
    if tests.is_dir():
        for path in sorted(tests.rglob("*.dew")):
            logical = path.relative_to(tests).as_posix()
            if not logical.endswith("_test.dew"):
                raise SnapshotError(f"{path.relative_to(ROOT)} must end in _test.dew")
            sources.append(("snapshot.main", logical, path))
    modules = source.with_suffix(".modules")
    if modules.exists() and not modules.is_dir():
        raise SnapshotError(f"{modules.relative_to(ROOT)} must be a directory")
    if modules.is_dir():
        for module in sorted(path for path in modules.iterdir() if path.is_dir()):
            if not module.name or module.name == "snapshot.main":
                raise SnapshotError(f"invalid module directory {module.relative_to(ROOT)}")
            module_files = sorted(module.rglob("*.dew"))
            if not module_files:
                raise SnapshotError(f"{module.relative_to(ROOT)} contains no Dew files")
            for path in module_files:
                sources.append((module.name, path.relative_to(module).as_posix(), path))
    return sources


def compile_fixture(
    compiler: Path,
    source: Path,
    output: Path,
    cache_dir: Path,
) -> tuple[bool, list[str], list[str]]:
    command = [
        str(compiler),
        str(output),
        fixture_mode(source),
    ]
    for module, logical, path in fixture_sources(source):
        command.extend((module, logical, str(path)))
    process = subprocess.run(
        command,
        cwd=ROOT,
        env={**os.environ, "DEW_CACHE_DIR": str(cache_dir)},
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    errors, warnings, internals = compiler_diagnostics(
        process.stdout + "\n" + process.stderr
    )
    if internals:
        raise SnapshotError("; ".join(internals))
    if process.returncode == 0:
        if errors:
            raise SnapshotError("compiler succeeded after reporting errors")
        run(["wasm-tools", "validate", "--features", "all", str(output)])
        return True, errors, warnings
    if not errors:
        detail = process.stderr.strip() or process.stdout.strip()
        raise SnapshotError(f"compiler failed without Dew diagnostics: {detail}")
    return False, errors, warnings


def parse_runtime_result(runtime: str, process: subprocess.CompletedProcess[str]) -> Any:
    if process.returncode != 0:
        detail = process.stderr.strip() or process.stdout.strip()
        raise SnapshotError(f"{runtime} fixture runtime failed: {detail}")
    try:
        result = json.loads(process.stdout)
    except json.JSONDecodeError as error:
        raise SnapshotError(
            f"{runtime} fixture runtime returned invalid JSON: {process.stdout!r}"
        ) from error
    if not isinstance(result, dict) or set(result) != {"output", "trap"}:
        raise SnapshotError(f"{runtime} fixture runtime returned invalid result: {result!r}")
    output = result["output"]
    trap = result["trap"]
    if not isinstance(output, list) or not all(isinstance(line, str) for line in output):
        raise SnapshotError(
            f"{runtime} fixture runtime output is not an array of strings: {output!r}"
        )
    if trap is None:
        return output
    if not isinstance(trap, str):
        raise SnapshotError(f"{runtime} fixture runtime trap is not a string: {trap!r}")
    return {"trap": trap, "stdout": output}


def run_main_node(binary: Path, host: dict[str, Any], mode: str) -> Any:
    process = subprocess.run(
        [
            "node",
            "tools/module-snapshots/run-main.mjs",
            str(binary),
            json.dumps(host, separators=(",", ":")),
            mode,
        ],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return parse_runtime_result("Node", process)


def build_wago_runner(output: Path) -> None:
    process = subprocess.run(
        ["go", "-C", str(WAGO_RUNNER), "build", "-o", str(output), "."],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if process.returncode != 0:
        detail = process.stderr.strip() or process.stdout.strip()
        raise SnapshotError(f"cannot build Wago snapshot runner: {detail}")


def run_main_wago(runner: Path, binary: Path, host: dict[str, Any], mode: str) -> Any:
    process = subprocess.run(
        [
            str(runner),
            str(binary),
            json.dumps(host, separators=(",", ":")),
            mode,
        ],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return parse_runtime_result("Wago", process)


def render_wat(binary: Path, output: Path) -> None:
    run([
        "wasm-tools",
        "print",
        "--color",
        "never",
        "--indent",
        "2",
        "-o",
        str(output),
        str(binary),
    ])


def compare_wat(expected: Path, actual: Path, update: bool) -> tuple[bool, str | None]:
    if update:
        expected.write_bytes(actual.read_bytes())
        return True, f"updated {expected.relative_to(ROOT)}"
    if not expected.is_file():
        return False, f"missing {expected.relative_to(ROOT)}; run with --update"
    expected_lines = expected.read_text(encoding="utf-8").splitlines(keepends=True)
    actual_lines = actual.read_text(encoding="utf-8").splitlines(keepends=True)
    if expected_lines == actual_lines:
        return True, None
    return False, "".join(
        difflib.unified_diff(
            expected_lines,
            actual_lines,
            fromfile=str(expected.relative_to(ROOT)),
            tofile=f"{actual.stem}.actual.wat",
        )
    )


def fixture_name(source: Path) -> str:
    return source.relative_to(FIXTURES).with_suffix("").as_posix()


def fixture_paths(selected: list[str]) -> list[Path]:
    fixtures = sorted(
        path
        for path in FIXTURES.rglob("*.dew")
        if not any(parent.name.endswith((".files", ".tests", ".modules")) for parent in path.parents)
    )
    if not selected:
        return fixtures
    names = set(selected)
    known = {fixture_name(fixture) for fixture in fixtures}
    unknown = sorted(names - known)
    if unknown:
        raise SnapshotError(f"unknown fixture(s): {', '.join(unknown)}")
    return [fixture for fixture in fixtures if fixture_name(fixture) in names]


@dataclass(frozen=True)
class FixtureResult:
    stdout: tuple[str, ...]
    stderr: tuple[str, ...]
    failed: bool


def process_fixture(
    source: Path,
    temp: Path,
    compiler: Path,
    wago_runner: Path,
    runtimes: list[str],
    no_repro_check: bool,
    update: bool,
) -> FixtureResult:
    name = fixture_name(source)
    stdout = [f"checking {name}"]
    stderr: list[str] = []

    def failure(message: str) -> FixtureResult:
        stderr.append(f"{name}: {message}")
        return FixtureResult(tuple(stdout), tuple(stderr), True)

    temporary_name = name.replace("/", "__")
    expected = load_expectation(source)
    first = temp / f"{temporary_name}.wasm"
    second = temp / f"{temporary_name}.repeat.wasm"
    actual_wat = temp / f"{temporary_name}.wat"
    cache_dir = temp / f"{temporary_name}.cache"
    try:
        compiled, errors, warnings = compile_fixture(
            compiler, source, first, cache_dir
        )
        if not no_repro_check:
            repeated, repeated_errors, repeated_warnings = compile_fixture(
                compiler, source, second, cache_dir
            )
            if repeated != compiled or repeated_errors != errors or repeated_warnings != warnings:
                raise SnapshotError("repeated compilation changed diagnostics or success state")
            if compiled and first.read_bytes() != second.read_bytes():
                raise SnapshotError("repeated compilation changed Wasm bytes")
    except SnapshotError as error:
        return failure(str(error))

    host = expected.get("host", {})
    if compiled:
        try:
            runtime_outputs: dict[str, Any] = {}
            if "node" in runtimes:
                runtime_outputs["node"] = run_main_node(first, host, fixture_mode(source))
            if "wago" in runtimes:
                runtime_outputs["wago"] = run_main_wago(
                    wago_runner, first, host, fixture_mode(source)
                )
            if len(
                set(json.dumps(value, sort_keys=True) for value in runtime_outputs.values())
            ) != 1:
                raise SnapshotError(f"Node/Wago output mismatch: {runtime_outputs!r}")
            output = runtime_outputs[runtimes[0]]
        except SnapshotError as error:
            return failure(str(error))
    else:
        output = None

    if update:
        updated = {"errors": errors, "warnings": warnings, "output": output}
        if host:
            updated["host"] = host
        expected = updated
        write_expectation(source, expected)
        stdout.append(f"updated {expectation_path(source).relative_to(ROOT)}")
    elif errors != expected["errors"] or warnings != expected["warnings"] or output != expected["output"]:
        return failure(
            f"expected diagnostics/output {expected!r}, got "
            f"{{'errors': {errors!r}, 'warnings': {warnings!r}, 'output': {output!r}}}"
        )

    expected_wat = source.with_suffix(".wat")
    if not compiled:
        if update and expected_wat.exists():
            expected_wat.unlink()
            stdout.append(f"removed {expected_wat.relative_to(ROOT)}")
        elif not update and expected_wat.exists():
            return failure("failed compilation must not have a WAT snapshot")
        stdout.append(f"ok {name}")
        return FixtureResult(tuple(stdout), tuple(stderr), False)

    render_wat(first, actual_wat)
    matched, comparison = compare_wat(expected_wat, actual_wat, update)
    if comparison is not None:
        if matched:
            stdout.append(comparison)
        else:
            stderr.append(comparison)
    if not matched:
        return FixtureResult(tuple(stdout), tuple(stderr), True)
    stdout.append(f"ok {name}")
    return FixtureResult(tuple(stdout), tuple(stderr), False)


def emit_result(result: FixtureResult) -> None:
    for message in result.stdout:
        print(message)
    for message in result.stderr:
        print(message, file=sys.stderr, end="" if message.endswith("\n") else "\n")


def default_snapshot_jobs() -> int:
    configured = os.environ.get("DEW_SNAPSHOT_JOBS")
    if configured is None:
        return min(8, os.cpu_count() or 1)
    try:
        jobs = int(configured)
    except ValueError as error:
        raise SnapshotError("DEW_SNAPSHOT_JOBS must be a positive integer") from error
    if jobs <= 0:
        raise SnapshotError("DEW_SNAPSHOT_JOBS must be a positive integer")
    return jobs


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--update", action="store_true", help="replace expected diagnostics, output, and WAT")
    parser.add_argument("--fixture", action="append", default=[], help="run one fixture")
    parser.add_argument("--list", action="store_true", help="list fixture names")
    parser.add_argument("--no-repro-check", action="store_true", help="compile only once")
    parser.add_argument(
        "--jobs",
        type=int,
        default=default_snapshot_jobs(),
        help="fixtures to run concurrently (default: min(8, CPU count); DEW_SNAPSHOT_JOBS overrides)",
    )
    parser.add_argument(
        "--runtime",
        action="append",
        choices=("node", "wago"),
        help="runtime to execute; repeat to select both (default: node and wago)",
    )
    args = parser.parse_args()
    if args.jobs <= 0:
        parser.error("--jobs must be a positive integer")
    runtimes = args.runtime or ["node", "wago"]
    if len(set(runtimes)) != len(runtimes):
        raise SnapshotError("each --runtime may be supplied only once")

    fixtures = fixture_paths(args.fixture)
    if args.list:
        for fixture in fixtures:
            print(fixture_name(fixture))
        return 0
    if not fixtures:
        raise SnapshotError("no <feature>/<test>.dew fixtures found")
    check_wasm_tools_version()
    compiler = build_snapshot_compiler()

    failures = 0
    with tempfile.TemporaryDirectory(prefix="dew-module-snapshots-") as temporary:
        temp = Path(temporary)
        wago_runner = temp / "wago-snapshot-runner"
        if "wago" in runtimes:
            build_wago_runner(wago_runner)
        with ThreadPoolExecutor(max_workers=args.jobs) as executor:
            results = executor.map(
                lambda source: process_fixture(
                    source,
                    temp,
                    compiler,
                    wago_runner,
                    runtimes,
                    args.no_repro_check,
                    args.update,
                ),
                fixtures,
            )
            for result in results:
                emit_result(result)
                failures += int(result.failed)

    if failures:
        print(f"module snapshots failed: {failures} fixture(s)", file=sys.stderr)
        return 1
    print(
        f"module snapshots passed: {len(fixtures)} fixture(s) "
        f"[{','.join(runtimes)}]"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SnapshotError as error:
        print(f"module snapshot error: {error}", file=sys.stderr)
        raise SystemExit(2)
    except subprocess.CalledProcessError as error:
        print(f"module snapshot command failed with exit code {error.returncode}", file=sys.stderr)
        raise SystemExit(error.returncode)
