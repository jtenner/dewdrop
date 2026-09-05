"""Immediate-free SIMD builtins use one opcode and an exact stack contract."""

import re
import unittest
from pathlib import Path

from wasm_simd_intrinsics import SIMD_INSTRUCTIONS, SIMD_CROSS_OPERATIONS

ROOT = Path(__file__).resolve().parents[1]


class SimdBuiltinPolicyTests(unittest.TestCase):
    def test_catalog_has_one_instruction_per_unique_opcode(self):
        source = (ROOT / "src/backend/starshine_v128_builtins.mbt").read_text()
        instructions = re.findall(
            r'name == b"([^"]+)" \{\s*Some\(\[@lib\.Instruction::(\w+)\(\)\]\)', source
        )
        self.assertEqual(len(instructions), 194)
        self.assertEqual(instructions, [(opcode, instruction) for opcode, instruction, _, _ in SIMD_INSTRUCTIONS])
        self.assertEqual(len(dict(instructions)), 194)

    def test_no_old_opcode_aliases_in_library_or_emitters(self):
        paths = list((ROOT / "std").rglob("*.dew")) + [
            ROOT / "src/backend/starshine_v128_builtins.mbt",
            ROOT / "self_host/compiler/starshine_builtin_emit.dew",
        ]
        for path in paths:
            with self.subTest(path=path.relative_to(ROOT)):
                self.assertNotIn('"dew_v128_', path.read_text())

    def test_cross_lane_aliases_are_removed(self):
        for type_, suffix, _, _ in SIMD_CROSS_OPERATIONS:
            source = (ROOT / f"std/{type_.lower()}.dew").read_text()
            self.assertNotIn(f'"dew_{type_.lower()}_{suffix}"', source)

    def test_ternary_and_shift_contracts(self):
        contracts = {opcode: (inputs, result) for opcode, _, inputs, result in SIMD_INSTRUCTIONS}
        self.assertEqual(contracts["v128.bitselect"], (("V128", "V128", "V128"), "V128"))
        for opcode, (inputs, result) in contracts.items():
            if opcode.endswith((".shl", ".shr_s", ".shr_u")):
                self.assertEqual((inputs, result), (("V128", "I32"), "V128"))


if __name__ == "__main__":
    unittest.main()
