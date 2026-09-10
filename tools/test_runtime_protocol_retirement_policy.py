"""Compiler and provider APIs must not retain the removed runtime protocol."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class RuntimeProtocolRetirementPolicy(unittest.TestCase):
    def test_runtime_body_file_is_removed(self):
        self.assertFalse((ROOT / "src/backend/starshine_text_runtime.mbt").exists())
        self.assertFalse((ROOT / "starshine-mb/src/ffi_bridge/text_runtime.mbt").exists())

    def test_runtime_kind_bridge_and_lookup_tables_are_removed(self):
        for directory in ("src/semantic", "src/backend", "starshine-mb/src/ffi_bridge"):
            sources = sorted((ROOT / directory).glob("*.mbt"))
            sources += sorted((ROOT / directory).glob("*.mbti"))
            self.assertTrue(sources, directory)
            for path in sources:
                source = path.read_text()
                for name in ("PlannedWasmRuntimeFunction",
                             "emit_starshine_text_runtime_function",
                             "runtime_function_indices", "RuntimeFunctionBuilder",
                             "runtime_function_builder_new", "funcs_push_runtime"):
                    with self.subTest(path=str(path), name=name):
                        self.assertFalse(name in source, f"{path}: retired identifier {name}")


if __name__ == "__main__":
    unittest.main()
