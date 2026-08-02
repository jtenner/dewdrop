#!/usr/bin/env python3
"""Bootstrap dispatcher for explicit Dew inputs and minimal package manifests."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


class ManifestError(ValueError):
    pass


def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ManifestError(f"duplicate manifest key: {key}")
        result[key] = value
    return result


def exact_keys(value: dict[str, Any], expected: set[str], context: str) -> None:
    unknown = set(value) - expected
    missing = expected - set(value)
    if unknown:
        raise ManifestError(f"unknown {context} field: {sorted(unknown)[0]}")
    if missing:
        raise ManifestError(f"missing {context} field: {sorted(missing)[0]}")


def load_manifest(path: Path) -> tuple[str, list[tuple[str, list[str]]]]:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as error:
        raise ManifestError(f"cannot read manifest {path}: {error}") from error
    try:
        raw = json.loads(text, object_pairs_hook=unique_object)
    except (json.JSONDecodeError, UnicodeError, ManifestError) as error:
        raise ManifestError(f"invalid manifest {path}: {error}") from error
    if not isinstance(raw, dict):
        raise ManifestError("manifest root must be an object")
    exact_keys(raw, {"root", "modules"}, "manifest")
    root = raw["root"]
    entries = raw["modules"]
    if not isinstance(root, str) or not root:
        raise ManifestError("manifest root must be a nonempty module name")
    if not isinstance(entries, list) or not entries:
        raise ManifestError("manifest modules must be a nonempty array")

    package_root = path.resolve().parent
    modules: list[tuple[str, list[str]]] = []
    names: set[str] = set()
    logical_files: set[str] = set()
    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            raise ManifestError(f"module {index} must be an object")
        exact_keys(entry, {"name", "files"}, f"module {index}")
        name = entry["name"]
        files = entry["files"]
        if not isinstance(name, str) or not name:
            raise ManifestError(f"module {index} name must be nonempty")
        if name in names:
            raise ManifestError(f"duplicate manifest module: {name}")
        names.add(name)
        if not isinstance(files, list) or not files:
            raise ManifestError(f"module {name} files must be a nonempty array")
        resolved_files: list[str] = []
        for file_index, logical in enumerate(files):
            if not isinstance(logical, str) or not logical:
                raise ManifestError(
                    f"module {name} file {file_index} must be a nonempty string"
                )
            logical_path = Path(logical)
            if logical_path.is_absolute():
                raise ManifestError(f"manifest source must be relative: {logical}")
            source = (package_root / logical_path).resolve()
            try:
                source.relative_to(package_root)
            except ValueError as error:
                raise ManifestError(f"manifest source escapes package root: {logical}") from error
            canonical = source.relative_to(ROOT).as_posix() if source.is_relative_to(ROOT) else ""
            if not canonical:
                raise ManifestError(f"manifest source is outside the workspace: {logical}")
            if not canonical.endswith(".dew"):
                raise ManifestError(f"manifest source must end in .dew: {logical}")
            if canonical in logical_files:
                raise ManifestError(f"duplicate manifest source: {logical}")
            if not source.is_file():
                raise ManifestError(f"manifest source does not exist: {logical}")
            logical_files.add(canonical)
            resolved_files.append(canonical)
        modules.append((name, resolved_files))
    if root not in names:
        raise ManifestError(f"manifest root module is not declared: {root}")
    return root, modules


def package_root_arguments(arguments: list[str]) -> tuple[list[Path], bool, list[str]]:
    roots: list[Path] = []
    bootstrap = False
    remaining: list[str] = []
    index = 0
    while index < len(arguments):
        argument = arguments[index]
        if argument == "--package-root":
            if index + 1 >= len(arguments):
                raise ManifestError("missing value for --package-root")
            roots.append(Path(arguments[index + 1]))
            index += 2
        elif argument == "--bootstrap-std":
            bootstrap = True
            index += 1
        elif argument == "--std-root":
            raise ManifestError("--std-root is an internal compiler option; use --package-root")
        else:
            remaining.append(argument)
            index += 1
    return roots, bootstrap, remaining


def resolve_standard_package_root(explicit: list[Path]) -> Path:
    environment = os.environ.get("DEW_PACKAGE_ROOTS", "")
    if explicit:
        candidates = list(explicit)
    elif environment:
        candidates = [Path(entry) for entry in environment.split(os.pathsep) if entry]
    else:
        candidates = [ROOT]
    seen: set[Path] = set()
    checked: list[str] = []
    for candidate in candidates:
        canonical = candidate.expanduser().resolve()
        if canonical in seen:
            continue
        seen.add(canonical)
        for package in (canonical / "dew.std", canonical):
            sentinel = package / "std" / "preamble" / "00-builtins.dew"
            checked.append(str(package))
            if sentinel.is_file():
                return package
    detail = ", ".join(checked)
    raise ManifestError(f"cannot locate dew.std package in ordered roots: {detail}")


def configure_standard_package(arguments: list[str]) -> list[str]:
    roots, bootstrap, remaining = package_root_arguments(arguments)
    if bootstrap:
        if roots:
            raise ManifestError("--bootstrap-std cannot be combined with --package-root")
        os.environ["DEW_BOOTSTRAP_STD"] = "1"
        os.environ.pop("DEW_STD_ROOT", None)
    else:
        os.environ.pop("DEW_BOOTSTRAP_STD", None)
        os.environ["DEW_STD_ROOT"] = str(resolve_standard_package_root(roots))
    return remaining


def manifest_argument(arguments: list[str]) -> tuple[Path | None, list[str]]:
    path: Path | None = None
    remaining: list[str] = []
    index = 0
    while index < len(arguments):
        if arguments[index] == "--manifest":
            if path is not None:
                raise ManifestError("--manifest may be supplied only once")
            if index + 1 >= len(arguments):
                raise ManifestError("missing value for --manifest")
            path = Path(arguments[index + 1])
            index += 2
        else:
            remaining.append(arguments[index])
            index += 1
    return path, remaining


def run_manifest_tests(
    root: str,
    modules: list[tuple[str, list[str]]],
    runner_arguments: list[str],
) -> None:
    if not any(path.endswith("_test.dew") for _, files in modules for path in files):
        raise ManifestError("manifest-driven dew test requires at least one _test.dew file")
    temp = ROOT / ".tmp"
    temp.mkdir(exist_ok=True)
    wasm = temp / f"dew-manifest-test-{os.getpid()}.wasm"
    compile_command = [
        "moon",
        "run",
        "--target",
        "native",
        "--release",
        "src/dew_test_gen",
        "--",
        str(wasm),
        root,
    ]
    for module_name, files in modules:
        for logical in files:
            compile_command.extend((module_name, logical, str(ROOT / logical)))
    run_command = [
        "node",
        "tools/dew-test/run.mjs",
        "--wasm",
        str(wasm),
        "--label",
        "Dew tests",
        *runner_arguments,
    ]
    try:
        compiled = subprocess.run(compile_command, cwd=ROOT, check=False)
        if compiled.returncode != 0:
            raise SystemExit(compiled.returncode)
        executed = subprocess.run(run_command, cwd=ROOT, check=False)
        if executed.returncode != 0:
            raise SystemExit(executed.returncode)
    finally:
        wasm.unlink(missing_ok=True)


def main() -> None:
    if len(sys.argv) < 2:
        os.execvp(
            "moon",
            ["moon", "run", "--target", "native", "--release", "src/dew_cli", "--"],
        )
    command = sys.argv[1]
    try:
        configured = configure_standard_package(sys.argv[2:])
        manifest, remaining = manifest_argument(configured)
        if command == "test" and "--no-default-preamble" in remaining:
            raise ManifestError("--no-default-preamble is not supported by dew test")
        if manifest is None:
            if command == "test":
                os.execvp("python3", ["python3", "tools/dew-test-cli.py", *remaining])
            os.execvp(
                "moon",
                [
                    "moon",
                    "run",
                    "--target",
                    "native",
                    "--release",
                    "src/dew_cli",
                    "--",
                    command,
                    *remaining,
                ],
            )
        if command not in {"check", "build", "test"}:
            raise ManifestError("--manifest is supported only by check, build, and test")
        for argument in remaining:
            if argument == "--root" or (
                command != "test" and argument == "--module"
            ):
                raise ManifestError(
                    "explicit module/root selection cannot be combined with this manifest command"
                )
        root, modules = load_manifest(manifest)
        if command == "test":
            run_manifest_tests(root, modules, remaining)
            return
        expanded = [command, *remaining, "--root", root]
        for name, files in modules:
            expanded.extend(("--module", name, *files))
        os.execvp(
            "moon",
            [
                "moon",
                "run",
                "--target",
                "native",
                "--release",
                "src/dew_cli",
                "--",
                *expanded,
            ],
        )
    except ManifestError as error:
        print(f"dew: {error}", file=sys.stderr)
        raise SystemExit(2) from error


if __name__ == "__main__":
    main()
