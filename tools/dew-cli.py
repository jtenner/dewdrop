#!/usr/bin/env python3
"""Bootstrap dispatcher for explicit Dew inputs and minimal package manifests."""

from __future__ import annotations

import hashlib
import json
import os
import re
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


class DependencySpec:
    def __init__(
        self,
        name: str,
        version: str,
        path: Path,
        integrity: str,
        interface_fingerprint: str,
    ) -> None:
        self.name = name
        self.version = version
        self.path = path
        self.integrity = integrity
        self.interface_fingerprint = interface_fingerprint


class ParsedManifest:
    def __init__(
        self,
        path: Path,
        root: str,
        modules: tuple[tuple[str, tuple[str, ...]], ...],
        package_name: str | None,
        package_version: str | None,
        dependencies: tuple[DependencySpec, ...],
        integrity: str,
    ) -> None:
        self.path = path
        self.root = root
        self.modules = modules
        self.package_name = package_name
        self.package_version = package_version
        self.dependencies = dependencies
        self.integrity = integrity


_VERSION = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.-]+)?$")
_INTEGRITY = re.compile(r"^sha256-[0-9a-f]{64}$")


def _write_hash_string(digest: "hashlib._Hash", value: str) -> None:
    encoded = value.encode("utf-8")
    digest.update(len(encoded).to_bytes(4, "little"))
    digest.update(encoded)


def _manifest_integrity(
    root: str,
    modules: list[tuple[str, list[tuple[str, Path]]]],
    package_name: str,
    package_version: str,
    dependencies: list[DependencySpec],
) -> str:
    digest = hashlib.sha256()
    digest.update(b"DEW_PACKAGE_INTEGRITY_V1\x00")
    _write_hash_string(digest, package_name)
    _write_hash_string(digest, package_version)
    _write_hash_string(digest, root)
    for module_name, files in modules:
        _write_hash_string(digest, module_name)
        for logical, source in files:
            _write_hash_string(digest, logical)
            data = source.read_bytes()
            digest.update(len(data).to_bytes(4, "little"))
            digest.update(data)
    for dependency in dependencies:
        _write_hash_string(digest, dependency.name)
        _write_hash_string(digest, dependency.version)
        _write_hash_string(digest, dependency.integrity)
        _write_hash_string(digest, dependency.interface_fingerprint)
    return f"sha256-{digest.hexdigest()}"


def _load_manifest_file(path: Path) -> ParsedManifest:
    path = path.expanduser().resolve()
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
    unknown = set(raw) - {"root", "modules", "package", "dependencies"}
    missing = {"root", "modules"} - set(raw)
    if unknown:
        raise ManifestError(f"unknown manifest field: {sorted(unknown)[0]}")
    if missing:
        raise ManifestError(f"missing manifest field: {sorted(missing)[0]}")
    root = raw["root"]
    entries = raw["modules"]
    if not isinstance(root, str) or not root:
        raise ManifestError("manifest root must be a nonempty module name")
    if not isinstance(entries, list) or not entries:
        raise ManifestError("manifest modules must be a nonempty array")

    package_name: str | None = None
    package_version: str | None = None
    package = raw.get("package")
    if package is not None:
        if not isinstance(package, dict):
            raise ManifestError("manifest package must be an object")
        exact_keys(package, {"name", "version"}, "package")
        package_name = package["name"]
        package_version = package["version"]
        if not isinstance(package_name, str) or not package_name:
            raise ManifestError("package name must be nonempty")
        if not isinstance(package_version, str) or not _VERSION.fullmatch(package_version):
            raise ManifestError("package version must be a semantic version")

    package_root = path.parent
    modules_for_hash: list[tuple[str, list[tuple[str, Path]]]] = []
    modules: list[tuple[str, tuple[str, ...]]] = []
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
        hash_files: list[tuple[str, Path]] = []
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
            try:
                canonical = source.relative_to(ROOT).as_posix()
            except ValueError as error:
                raise ManifestError(f"manifest source is outside the workspace: {logical}") from error
            if not canonical.endswith(".dew"):
                raise ManifestError(f"manifest source must end in .dew: {logical}")
            if canonical in logical_files:
                raise ManifestError(f"duplicate manifest source: {logical}")
            if not source.is_file():
                raise ManifestError(f"manifest source does not exist: {logical}")
            logical_files.add(canonical)
            resolved_files.append(canonical)
            hash_files.append((logical_path.as_posix(), source))
        modules.append((name, tuple(resolved_files)))
        modules_for_hash.append((name, hash_files))
    if root not in names:
        raise ManifestError(f"manifest root module is not declared: {root}")

    dependencies: list[DependencySpec] = []
    dependency_entries = raw.get("dependencies", [])
    if not isinstance(dependency_entries, list):
        raise ManifestError("manifest dependencies must be an array")
    if dependency_entries and package_name is None:
        raise ManifestError("manifest dependencies require package identity")
    dependency_names: set[str] = set()
    for index, entry in enumerate(dependency_entries):
        if not isinstance(entry, dict):
            raise ManifestError(f"dependency {index} must be an object")
        exact_keys(
            entry,
            {"name", "version", "path", "integrity", "interface"},
            f"dependency {index}",
        )
        name = entry["name"]
        version = entry["version"]
        logical = entry["path"]
        integrity = entry["integrity"]
        interface_fingerprint = entry["interface"]
        if not isinstance(name, str) or not name:
            raise ManifestError(f"dependency {index} name must be nonempty")
        if name in dependency_names:
            raise ManifestError(f"duplicate dependency package: {name}")
        dependency_names.add(name)
        if not isinstance(version, str) or not _VERSION.fullmatch(version):
            raise ManifestError(f"dependency {name} version must be semantic")
        if not isinstance(logical, str) or not logical:
            raise ManifestError(f"dependency {name} path must be nonempty")
        dependency_path = (package_root / logical).resolve()
        if dependency_path.is_dir():
            dependency_path /= "dew.json"
        try:
            dependency_path.relative_to(ROOT)
        except ValueError as error:
            raise ManifestError(f"dependency {name} is outside the workspace") from error
        if not isinstance(integrity, str) or not _INTEGRITY.fullmatch(integrity):
            raise ManifestError(f"dependency {name} integrity must be sha256-<hex>")
        if (
            not isinstance(interface_fingerprint, str)
            or not re.fullmatch(r"[0-9a-f]{64}", interface_fingerprint)
        ):
            raise ManifestError(f"dependency {name} interface must be 64 lowercase hexadecimal digits")
        dependencies.append(
            DependencySpec(name, version, dependency_path, integrity, interface_fingerprint)
        )

    if package_name is None:
        integrity = ""
    else:
        assert package_version is not None
        integrity = _manifest_integrity(
            root,
            modules_for_hash,
            package_name,
            package_version,
            dependencies,
        )
    return ParsedManifest(
        path,
        root,
        tuple(modules),
        package_name,
        package_version,
        tuple(dependencies),
        integrity,
    )


def package_integrity(path: Path) -> str:
    manifest = _load_manifest_file(path)
    if manifest.package_name is None:
        raise ManifestError("package integrity requires manifest package identity")
    return manifest.integrity


def load_manifest(
    path: Path,
) -> tuple[str, list[tuple[str, list[str]]], str, list[tuple[str, str]]]:
    root_manifest = _load_manifest_file(path)
    visiting: set[Path] = set()
    visited: dict[str, ParsedManifest] = {}
    ordered: list[ParsedManifest] = []

    def visit(manifest: ParsedManifest, expected: DependencySpec | None = None) -> None:
        if expected is not None:
            if manifest.package_name != expected.name or manifest.package_version != expected.version:
                raise ManifestError(
                    f"dependency identity mismatch for {expected.name}@{expected.version}"
                )
            if manifest.integrity != expected.integrity:
                raise ManifestError(
                    f"dependency integrity mismatch for {expected.name}@{expected.version}: "
                    f"expected {expected.integrity}, got {manifest.integrity}"
                )
        if manifest.path in visiting:
            raise ManifestError(f"dependency manifest cycle at {manifest.path}")
        if manifest.package_name is not None and manifest.package_name in visited:
            previous = visited[manifest.package_name]
            if previous.package_version != manifest.package_version or previous.integrity != manifest.integrity:
                raise ManifestError(f"conflicting dependency package: {manifest.package_name}")
            return
        visiting.add(manifest.path)
        for dependency in manifest.dependencies:
            visit(_load_manifest_file(dependency.path), dependency)
        visiting.remove(manifest.path)
        if manifest.package_name is not None:
            visited[manifest.package_name] = manifest
        ordered.append(manifest)

    visit(root_manifest)
    modules: list[tuple[str, list[str]]] = []
    module_names: set[str] = set()
    for manifest in ordered:
        for name, files in manifest.modules:
            if name in module_names:
                raise ManifestError(f"duplicate resolved package module: {name}")
            module_names.add(name)
            modules.append((name, list(files)))
    dependency_digest = hashlib.sha256()
    dependency_digest.update(b"DEW_DEPENDENCY_INTERFACE_KEY_V1\x00")
    for manifest in ordered:
        if manifest is root_manifest or manifest.package_name is None:
            continue
        _write_hash_string(dependency_digest, manifest.package_name)
        _write_hash_string(dependency_digest, manifest.package_version or "")
        _write_hash_string(dependency_digest, manifest.integrity)
    expectations: dict[str, str] = {}
    for manifest in ordered:
        for dependency in manifest.dependencies:
            dependency_manifest = _load_manifest_file(dependency.path)
            previous = expectations.get(dependency_manifest.root)
            if previous is not None and previous != dependency.interface_fingerprint:
                raise ManifestError(
                    f"conflicting interface fingerprints for {dependency_manifest.root}"
                )
            expectations[dependency_manifest.root] = dependency.interface_fingerprint
            _write_hash_string(dependency_digest, dependency.interface_fingerprint)
    dependency_key = dependency_digest.hexdigest() if root_manifest.dependencies else ""
    return root_manifest.root, modules, dependency_key, sorted(expectations.items())


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


def moon_cli(arguments: list[str], *, check: bool = False) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        [
            "moon",
            "run",
            "--target",
            "native",
            "--release",
            "src/dew_cli",
            "--",
            *arguments,
        ],
        cwd=ROOT,
        check=check,
    )


def take_emit(arguments: list[str]) -> tuple[str, list[str]]:
    emit = "wasm"
    remaining: list[str] = []
    index = 0
    seen = False
    while index < len(arguments):
        if arguments[index] == "--emit":
            if seen:
                raise ManifestError("--emit may be supplied only once")
            if index + 1 >= len(arguments):
                raise ManifestError("missing value for --emit")
            emit = arguments[index + 1]
            if emit not in {"hir", "lowering", "wat", "wasm"}:
                raise ManifestError("--emit must be hir, lowering, wat, or wasm")
            seen = True
            index += 2
        else:
            remaining.append(arguments[index])
            index += 1
    return emit, remaining


def take_output(arguments: list[str]) -> tuple[Path, list[str]]:
    output: Path | None = None
    remaining: list[str] = []
    index = 0
    while index < len(arguments):
        if arguments[index] in {"-o", "--output"}:
            if output is not None:
                raise ManifestError("output path may be supplied only once")
            if index + 1 >= len(arguments):
                raise ManifestError("missing output path")
            output = Path(arguments[index + 1])
            index += 2
        else:
            remaining.append(arguments[index])
            index += 1
    if output is None:
        raise ManifestError("build requires -o OUTPUT")
    return output, remaining


def run_compiled(arguments: list[str]) -> None:
    emit, compile_arguments = take_emit(arguments)
    if emit != "wasm":
        raise ManifestError("dew run does not accept --emit")
    if "-o" in compile_arguments or "--output" in compile_arguments:
        raise ManifestError("dew run does not accept an output path")
    temp = ROOT / ".tmp"
    temp.mkdir(exist_ok=True)
    wasm = temp / f"dew-run-{os.getpid()}.wasm"
    try:
        compiled = moon_cli(["build", *compile_arguments, "-o", str(wasm)])
        if compiled.returncode != 0:
            raise SystemExit(compiled.returncode)
        executed = subprocess.run(
            ["node", "tools/dew-run.mjs", str(wasm)], cwd=ROOT, check=False
        )
        if executed.returncode != 0:
            raise SystemExit(executed.returncode)
    finally:
        wasm.unlink(missing_ok=True)


def emit_wat(arguments: list[str]) -> None:
    output, compile_arguments = take_output(arguments)
    temp = ROOT / ".tmp"
    temp.mkdir(exist_ok=True)
    wasm = temp / f"dew-emit-wat-{os.getpid()}.wasm"
    try:
        compiled = moon_cli(["build", *compile_arguments, "-o", str(wasm)])
        if compiled.returncode != 0:
            raise SystemExit(compiled.returncode)
        rendered = subprocess.run(
            ["wasm-tools", "print", str(wasm), "-o", str(output)],
            cwd=ROOT,
            check=False,
        )
        if rendered.returncode != 0:
            raise SystemExit(rendered.returncode)
        print(f"wrote {output} ({output.stat().st_size} bytes)")
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
        if command == "package-integrity":
            if len(sys.argv) != 3:
                raise ManifestError("usage: dew package-integrity MANIFEST")
            print(package_integrity(Path(sys.argv[2])))
            return
        configured = configure_standard_package(sys.argv[2:])
        manifest, remaining = manifest_argument(configured)
        if command == "test" and "--no-default-preamble" in remaining:
            raise ManifestError("--no-default-preamble is not supported by dew test")
        if manifest is not None:
            if command not in {"check", "build", "test", "run"}:
                raise ManifestError(
                    "--manifest is supported only by check, build, test, and run"
                )
            for argument in remaining:
                if argument == "--root" or (
                    command != "test" and argument == "--module"
                ):
                    raise ManifestError(
                        "explicit module/root selection cannot be combined with this manifest command"
                    )
            root, modules, dependency_key, dependency_interfaces = load_manifest(manifest)
            if dependency_key:
                os.environ["DEW_DEPENDENCY_INTERFACE_KEY"] = dependency_key
            else:
                os.environ.pop("DEW_DEPENDENCY_INTERFACE_KEY", None)
            if command == "test":
                run_manifest_tests(root, modules, remaining)
                return
            remaining = [*remaining, "--root", root]
            for module_name, fingerprint in dependency_interfaces:
                remaining.extend(("--dependency-interface", module_name, fingerprint))
            for name, files in modules:
                remaining.extend(("--module", name, *files))
        else:
            os.environ.pop("DEW_DEPENDENCY_INTERFACE_KEY", None)
            if command == "test":
                os.execvp("python3", ["python3", "tools/dew-test-cli.py", *remaining])

        if command == "run":
            run_compiled(remaining)
            return
        emit, without_emit = take_emit(remaining)
        if command == "build" and emit == "wat":
            emit_wat(without_emit)
            return
        forwarded = [command, *without_emit]
        if emit != "wasm":
            forwarded.extend(("--emit", emit))
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
                *forwarded,
            ],
        )
    except ManifestError as error:
        print(f"dew: {error}", file=sys.stderr)
        raise SystemExit(2) from error


if __name__ == "__main__":
    main()
