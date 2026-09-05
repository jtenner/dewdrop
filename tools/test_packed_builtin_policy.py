#!/usr/bin/env python3
"""Packed API operations are Dew wrappers, not compiler operation aliases."""

import re
import unittest
from pathlib import Path

import generate_lane_std as lanes


class PackedBuiltinPolicyTests(unittest.TestCase):
    def test_every_swar_module_has_only_library_functions(self):
        for width, family in [(32, lanes.SWAR32_TYPES), (64, lanes.SWAR64_TYPES)]:
            for args in family:
                with self.subTest(type=args[0]):
                    source = lanes.swar_source(*args, width)
                    self.assertNotRegex(source, r"\bbuiltin\b")
                    self.assertIn("unsafe_bitcast", source)

    def test_vector_carrier_helpers_are_library_functions(self):
        for args in lanes.V128_TYPES:
            with self.subTest(type=args[0]):
                source = lanes.v128_source(*args)
                for name in re.findall(r"^(?:pub\s+)?builtin (\w+)", source, re.M):
                    self.assertNotRegex(name, r"_(?:from_v128|to_v128|reinterpret_as_\w+|load|store|and|or|xor)$")

    def test_obsolete_alias_handlers_are_removed(self):
        root = Path(__file__).resolve().parents[1]
        forbidden = {"dew_reinterpret"}
        for width in [32, 64]:
            forbidden.update(f"swar{width}_{op}" for op in ["from_bits", "to_bits", "and", "or", "xor"])
            forbidden.update(f"dew_swar{width}_{op}" for op in ["load", "store"])
        for relative in [
            "src/backend/starshine_code.mbt",
            "src/backend/starshine_memory_builtins.mbt",
            "self_host/compiler/starshine_builtin_emit.dew",
            "std/wasm/intrinsics.dew",
        ]:
            text = (root / relative).read_text()
            targets = set(re.findall(r'"([^"\n]+)"', text))
            with self.subTest(file=relative):
                self.assertEqual(targets & forbidden, set())


if __name__ == "__main__":
    unittest.main()
