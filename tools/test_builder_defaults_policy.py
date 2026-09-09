"""Builder defaults belong to Dew, not a second runtime constructor."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BuilderDefaultsPolicy(unittest.TestCase):
    def test_string_builder_default_is_a_dew_body(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        self.assertIn("pub fn string_builder_new() -> StringBuilder {", source)
        self.assertNotIn("pub builtin string_builder_new", source)

    def test_string_builder_default_runtime_is_removed(self):
        for relative in ("src/backend/starshine_text_runtime.mbt",
                         "src/semantic/wasmgc_fragment_plan.mbt",
                         "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            with self.subTest(path=relative):
                self.assertNotIn('"dew_string_builder_new"',
                                 (ROOT / relative).read_text())

    def test_bytes_builder_default_is_a_dew_body(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        self.assertIn("pub fn bytes_builder_new() -> BytesBuilder {", source)
        self.assertNotIn("pub builtin bytes_builder_new", source)

    def test_bytes_builder_default_runtime_is_removed(self):
        for relative in ("src/backend/starshine_text_runtime.mbt",
                         "src/semantic/wasmgc_fragment_plan.mbt",
                         "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            with self.subTest(path=relative):
                self.assertNotIn('"dew_bytes_builder_new"',
                                 (ROOT / relative).read_text())


if __name__ == "__main__":
    unittest.main()
