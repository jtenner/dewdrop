"""Math declarations must use real Wasm instruction targets."""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class MathBuiltinPolicyTests(unittest.TestCase):
    def test_math_targets_are_wasm_instructions(self):
        source = (ROOT / "std/math.dew").read_text()
        targets = re.findall(r'^pub builtin .* = "([^"]+)"$', source, re.M)
        self.assertEqual(len(targets), 16)
        for target in targets:
            with self.subTest(target=target):
                self.assertRegex(target, r'^(i32|i64|f32|f64)\.')

    def test_numeric_table_has_no_library_operation_names(self):
        source = (ROOT / "src/backend/starshine_numeric_builtins.mbt").read_text()
        targets = re.findall(r'name == b"([^"]+)"', source)
        self.assertEqual(len(targets), 86)
        for target in targets:
            with self.subTest(target=target):
                self.assertRegex(target, r'^(i32|i64|f32|f64)\.')


if __name__ == "__main__":
    unittest.main()
