"""BytesBuilder storage algorithms belong to Dew, not compiler emitters."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
OPERATIONS = ("with_capacity", "append", "append_byte", "finish")


class BytesBuilderStoragePolicy(unittest.TestCase):
    def test_operations_have_dew_bodies(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        for operation in OPERATIONS:
            name = "bytes_builder_" + operation
            if operation == "with_capacity":
                name += "_raw"
            with self.subTest(operation=operation):
                self.assertIn(f"pub fn {name}(", source)
                self.assertNotIn(f"pub builtin {name}(", source)

    def test_storage_is_declared_and_growth_uses_core_array_copy(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        self.assertIn("struct BytesBuilderStorage {", source)
        self.assertIn("mut chunks: WasmArray<V128>", source)
        self.assertIn("wasm_array_copy(", source)

    def test_runtime_entries_are_removed(self):
        for path in ("src/semantic/wasmgc_fragment_plan.mbt",
                     "src/backend/starshine_text_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            source = (ROOT / path).read_text()
            for operation in OPERATIONS:
                with self.subTest(path=path, operation=operation):
                    self.assertNotIn(f'b"dew_bytes_builder_{operation}"', source)

    def test_facet_uses_library_calls(self):
        source = (ROOT / "self_host/compiler/facet_runtime.dew").read_text()
        for operation in OPERATIONS:
            self.assertNotIn(f'"dew_bytes_builder_{operation}"', source)


if __name__ == "__main__":
    unittest.main()
