"""Text Debug formatting must be a Dew algorithm, not a runtime builder."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DebugTextPolicyTests(unittest.TestCase):
    def test_string_formatter_is_a_dew_function(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        self.assertRegex(source, r"(?m)^pub fn __dew_debug_string\(")
        self.assertNotRegex(source, r"(?m)^(?:pub )?builtin __dew_debug_string\(")

    def test_string_runtime_entry_is_removed(self):
        for path in [
            "src/backend/starshine_text_runtime.mbt",
            "starshine-mb/src/ffi_bridge/text_runtime.mbt",
            "src/semantic/wasmgc_fragment_plan.mbt",
            "self_host/compiler/semantic_program_link_plan.dew",
        ]:
            with self.subTest(path=path):
                self.assertNotIn('"dew_debug_string"', (ROOT / path).read_text())


if __name__ == "__main__":
    unittest.main()
