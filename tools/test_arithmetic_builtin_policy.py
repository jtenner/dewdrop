"""Narrow arithmetic policy belongs to Dew, not backend instruction sequences."""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class ArithmeticBuiltinPolicyTests(unittest.TestCase):
    def test_narrow_operations_are_library_functions(self):
        source = (ROOT / "std/preamble/40-numeric-builtins.dew").read_text()
        for type_ in ["i8", "u8", "i16", "u16"]:
            for op in ["or", "xor", "and", "eq", "ne", "lt", "lte", "gt", "gte", "shl", "shr", "add", "sub", "mul", "div", "rem"]:
                with self.subTest(type=type_, operation=op):
                    self.assertIn(f"pub fn {type_}_{op}(", source)

    def test_numeric_backend_contains_only_single_instructions(self):
        source = (ROOT / "src/backend/starshine_numeric_builtins.mbt").read_text()
        branches = re.findall(r'name == b"([^"]+)" \{\s+Some\(\[(.*?)\]\)', source, re.S)
        # 66 binary arithmetic and 18 unary math/bit instructions.
        self.assertEqual(len(branches), 84)
        for name, body in branches:
            with self.subTest(opcode=name):
                self.assertRegex(body.strip(), r'^@lib\.Instruction::\w+\(\)$')


if __name__ == "__main__":
    unittest.main()
