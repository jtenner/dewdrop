"""Focused checks for the compiler CLI fixture harness."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path


def load_fixtures():
    path = Path(__file__).with_name("cli-fixtures.py")
    spec = importlib.util.spec_from_file_location("dew_cli_fixtures", path)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load CLI fixture harness")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


fixtures = load_fixtures()


class CliFixtureTests(unittest.TestCase):
    def test_subprocesses_receive_eof_without_terminal_input(self):
        result = fixtures.run(
            [sys.executable, "-c", "import sys; print(repr(sys.stdin.read()))"]
        )
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "''\n")


if __name__ == "__main__":
    unittest.main()
