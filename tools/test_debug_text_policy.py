"""Text Debug formatting must be a Dew algorithm, not a runtime builder."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DebugTextPolicyTests(unittest.TestCase):
    def test_bytes_formatter_is_a_dew_function(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        self.assertRegex(source, r"(?m)^pub fn __dew_debug_bytes\(")
        self.assertNotRegex(source, r"(?m)^(?:pub )?builtin __dew_debug_bytes\(")

    def test_private_formatter_and_write_builders_are_removed(self):
        for path in ["src/backend/starshine_wasi_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/wasi_runtime.mbt"]:
            with self.subTest(path=path):
                self.assertFalse((ROOT / path).exists(), "obsolete runtime file remains")

    def test_string_formatter_is_a_dew_function(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        self.assertRegex(source, r"(?m)^pub fn __dew_debug_string\(")
        self.assertNotRegex(source, r"(?m)^(?:pub )?builtin __dew_debug_string\(")

    def test_text_runtime_entries_are_removed(self):
        for path in [
            "src/backend/starshine_program_assembly.mbt",
            "starshine-mb/src/ffi_bridge/ffi_bridge.mbt",
            "src/semantic/wasmgc_fragment_plan.mbt",
            "self_host/compiler/semantic_program_link_plan.dew",
        ]:
            with self.subTest(path=path):
                source = (ROOT / path).read_text()
                self.assertNotIn('"dew_debug_string"', source)
                self.assertNotIn('"dew_debug_bytes"', source)


if __name__ == "__main__":
    unittest.main()
