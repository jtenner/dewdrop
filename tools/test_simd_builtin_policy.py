"""Immediate-free SIMD builtins use one opcode and an exact stack contract."""

import re
import unittest
from pathlib import Path

from wasm_simd_intrinsics import SIMD_INSTRUCTIONS, SIMD_CROSS_OPERATIONS, SIMD_LANE_INSTRUCTIONS, SIMD_MEMORY_INSTRUCTIONS, SIMD_SIGNATURES, simd_shuffle_immediates

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

    def test_lane_immediates_cover_complete_valid_ranges(self):
        self.assertEqual(len(SIMD_LANE_INSTRUCTIONS), 96)
        source = (ROOT / "src/backend/starshine_v128_builtins.mbt").read_text()
        for descriptor, _, _, _, indices in SIMD_LANE_INSTRUCTIONS:
            with self.subTest(descriptor=descriptor):
                self.assertIn(f'name == b"{descriptor}"', source)
                family = descriptor.split(".")[0]
                self.assertEqual(len(indices), 1)
                self.assertLess(indices[0], int(family.split("x")[1]))

    def test_generic_shuffle_accepts_custom_recipe_and_rejects_mutations(self):
        descriptor = "i8x16.shuffle 31 31 0 30 1 29 2 28 3 27 4 26 5 25 6 24"
        indices = simd_shuffle_immediates(descriptor)
        self.assertEqual(indices, (31, 31, 0, 30, 1, 29, 2, 28, 3, 27, 4, 26, 5, 25, 6, 24))
        for position in range(16):
            bad = list(map(str, indices))
            bad[position] = "32"
            self.assertIsNone(simd_shuffle_immediates("i8x16.shuffle " + " ".join(bad)))
        for bad in (descriptor + " 0", descriptor[:-3], descriptor.replace(" 0 ", " 00 ")):
            self.assertIsNone(simd_shuffle_immediates(bad))

    def test_memory_contracts_and_all_typed_module_builtins(self):
        self.assertEqual(len(SIMD_MEMORY_INSTRUCTIONS), 72)
        contracts = {opcode: (inputs, result) for opcode, _, inputs, result in SIMD_SIGNATURES}
        self.assertEqual(contracts["v128.store64_lane 1"], (("I32", "V128"), "Unit"))
        self.assertEqual(contracts["v128.load8x8_s"], (("I32",), "V128"))
        for family in ("i8x16", "u8x16", "i16x8", "u16x8", "i32x4", "u32x4", "i64x2", "u64x2", "f32x4", "f64x2"):
            source = (ROOT / f"std/{family}.dew").read_text()
            targets = re.findall(r'^(?:pub )?builtin .* = "([^"]+)"$', source, re.M)
            self.assertTrue(targets)
            for target in targets:
                with self.subTest(module=family, target=target):
                    self.assertTrue(target in contracts or simd_shuffle_immediates(target) is not None)


if __name__ == "__main__":
    unittest.main()
