"""Physical variant selection uses source declarations, not runtime adapters."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "self_host/compiler/starshine_module.dew"


class VariantLookupPolicyTests(unittest.TestCase):
    def test_obsolete_global_variant_searches_are_removed(self):
        source = SOURCE.read_text()
        for name in ("self_host_linked_variant_type_by_name(",
                     "self_host_linked_variant_type_by_name_and_arity(",
                     "self_host_linked_variant_type_by_owner_name_and_arity("):
            with self.subTest(helper=name):
                self.assertTrue(name not in source,
                                f"obsolete physical variant name search: {name}")

    def test_variant_constructors_use_declared_fragments(self):
        source = SOURCE.read_text()
        self.assertNotIn("fn self_host_linked_expression_variant_type(", source)
        self.assertNotIn("fn self_host_linked_schedule_variant_arguments(", source)
        self.assertNotIn("fn self_host_linked_zero_arity_variant_type(", source)
        self.assertIn("self_host_schedule_planned_variant_constructor(", source)
        planner = (ROOT / "self_host/compiler/semantic_variant_constructor_plans.dew").read_text()
        self.assertIn("let type_index = value.selected_type_index", planner)
        self.assertIn("WasmVariantPayloadField(selected, ordinal)", planner)
        self.assertNotIn("let name =", planner)
        emitter = (ROOT / "self_host/compiler/starshine_variant_constructor_recipes.dew").read_text()
        for forbidden in ("self_host_linked_variant_type_index(",
                          "self_host_linked_exact_emitted_expression_carrier(",
                          "self_host_linked_nominal_field_type_index(",
                          "self_host_linked_variant_payload_box_type("):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, emitter)
        self.assertIn("EmitLinkedStructNew(recipe.physical_type", emitter)
        self.assertIn("operand.expression", emitter)

    def test_runtime_only_payload_seeding_is_removed(self):
        source = (ROOT / "self_host/compiler/semantic_wasm_body_plan.dew").read_text()
        self.assertNotIn("self_host_body_seed_match_payload_binding(", source)
        self.assertNotIn("self_host_pattern_runtime_payload_argument(", source)
        self.assertIn("self_host_body_pattern_payload_value(", source,
                      "ordinary source payload planning remains required")

    def test_missing_payload_does_not_use_a_variant_spelling(self):
        source = (ROOT / "self_host/compiler/semantic_wasm_body_plan.dew").read_text()
        start = source.index("fn self_host_body_pattern_payload_value(")
        end = source.index("\nfn ", start + 3)
        function = source[start:end]
        for heuristic in ("self_host_linked_declaration_name(", "ends_with(",
                          "pattern_type_arguments["):
            with self.subTest(heuristic=heuristic):
                self.assertFalse(heuristic in function,
                                 f"missing payload evidence uses a spelling or slot guess: {heuristic}")

    def test_exact_call_payload_uses_the_declared_result(self):
        source = SOURCE.read_text()
        start = source.index("fn self_host_linked_exact_call_result_payload_shape(")
        end = source.index("\nfn ", start + 3)
        function = source[start:end]
        self.assertTrue("self_host_linked_physical_result_argument_shape(" in function,
                        "exact call payloads require the selected result type")
        self.assertTrue("self_host_linked_physical_function_specialization_shape_at(" not in function,
                        "a fixed specialization slot does not prove a result payload")


if __name__ == "__main__":
    unittest.main()
