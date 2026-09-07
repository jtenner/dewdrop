#!/usr/bin/env python3
"""Bytes algorithms must be ordinary Dew functions, not runtime builtins."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BytesAlgorithmPolicyTests(unittest.TestCase):
    def test_algorithms_are_not_builtins(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        for name in ("bytes_is_valid_utf8", "bytes_equals", "bytes_hash",
                     "bytes_find_byte_raw", "bytes_find_raw",
                     "bytes_starts_with", "bytes_ends_with", "bytes_to_string"):
            with self.subTest(name=name):
                self.assertNotRegex(source, rf"\bbuiltin\s+{name}\(")
                self.assertRegex(source, rf"\bfn\s+{name}\(")

    def test_native_algorithm_dispatch_is_removed(self):
        paths = ("src/backend/starshine_text_runtime.mbt",
                 "src/semantic/wasmgc_fragment_plan.mbt",
                 "src/semantic/program_specialization_plan.mbt")
        names = ("is_valid_utf8", "to_string", "equals", "hash",
                 "find_byte", "find", "starts_with", "ends_with")
        for path in paths:
            source = (ROOT / path).read_text()
            for name in names:
                with self.subTest(path=path, name=name):
                    self.assertNotIn(f'"dew_bytes_{name}"', source)


if __name__ == "__main__":
    unittest.main()
