#!/usr/bin/env python3
"""Queue must use normal Dew calls, not compiler-owned operation dispatch."""

import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class QueueBuiltinPolicyTests(unittest.TestCase):
    def test_queue_is_a_library_module(self):
        source = (ROOT / "std/queue.dew").read_text()
        self.assertNotRegex(source, r"\bbuiltin\b")
        self.assertIn("CircularBuffer<t>", source)

    def test_no_queue_operation_dispatch(self):
        registry = json.loads((ROOT / "tools/standard-builtin-registry.json").read_text())
        self.assertEqual(registry["modules"]["queue"]["operations"], {})
        self.assertNotIn("methods", registry["modules"]["queue"])
        source = (ROOT / "src/semantic/lowering_plan.mbt").read_text()
        self.assertNotIn("standard_queue_operation", source)


if __name__ == "__main__":
    unittest.main()
