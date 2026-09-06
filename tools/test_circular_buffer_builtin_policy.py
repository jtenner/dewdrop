#!/usr/bin/env python3
"""Circular buffer storage must be declared and implemented in Dew."""

import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class CircularBufferBuiltinPolicyTests(unittest.TestCase):
    def test_storage_is_declared(self):
        source = (ROOT / "std/collections/circular_buffer.dew").read_text()
        self.assertIn("pub struct CircularBuffer<t>", source)
        self.assertIn("pub struct CircularBufferIter<t>", source)
        self.assertNotRegex(source, r"\bbuiltin\b")

    def test_no_circular_buffer_operation_dispatch(self):
        registry = json.loads((ROOT / "tools/standard-builtin-registry.json").read_text())
        self.assertEqual(registry["modules"]["circular_buffer"]["operations"], {})
        self.assertNotIn("methods", registry["modules"]["circular_buffer"])
        source = (ROOT / "src/semantic/lowering_plan.mbt").read_text()
        self.assertNotIn("standard_circular_buffer_operation", source)
        self.assertNotRegex(source, r"\bPlannedCircularBuffer\w*")


if __name__ == "__main__":
    unittest.main()
