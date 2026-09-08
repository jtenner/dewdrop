"""Unit Debug writes its delimiters through the checked Dew foreign loop."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DebugUnitPolicyTests(unittest.TestCase):
    def test_unit_output_has_no_opaque_write(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        start = source.index("impl Debug for Unit {")
        end = source.index("impl Debug for Bool {", start)
        self.assertTrue("__dew_debug_write(" not in source[start:end],
                        "Unit Debug still calls the opaque Bytes write builtin")


if __name__ == "__main__":
    unittest.main()
