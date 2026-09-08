"""Packed scalar Debug uses Dew formatting and the checked foreign write loop."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DebugSwarPolicyTests(unittest.TestCase):
    def test_swar_output_has_no_opaque_write(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        start = source.index("impl Debug for Swar32 {")
        end = source.index("impl Debug for V128 {", start)
        self.assertTrue("__dew_debug_write(" not in source[start:end],
                        "SWAR Debug still calls the opaque Bytes write builtin")


if __name__ == "__main__":
    unittest.main()
