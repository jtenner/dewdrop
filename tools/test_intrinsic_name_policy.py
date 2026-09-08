"""Instruction identity comes from metadata, not host-like source spelling."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class IntrinsicNamePolicy(unittest.TestCase):
    def test_no_implicit_wasi_call_or_signature_builder(self):
        source = (ROOT / "self_host/compiler/starshine_module.dew").read_text()
        for removed in ("self_host_linked_wasi_function_index", "EmitLinkedWasiCall",
                        "self_host_linked_append_wasi_import",
                        "self_host_linked_append_wasi_signature",
                        "self_host_linked_append_wasi_void_signature"):
            with self.subTest(name=removed):
                self.assertNotIn(removed, source)

    def test_unused_foreign_imports_follow_fragment_reachability(self):
        source = (ROOT / "self_host/compiler/semantic_program_link_plan.dew").read_text()
        self.assertNotIn("forced_wasi_import", source)


if __name__ == "__main__":
    unittest.main()
