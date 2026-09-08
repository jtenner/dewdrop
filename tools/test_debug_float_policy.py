"""Floating Debug bit formatting is Dew code, not a runtime builder."""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DebugFloatPolicyTests(unittest.TestCase):
    def test_private_debug_helpers_do_not_become_public_aliases(self):
        from generate_wasm_intrinsics_std import rendered_intrinsics
        source, _, _ = rendered_intrinsics()
        self.assertTrue("wasm___dew_debug" not in source,
                        "generated intrinsics must not publish private Debug helpers")

    def test_float_formatters_are_dew_functions(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        self.assertIn('builtin __dew_debug_f32_bits(value: F32) -> U32 = "i32.reinterpret_f32"', source)
        self.assertIn('builtin __dew_debug_f64_bits(value: F64) -> U64 = "i64.reinterpret_f64"', source)
        for kind in ("f32", "f64"):
            with self.subTest(kind=kind):
                self.assertIsNone(re.search(rf"\bbuiltin\s+__dew_debug_{kind}\(", source))
                self.assertIsNotNone(re.search(rf"\bfn\s+__dew_debug_{kind}\(", source))

    def test_compiler_float_formatting_is_removed(self):
        for path in ("src/backend/starshine_text_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/text_runtime.mbt",
                     "src/semantic/wasmgc_fragment_plan.mbt",
                     "self_host/compiler/semantic_program_link_plan.dew"):
            source = (ROOT / path).read_text()
            with self.subTest(path=path):
                for kind in ("f32", "f64"):
                    self.assertTrue(f'"dew_debug_{kind}"' not in source,
                                    f"{path} still contains dew_debug_{kind}")
                self.assertTrue("starshine_debug_float_body" not in source,
                                f"{path} still contains the float runtime builder")


if __name__ == "__main__":
    unittest.main()
