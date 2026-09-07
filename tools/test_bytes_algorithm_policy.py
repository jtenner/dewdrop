#!/usr/bin/env python3
"""Bytes algorithms must be ordinary Dew functions, not runtime builtins."""

from pathlib import Path
import unittest
import re

ROOT = Path(__file__).resolve().parents[1]


class BytesAlgorithmPolicyTests(unittest.TestCase):
    def test_algorithms_are_not_builtins(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        for name in ("bytes_is_valid_utf8", "bytes_equals", "bytes_hash",
                     "bytes_find_byte_raw", "bytes_find_raw",
                     "bytes_starts_with", "bytes_ends_with", "bytes_to_string", "bytes_concat"):
            with self.subTest(name=name):
                self.assertIsNone(re.search(rf"\bbuiltin\s+{name}\(", source), f"{name} must not be a builtin")
                self.assertIsNotNone(re.search(rf"\bfn\s+{name}\(", source), f"{name} must have a Dew body")

    def test_native_algorithm_dispatch_is_removed(self):
        paths = ("src/backend/starshine_text_runtime.mbt",
                 "src/semantic/wasmgc_fragment_plan.mbt",
                 "src/semantic/program_specialization_plan.mbt")
        names = ("is_valid_utf8", "to_string", "equals", "hash",
                 "find_byte", "find", "starts_with", "ends_with", "concat")
        for path in paths:
            source = (ROOT / path).read_text()
            for name in names:
                with self.subTest(path=path, name=name):
                    self.assertFalse(f'"dew_bytes_{name}"' in source, f"{path}: obsolete Bytes {name} dispatch")


if __name__ == "__main__":
    unittest.main()
