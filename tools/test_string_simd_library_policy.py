"""String SIMD access uses a Dew conversion and the shared Bytes storage path."""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class StringSimdLibraryPolicy(unittest.TestCase):
    def test_string_simd_access_has_an_ordinary_library_body(self):
        source = (ROOT / "std/wasm/intrinsics.dew").read_text()
        self.assertIsNone(re.search(r"\bbuiltin\s+wasm_string_load_u8x16\b", source))
        self.assertRegex(source, r"\bfn\s+wasm_string_load_u8x16\(")
        self.assertIn("wasm_bytes_load_u8x16(__dew_text_bytes(value), start)", source)

    def test_no_separate_string_simd_runtime_dispatch(self):
        for path in ("src/backend/starshine_text_runtime.mbt",
                     "src/semantic/wasmgc_fragment_plan.mbt",
                     "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            with self.subTest(path=path):
                self.assertFalse('"dew_string_load_u8x16"' in (ROOT / path).read_text(),
                                 f"{path}: separate String SIMD runtime remains")


if __name__ == "__main__":
    unittest.main()
