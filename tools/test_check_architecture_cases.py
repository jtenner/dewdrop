"""Focused checks for declarative architecture cases."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path


def load_checker():
    path = Path(__file__).with_name("check-architecture-cases.py")
    spec = importlib.util.spec_from_file_location("dew_architecture_cases", path)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load architecture case checker")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


checker = load_checker()
EXPECTED = {"export": "run", "result": {"type": "i32", "value": 42}}


class ArchitectureCaseTests(unittest.TestCase):
    def test_consumer_result_requires_exact_json_equality(self):
        self.assertIsNone(
            checker.consumer_result_error(
                '{"export":"run","result":{"type":"i32","value":42}}\n',
                EXPECTED,
            )
        )
        self.assertIsNotNone(
            checker.consumer_result_error(
                '{"export":"run","result":{"type":"i32","value":420}}\n',
                EXPECTED,
            )
        )

    def test_consumer_result_rejects_non_json_output(self):
        self.assertIn(
            "invalid JSON",
            checker.consumer_result_error("not json", EXPECTED),
        )


if __name__ == "__main__":
    unittest.main()
