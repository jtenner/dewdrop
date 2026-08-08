#!/usr/bin/env python3
"""Bootstrap dispatcher for explicit Dew inputs and convention-first packages."""

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
WORKING_DIRECTORY = Path(os.environ.get("DEW_WORKING_DIRECTORY", os.getcwd())).resolve()


def working_path(path: Path) -> Path:
    return path if path.is_absolute() else WORKING_DIRECTORY / path


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


class DependencyRequest:
    def __init__(self, name: str, requirement: str) -> None:
        self.name = name
        self.requirement = requirement


class PackageDefinition:
    def __init__(
        self,
        path: Path,
        name: str,
        version: str,
        dependencies: tuple[DependencyRequest, ...],
    ) -> None:
        self.path = path
        self.name = name
        self.version = version
        self.dependencies = dependencies


class LockedPackage:
    def __init__(
        self,
        name: str,
        version: str,
        source: str,
        path: Path,
        integrity: str,
        interface_fingerprint: str,
    ) -> None:
        self.name = name
        self.version = version
        self.source = source
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
        dependencies: tuple[LockedPackage, ...],
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
_VERSION_REQUIREMENT = re.compile(r"^(?:\^|~)?[0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.-]+)?$|^\*$")
_PACKAGE_NAME = re.compile(r"^@[a-z0-9][a-z0-9._-]*/[a-z0-9][a-z0-9._-]*$")
_INTEGRITY = re.compile(r"^sha256-[0-9a-f]{64}$")
_FINGERPRINT = re.compile(r"^[0-9a-f]{64}$")
_GIT_PREFIXES = ("git://", "git+https://", "git+ssh://", "https://", "ssh://", "git@")


def _write_hash_string(digest: "hashlib._Hash", value: str) -> None:
    encoded = value.encode("utf-8")
    digest.update(len(encoded).to_bytes(4, "little"))
    digest.update(encoded)


def _read_json_object(path: Path, kind: str) -> dict[str, Any]:
    path = path.expanduser().resolve()
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as error:
        raise ManifestError(f"cannot read {kind} {path}: {error}") from error
    try:
        raw = json.loads(text, object_pairs_hook=unique_object)
    except (json.JSONDecodeError, UnicodeError, ManifestError) as error:
        raise ManifestError(f"invalid {kind} {path}: {error}") from error
    if not isinstance(raw, dict):
        raise ManifestError(f"{kind} root must be an object")
    return raw


def _package_module_name(name: str) -> str:
    scope, package = name[1:].split("/", 1)
    return f"{scope.replace('-', '_')}.{package.replace('-', '_')}"


def _is_git_requirement(requirement: str) -> bool:
    return requirement.startswith(_GIT_PREFIXES) or requirement.endswith(".git")


def _version_tuple(version: str) -> tuple[int, int, int]:
    core = version.split("-", 1)[0].split("+", 1)[0]
    major, minor, patch = core.split(".")
    return int(major), int(minor), int(patch)


def _version_satisfies(version: str, requirement: str) -> bool:
    if requirement == "*":
        return True
    if requirement.startswith("^"):
        minimum = _version_tuple(requirement[1:])
        actual = _version_tuple(version)
        if minimum[0] > 0:
            return actual >= minimum and actual[0] == minimum[0]
        if minimum[1] > 0:
            return actual >= minimum and actual[:2] == minimum[:2]
        return actual == minimum
    if requirement.startswith("~"):
        minimum = _version_tuple(requirement[1:])
        actual = _version_tuple(version)
        return actual >= minimum and actual[:2] == minimum[:2]
    return version == requirement


def _workspace_path(path: Path, context: str) -> Path:
    resolved = path.expanduser().resolve()
    try:
        resolved.relative_to(ROOT)
    except ValueError as error:
        raise ManifestError(f"{context} is outside the workspace") from error
    return resolved


def _load_package_definition(path: Path) -> PackageDefinition:
    if path.is_dir():
        path /= "dew.json"
    path = path.expanduser().resolve()
    raw = _read_json_object(path, "package definition")
    unknown = set(raw) - {"name", "version", "dependencies"}
    missing = {"name", "version"} - set(raw)
    if unknown:
        raise ManifestError(f"unknown package definition field: {sorted(unknown)[0]}")
    if missing:
        raise ManifestError(f"missing package definition field: {sorted(missing)[0]}")
    name = raw["name"]
    version = raw["version"]
    dependencies = raw.get("dependencies", {})
    if not isinstance(name, str) or not _PACKAGE_NAME.fullmatch(name):
        raise ManifestError("package name must use @scope/name")
    if not isinstance(version, str) or not _VERSION.fullmatch(version):
        raise ManifestError("package version must be an exact semantic version")
    if not isinstance(dependencies, dict):
        raise ManifestError("package dependencies must be an object")
    requests: list[DependencyRequest] = []
    for dependency_name in sorted(dependencies):
        requirement = dependencies[dependency_name]
        if not isinstance(dependency_name, str) or not _PACKAGE_NAME.fullmatch(dependency_name):
            raise ManifestError(f"dependency name must use @scope/name: {dependency_name}")
        if not isinstance(requirement, str) or not requirement:
            raise ManifestError(f"dependency {dependency_name} requirement must be nonempty")
        if not _is_git_requirement(requirement) and not _VERSION_REQUIREMENT.fullmatch(requirement):
            raise ManifestError(
                f"dependency {dependency_name} must use a semantic version requirement or git URL"
            )
        requests.append(DependencyRequest(dependency_name, requirement))
    return PackageDefinition(path, name, version, tuple(requests))


def _conventional_source_paths(
    package: PackageDefinition,
    *,
    include_tests: bool,
) -> tuple[list[str], list[tuple[str, Path]]]:
    package_root = package.path.parent
    source_root = package_root / "src"
    if source_root.is_dir():
        candidates = sorted(source_root.rglob("*.dew"))
    else:
        candidates = sorted(package_root.glob("*.dew"))
    hash_files: list[tuple[str, Path]] = []
    compile_files: list[str] = []
    for source in candidates:
        relative = source.relative_to(package_root).as_posix()
        canonical_source = _workspace_path(source, f"package source {relative}")
        canonical = canonical_source.relative_to(ROOT).as_posix()
        hash_files.append((relative, canonical_source))
        if include_tests or not source.name.endswith("_test.dew"):
            compile_files.append(canonical)
    if not compile_files:
        suffix = " including tests" if include_tests else ""
        raise ManifestError(f"package {package.name} has no conventional .dew sources{suffix}")
    return compile_files, hash_files


def _package_integrity(package: PackageDefinition) -> str:
    _, files = _conventional_source_paths(package, include_tests=True)
    digest = hashlib.sha256()
    digest.update(b"DEW_PACKAGE_INTEGRITY_V2\x00")
    _write_hash_string(digest, package.name)
    _write_hash_string(digest, package.version)
    _write_hash_string(digest, _package_module_name(package.name))
    for logical, source in files:
        _write_hash_string(digest, logical)
        data = source.read_bytes()
        digest.update(len(data).to_bytes(4, "little"))
        digest.update(data)
    for dependency in package.dependencies:
        _write_hash_string(digest, dependency.name)
        _write_hash_string(digest, dependency.requirement)
    return f"sha256-{digest.hexdigest()}"


def _load_lockfile(path: Path, package_root: Path) -> dict[str, LockedPackage]:
    raw = _read_json_object(path, "lockfile")
    exact_keys(raw, {"lockfileVersion", "packages"}, "lockfile")
    if raw["lockfileVersion"] != 1:
        raise ManifestError("lockfileVersion must be 1")
    entries = raw["packages"]
    if not isinstance(entries, list):
        raise ManifestError("lockfile packages must be an array")
    result: dict[str, LockedPackage] = {}
    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            raise ManifestError(f"locked package {index} must be an object")
        exact_keys(
            entry,
            {"name", "version", "source", "path", "integrity", "interface"},
            f"locked package {index}",
        )
        name = entry["name"]
        version = entry["version"]
        source = entry["source"]
        logical_path = entry["path"]
        integrity = entry["integrity"]
        interface = entry["interface"]
        if not isinstance(name, str) or not _PACKAGE_NAME.fullmatch(name):
            raise ManifestError(f"locked package {index} name must use @scope/name")
        if name in result:
            raise ManifestError(f"duplicate locked package: {name}")
        if not isinstance(version, str) or not _VERSION.fullmatch(version):
            raise ManifestError(f"locked package {name} version must be semantic")
        if not isinstance(source, str) or not source:
            raise ManifestError(f"locked package {name} source must be nonempty")
        if not isinstance(logical_path, str) or not logical_path:
            raise ManifestError(f"locked package {name} path must be nonempty")
        package_path = Path(logical_path)
        if package_path.is_absolute():
            raise ManifestError(f"locked package {name} path must be relative")
        package_manifest = _workspace_path(package_root / package_path, f"locked package {name}")
        if package_manifest.is_dir():
            package_manifest /= "dew.json"
        if not isinstance(integrity, str) or not _INTEGRITY.fullmatch(integrity):
            raise ManifestError(f"locked package {name} integrity must be sha256-<hex>")
        if not isinstance(interface, str) or not _FINGERPRINT.fullmatch(interface):
            raise ManifestError(f"locked package {name} interface must be 64 lowercase hexadecimal digits")
        result[name] = LockedPackage(
            name, version, source, package_manifest, integrity, interface
        )
    return result


def _load_legacy_manifest(path: Path) -> ParsedManifest:
    path = path.expanduser().resolve()
    raw = _read_json_object(path, "module manifest")
    exact_keys(raw, {"root", "modules"}, "module manifest")
    root = raw["root"]
    entries = raw["modules"]
    if not isinstance(root, str) or not root:
        raise ManifestError("module manifest root must be nonempty")
    if not isinstance(entries, list) or not entries:
        raise ManifestError("module manifest modules must be a nonempty array")
    package_root = path.parent
    modules: list[tuple[str, tuple[str, ...]]] = []
    names: set[str] = set()
    sources: set[str] = set()
    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            raise ManifestError(f"module {index} must be an object")
        exact_keys(entry, {"name", "files"}, f"module {index}")
        name = entry["name"]
        files = entry["files"]
        if not isinstance(name, str) or not name:
            raise ManifestError(f"module {index} name must be nonempty")
        if name in names:
            raise ManifestError(f"duplicate module manifest module: {name}")
        names.add(name)
        if not isinstance(files, list) or not files:
            raise ManifestError(f"module {name} files must be a nonempty array")
        resolved: list[str] = []
        for logical in files:
            if not isinstance(logical, str) or not logical:
                raise ManifestError(f"module {name} source must be nonempty")
            logical_path = Path(logical)
            if logical_path.is_absolute():
                raise ManifestError(f"module manifest source must be relative: {logical}")
            source = _workspace_path(package_root / logical_path, f"module source {logical}")
            canonical = source.relative_to(ROOT).as_posix()
            if not canonical.endswith(".dew"):
                raise ManifestError(f"module manifest source must end in .dew: {logical}")
            if canonical in sources:
                raise ManifestError(f"duplicate module manifest source: {logical}")
            if not source.is_file():
                raise ManifestError(f"module manifest source does not exist: {logical}")
            sources.add(canonical)
            resolved.append(canonical)
        modules.append((name, tuple(resolved)))
    if root not in names:
        raise ManifestError(f"module manifest root is not declared: {root}")
    return ParsedManifest(path, root, tuple(modules), None, None, (), "")


def _manifest_kind(path: Path) -> str:
    candidate = path / "dew.json" if path.is_dir() else path
    raw = _read_json_object(candidate, "manifest")
    if "name" in raw or "version" in raw or "dependencies" in raw:
        return "package"
    return "legacy"


def package_integrity(path: Path) -> str:
    package = _load_package_definition(path)
    return _package_integrity(package)


def load_manifest(
    path: Path,
    *,
    include_tests: bool = False,
) -> tuple[str, list[tuple[str, list[str]]], str, list[tuple[str, str]]]:
    if _manifest_kind(path) == "legacy":
        manifest = _load_legacy_manifest(path)
        return manifest.root, [(name, list(files)) for name, files in manifest.modules], "", []

    root_package = _load_package_definition(path)
    lock_path = root_package.path.with_name("dew.lock")
    if root_package.dependencies:
        if not lock_path.is_file():
            raise ManifestError(f"package dependencies require lockfile {lock_path}")
        locked = _load_lockfile(lock_path, root_package.path.parent)
    else:
        locked = _load_lockfile(lock_path, root_package.path.parent) if lock_path.is_file() else {}

    visiting: set[str] = set()
    visited: dict[str, tuple[PackageDefinition, LockedPackage | None]] = {}
    ordered: list[tuple[PackageDefinition, LockedPackage | None]] = []

    def visit(package: PackageDefinition, lock: LockedPackage | None) -> None:
        if package.name in visiting:
            raise ManifestError(f"dependency cycle at {package.name}")
        if package.name in visited:
            previous, _ = visited[package.name]
            if previous.version != package.version or _package_integrity(previous) != _package_integrity(package):
                raise ManifestError(f"conflicting dependency package: {package.name}")
            return
        visiting.add(package.name)
        for dependency in package.dependencies:
            dependency_lock = locked.get(dependency.name)
            if dependency_lock is None:
                raise ManifestError(f"dependency {dependency.name} is missing from dew.lock")
            if _is_git_requirement(dependency.requirement):
                if dependency_lock.source != dependency.requirement:
                    raise ManifestError(
                        f"locked source mismatch for {dependency.name}: expected {dependency.requirement}"
                    )
            elif not _version_satisfies(dependency_lock.version, dependency.requirement):
                raise ManifestError(
                    f"locked version {dependency_lock.version} does not satisfy "
                    f"{dependency.name} {dependency.requirement}"
                )
            dependency_package = _load_package_definition(dependency_lock.path)
            if dependency_package.name != dependency_lock.name or dependency_package.version != dependency_lock.version:
                raise ManifestError(
                    f"locked package identity mismatch for {dependency_lock.name}@{dependency_lock.version}"
                )
            actual_integrity = _package_integrity(dependency_package)
            if actual_integrity != dependency_lock.integrity:
                raise ManifestError(
                    f"dependency integrity mismatch for {dependency_lock.name}@{dependency_lock.version}: "
                    f"expected {dependency_lock.integrity}, got {actual_integrity}"
                )
            visit(dependency_package, dependency_lock)
        visiting.remove(package.name)
        visited[package.name] = (package, lock)
        ordered.append((package, lock))

    visit(root_package, None)
    modules: list[tuple[str, list[str]]] = []
    module_names: set[str] = set()
    expectations: dict[str, str] = {}
    dependency_digest = hashlib.sha256()
    dependency_digest.update(b"DEW_DEPENDENCY_INTERFACE_KEY_V2\x00")
    for package, lock in ordered:
        module_name = _package_module_name(package.name)
        if module_name in module_names:
            raise ManifestError(f"duplicate resolved package module: {module_name}")
        module_names.add(module_name)
        files, _ = _conventional_source_paths(
            package, include_tests=include_tests and package is root_package
        )
        modules.append((module_name, files))
        if lock is not None:
            expectations[module_name] = lock.interface_fingerprint
            _write_hash_string(dependency_digest, lock.name)
            _write_hash_string(dependency_digest, lock.version)
            _write_hash_string(dependency_digest, lock.source)
            _write_hash_string(dependency_digest, lock.integrity)
            _write_hash_string(dependency_digest, lock.interface_fingerprint)
    dependency_key = dependency_digest.hexdigest() if root_package.dependencies else ""
    return _package_module_name(root_package.name), modules, dependency_key, sorted(expectations.items())

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
            roots.append(working_path(Path(arguments[index + 1])))
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
            path = working_path(Path(arguments[index + 1]))
            index += 2
        else:
            remaining.append(arguments[index])
            index += 1
    return path, remaining


def conventional_package_manifest(
    explicit: Path | None,
    arguments: list[str],
    *,
    directory: Path | None = None,
) -> Path | None:
    if explicit is not None:
        return explicit
    if any(argument.endswith(".dew") for argument in arguments):
        return None
    if "--module" in arguments or "--root" in arguments:
        return None
    candidate = (directory or WORKING_DIRECTORY) / "dew.json"
    return candidate if candidate.is_file() else None


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
            output = working_path(Path(arguments[index + 1]))
            index += 2
        else:
            remaining.append(arguments[index])
            index += 1
    if output is None:
        raise ManifestError("build requires -o OUTPUT")
    return output, remaining


def normalize_native_paths(
    arguments: list[str], *, explicit_sources: bool
) -> list[str]:
    normalized: list[str] = []
    index = 0
    while index < len(arguments):
        argument = arguments[index]
        if argument in {"-o", "--output"} and index + 1 < len(arguments):
            normalized.extend((argument, str(working_path(Path(arguments[index + 1])))))
            index += 2
        elif explicit_sources and argument.endswith(".dew"):
            source = working_path(Path(argument))
            try:
                normalized.append(source.relative_to(ROOT).as_posix())
            except ValueError:
                normalized.append(str(source))
            index += 1
        else:
            normalized.append(argument)
            index += 1
    return normalized


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
            package_path = working_path(Path(sys.argv[2]))
            print(package_integrity(package_path))
            return
        configured = configure_standard_package(sys.argv[2:])
        manifest, remaining = manifest_argument(configured)
        manifest = conventional_package_manifest(manifest, remaining)
        if command == "test" and "--no-default-preamble" in remaining:
            raise ManifestError("--no-default-preamble is not supported by dew test")
        using_manifest = manifest is not None
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
            root, modules, dependency_key, dependency_interfaces = load_manifest(
                manifest, include_tests=command == "test"
            )
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
        without_emit = normalize_native_paths(
            without_emit, explicit_sources=not using_manifest
        )
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
