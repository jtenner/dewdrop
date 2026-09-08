#!/usr/bin/env python3
"""StringView algorithms use Dew bodies rather than compiler runtimes."""
from pathlib import Path
import unittest
import re

ROOT = Path(__file__).resolve().parents[1]
NAMES = {"byte_length": "byte_length", "byte_at": "byte_at", "to_string": "to_string",
         "utf16_length": "utf16_length", "equals": "equals", "hash": "hash",
         "find_raw": "find", "find_string_raw": "find_string",
         "starts_with": "starts_with", "starts_with_string": "starts_with_string",
         "ends_with": "ends_with", "ends_with_string": "ends_with_string"}


class StringViewAlgorithmPolicyTests(unittest.TestCase):
    def test_library_algorithms_have_bodies(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        for name in NAMES:
            with self.subTest(name=name):
                self.assertIsNone(re.search(rf"\bbuiltin\s+string_view_{name}\(", source), f"string_view_{name} must not be a builtin")
                self.assertIsNotNone(re.search(rf"\bfn\s+string_view_{name}\(", source), f"string_view_{name} must have a Dew body")

    def test_compiler_dispatch_is_removed(self):
        for path in ("src/backend/starshine_text_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/text_runtime.mbt",
                     "src/semantic/wasmgc_fragment_plan.mbt"):
            source = (ROOT / path).read_text()
            for name in NAMES.values():
                with self.subTest(path=path, name=name):
                    self.assertFalse(f'"dew_string_view_{name}"' in source, f"{path}: obsolete StringView {name} dispatch")

    def test_provider_does_not_keep_unused_text_algorithms(self):
        source = (ROOT / "starshine-mb/src/ffi_bridge/text_runtime.mbt").read_text()
        for name in ("starshine_utf16_length_type_body", "starshine_text_equals_type_body",
                     "starshine_text_find_body", "starshine_text_affix_body",
                     "starshine_text_hash_body", "text_verify_bytes_candidate",
                     "text_set_byte_local", "text_false_return"):
            with self.subTest(name=name):
                self.assertTrue(name not in source, f"provider retains obsolete {name}")

    def test_access_helpers_use_library_calls(self):
        for path in ("std/ordering.dew", "std/text.dew",
                     "self_host/compiler/semantic_physical_specialization_test.dew"):
            source = (ROOT / path).read_text()
            for name in ("byte_length", "byte_at", "to_string"):
                with self.subTest(path=path, name=name):
                    self.assertFalse(f"dew_string_view_{name}" in source, f"{path}: obsolete StringView access builtin")


if __name__ == "__main__":
    unittest.main()
