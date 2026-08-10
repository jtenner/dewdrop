#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import os
import tempfile
import unittest
from contextlib import redirect_stderr
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
    def test_versioned_request_carries_ordered_inputs_and_policy(self) -> None:
        environment = {
            "DEW_BOOTSTRAP_STD": "1",
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
                    "--no-interface-cache",
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
        self.assertEqual(read_u32(), 1)
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
        self.assertEqual((read_u32(), read_u32(), read_u32()), (0, 0, 1))
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


if __name__ == "__main__":
    unittest.main()
