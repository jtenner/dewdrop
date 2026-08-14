#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
import os
import shutil
import tempfile
import time
import unittest
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path
from unittest import mock

MODULE_PATH = Path(__file__).with_name("dew-cli.py")
SPEC = importlib.util.spec_from_file_location("dew_cli", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
dew_cli = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(dew_cli)


class VersionedManifestTests(unittest.TestCase):
    def write_json(self, path: Path, value: object) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(__import__("json").dumps(value), encoding="utf-8")

    def package(self, root: Path) -> tuple[Path, str]:
        package = root / "dependency"
        package.mkdir(parents=True)
        (package / "callback.dew").write_text(
            "pub fn answer() -> I32 {\n  42\n}\n", encoding="utf-8"
        )
        (package / "callback_test.dew").write_text(
            'test "dependency test" { () }\n', encoding="utf-8"
        )
        manifest = package / "dew.json"
        self.write_json(
            manifest,
            {
                "name": "@fixture/library",
                "version": "1.2.3",
                "dependencies": {},
            },
        )
        return manifest, dew_cli.package_integrity(manifest)

    def root_package(
        self,
        root: Path,
        dependency: Path,
        integrity: str,
        *,
        requirement: str = "^1.2.0",
        source: str = "file:dependency",
        interface: str = "1" * 64,
    ) -> Path:
        (root / "main.dew").write_text(
            "open fixture.library\npub fn main() -> I32 {\n  answer()\n}\n",
            encoding="utf-8",
        )
        manifest = root / "dew.json"
        self.write_json(
            manifest,
            {
                "name": "@fixture/application",
                "version": "1.0.0",
                "dependencies": {"@fixture/library": requirement},
            },
        )
        self.write_json(
            root / "dew.lock",
            {
                "lockfileVersion": 1,
                "packages": [
                    {
                        "name": "@fixture/library",
                        "version": "1.2.3",
                        "source": source,
                        "path": str(dependency.parent.relative_to(root)),
                        "integrity": integrity,
                        "interface": interface,
                    }
                ],
            },
        )
        return manifest

    def test_resolve_locked_dependency_by_convention(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, integrity = self.package(root)
                manifest = self.root_package(root, dependency, integrity)
                (root / ".dew" / "cache").mkdir(parents=True)
                resolved_root, modules, dependency_key, interfaces = dew_cli.load_manifest(manifest)
                self.assertEqual(resolved_root, "fixture.application")
                self.assertEqual(
                    [name for name, _ in modules],
                    ["fixture.library", "fixture.application"],
                )
                self.assertEqual(Path(modules[0][1][0]).name, "callback.dew")
                self.assertEqual(Path(modules[1][1][0]).name, "main.dew")
                self.assertRegex(dependency_key, r"^[0-9a-f]{64}$")
                self.assertEqual(interfaces, [("fixture.library", "1" * 64)])
                _, test_modules, _, _ = dew_cli.load_manifest(
                    manifest, include_tests=True
                )
                self.assertEqual(len(test_modules[0][1]), 1)

    def test_restore_locked_dependency_from_installed_artifact(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, integrity = self.package(root)
                manifest = self.root_package(root, dependency, integrity)
                first = dew_cli.load_manifest(manifest)
                artifacts = list((root / ".dew" / "cache" / "packages").glob("v1-*.dpa"))
                self.assertEqual(len(artifacts), 1)
                shutil.rmtree(dependency.parent)
                second = dew_cli.load_manifest(manifest)
                self.assertEqual(first, second)
                self.assertTrue(dependency.is_file())
                self.assertEqual(dew_cli.package_integrity(dependency), integrity)

    def test_corrupt_installed_dependency_artifact_fails_visibly(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, integrity = self.package(root)
                manifest = self.root_package(root, dependency, integrity)
                dew_cli.load_manifest(manifest)
                artifact = next((root / ".dew" / "cache" / "packages").glob("v1-*.dpa"))
                artifact.write_bytes(b"corrupt")
                shutil.rmtree(dependency.parent)
                with self.assertRaisesRegex(
                    dew_cli.ManifestError,
                    "unsupported or truncated installed package artifact",
                ):
                    dew_cli.load_manifest(manifest)

    def test_installed_artifact_does_not_overwrite_partial_dependency_tree(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, integrity = self.package(root)
                manifest = self.root_package(root, dependency, integrity)
                dew_cli.load_manifest(manifest)
                shutil.rmtree(dependency.parent)
                dependency.parent.mkdir()
                partial = dependency.parent / "partial.txt"
                partial.write_text("keep", encoding="utf-8")
                with self.assertRaisesRegex(
                    dew_cli.ManifestError,
                    "cannot restore installed package artifact into nonempty path",
                ):
                    dew_cli.load_manifest(manifest)
                self.assertEqual(partial.read_text(encoding="utf-8"), "keep")

    def test_reject_dependency_integrity_mismatch(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, _ = self.package(root)
                manifest = self.root_package(root, dependency, "sha256-" + "0" * 64)
                with self.assertRaisesRegex(dew_cli.ManifestError, "integrity mismatch"):
                    dew_cli.load_manifest(manifest)

    def test_reject_missing_lockfile(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                (root / "main.dew").write_text("pub fn main() -> Unit {}\n")
                manifest = root / "dew.json"
                self.write_json(
                    manifest,
                    {
                        "name": "@fixture/application",
                        "version": "1.0.0",
                        "dependencies": {"@fixture/library": "1.2.3"},
                    },
                )
                with self.assertRaisesRegex(dew_cli.ManifestError, "require lockfile"):
                    dew_cli.load_manifest(manifest)

    def test_reject_lock_version_outside_requirement(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, integrity = self.package(root)
                manifest = self.root_package(root, dependency, integrity, requirement="^2.0.0")
                with self.assertRaisesRegex(dew_cli.ManifestError, "does not satisfy"):
                    dew_cli.load_manifest(manifest)

    def test_git_requirement_matches_locked_source(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, integrity = self.package(root)
                source = "git+https://example.test/fixture/library.git#abc123"
                manifest = self.root_package(
                    root,
                    dependency,
                    integrity,
                    requirement=source,
                    source=source,
                )
                resolved_root, _, _, _ = dew_cli.load_manifest(manifest)
                self.assertEqual(resolved_root, "fixture.application")

    def test_package_integrity_ignores_lockfile_resolution(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, integrity = self.package(root)
                before = dew_cli.package_integrity(dependency)
                self.write_json(
                    dependency.parent / "dew.lock",
                    {"lockfileVersion": 1, "packages": []},
                )
                self.assertEqual(dew_cli.package_integrity(dependency), before)
                self.assertEqual(before, integrity)

    def test_package_is_discovered_from_working_directory(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = root / "dew.json"
            manifest.write_text("{}", encoding="utf-8")
            self.assertEqual(
                dew_cli.conventional_package_manifest(None, ["-o", "app.wasm"], directory=root),
                manifest,
            )
            self.assertIsNone(
                dew_cli.conventional_package_manifest(None, ["main.dew"], directory=root)
            )

    def test_tests_are_selected_only_for_test_mode(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                (root / "main.dew").write_text("pub fn main() -> Unit {}\n")
                (root / "main_test.dew").write_text("test main_test { () }\n")
                manifest = root / "dew.json"
                self.write_json(
                    manifest,
                    {
                        "name": "@fixture/application",
                        "version": "1.0.0",
                        "dependencies": {},
                    },
                )
                _, build_modules, _, _ = dew_cli.load_manifest(manifest)
                _, test_modules, _, _ = dew_cli.load_manifest(manifest, include_tests=True)
                self.assertEqual(len(build_modules[0][1]), 1)
                self.assertEqual(len(test_modules[0][1]), 2)


class CompileRequestProtocolTests(unittest.TestCase):
    @staticmethod
    def cache_policy(encoded: bytes) -> tuple[bool, bool, bool]:
        offset = 0

        def read_u32() -> int:
            nonlocal offset
            value = __import__("struct").unpack_from("<I", encoded, offset)[0]
            offset += 4
            return value

        def skip_string() -> None:
            nonlocal offset
            length = read_u32()
            offset += length

        read_u32()
        read_u32()
        read_u32()
        read_u32()
        skip_string()
        skip_string()
        for _ in range(read_u32()):
            skip_string()
            for _ in range(read_u32()):
                skip_string()
        for _ in range(read_u32()):
            skip_string()
            skip_string()
        read_u32()
        skip_string()
        read_u32()
        read_u32()
        read_u32()
        return bool(read_u32()), bool(read_u32()), bool(read_u32())

    def test_body_cache_is_opt_in_and_family_mode_enables_it(self) -> None:
        with mock.patch.dict(os.environ, {}, clear=True):
            default_request = dew_cli._compile_request_bytes(["check", "main.dew"])
            explicit_request = dew_cli._compile_request_bytes(
                ["check", "--body-cache", "main.dew"]
            )
        with mock.patch.dict(
            os.environ,
            {"DEW_BODY_CACHE": "0", "DEW_BODY_FAMILY_CACHE": "0"},
            clear=True,
        ):
            family_request = dew_cli._compile_request_bytes(
                ["check", "--body-family-cache", "main.dew"]
            )
        with mock.patch.dict(
            os.environ,
            {"DEW_BODY_CACHE": "0", "DEW_BODY_FAMILY_CACHE": "1"},
            clear=True,
        ):
            family_environment_request = dew_cli._compile_request_bytes(
                ["check", "main.dew"]
            )
        with mock.patch.dict(
            os.environ,
            {"DEW_PLAN_CACHE": "1"},
            clear=True,
        ):
            planning_environment_request = dew_cli._compile_request_bytes(
                ["check", "main.dew"]
            )
        explicit_planning_request = dew_cli._compile_request_bytes(
            ["check", "--plan-cache", "main.dew"]
        )
        disabled_planning_request = dew_cli._compile_request_bytes(
            ["check", "--plan-cache", "--no-plan-cache", "main.dew"]
        )
        self.assertEqual(
            self.cache_policy(default_request),
            (False, False, False),
        )
        self.assertEqual(
            self.cache_policy(explicit_request),
            (True, False, False),
        )
        self.assertEqual(
            self.cache_policy(family_request),
            (True, True, False),
        )
        self.assertEqual(
            self.cache_policy(family_environment_request),
            (True, True, False),
        )
        self.assertEqual(
            self.cache_policy(planning_environment_request),
            (False, False, True),
        )
        self.assertEqual(
            self.cache_policy(explicit_planning_request),
            (False, False, True),
        )
        self.assertEqual(
            self.cache_policy(disabled_planning_request),
            (False, False, False),
        )

    def test_versioned_request_carries_ordered_inputs_and_policy(self) -> None:
        environment = {
            "DEW_BOOTSTRAP_STD": "1",
            "DEW_BODY_CACHE": "1",
            "DEW_BODY_FAMILY_CACHE": "0",
            "DEW_DEPENDENCY_INTERFACE_KEY": "dependency-key",
        }
        with mock.patch.dict(os.environ, environment, clear=False):
            encoded = dew_cli._compile_request_bytes(
                [
                    "build",
                    "--root",
                    "app.main",
                    "--dependency-interface",
                    "dep.value",
                    "a" * 64,
                    "--module",
                    "dep.value",
                    "dep.dew",
                    "--module",
                    "app.main",
                    "main.dew",
                    "--no-default-preamble",
                    "--no-parse-event-cache",
                    "--no-interface-cache",
                    "--no-body-cache",
                    "--body-family-cache",
                    "--cache-report",
                    "-o",
                    "app.wasm",
                ]
            )

        offset = 0

        def read_u32() -> int:
            nonlocal offset
            value = __import__("struct").unpack_from("<I", encoded, offset)[0]
            offset += 4
            return value

        def read_string() -> str:
            nonlocal offset
            length = read_u32()
            value = encoded[offset : offset + length].decode("utf-8")
            offset += length
            return value

        self.assertEqual(read_u32(), 0x44574352)
        self.assertEqual(read_u32(), 5)
        self.assertEqual(read_u32(), 1)
        self.assertEqual(read_u32(), 0)
        self.assertEqual(read_string(), "app.wasm")
        self.assertEqual(read_string(), "app.main")
        self.assertEqual(read_u32(), 2)
        self.assertEqual((read_string(), read_u32(), read_string()), ("dep.value", 1, "dep.dew"))
        self.assertEqual((read_string(), read_u32(), read_string()), ("app.main", 1, "main.dew"))
        self.assertEqual(read_u32(), 1)
        self.assertEqual((read_string(), read_string()), ("dep.value", "a" * 64))
        self.assertEqual(read_u32(), 1)
        self.assertEqual(read_string(), "")
        self.assertEqual(
            (
                read_u32(),
                read_u32(),
                read_u32(),
                read_u32(),
                read_u32(),
                read_u32(),
                read_u32(),
            ),
            (0, 0, 0, 1, 1, 0, 1),
        )
        self.assertEqual(read_u32(), 0)
        self.assertEqual(read_string(), "dependency-key")
        self.assertEqual(offset, len(encoded))

    def test_request_rejects_unknown_internal_options(self) -> None:
        with self.assertRaisesRegex(dew_cli.ManifestError, "unknown compiler request option"):
            dew_cli._compile_request_bytes(["check", "--mystery", "main.dew"])


class PackageRootTests(unittest.TestCase):
    def package(self, root: Path, nested: bool) -> Path:
        package = root / "dew.std" if nested else root
        sentinel = package / "std" / "preamble" / "00-builtins.dew"
        sentinel.parent.mkdir(parents=True)
        sentinel.write_text("", encoding="utf-8")
        return package.resolve()

    def test_explicit_root_resolves_nested_dew_std_package(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            package = self.package(root, True)
            self.assertEqual(dew_cli.resolve_standard_package_root([root]), package)

    def test_explicit_root_resolves_bootstrap_compatible_layout(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            package = self.package(root, False)
            self.assertEqual(dew_cli.resolve_standard_package_root([root]), package)

    def test_explicit_missing_root_does_not_fall_back(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            with self.assertRaisesRegex(dew_cli.ManifestError, "cannot locate dew.std"):
                dew_cli.resolve_standard_package_root([Path(temporary) / "missing"])

    def test_package_options_are_removed_before_native_dispatch(self) -> None:
        roots, bootstrap, remaining = dew_cli.package_root_arguments(
            ["--package-root", "packages", "--root", "app.main", "main.dew"]
        )
        self.assertEqual(roots, [dew_cli.WORKING_DIRECTORY / "packages"])
        self.assertFalse(bootstrap)
        self.assertEqual(remaining, ["--root", "app.main", "main.dew"])

    def test_test_command_rejects_no_default_preamble(self) -> None:
        with redirect_stderr(StringIO()), self.assertRaisesRegex(SystemExit, "2"):
            previous = os.environ.get("DEW_BOOTSTRAP_STD")
            try:
                os.environ["DEW_BOOTSTRAP_STD"] = "1"
                with mock.patch(
                    "sys.argv", ["dew-cli.py", "test", "--no-default-preamble", "x_test.dew"]
                ):
                    dew_cli.main()
            finally:
                if previous is None:
                    os.environ.pop("DEW_BOOTSTRAP_STD", None)
                else:
                    os.environ["DEW_BOOTSTRAP_STD"] = previous

    def test_environment_roots_preserve_declared_order(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            base = Path(temporary)
            first = base / "first"
            second = base / "second"
            package = self.package(second, True)
            previous = os.environ.get("DEW_PACKAGE_ROOTS")
            os.environ["DEW_PACKAGE_ROOTS"] = os.pathsep.join((str(first), str(second)))
            try:
                self.assertEqual(dew_cli.resolve_standard_package_root([]), package)
            finally:
                if previous is None:
                    os.environ.pop("DEW_PACKAGE_ROOTS", None)
                else:
                    os.environ["DEW_PACKAGE_ROOTS"] = previous


class BuildOutputCacheTests(unittest.TestCase):
    def compiler_tree(self, root: Path) -> None:
        (root / "src").mkdir(parents=True)
        (root / "std").mkdir()
        (root / "moon.mod").write_text("{}", encoding="utf-8")
        (root / "src" / "compiler.mbt").write_text("fn compiler() {}", encoding="utf-8")
        (root / "std" / "base.dew").write_text("pub fn base() -> Unit {}", encoding="utf-8")

    def test_compiler_fingerprint_reuses_validated_file_manifest(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            self.compiler_tree(root)
            with mock.patch.object(dew_cli, "ROOT", root):
                first = dew_cli._build_cache_compiler_fingerprint()
                with mock.patch.object(
                    dew_cli,
                    "_build_cache_compiler_files",
                    side_effect=AssertionError("unexpected compiler-tree rescan"),
                ):
                    second = dew_cli._build_cache_compiler_fingerprint()
                self.assertEqual(first, second)
                memo = root / ".dew" / "cache" / "compiler-fingerprint-v4.dbm"
                corrupted = bytearray(memo.read_bytes())
                corrupted[-1] ^= 0xFF
                memo.write_bytes(corrupted)
                self.assertEqual(first, dew_cli._build_cache_compiler_fingerprint())
                compiler = root / "src" / "compiler.mbt"
                compiler_status = compiler.stat()
                for _ in range(100):
                    compiler.write_text("fn compileR() {}", encoding="utf-8")
                    os.utime(
                        compiler,
                        ns=(
                            compiler_status.st_atime_ns,
                            compiler_status.st_mtime_ns,
                        ),
                    )
                    if compiler.stat().st_ctime_ns != compiler_status.st_ctime_ns:
                        break
                    time.sleep(0.01)
                else:
                    self.fail("filesystem did not advance compiler source ctime")
                same_size_changed = dew_cli._build_cache_compiler_fingerprint()
                self.assertNotEqual(first, same_size_changed)
                (root / "src" / "added.mbt").write_text(
                    "fn added() {}", encoding="utf-8"
                )
                changed = dew_cli._build_cache_compiler_fingerprint()
                self.assertNotEqual(same_size_changed, changed)

    def test_compiler_fingerprint_memo_rejects_every_truncation_and_mutation(self) -> None:
        files = [
            {
                "path": "moon.mod",
                "size": 2,
                "mtime_ns": 10,
                "ctime_ns": 11,
            },
            {
                "path": "src/compiler.mbt",
                "size": 16,
                "mtime_ns": 20,
                "ctime_ns": 21,
            },
        ]
        encoded = dew_cli._encode_compiler_memo(files, "3" * 64)
        self.assertEqual(dew_cli._decode_compiler_memo(encoded), ("3" * 64, files))
        for cut in range(len(encoded)):
            with self.assertRaises(ValueError):
                dew_cli._decode_compiler_memo(encoded[:cut])
        for selected in range(len(encoded)):
            mutated = bytearray(encoded)
            mutated[selected] ^= 0x80
            with self.assertRaises(ValueError):
                dew_cli._decode_compiler_memo(bytes(mutated))

    def test_build_cache_key_tracks_sources_and_ignores_output(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            self.compiler_tree(root)
            source = root / "main.dew"
            source.write_text("pub fn main() -> I32 { 1 }", encoding="utf-8")
            with mock.patch.object(dew_cli, "ROOT", root), mock.patch.object(
                dew_cli, "WORKING_DIRECTORY", root
            ):
                first = dew_cli._build_cache_key(
                    ["build", "main.dew", "-o", "first.wasm"]
                )
                second = dew_cli._build_cache_key(
                    ["build", "main.dew", "-o", "second.wasm"]
                )
                self.assertEqual(first, second)
                source.write_text("pub fn main() -> I32 { 2 }", encoding="utf-8")
                changed = dew_cli._build_cache_key(
                    ["build", "main.dew", "-o", "second.wasm"]
                )
                self.assertNotEqual(first, changed)
                (root / "src" / "compiler.mbt").write_text(
                    "fn compiler() { let changed = 1 }", encoding="utf-8"
                )
                compiler_changed = dew_cli._build_cache_key(
                    ["build", "main.dew", "-o", "second.wasm"]
                )
                self.assertNotEqual(changed, compiler_changed)

    def test_build_cache_artifact_round_trip_and_corruption(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            artifact = Path(temporary) / "entry.dba"
            payload = b"wasm"
            encoded = dew_cli._encode_build_cache_artifact(
                "a" * 64, "wasm", payload
            )
            self.assertEqual(encoded[:8], b"DEWART\x00\x01")
            self.assertEqual(encoded[8], dew_cli._BUILD_ARTIFACT_KIND)
            self.assertEqual(
                __import__("struct").unpack_from("<I", encoded, 9)[0], 2
            )
            artifact.write_bytes(encoded)
            self.assertEqual(
                dew_cli._decode_build_cache_artifact(
                    artifact, "a" * 64, "wasm"
                ),
                payload,
            )
            for cut in range(len(encoded)):
                artifact.write_bytes(encoded[:cut])
                with self.assertRaisesRegex(
                    dew_cli.ManifestError, "corrupt build cache artifact"
                ):
                    dew_cli._decode_build_cache_artifact(
                        artifact, "a" * 64, "wasm"
                    )
            for selected in range(len(encoded)):
                mutated = bytearray(encoded)
                mutated[selected] ^= 0x40
                artifact.write_bytes(mutated)
                with self.assertRaisesRegex(
                    dew_cli.ManifestError, "corrupt build cache artifact"
                ):
                    dew_cli._decode_build_cache_artifact(
                        artifact, "a" * 64, "wasm"
                    )

    def test_cached_build_restores_verified_output_without_compiling(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            self.compiler_tree(root)
            (root / "main.dew").write_text(
                "pub fn main() -> I32 { 42 }", encoding="utf-8"
            )
            output = root / "program.wasm"
            arguments = ["build", "main.dew", "-o", str(output)]
            with mock.patch.object(dew_cli, "ROOT", root), mock.patch.object(
                dew_cli, "WORKING_DIRECTORY", root
            ), mock.patch.dict(
                os.environ, {"DEW_CACHE_DIR": ".cache"}, clear=False
            ):
                def compile_once(_: list[str]) -> object:
                    output.write_bytes(b"compiled wasm")
                    return __import__("subprocess").CompletedProcess(arguments, 0)

                with mock.patch.object(dew_cli, "moon_cli", side_effect=compile_once) as compile_mock:
                    dew_cli.run_cached_build(arguments)
                    self.assertEqual(compile_mock.call_count, 1)
                output.unlink()
                with mock.patch.object(dew_cli, "moon_cli") as compile_mock, redirect_stdout(
                    StringIO()
                ):
                    result = dew_cli.run_cached_build(arguments)
                    self.assertEqual(result.returncode, 0)
                    self.assertEqual(compile_mock.call_count, 0)
                self.assertEqual(output.read_bytes(), b"compiled wasm")


class CleanCommandTests(unittest.TestCase):
    def test_default_cache_is_nested_under_dew_metadata(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root), mock.patch.dict(
                os.environ, {}, clear=True
            ):
                self.assertEqual(
                    dew_cli._configured_cache_path(), root / ".dew" / "cache"
                )

    def test_clean_removes_configured_cache(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            cache = root / "cache"
            (cache / "interfaces").mkdir(parents=True)
            (cache / "interfaces" / "entry.dwi").write_bytes(b"cached")
            with mock.patch.object(dew_cli, "ROOT", root), mock.patch.dict(
                os.environ, {"DEW_CACHE_DIR": "cache"}, clear=False
            ):
                output = StringIO()
                with redirect_stdout(output):
                    dew_cli.run_clean([])
                self.assertFalse(cache.exists())
                self.assertIn("removed Dew cache", output.getvalue())

    def test_clean_dry_run_preserves_cache(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            cache = root / "cache"
            cache.mkdir()
            with mock.patch.object(dew_cli, "ROOT", root), mock.patch.dict(
                os.environ, {"DEW_CACHE_DIR": "cache"}, clear=False
            ):
                output = StringIO()
                with redirect_stdout(output):
                    dew_cli.run_clean(["--dry-run"])
                self.assertTrue(cache.is_dir())
                self.assertIn("would remove Dew cache", output.getvalue())

    def test_clean_refuses_project_root(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root), mock.patch.object(
                dew_cli, "WORKING_DIRECTORY", root
            ), mock.patch.dict(
                os.environ, {"DEW_CACHE_DIR": str(root)}, clear=False
            ):
                with self.assertRaisesRegex(
                    dew_cli.ManifestError, "refusing to clean unsafe cache path"
                ):
                    dew_cli.run_clean([])

    def test_clean_unlinks_cache_symlink_without_removing_target(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            target = root / "target"
            target.mkdir()
            (target / "keep").write_text("keep", encoding="utf-8")
            cache = root / "cache-link"
            cache.symlink_to(target, target_is_directory=True)
            with mock.patch.object(dew_cli, "ROOT", root), mock.patch.dict(
                os.environ, {"DEW_CACHE_DIR": "cache-link"}, clear=False
            ):
                with redirect_stdout(StringIO()):
                    dew_cli.run_clean([])
                self.assertFalse(cache.exists())
                self.assertTrue((target / "keep").is_file())


if __name__ == "__main__":
    unittest.main()
