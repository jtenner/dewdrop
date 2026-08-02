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
