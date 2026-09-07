"""Integer Debug formatting belongs in Dew, not compiler runtime builders."""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KINDS = ("i8", "i16", "i32", "i64", "u8", "u16", "u32", "u64")


class DebugIntegerPolicyTests(unittest.TestCase):
    def test_integer_formatters_are_dew_functions(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        for kind in KINDS:
            with self.subTest(kind=kind):
                self.assertIsNone(re.search(rf"\bbuiltin\s+__dew_debug_{kind}\(", source))
                self.assertIsNotNone(re.search(rf"\bfn\s+__dew_debug_{kind}\(", source))

    def test_compiler_integer_formatting_is_removed(self):
        for path in ("src/backend/starshine_wasi_runtime.mbt",
                     "src/backend/starshine_text_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/wasi_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/text_runtime.mbt",
                     "src/semantic/wasmgc_fragment_plan.mbt",
                     "self_host/compiler/semantic_program_link_plan.dew"):
            source = (ROOT / path).read_text()
            with self.subTest(path=path):
                for kind in KINDS:
                    self.assertNotIn(f'"dew_debug_{kind}"', source)
                self.assertNotIn("starshine_debug_i32_body", source)
                self.assertNotIn("starshine_debug_i64_body", source)


if __name__ == "__main__":
    unittest.main()
