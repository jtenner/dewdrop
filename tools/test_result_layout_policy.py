#!/usr/bin/env python3
"""Result storage must come from its Dew enum declaration."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMPILER = ROOT / "self_host" / "compiler"


class ResultLayoutPolicy(unittest.TestCase):
    def test_no_result_adapter_or_spelling_dispatch(self):
        self.assertFalse((COMPILER / "semantic_runtime_variant_adapters.dew").exists())
        for name in (
            "semantic_pattern_constructor_identity.dew",
            "semantic_variant_payload_storage.dew",
            "semantic_wasm_body_plan.dew",
            "semantic_pattern_storage_carriers.dew",
            "starshine_call_result_shapes.dew",
            "semantic_program_link_plan.dew",
            "starshine_module.dew",
        ):
            source = (COMPILER / name).read_text()
            for forbidden in (
                "runtime_variant_adapters", "RuntimeResult",
                '"Result"', '"Ok"', '"Err"', '".Result"', '".Ok"', '".Err"',
                "EmitLinkedResultErrorIdentity",
            ):
                with self.subTest(file=name, forbidden=forbidden):
                    self.assertNotIn(forbidden, source)

    def test_no_unused_result_runtime_types(self):
        source = (COMPILER / "starshine_runtime_emit.dew").read_text()
        for forbidden in (
            "result_runtime_base", "let result_base =",
            "append_runtime_variant_subtype",
            "append_result_error_runtime_subtype",
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)
        self.assertIn("self_host_linked_array_runtime_base(link) + 9u32", source)


if __name__ == "__main__":
    unittest.main()
