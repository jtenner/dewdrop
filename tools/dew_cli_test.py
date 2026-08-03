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
    def write_manifest(self, path: Path, value: object) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(__import__("json").dumps(value), encoding="utf-8")

    def package(self, root: Path) -> tuple[Path, str]:
        package = root / "dependency"
        package.mkdir(parents=True)
        (package / "library.dew").write_text(
            "pub fn answer() -> I32 {\n  42\n}\n", encoding="utf-8"
        )
        manifest = package / "dew.json"
        self.write_manifest(
            manifest,
            {
                "package": {"name": "fixture.library", "version": "1.2.3"},
                "root": "fixture.library",
                "modules": [{"name": "fixture.library", "files": ["library.dew"]}],
            },
        )
        return manifest, dew_cli.package_integrity(manifest)

    def test_resolve_versioned_dependency_and_integrity_key(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, integrity = self.package(root)
                (root / "main.dew").write_text(
                    "open fixture.library\npub fn main() -> I32 {\n  answer()\n}\n",
                    encoding="utf-8",
                )
                manifest = root / "dew.json"
                self.write_manifest(
                    manifest,
                    {
                        "package": {"name": "fixture.app", "version": "1.0.0"},
                        "root": "fixture.main",
                        "modules": [{"name": "fixture.main", "files": ["main.dew"]}],
                        "dependencies": [
                            {
                                "name": "fixture.library",
                                "version": "1.2.3",
                                "path": str(dependency.relative_to(root)),
                                "integrity": integrity,
                                "interface": "1" * 64,
                            }
                        ],
                    },
                )
                resolved_root, modules, dependency_key, interfaces = dew_cli.load_manifest(manifest)
                self.assertEqual(resolved_root, "fixture.main")
                self.assertEqual([name for name, _ in modules], ["fixture.library", "fixture.main"])
                self.assertRegex(dependency_key, r"^[0-9a-f]{64}$")
                self.assertEqual(interfaces, [("fixture.library", "1" * 64)])

    def test_reject_dependency_integrity_mismatch(self) -> None:
        with tempfile.TemporaryDirectory(dir=dew_cli.ROOT / ".tmp") as temporary:
            root = Path(temporary)
            with mock.patch.object(dew_cli, "ROOT", root):
                dependency, _ = self.package(root)
                (root / "main.dew").write_text("pub fn main() -> Unit {}\n", encoding="utf-8")
                manifest = root / "dew.json"
                self.write_manifest(
                    manifest,
                    {
                        "package": {"name": "fixture.app", "version": "1.0.0"},
                        "root": "fixture.main",
                        "modules": [{"name": "fixture.main", "files": ["main.dew"]}],
                        "dependencies": [
                            {
                                "name": "fixture.library",
                                "version": "1.2.3",
                                "path": str(dependency.relative_to(root)),
                                "integrity": "sha256-" + "0" * 64,
                                "interface": "1" * 64,
                            }
                        ],
                    },
                )
                with self.assertRaisesRegex(dew_cli.ManifestError, "integrity mismatch"):
                    dew_cli.load_manifest(manifest)


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
        self.assertEqual(roots, [Path("packages")])
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
