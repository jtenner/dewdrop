#!/usr/bin/env python3
"""String scans and concatenation must use ordinary library bodies."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
NAMES = {"byte_length": "byte_length", "byte_at": "byte_at",
         "equals": "equals", "utf16_length": "utf16_length", "hash": "hash",
         "find_raw": "find", "find_view_raw": "find_view",
         "starts_with": "starts_with", "starts_with_view": "starts_with_view",
         "ends_with": "ends_with", "ends_with_view": "ends_with_view",
         "concat": "concat", "concat_view": "concat_view"}


class StringAlgorithmPolicyTests(unittest.TestCase):
    def test_library_algorithms_have_bodies(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        for name in NAMES:
            with self.subTest(name=name):
                self.assertIsNone(re.search(rf"\bbuiltin\s+string_{name}\(", source), f"string_{name} must not be a builtin")
                self.assertIsNotNone(re.search(rf"\bfn\s+string_{name}\(", source), f"string_{name} must have a Dew body")

    def test_compiler_dispatch_is_removed(self):
        for path in ("src/backend/starshine_text_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/text_runtime.mbt",
                     "src/semantic/wasmgc_fragment_plan.mbt"):
            source = (ROOT / path).read_text()
            for name in NAMES.values():
                with self.subTest(path=path, name=name):
                    self.assertFalse(f'"dew_string_{name}"' in source, f"{path}: obsolete String {name} dispatch")

    def test_provider_does_not_keep_unused_string_wrappers(self):
        source = (ROOT / "starshine-mb/src/ffi_bridge/text_runtime.mbt").read_text()
        for name in ("starshine_text_concat_body", "starshine_utf16_length_body",
                     "starshine_text_equals_body", "starshine_text_length_body",
                     "starshine_text_byte_at_body"):
            with self.subTest(name=name):
                self.assertTrue(name not in source, f"provider retains obsolete {name}")

    def test_string_patterns_do_not_resolve_a_runtime_name(self):
        for path in ("src/backend/starshine_code.mbt",
                     "src/semantic/program_specialization_plan.mbt",
                     "self_host/compiler/starshine_module.dew",
                     "self_host/compiler/semantic_nested_pattern_emit.dew",
                     "self_host/compiler/semantic_model.dew",
                     "self_host/compiler/request.dew",
                     "self_host/compiler/tokenizer.dew",
                     "self_host/compiler/main.dew"):
            with self.subTest(path=path):
                self.assertFalse('"dew_string_equals"' in (ROOT / path).read_text(), f"{path}: obsolete String equality runtime lookup")

    def test_string_access_does_not_use_runtime_shortcuts(self):
        for path in ("std/ordering.dew", "std/text.dew",
                     "self_host/compiler/facet_runtime.dew",
                     "self_host/compiler/starshine_module.dew"):
            source = (ROOT / path).read_text()
            for name in ("byte_length", "byte_at"):
                with self.subTest(path=path, name=name):
                    self.assertFalse(f'"dew_string_{name}"' in source,
                                     f"{path}: obsolete String access builtin")
        self.assertFalse("self_host_linked_primitive_text_runtime_name" in
                         (ROOT / "self_host/compiler/starshine_module.dew").read_text(),
                         "String methods must use their selected declaration")


if __name__ == "__main__":
    unittest.main()
