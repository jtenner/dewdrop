"""Bool Debug writes ASCII through the checked Dew foreign loop."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DebugBoolPolicyTests(unittest.TestCase):
    def test_bool_output_has_no_opaque_write(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        start = source.index("impl Debug for Bool {")
        end = source.index("impl Debug for I8 {", start)
        self.assertTrue("__dew_debug_write(" not in source[start:end],
                        "Bool Debug still calls the opaque Bytes write builtin")


if __name__ == "__main__":
    unittest.main()
