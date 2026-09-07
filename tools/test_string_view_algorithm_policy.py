#!/usr/bin/env python3
"""StringView algorithms use Dew bodies rather than compiler runtimes."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
NAMES = {"utf16_length": "utf16_length", "equals": "equals", "hash": "hash",
         "find_raw": "find", "find_string_raw": "find_string",
         "starts_with": "starts_with", "starts_with_string": "starts_with_string",
         "ends_with": "ends_with", "ends_with_string": "ends_with_string"}


class StringViewAlgorithmPolicyTests(unittest.TestCase):
    def test_library_algorithms_have_bodies(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        for name in NAMES:
            with self.subTest(name=name):
                self.assertNotRegex(source, rf"\bbuiltin\s+string_view_{name}\(")
                self.assertRegex(source, rf"\bfn\s+string_view_{name}\(")

    def test_compiler_dispatch_is_removed(self):
        for path in ("src/backend/starshine_text_runtime.mbt",
                     "src/semantic/wasmgc_fragment_plan.mbt"):
            source = (ROOT / path).read_text()
            for name in NAMES.values():
                with self.subTest(path=path, name=name):
                    self.assertNotIn(f'"dew_string_view_{name}"', source)


if __name__ == "__main__":
    unittest.main()
