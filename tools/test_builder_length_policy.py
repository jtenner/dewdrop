"""Builder lifetime checks belong to Dew, not opaque runtime functions."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BuilderLengthPolicy(unittest.TestCase):
    def test_string_builder_length_is_a_dew_body(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        self.assertIn("pub fn string_builder_byte_length(value: StringBuilder) -> U32 {", source)
        self.assertNotIn("pub builtin string_builder_byte_length", source)
        self.assertIn('builtin string_builder_length_raw(value: StringBuilder) -> U32 = "struct.get 1"', source)
        self.assertIn('builtin string_builder_consumed_raw(value: StringBuilder) -> U32 = "struct.get 2"', source)

    def test_string_builder_runtime_entry_and_shared_helper_are_removed(self):
        for relative in ("src/backend/starshine_text_runtime.mbt",
                         "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            with self.subTest(path=relative):
                source = (ROOT / relative).read_text()
                self.assertNotIn('"dew_string_builder_byte_length"', source)
                self.assertNotIn("fn starshine_text_builder_length_body(", source)
        self.assertNotIn('"dew_string_builder_byte_length"',
                         (ROOT / "src/semantic/wasmgc_fragment_plan.mbt").read_text())

    def test_bytes_builder_length_is_a_dew_body(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        self.assertIn("pub fn bytes_builder_byte_length(value: BytesBuilder) -> U32 {", source)
        self.assertNotIn("pub builtin bytes_builder_byte_length", source)
        self.assertIn('builtin bytes_builder_length_raw(value: BytesBuilder) -> U32 = "struct.get 1"', source)
        self.assertIn('builtin bytes_builder_consumed_raw(value: BytesBuilder) -> U32 = "struct.get 2"', source)

    def test_bytes_builder_runtime_entry_is_removed(self):
        for relative in ("src/backend/starshine_text_runtime.mbt",
                         "src/semantic/wasmgc_fragment_plan.mbt",
                         "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            with self.subTest(path=relative):
                self.assertNotIn('"dew_bytes_builder_byte_length"', (ROOT / relative).read_text())


if __name__ == "__main__":
    unittest.main()
