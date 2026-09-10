"""Bytes length is one checked Wasm field read, not a runtime algorithm."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BytesLengthPolicy(unittest.TestCase):
    def test_preamble_uses_the_raw_field_instruction(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        self.assertIn('pub builtin __dew_text_byte_length(value: Bytes) -> U32 = "struct.get 2"', source)

    def test_library_and_facet_do_not_declare_the_legacy_operation(self):
        for relative in ("std/ordering.dew", "std/text_runtime.dew", "self_host/compiler/facet_runtime.dew"):
            with self.subTest(path=relative):
                self.assertNotIn('"dew_bytes_byte_length"', (ROOT / relative).read_text())

    def test_both_runtime_builders_remove_the_old_entry_and_helper(self):
        for relative in ("src/backend/starshine_program_assembly.mbt", "starshine-mb/src/ffi_bridge/ffi_bridge.mbt"):
            with self.subTest(path=relative):
                source = (ROOT / relative).read_text()
                self.assertNotIn('"dew_bytes_byte_length"', source)
                self.assertNotIn("fn starshine_text_length_type_body(", source)

    def test_native_fragment_registry_removes_the_old_entry(self):
        self.assertNotIn('"dew_bytes_byte_length"', (ROOT / "src/semantic/wasmgc_fragment_plan.mbt").read_text())


if __name__ == "__main__":
    unittest.main()
