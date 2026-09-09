#!/usr/bin/env python3
"""Option uses declared enum layouts, not compiler-owned runtime types."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMPILER = ROOT / "self_host" / "compiler"


class OptionLayoutPolicy(unittest.TestCase):
    def test_no_option_adapter_or_spelling_dispatch(self):
        for name in (
            "semantic_pattern_constructor_identity.dew",
            "semantic_wasm_body_plan.dew",
            "semantic_pattern_storage_carriers.dew",
            "semantic_call_payload_shapes.dew",
            "semantic_object_constructor_plans.dew",
            "starshine_module.dew",
        ):
            source = (COMPILER / name).read_text()
            for forbidden in ('RuntimeOption', '"Option"', '"Some"', '"None"', '".Some"', '".Option"'):
                with self.subTest(file=name, forbidden=forbidden):
                    self.assertNotIn(forbidden, source)

    def test_no_unused_option_runtime_type_group(self):
        source = (COMPILER / "starshine_runtime_emit.dew").read_text()
        for forbidden in (
            "let option_base =",
            "append_option_runtime_subtype",
            "linked_option_none_type_index",
            "linked_option_some_type_index",
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)
        arrays = (COMPILER / "semantic_raw_array_storage.dew").read_text()
        boxes = (COMPILER / "semantic_erased_field_adapters.dew").read_text()
        self.assertIn("self_host_linked_scalar_box_runtime_base(link) + 5u32", arrays)
        self.assertIn("self_host_linked_scalar_box_runtime_base(link) + offset", boxes)


if __name__ == "__main__":
    unittest.main()
