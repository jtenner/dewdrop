#!/usr/bin/env python3
"""String scans and concatenation must use ordinary library bodies."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
NAMES = {"utf16_length": "utf16_length", "hash": "hash",
         "find_raw": "find", "find_view_raw": "find_view",
         "starts_with": "starts_with", "starts_with_view": "starts_with_view",
         "ends_with": "ends_with", "ends_with_view": "ends_with_view",
         "concat": "concat", "concat_view": "concat_view"}


class StringAlgorithmPolicyTests(unittest.TestCase):
    def test_library_algorithms_have_bodies(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        for name in NAMES:
            with self.subTest(name=name):
                self.assertNotRegex(source, rf"\bbuiltin\s+string_{name}\(")
                self.assertRegex(source, rf"\bfn\s+string_{name}\(")

    def test_compiler_dispatch_is_removed(self):
        for path in ("src/backend/starshine_text_runtime.mbt",
                     "src/semantic/wasmgc_fragment_plan.mbt"):
            source = (ROOT / path).read_text()
            for name in NAMES.values():
                with self.subTest(path=path, name=name):
                    self.assertNotIn(f'"dew_string_{name}"', source)


if __name__ == "__main__":
    unittest.main()
