"""Bytes SIMD loading belongs to Dew, not an opaque runtime builtin."""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BytesSimdLibraryPolicy(unittest.TestCase):
    def test_bytes_simd_access_has_an_ordinary_library_body(self):
        source = (ROOT / "std/wasm/intrinsics.dew").read_text()
        self.assertIsNone(re.search(r"\bbuiltin\s+wasm_bytes_load_u8x16\b", source))
        self.assertRegex(source, r"\bfn\s+wasm_bytes_load_u8x16\(")
        self.assertIn("length - start < 16u32", source)
        for lane in range(1, 16):
            self.assertIn(f"wasm_u8x16_replace_{lane}(", source)

    def test_compilers_and_provider_do_not_own_the_algorithm(self):
        for relative in ("src/backend/starshine_program_assembly.mbt",
                         "src/semantic/wasmgc_fragment_plan.mbt",
                         "starshine-mb/src/ffi_bridge/ffi_bridge.mbt"):
            source = (ROOT / relative).read_text()
            with self.subTest(path=relative):
                self.assertNotIn('"dew_bytes_load_u8x16"', source)
                self.assertNotIn("fn starshine_text_load_u8x16_body(", source)


if __name__ == "__main__":
    unittest.main()
