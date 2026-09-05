"""Every scalar and whole-vector memory target is an explicit Wasm instruction."""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class MemoryBuiltinPolicyTests(unittest.TestCase):
    def test_exact_memory_instruction_inventory(self):
        source = (ROOT / "std/preamble/60-memory.dew").read_text()
        native = (ROOT / "src/backend/starshine_memory_builtins.mbt").read_text()
        hosted = (ROOT / "self_host/compiler/starshine_builtin_emit.dew").read_text()
        expected = {
            "i32.load8_s", "i32.load8_u", "i32.load16_s", "i32.load16_u",
            "i32.store8", "i32.store16", "i32.load", "i32.store",
            "i64.load", "i64.store", "f32.load", "f32.store",
            "f64.load", "f64.store", "v128.load", "v128.store",
        }
        self.assertEqual(set(re.findall(r'^pub builtin .* = "([^"]+)"$', source, re.M)), expected)
        branches = re.findall(r'name == b"([^"]+)" \{\s+Some\(\[(.*?)\]\)', native, re.S)
        self.assertEqual(len(branches), len(expected))
        self.assertEqual({name for name, _ in branches}, expected)
        for name, body in branches:
            with self.subTest(opcode=name):
                self.assertRegex(body.strip(), r'^@lib\.Instruction::\w+\(starshine_memory_argument\([0-4]U\)\)$')
                self.assertEqual(hosted.count(f'name.equals(b"{name}")'), 1)
        for text in [source, native, hosted]:
            self.assertIsNone(re.search(r'"dew_[iuf](?:8|16|32|64)_(?:load|store)"', text))


if __name__ == "__main__":
    unittest.main()
