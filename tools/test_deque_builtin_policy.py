#!/usr/bin/env python3
"""Deque entry points must use ordinary library calls."""

import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DequeBuiltinPolicyTests(unittest.TestCase):
    def test_deque_is_a_library_module(self):
        source = (ROOT / "std/collections/deque.dew").read_text()
        self.assertNotRegex(source, r"\bbuiltin\b")

    def test_no_deque_operation_dispatch(self):
        registry = json.loads((ROOT / "tools/standard-builtin-registry.json").read_text())
        self.assertEqual(registry["modules"]["deque"]["operations"], {})
        self.assertNotIn("methods", registry["modules"]["deque"])
        source = (ROOT / "src/semantic/lowering_plan.mbt").read_text()
        self.assertNotIn("standard_deque_operation", source)


if __name__ == "__main__":
    unittest.main()
