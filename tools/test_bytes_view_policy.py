"""Bytes ranges use declared Dew storage and raw instructions."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BytesViewPolicy(unittest.TestCase):
    def test_view_is_an_ordinary_library_function(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        self.assertIn("pub fn bytes_view(", source)
        self.assertNotIn("pub builtin bytes_view(", source)

    def test_old_runtime_dispatch_and_body_are_removed(self):
        for file in ("src/semantic/wasmgc_fragment_plan.mbt",
                     "src/backend/starshine_text_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            with self.subTest(file=file):
                source = (ROOT / file).read_text()
                self.assertNotIn('b"dew_bytes_view"', source)
                self.assertNotIn("fn starshine_bytes_view_body(", source)


if __name__ == "__main__":
    unittest.main()
