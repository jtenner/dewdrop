"""StringBuilder construction, encoding, and finish must be Dew functions."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
OPERATIONS = ("with_capacity", "append_scalar", "finish")


class StringBuilderStoragePolicy(unittest.TestCase):
    def test_operations_have_dew_bodies(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        for operation in OPERATIONS:
            name = "string_builder_" + operation
            if operation == "with_capacity":
                name += "_raw"
            with self.subTest(operation=operation):
                self.assertIn(f"pub fn {name}(", source)
                self.assertNotIn(f"pub builtin {name}(", source)

    def test_old_runtime_entries_and_encoding_body_are_removed(self):
        for path in ("src/semantic/wasmgc_fragment_plan.mbt",
                     "src/backend/starshine_text_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            source = (ROOT / path).read_text()
            for operation in OPERATIONS:
                with self.subTest(path=path, operation=operation):
                    self.assertNotIn(f'b"dew_string_builder_{operation}"', source)
            self.assertNotIn("fn starshine_string_builder_append_scalar_body(", source)

    def test_no_stdlib_runtime_algorithm_builtin_remains(self):
        for path in (ROOT / "std").rglob("*.dew"):
            # Include multiline declarations, not just one-line generated files.
            for opcode in re.findall(
                r'^\s*(?:pub\s+)?builtin\s+\w+[^=]*=\s*"([^\"]+)"',
                path.read_text(), re.MULTILINE,
            ):
                with self.subTest(path=str(path), opcode=opcode):
                    self.assertFalse(opcode.startswith("dew_"))


if __name__ == "__main__":
    unittest.main()
