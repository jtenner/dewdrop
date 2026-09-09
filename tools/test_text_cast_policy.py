"""Text conversion uses a declared raw cast, not a named runtime body."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class TextCastPolicy(unittest.TestCase):
    def test_view_bytes_uses_raw_cast(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        self.assertIn('pub builtin string_view_as_bytes_unchecked(value: StringView) -> Bytes = "ref.cast"', source)

    def test_view_bytes_runtime_is_removed(self):
        for relative in ("src/backend/starshine_text_runtime.mbt",
                         "src/semantic/wasmgc_fragment_plan.mbt",
                         "self_host/compiler/starshine_runtime_emit.dew",
                         "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            with self.subTest(path=relative):
                self.assertNotIn('"dew_string_view_as_bytes"',
                                 (ROOT / relative).read_text())

    def test_string_bytes_uses_raw_cast(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        self.assertIn('pub builtin __dew_text_bytes(value: String) -> Bytes = "ref.cast"', source)

    def test_string_bytes_runtime_is_removed(self):
        for relative in ("src/backend/starshine_text_runtime.mbt",
                         "src/semantic/wasmgc_fragment_plan.mbt",
                         "self_host/compiler/starshine_runtime_emit.dew",
                         "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            with self.subTest(path=relative):
                self.assertNotIn('"dew_string_as_bytes"',
                                 (ROOT / relative).read_text())


if __name__ == "__main__":
    unittest.main()
