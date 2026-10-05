"""Focused tests for the module snapshot harness."""

from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path


def load_runner():
    path = Path(__file__).with_name("run.py")
    spec = importlib.util.spec_from_file_location("dew_module_snapshot_runner", path)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load module snapshot runner")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


runner = load_runner()


class ModuleSnapshotRunnerTests(unittest.TestCase):
    def test_update_can_start_without_an_expectation(self):
        with tempfile.TemporaryDirectory(prefix="dew-snapshot-test-") as directory:
            source = Path(directory) / "new-fixture.dew"
            source.write_text("pub fn main() -> Unit {}\n", encoding="utf-8")
            self.assertEqual(
                runner.load_expectation(source, allow_missing=True),
                {"errors": [], "warnings": [], "output": None},
            )

    def test_unframed_compiler_output_is_an_internal_failure(self):
        errors, warnings, internals = runner.compiler_diagnostics(
            "DEW_ERROR\nexpected type error\nDEW_END\n"
            "fatal: allocator corruption\n"
        )
        self.assertEqual(errors, ["expected type error"])
        self.assertEqual(warnings, [])
        self.assertEqual(
            internals,
            ["unframed compiler output: fatal: allocator corruption"],
        )


if __name__ == "__main__":
    unittest.main()
