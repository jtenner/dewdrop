#!/usr/bin/env python3
"""Bootstrap dispatcher for explicit Dew inputs and convention-first packages."""

from __future__ import annotations

import base64
import hashlib
import json
import os
import re
import shutil
import stat as stat_module
import struct
import subprocess
import sys
import tempfile
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
        candidates = sorted(
            source for source in source_root.rglob("*.dew") if source.is_file()
        )
    else:
        candidates = sorted(
            source for source in package_root.glob("*.dew") if source.is_file()
        )
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


def _package_integrity_records(
    name: str,
    version: str,
    dependencies: tuple[DependencyRequest, ...],
    files: list[tuple[str, bytes]],
) -> str:
    digest = hashlib.sha256()
    digest.update(b"DEW_PACKAGE_INTEGRITY_V2\x00")
    _write_hash_string(digest, name)
    _write_hash_string(digest, version)
    _write_hash_string(digest, _package_module_name(name))
    for logical, data in files:
        _write_hash_string(digest, logical)
        digest.update(len(data).to_bytes(4, "little"))
        digest.update(data)
    for dependency in dependencies:
        _write_hash_string(digest, dependency.name)
        _write_hash_string(digest, dependency.requirement)
    return f"sha256-{digest.hexdigest()}"


def _package_integrity(package: PackageDefinition) -> str:
    _, files = _conventional_source_paths(package, include_tests=True)
    return _package_integrity_records(
        package.name,
        package.version,
        package.dependencies,
        [(logical, source.read_bytes()) for logical, source in files],
    )


_PACKAGE_ARTIFACT_MAGIC = b"DEW_PACKAGE_ARTIFACT_V1\x00"


def _package_artifact_key(lock: LockedPackage) -> str:
    digest = hashlib.sha256()
    digest.update(b"DEW_PACKAGE_ARTIFACT_KEY_V1\x00")
    for value in (
        lock.name,
        lock.version,
        lock.source,
        lock.integrity,
        lock.interface_fingerprint,
        _package_module_name(lock.name),
    ):
        _write_hash_string(digest, value)
    return digest.hexdigest()


def _configured_cache_path() -> Path:
    configured = Path(os.environ.get("DEW_CACHE_DIR", ".dew/cache"))
    return configured if configured.is_absolute() else ROOT / configured


def _package_cache_root() -> Path:
    return _configured_cache_path().resolve()


_ARTIFACT_MAGIC = b"DEWART\x00\x01"
_BUILD_ARTIFACT_KIND = 6
_COMPILER_MEMO_ARTIFACT_KIND = 7
_BUILD_ARTIFACT_VERSION = 2
_COMPILER_MEMO_VERSION = 4


def _encode_uvar(value: int) -> bytes:
    if value < 0 or value > 0xFFFFFFFFFFFFFFFF:
        raise ValueError("unsigned varint is out of range")
    output = bytearray()
    while value >= 0x80:
        output.append((value & 0x7F) | 0x80)
        value >>= 7
    output.append(value)
    return bytes(output)


def _decode_uvar(data: bytes, offset: int) -> tuple[int, int]:
    start = offset
    value = 0
    for index in range(10):
        if offset >= len(data):
            raise ValueError("truncated unsigned varint")
        byte = data[offset]
        offset += 1
        if index == 9 and byte > 1:
            raise ValueError("unsigned varint overflow")
        value |= (byte & 0x7F) << (index * 7)
        if byte < 0x80:
            if offset - start > 1 and value < 1 << ((offset - start - 1) * 7):
                raise ValueError("non-canonical unsigned varint")
            return value, offset
    raise ValueError("unterminated unsigned varint")


def _wrap_binary_artifact(
    kind: int,
    version: int,
    provenance: list[bytes],
    payload: bytes,
) -> bytes:
    if kind < 0 or kind > 255 or version < 0 or version > 0xFFFFFFFF:
        raise ValueError("artifact identity is out of range")
    if len(provenance) > 255 or any(len(digest) != 32 for digest in provenance):
        raise ValueError("artifact provenance must contain SHA-256 digests")
    return b"".join(
        (
            _ARTIFACT_MAGIC,
            bytes((kind,)),
            struct.pack("<IIQ", version, 0, len(payload)),
            _encode_uvar(len(provenance)),
            *provenance,
            hashlib.sha256(payload).digest(),
            payload,
        )
    )


def _unwrap_binary_artifact(
    encoded: bytes,
    kind: int,
    version: int,
    expected_provenance: list[bytes] | None = None,
) -> tuple[bytes, list[bytes]]:
    minimum = len(_ARTIFACT_MAGIC) + 1 + 4 + 4 + 8 + 1 + 32
    if len(encoded) < minimum or encoded[: len(_ARTIFACT_MAGIC)] != _ARTIFACT_MAGIC:
        raise ValueError("unsupported or truncated artifact magic")
    offset = len(_ARTIFACT_MAGIC)
    actual_kind = encoded[offset]
    offset += 1
    actual_version, flags, payload_length = struct.unpack_from("<IIQ", encoded, offset)
    offset += 16
    if actual_kind != kind or actual_version != version or flags != 0:
        raise ValueError("unsupported artifact kind, version, or flags")
    provenance_count, offset = _decode_uvar(encoded, offset)
    if provenance_count > 255:
        raise ValueError("artifact provenance count exceeds limit")
    provenance: list[bytes] = []
    for _ in range(provenance_count):
        end = offset + 32
        if end > len(encoded):
            raise ValueError("truncated artifact provenance")
        provenance.append(encoded[offset:end])
        offset = end
    checksum_end = offset + 32
    if checksum_end > len(encoded):
        raise ValueError("truncated artifact checksum")
    checksum = encoded[offset:checksum_end]
    offset = checksum_end
    if payload_length > len(encoded) - offset or offset + payload_length != len(encoded):
        raise ValueError("invalid artifact payload length or trailing bytes")
    payload = encoded[offset:]
    if hashlib.sha256(payload).digest() != checksum:
        raise ValueError("artifact payload checksum mismatch")
    if expected_provenance is not None and provenance != expected_provenance:
        raise ValueError("artifact provenance mismatch")
    return payload, provenance


def _build_cache_compiler_roots() -> list[Path]:
    roots = {ROOT.resolve()}
    workspace = ROOT / "moon.work"
    if workspace.is_file():
        for member in re.findall(r'"([^"]+)"', workspace.read_text(encoding="utf-8")):
            candidate = (ROOT / member).resolve()
            if candidate.is_dir():
                roots.add(candidate)
    return sorted(roots, key=lambda path: path.as_posix())


def _build_cache_compiler_file_paths() -> list[str]:
    files = {Path(__file__).resolve().as_posix()}
    for compiler_root in _build_cache_compiler_roots():
        for candidate in (
            compiler_root / "moon.mod",
            compiler_root / "moon.pkg",
            compiler_root / "moon.work",
            compiler_root / ".mooncakes" / ".moon-lock",
        ):
            if candidate.is_file():
                files.add(candidate.as_posix())
        source_root = compiler_root / "src"
        if source_root.is_dir():
            for directory, _, names in os.walk(source_root):
                for name in names:
                    if name.endswith(".mbt") or name == "moon.pkg":
                        files.add((Path(directory) / name).as_posix())
    standard_roots = {ROOT / "std"}
    configured_standard = os.environ.get("DEW_STD_ROOT", "")
    if configured_standard:
        configured = Path(configured_standard).expanduser().resolve()
        standard_roots.add(configured / "std" if (configured / "std").is_dir() else configured)
    for standard_root in standard_roots:
        if standard_root.is_dir():
            for directory, _, names in os.walk(standard_root):
                for name in names:
                    if name.endswith(".dew"):
                        files.add((Path(directory) / name).as_posix())
    tools_root = ROOT / "tools"
    if tools_root.is_dir():
        for directory, _, names in os.walk(tools_root):
            if "dew-cli.py" in names:
                files.add((Path(directory) / "dew-cli.py").as_posix())
    return sorted(files)


def _build_cache_compiler_files() -> list[Path]:
    return [Path(path) for path in _build_cache_compiler_file_paths()]


def _build_cache_metadata_record(path: Path) -> dict[str, object] | None:
    try:
        status = os.stat(path, follow_symlinks=False)
    except OSError:
        return None
    if not stat_module.S_ISREG(status.st_mode):
        return None
    return {
        "ctime_ns": status.st_ctime_ns,
        "mtime_ns": status.st_mtime_ns,
        "path": path.as_posix(),
        "size": status.st_size,
    }


def _encode_compiler_memo(
    files: list[dict[str, object]], fingerprint: str
) -> bytes:
    fingerprint_bytes = bytes.fromhex(fingerprint)
    body = bytearray(fingerprint_bytes)
    body.extend(_encode_uvar(len(files)))
    for record in files:
        path = str(record["path"]).encode("utf-8")
        body.extend(_encode_uvar(len(path)))
        body.extend(path)
        body.extend(
            struct.pack(
                "<Qqq",
                int(record["size"]),
                int(record["mtime_ns"]),
                int(record["ctime_ns"]),
            )
        )
    manifest_checksum = hashlib.sha256(body).digest()
    payload = bytes(body) + manifest_checksum
    return _wrap_binary_artifact(
        _COMPILER_MEMO_ARTIFACT_KIND,
        _COMPILER_MEMO_VERSION,
        [manifest_checksum],
        payload,
    )


def _decode_compiler_memo(encoded: bytes) -> tuple[str, list[dict[str, object]]]:
    payload, provenance = _unwrap_binary_artifact(
        encoded,
        _COMPILER_MEMO_ARTIFACT_KIND,
        _COMPILER_MEMO_VERSION,
    )
    if len(payload) < 64:
        raise ValueError("truncated compiler fingerprint memo")
    body = payload[:-32]
    manifest_checksum = payload[-32:]
    if hashlib.sha256(body).digest() != manifest_checksum or provenance != [manifest_checksum]:
        raise ValueError("compiler fingerprint memo manifest checksum mismatch")
    fingerprint = body[:32].hex()
    offset = 32
    count, offset = _decode_uvar(body, offset)
    if count < 1 or count > 1_000_000:
        raise ValueError("compiler fingerprint memo file count exceeds limit")
    files: list[dict[str, object]] = []
    previous = ""
    for _ in range(count):
        length, offset = _decode_uvar(body, offset)
        if length > 1_048_576 or length > len(body) - offset:
            raise ValueError("invalid compiler fingerprint memo path length")
        try:
            path = body[offset : offset + length].decode("utf-8")
        except UnicodeDecodeError as error:
            raise ValueError("invalid compiler fingerprint memo path UTF-8") from error
        offset += length
        if path <= previous or len(body) - offset < 24:
            raise ValueError("unordered or truncated compiler fingerprint memo")
        size, mtime_ns, ctime_ns = struct.unpack_from("<Qqq", body, offset)
        offset += 24
        files.append(
            {
                "path": path,
                "size": size,
                "mtime_ns": mtime_ns,
                "ctime_ns": ctime_ns,
            }
        )
        previous = path
    if offset != len(body):
        raise ValueError("trailing compiler fingerprint memo bytes")
    return fingerprint, files


def _build_cache_metadata_matches(record: object) -> bool:
    if (
        not isinstance(record, dict)
        or set(record) != {"ctime_ns", "mtime_ns", "path", "size"}
        or not isinstance(record.get("path"), str)
    ):
        return False
    try:
        status = os.stat(record["path"], follow_symlinks=False)
    except OSError:
        return False
    return (
        stat_module.S_ISREG(status.st_mode)
        and status.st_ctime_ns == record["ctime_ns"]
        and status.st_mtime_ns == record["mtime_ns"]
        and status.st_size == record["size"]
    )


def _build_cache_compiler_memo_matches(
    cached: tuple[str, list[dict[str, object]]]
) -> bool:
    fingerprint, files = cached
    if re.fullmatch(r"[0-9a-f]{64}", fingerprint) is None or not files:
        return False
    cached_paths = [str(record["path"]) for record in files]
    if cached_paths != _build_cache_compiler_file_paths():
        return False
    return all(_build_cache_metadata_matches(record) for record in files)


def _build_cache_argument_path(value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else ROOT / path


def _build_cache_compiler_fingerprint() -> str:
    memo = _package_cache_root() / "compiler-fingerprint-v4.dbm"
    if memo.is_file() and not memo.is_symlink():
        try:
            cached = _decode_compiler_memo(memo.read_bytes())
            if _build_cache_compiler_memo_matches(cached):
                return cached[0]
        except (OSError, ValueError):
            pass
    files = _build_cache_compiler_files()
    file_records: list[dict[str, object]] = []
    for path in files:
        record = _build_cache_metadata_record(path)
        if record is None:
            raise ManifestError(f"compiler fingerprint input disappeared: {path}")
        file_records.append(record)
    digest = hashlib.sha256()
    digest.update(b"DEW_COMPILER_SOURCE_FINGERPRINT_V4\x00")
    for record, path in zip(file_records, files):
        _write_hash_string(digest, str(record["path"]))
        data = path.read_bytes()
        digest.update(len(data).to_bytes(8, "little"))
        digest.update(data)
    fingerprint = digest.hexdigest()
    _atomic_write(memo, _encode_compiler_memo(file_records, fingerprint))
    return fingerprint


def _build_cache_key(arguments: list[str]) -> str | None:
    digest = hashlib.sha256()
    digest.update(b"DEW_BUILD_OUTPUT_KEY_V2\x00")
    normalized: list[str] = []
    source_paths: list[Path] = []
    standard_roots: list[Path] = []
    index = 0
    while index < len(arguments):
        argument = arguments[index]
        if argument in {"-o", "--output"}:
            if index + 1 >= len(arguments):
                return None
            index += 2
            continue
        if argument == "--cache-report":
            index += 1
            continue
        normalized.append(argument)
        if argument.endswith(".dew"):
            source_paths.append(_build_cache_argument_path(argument))
        if argument == "--std-root" and index + 1 < len(arguments):
            standard_roots.append(
                _build_cache_argument_path(arguments[index + 1])
            )
        index += 1
    for argument in normalized:
        _write_hash_string(digest, argument)
    for name in (
        "DEW_DEPENDENCY_INTERFACE_KEY",
        "DEW_BOOTSTRAP_STD",
        "DEW_PACKAGE_ROOTS",
        "DEW_STD_ROOT",
    ):
        _write_hash_string(digest, name)
        _write_hash_string(digest, os.environ.get(name, ""))
    for source in source_paths:
        if not source.is_file():
            return None
        _write_hash_string(digest, source.as_posix())
        data = source.read_bytes()
        digest.update(len(data).to_bytes(8, "little"))
        digest.update(data)
    for standard_root in standard_roots:
        if not standard_root.is_dir():
            return None
        for source in sorted(standard_root.rglob("*.dew"), key=lambda path: path.as_posix()):
            if not source.is_file():
                continue
            _write_hash_string(digest, source.relative_to(standard_root).as_posix())
            data = source.read_bytes()
            digest.update(len(data).to_bytes(8, "little"))
            digest.update(data)
    _write_hash_string(digest, _build_cache_compiler_fingerprint())
    return digest.hexdigest()


def _build_cache_emit(arguments: list[str]) -> str:
    for index, argument in enumerate(arguments):
        if argument == "--emit" and index + 1 < len(arguments):
            return arguments[index + 1]
    return "wasm"


def _build_cache_artifact_path(key: str) -> Path:
    return _package_cache_root() / "builds" / f"v2-{key}.dba"


def _build_cache_emit_tag(emit: str) -> int:
    try:
        return {"wasm": 0, "hir": 1, "lowering": 2}[emit]
    except KeyError as error:
        raise ManifestError(f"unsupported build cache emit kind: {emit}") from error


def _encode_build_cache_artifact(key: str, emit: str, payload: bytes) -> bytes:
    try:
        key_bytes = bytes.fromhex(key)
    except ValueError as error:
        raise ManifestError("build cache key is not SHA-256") from error
    if len(key_bytes) != 32:
        raise ManifestError("build cache key is not SHA-256")
    digest = hashlib.sha256(payload).digest()
    body = b"".join(
        (
            bytes((_build_cache_emit_tag(emit),)),
            key_bytes,
            digest,
            struct.pack("<Q", len(payload)),
            payload,
        )
    )
    return _wrap_binary_artifact(
        _BUILD_ARTIFACT_KIND,
        _BUILD_ARTIFACT_VERSION,
        [key_bytes],
        body,
    )


def _decode_build_cache_artifact(
    artifact: Path, key: str, emit: str
) -> bytes | None:
    if not artifact.exists() and not artifact.is_symlink():
        return None
    if artifact.is_symlink() or not artifact.is_file():
        raise ManifestError(f"corrupt build cache artifact: {artifact}")
    try:
        encoded = artifact.read_bytes()
        key_bytes = bytes.fromhex(key)
        if len(key_bytes) != 32:
            raise ValueError("invalid key")
        body, _ = _unwrap_binary_artifact(
            encoded,
            _BUILD_ARTIFACT_KIND,
            _BUILD_ARTIFACT_VERSION,
            [key_bytes],
        )
        header_length = 1 + 32 + 32 + 8
        if len(body) < header_length:
            raise ValueError("truncated build artifact header")
        emit_tag = body[0]
        stored_key = body[1:33]
        stored_digest = body[33:65]
        payload_length = struct.unpack_from("<Q", body, 65)[0]
        payload = body[header_length:]
        if (
            emit_tag != _build_cache_emit_tag(emit)
            or stored_key != key_bytes
            or payload_length != len(payload)
            or stored_digest != hashlib.sha256(payload).digest()
        ):
            raise ValueError("build artifact header mismatch")
        return payload
    except (OSError, ValueError) as error:
        raise ManifestError(f"corrupt build cache artifact: {artifact}") from error


def _atomic_write(path: Path, payload: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            prefix=f".{path.name}.", dir=path.parent, delete=False
        ) as output:
            output.write(payload)
            output.flush()
            os.fsync(output.fileno())
            temporary = Path(output.name)
        os.replace(temporary, path)
        temporary = None
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def _publish_build_cache_artifact(
    artifact: Path, key: str, emit: str, payload: bytes
) -> None:
    encoded = _encode_build_cache_artifact(key, emit, payload)
    _atomic_write(artifact, encoded)


def run_cached_build(arguments: list[str]) -> subprocess.CompletedProcess[bytes]:
    output, _ = take_output(arguments[1:])
    key = _build_cache_key(arguments)
    if key is None:
        return moon_cli(arguments)
    emit = _build_cache_emit(arguments)
    artifact = _build_cache_artifact_path(key)
    cached = _decode_build_cache_artifact(artifact, key, emit)
    report = "--cache-report" in arguments
    if cached is not None:
        _atomic_write(output, cached)
        if report:
            print(f"build output cache: hit {key}")
        print(f"wrote {output} ({len(cached)} bytes)")
        return subprocess.CompletedProcess(arguments, 0)
    compiled = moon_cli(arguments)
    if compiled.returncode != 0:
        return compiled
    if not output.is_file():
        raise ManifestError(f"compiler did not write build output: {output}")
    payload = output.read_bytes()
    if _build_cache_key(arguments) == key:
        _publish_build_cache_artifact(artifact, key, emit, payload)
    if report:
        print(f"build output cache: miss {key}")
    return compiled


def take_build_cache(arguments: list[str]) -> tuple[bool, list[str]]:
    enabled = True
    remaining: list[str] = []
    for argument in arguments:
        if argument == "--no-build-cache":
            if not enabled:
                raise ManifestError("--no-build-cache may be supplied only once")
            enabled = False
        else:
            remaining.append(argument)
    return enabled, remaining


def run_clean(arguments: list[str]) -> None:
    dry_run = False
    for argument in arguments:
        if argument == "--dry-run":
            if dry_run:
                raise ManifestError("--dry-run may be supplied only once")
            dry_run = True
        else:
            raise ManifestError("usage: dew clean [--dry-run]")
    cache = _configured_cache_path().absolute()
    resolved = cache.resolve()
    dangerous = {Path("/"), Path.home().resolve(), ROOT.resolve(), WORKING_DIRECTORY}
    if resolved in dangerous:
        raise ManifestError(f"refusing to clean unsafe cache path: {resolved}")
    exists = cache.exists() or cache.is_symlink()
    if not exists:
        print(f"dew cache already clean: {cache}")
        return
    if dry_run:
        print(f"would remove Dew cache: {cache}")
        return
    if cache.is_symlink() or cache.is_file():
        cache.unlink()
    else:
        shutil.rmtree(cache)
    print(f"removed Dew cache: {cache}")


def _package_artifact_path(lock: LockedPackage) -> Path:
    return _package_cache_root() / "packages" / f"v1-{_package_artifact_key(lock)}.dpa"


def _package_artifact_payload(package: PackageDefinition, lock: LockedPackage) -> bytes:
    _, sources = _conventional_source_paths(package, include_tests=True)
    files = []
    for logical, source in sources:
        data = source.read_bytes()
        files.append(
            {
                "path": logical,
                "sha256": hashlib.sha256(data).hexdigest(),
                "content": base64.b64encode(data).decode("ascii"),
            }
        )
    payload = {
        "artifactVersion": 1,
        "name": lock.name,
        "version": lock.version,
        "source": lock.source,
        "integrity": lock.integrity,
        "interface": lock.interface_fingerprint,
        "module": _package_module_name(lock.name),
        "dependencies": [
            {"name": dependency.name, "requirement": dependency.requirement}
            for dependency in package.dependencies
        ],
        "files": files,
    }
    return json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")


def _decode_package_artifact(
    lock: LockedPackage,
    artifact: bytes,
) -> tuple[tuple[DependencyRequest, ...], list[tuple[str, bytes]]]:
    header_length = len(_PACKAGE_ARTIFACT_MAGIC)
    if (
        not artifact.startswith(_PACKAGE_ARTIFACT_MAGIC)
        or len(artifact) < header_length + 65
    ):
        raise ManifestError("unsupported or truncated installed package artifact")
    checksum = artifact[header_length : header_length + 64]
    if artifact[header_length + 64 : header_length + 65] != b"\n":
        raise ManifestError("malformed installed package artifact checksum")
    payload = artifact[header_length + 65 :]
    if checksum.decode("ascii", errors="ignore") != hashlib.sha256(payload).hexdigest():
        raise ManifestError("installed package artifact checksum mismatch")
    try:
        raw = json.loads(payload.decode("utf-8"), object_pairs_hook=unique_object)
    except (json.JSONDecodeError, UnicodeError, ManifestError) as error:
        raise ManifestError(f"invalid installed package artifact: {error}") from error
    if not isinstance(raw, dict):
        raise ManifestError("installed package artifact root must be an object")
    exact_keys(
        raw,
        {
            "artifactVersion",
            "name",
            "version",
            "source",
            "integrity",
            "interface",
            "module",
            "dependencies",
            "files",
        },
        "installed package artifact",
    )
    expected = {
        "artifactVersion": 1,
        "name": lock.name,
        "version": lock.version,
        "source": lock.source,
        "integrity": lock.integrity,
        "interface": lock.interface_fingerprint,
        "module": _package_module_name(lock.name),
    }
    for field, value in expected.items():
        if raw[field] != value:
            raise ManifestError(
                f"installed package artifact {field} mismatch for {lock.name}"
            )
    raw_dependencies = raw["dependencies"]
    if not isinstance(raw_dependencies, list):
        raise ManifestError("installed package artifact dependencies must be an array")
    dependencies: list[DependencyRequest] = []
    previous_name = ""
    for index, dependency in enumerate(raw_dependencies):
        if not isinstance(dependency, dict):
            raise ManifestError(
                f"installed package artifact dependency {index} must be an object"
            )
        exact_keys(
            dependency,
            {"name", "requirement"},
            f"installed package artifact dependency {index}",
        )
        name = dependency["name"]
        requirement = dependency["requirement"]
        if not isinstance(name, str) or not _PACKAGE_NAME.fullmatch(name):
            raise ManifestError(f"invalid installed package artifact dependency name at {index}")
        if not isinstance(requirement, str) or not requirement:
            raise ManifestError(
                f"invalid installed package artifact dependency requirement for {name}"
            )
        if name <= previous_name:
            raise ManifestError(
                "installed package artifact dependencies are not strictly ordered"
            )
        previous_name = name
        dependencies.append(DependencyRequest(name, requirement))
    raw_files = raw["files"]
    if not isinstance(raw_files, list) or not raw_files:
        raise ManifestError("installed package artifact files must be a nonempty array")
    files: list[tuple[str, bytes]] = []
    seen: set[str] = set()
    previous_path = ""
    for index, file in enumerate(raw_files):
        if not isinstance(file, dict):
            raise ManifestError(f"installed package artifact file {index} must be an object")
        exact_keys(
            file,
            {"path", "sha256", "content"},
            f"installed package artifact file {index}",
        )
        logical = file["path"]
        checksum_hex = file["sha256"]
        content = file["content"]
        if not isinstance(logical, str) or not logical or logical in seen:
            raise ManifestError(f"invalid installed package artifact path at {index}")
        relative = Path(logical)
        if (
            relative.is_absolute()
            or ".." in relative.parts
            or "\\" in logical
            or not logical.endswith(".dew")
        ):
            raise ManifestError(f"unsafe installed package artifact path: {logical}")
        if logical <= previous_path:
            raise ManifestError("installed package artifact files are not strictly ordered")
        previous_path = logical
        seen.add(logical)
        if not isinstance(checksum_hex, str) or not _FINGERPRINT.fullmatch(
            checksum_hex
        ):
            raise ManifestError(
                f"invalid installed package artifact checksum for {logical}"
            )
        if not isinstance(content, str):
            raise ManifestError(f"invalid installed package artifact content for {logical}")
        try:
            data = base64.b64decode(content, validate=True)
        except ValueError as error:
            raise ManifestError(
                f"invalid installed package artifact base64 for {logical}"
            ) from error
        if hashlib.sha256(data).hexdigest() != checksum_hex:
            raise ManifestError(
                f"installed package artifact file checksum mismatch for {logical}"
            )
        files.append((logical, data))
    dependency_tuple = tuple(dependencies)
    actual_integrity = _package_integrity_records(
        lock.name, lock.version, dependency_tuple, files
    )
    if actual_integrity != lock.integrity:
        raise ManifestError(
            f"installed package artifact integrity mismatch for {lock.name}@{lock.version}: "
            f"expected {lock.integrity}, got {actual_integrity}"
        )
    return dependency_tuple, files


def _store_package_artifact(package: PackageDefinition, lock: LockedPackage) -> None:
    path = _package_artifact_path(lock)
    if path.exists():
        return
    payload = _package_artifact_payload(package, lock)
    artifact = (
        _PACKAGE_ARTIFACT_MAGIC
        + hashlib.sha256(payload).hexdigest().encode("ascii")
        + b"\n"
        + payload
    )
    temporary = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        temporary.write_bytes(artifact)
        os.replace(temporary, path)
    except OSError as error:
        try:
            temporary.unlink(missing_ok=True)
        except OSError:
            pass
        raise ManifestError(
            f"cannot write installed package artifact {path}: {error}"
        ) from error


def _restore_package_artifact(lock: LockedPackage) -> PackageDefinition:
    path = _package_artifact_path(lock)
    if not path.is_file():
        raise ManifestError(
            f"locked package source is unavailable and no installed artifact exists for "
            f"{lock.name}@{lock.version}: {path}"
        )
    try:
        dependencies, files = _decode_package_artifact(lock, path.read_bytes())
    except OSError as error:
        raise ManifestError(
            f"cannot read installed package artifact {path}: {error}"
        ) from error
    package_root = lock.path.parent
    try:
        if package_root.exists() and any(package_root.iterdir()):
            raise ManifestError(
                f"cannot restore installed package artifact into nonempty path "
                f"{package_root}"
            )
    except OSError as error:
        raise ManifestError(
            f"cannot inspect installed package path {package_root}: {error}"
        ) from error
    staging = package_root.with_name(
        f".{package_root.name}.dew-artifact-{_package_artifact_key(lock)}"
    )
    try:
        if package_root.exists():
            package_root.rmdir()
        if staging.exists():
            shutil.rmtree(staging)
        staging.mkdir(parents=True)
        manifest = {
            "name": lock.name,
            "version": lock.version,
            "dependencies": {
                dependency.name: dependency.requirement for dependency in dependencies
            },
        }
        (staging / "dew.json").write_text(
            json.dumps(manifest, sort_keys=True, separators=(",", ":")) + "\n",
            encoding="utf-8",
        )
        for logical, data in files:
            destination = staging / logical
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(data)
        os.replace(staging, package_root)
    except OSError as error:
        try:
            if staging.exists():
                shutil.rmtree(staging)
        except OSError:
            pass
        raise ManifestError(
            f"cannot restore installed package artifact for "
            f"{lock.name}@{lock.version}: {error}"
        ) from error
    package = _load_package_definition(lock.path)
    if _package_integrity(package) != lock.integrity:
        raise ManifestError(
            f"restored installed package artifact failed integrity for {lock.name}"
        )
    return package


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
        if package_manifest.is_dir() or package_manifest.name != "dew.json":
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
            if dependency_lock.path.is_file():
                dependency_package = _load_package_definition(dependency_lock.path)
                if (
                    dependency_package.name != dependency_lock.name
                    or dependency_package.version != dependency_lock.version
                ):
                    raise ManifestError(
                        f"locked package identity mismatch for "
                        f"{dependency_lock.name}@{dependency_lock.version}"
                    )
                actual_integrity = _package_integrity(dependency_package)
                if actual_integrity != dependency_lock.integrity:
                    raise ManifestError(
                        f"dependency integrity mismatch for "
                        f"{dependency_lock.name}@{dependency_lock.version}: "
                        f"expected {dependency_lock.integrity}, got {actual_integrity}"
                    )
                _store_package_artifact(dependency_package, dependency_lock)
            else:
                dependency_package = _restore_package_artifact(dependency_lock)
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


def _compile_request_bytes(arguments: list[str]) -> bytes:
    if not arguments or arguments[0] not in {"check", "build"}:
        raise ManifestError("compile request command must be check or build")
    command = 0 if arguments[0] == "check" else 1
    emit = 0
    output = ""
    root_module = ""
    module_name = "main"
    files: list[str] = []
    modules: list[tuple[str, list[str]]] = []
    dependency_interfaces: list[tuple[str, str]] = []
    default_preamble = True
    parse_event_cache = True
    interface_cache = True
    body_family_cache = os.environ.get("DEW_BODY_FAMILY_CACHE", "0") == "1"
    body_cache = (
        os.environ.get("DEW_BODY_CACHE", "0") == "1" or body_family_cache
    )
    planning_cache = os.environ.get("DEW_PLAN_CACHE", "0") == "1"
    cache_pack = os.environ.get("DEW_CACHE_PACK", "1") != "0"
    program_cache = os.environ.get("DEW_PROGRAM_CACHE", "1") != "0"
    cache_report = False
    standard_policy = 1 if os.environ.get("DEW_BOOTSTRAP_STD") == "1" else 0
    standard_root = "" if standard_policy == 1 else os.environ.get("DEW_STD_ROOT", ".")
    dependency_cache_key = os.environ.get("DEW_DEPENDENCY_INTERFACE_KEY", "")

    def flush_module() -> None:
        nonlocal files
        if files:
            modules.append((module_name, files))
            files = []

    index = 1
    while index < len(arguments):
        argument = arguments[index]
        if argument == "--module":
            if index + 1 >= len(arguments):
                raise ManifestError("missing value for --module")
            flush_module()
            module_name = arguments[index + 1]
            index += 2
        elif argument == "--dependency-interface":
            if index + 2 >= len(arguments):
                raise ManifestError("missing dependency interface expectation")
            dependency_interfaces.append((arguments[index + 1], arguments[index + 2]))
            index += 3
        elif argument == "--root":
            if index + 1 >= len(arguments):
                raise ManifestError("missing value for --root")
            root_module = arguments[index + 1]
            index += 2
        elif argument == "--emit":
            if index + 1 >= len(arguments):
                raise ManifestError("missing value for --emit")
            value = arguments[index + 1]
            if value not in {"wasm", "hir", "lowering"}:
                raise ManifestError("compile request emit must be wasm, hir, or lowering")
            emit = {"wasm": 0, "hir": 1, "lowering": 2}[value]
            index += 2
        elif argument == "--std-root":
            if index + 1 >= len(arguments):
                raise ManifestError("missing value for --std-root")
            standard_policy = 0
            standard_root = arguments[index + 1]
            index += 2
        elif argument == "--bootstrap-std":
            standard_policy = 1
            standard_root = ""
            index += 1
        elif argument == "--no-default-preamble":
            default_preamble = False
            index += 1
        elif argument == "--no-parse-event-cache":
            parse_event_cache = False
            index += 1
        elif argument == "--no-interface-cache":
            interface_cache = False
            index += 1
        elif argument == "--body-cache":
            body_cache = True
            index += 1
        elif argument == "--no-body-cache":
            body_cache = False
            body_family_cache = False
            index += 1
        elif argument == "--body-family-cache":
            body_cache = True
            body_family_cache = True
            index += 1
        elif argument == "--plan-cache":
            planning_cache = True
            index += 1
        elif argument == "--no-plan-cache":
            planning_cache = False
            index += 1
        elif argument == "--cache-pack":
            cache_pack = True
            index += 1
        elif argument == "--no-cache-pack":
            cache_pack = False
            index += 1
        elif argument == "--program-cache":
            program_cache = True
            index += 1
        elif argument == "--no-program-cache":
            program_cache = False
            index += 1
        elif argument == "--cache-report":
            cache_report = True
            index += 1
        elif argument in {"-o", "--output"}:
            if index + 1 >= len(arguments):
                raise ManifestError("missing output path")
            output = arguments[index + 1]
            index += 2
        elif argument.startswith("-"):
            raise ManifestError(f"unknown compiler request option: {argument}")
        else:
            files.append(argument)
            index += 1
    flush_module()
    if not modules:
        raise ManifestError("compile request requires at least one source file")
    if command == 0 and output:
        raise ManifestError("check does not accept an output path")
    if command == 1 and not output:
        raise ManifestError("build requires -o OUTPUT")

    buffer = bytearray()

    def write_u32(value: int) -> None:
        buffer.extend(struct.pack("<I", value))

    def write_bool(value: bool) -> None:
        write_u32(1 if value else 0)

    def write_string(value: str) -> None:
        encoded = value.encode("utf-8")
        write_u32(len(encoded))
        buffer.extend(encoded)

    write_u32(0x44574352)
    write_u32(6)
    write_u32(command)
    write_u32(emit)
    write_string(output)
    write_string(root_module)
    write_u32(len(modules))
    for name, module_files in modules:
        write_string(name)
        write_u32(len(module_files))
        for path in module_files:
            write_string(path)
    write_u32(len(dependency_interfaces))
    for name, fingerprint in dependency_interfaces:
        write_string(name)
        write_string(fingerprint)
    write_u32(standard_policy)
    write_string(standard_root)
    write_bool(default_preamble)
    write_bool(parse_event_cache)
    write_bool(interface_cache)
    write_bool(body_cache)
    write_bool(body_family_cache)
    write_bool(planning_cache)
    write_bool(cache_pack)
    write_bool(program_cache)
    write_bool(cache_report)
    write_u32(0)  # production build mode
    write_string(dependency_cache_key)
    return bytes(buffer)


def moon_cli(arguments: list[str], *, check: bool = False) -> subprocess.CompletedProcess[bytes]:
    temp = ROOT / ".tmp"
    temp.mkdir(exist_ok=True)
    request_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            prefix="dew-compile-request-",
            suffix=".bin",
            dir=temp,
            delete=False,
        ) as request:
            request.write(_compile_request_bytes(arguments))
            request_path = Path(request.name)
        environment = os.environ.copy()
        environment["DEW_COMPILER_FINGERPRINT"] = _build_cache_compiler_fingerprint()
        return subprocess.run(
            [
                "moon",
                "run",
                "--target",
                "native",
                "--release",
                "src/dew_cli",
                "--",
                "--compile-request",
                str(request_path),
            ],
            cwd=ROOT,
            env=environment,
            check=check,
        )
    finally:
        if request_path is not None:
            request_path.unlink(missing_ok=True)


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
        if command == "clean":
            run_clean(sys.argv[2:])
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
        build_cache_enabled = True
        if "--no-build-cache" in without_emit:
            if command != "build":
                raise ManifestError("--no-build-cache is supported only by dew build")
            build_cache_enabled, without_emit = take_build_cache(without_emit)
        if command == "build" and emit == "wat":
            emit_wat(without_emit)
            return
        without_emit = normalize_native_paths(
            without_emit, explicit_sources=not using_manifest
        )
        forwarded = [command, *without_emit]
        if emit != "wasm":
            forwarded.extend(("--emit", emit))
        compiled = (
            run_cached_build(forwarded)
            if command == "build" and build_cache_enabled
            else moon_cli(forwarded)
        )
        if compiled.returncode != 0:
            raise SystemExit(compiled.returncode)
    except ManifestError as error:
        print(f"dew: {error}", file=sys.stderr)
        raise SystemExit(2) from error


if __name__ == "__main__":
    main()
