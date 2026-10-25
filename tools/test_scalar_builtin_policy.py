"""Range policy belongs to Dew, not either compiler's instruction table."""

import unittest
import re
from pathlib import Path

from wasm_scalar_intrinsics import CONVERSION_INSTRUCTIONS

ROOT = Path(__file__).resolve().parents[1]


class ScalarBuiltinPolicyTests(unittest.TestCase):
    def test_all_scalar_conversions_are_library_functions(self):
        source = (ROOT / "std/preamble/70-into-builtins.dew").read_text()
        native = (ROOT / "src/backend/starshine_conversion_builtins.mbt").read_text()
        hosted = (ROOT / "self_host/compiler/starshine_builtin_emit.dew").read_text()
        types = ["i8", "i16", "i32", "i64", "u8", "u16", "u32", "u64", "f32", "f64"]
        for origin in types:
            for target in types:
                name = f"{origin}_into_{target}"
                with self.subTest(name=name):
                    self.assertIn(f"pub fn {name}(", source)
                    self.assertNotIn(f'"dew_{name}"', source)
                    self.assertNotIn(f'"dew_{name}"', native)
                    self.assertNotIn(f'"dew_{name}"', hosted)

    def test_raw_conversions_emit_exactly_one_instruction(self):
        native = (ROOT / "src/backend/starshine_conversion_builtins.mbt").read_text()
        source = (ROOT / "std/preamble/70-into-builtins.dew").read_text()
        branches = re.findall(r'name == b"([^"]+)" \{\s+Some\(\[(.*?)\]\)', native, re.S)
        self.assertEqual(len(branches), 34)
        self.assertEqual(len({name for name, _ in branches}), 34)
        self.assertEqual(
            [(name, body.strip()) for name, body in branches],
            [(name, f"@lib.Instruction::{method}()")
             for name, method, _, _ in CONVERSION_INSTRUCTIONS],
        )
        targets = re.findall(r'^(?:pub )?builtin .* = "([^"]+)"$', source, re.M)
        # The scalar Into library uses a subset of the native conversion table.
        native_only = {"i64.extend8_s", "i64.extend16_s", "i64.extend32_s"} | {
            f"{integer}.trunc_sat_{floating}_{sign}"
            for integer in ("i32", "i64")
            for floating in ("f32", "f64")
            for sign in ("s", "u")
        }
        self.assertEqual(set(targets), {name for name, _ in branches} - native_only)
        self.assertEqual(len(targets), 23)
        for name, body in branches:
            with self.subTest(opcode=name):
                self.assertRegex(name, r'^(i32|i64|f32|f64)\.')
                self.assertRegex(body.strip(), r'^@lib\.Instruction::\w+\(\)$')


if __name__ == "__main__":
    unittest.main()
