"""V128 Debug formatting is Dew code with two one-to-one lane reads."""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DebugVectorPolicyTests(unittest.TestCase):
    def test_vector_formatter_is_a_dew_function(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        self.assertIsNone(re.search(r"\bbuiltin\s+__dew_debug_v128\(", source))
        self.assertIsNotNone(re.search(r"\bfn\s+__dew_debug_v128\(", source))
        self.assertIn('builtin __dew_debug_v128_low(value: V128) -> U64 = "i64x2.extract_lane 0"', source)
        self.assertIn('builtin __dew_debug_v128_high(value: V128) -> U64 = "i64x2.extract_lane 1"', source)

    def test_compiler_vector_formatting_is_removed(self):
        for path in ("src/backend/starshine_program_assembly.mbt",
                     "starshine-mb/src/ffi_bridge/ffi_bridge.mbt",
                     "src/semantic/wasmgc_fragment_plan.mbt",
                     "self_host/compiler/semantic_program_link_plan.dew"):
            source = (ROOT / path).read_text()
            with self.subTest(path=path):
                for name in ('"dew_debug_v128"', "starshine_debug_v128_body",
                             "starshine_debug_write_i64_hex"):
                    self.assertTrue(name not in source, f"{path} still contains {name}")


if __name__ == "__main__":
    unittest.main()
