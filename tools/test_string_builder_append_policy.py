"""StringBuilder forwarding and ASCII checks belong to Dew, not runtime bodies."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
NAMES = ("string_builder_append", "string_builder_append_view", "string_builder_append_ascii")


class StringBuilderAppendPolicy(unittest.TestCase):
    def test_append_functions_have_dew_bodies(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        for name in NAMES:
            with self.subTest(function=name):
                self.assertIn(f"pub fn {name}(", source)
                self.assertNotIn(f"pub builtin {name}(", source)

    def test_old_runtime_dispatch_is_removed(self):
        for file in ("src/semantic/wasmgc_fragment_plan.mbt",
                     "src/backend/starshine_program_assembly.mbt",
                     "starshine-mb/src/ffi_bridge/ffi_bridge.mbt"):
            source = (ROOT / file).read_text()
            for name in NAMES:
                with self.subTest(file=file, function=name):
                    self.assertNotIn(f'b"dew_{name}"', source)

    def test_byte_runtime_has_no_string_or_ascii_modes(self):
        for file in ("src/backend/starshine_program_assembly.mbt",
                     "starshine-mb/src/ffi_bridge/ffi_bridge.mbt"):
            with self.subTest(file=file):
                source = (ROOT / file).read_text()
                self.assertNotIn("ascii_only", source)
                self.assertNotIn("fn starshine_text_builder_append_body(", source)


if __name__ == "__main__":
    unittest.main()
