"""Wasm local declarations and expression reads use frozen carriers only."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMPILER = ROOT / "self_host" / "compiler"


class LocalDeclarationPolicy(unittest.TestCase):
    def test_expression_reads_do_not_recover_from_source_shapes_or_names(self):
        source = (COMPILER / "starshine_expression_values.dew").read_text()
        for forbidden in ("self_host_linked_expression_emits_value(",
                          "self_host_linked_callable_by_name(",
                          "self_host_linked_function_has_result("):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)
        self.assertIn("self_host_body_plan_expression(plan, expression)", source)
        self.assertIn("declaration: plan.declaration", source)

    def test_emitter_readers_share_the_checked_carrier_reader(self):
        source = (COMPILER / "starshine_module.dew").read_text()
        for name in ("self_host_linked_exact_emitted_expression_carrier",
                     "self_host_linked_logical_operand_carrier"):
            with self.subTest(reader=name):
                marker = f"fn {name}("
                self.assertIn(marker, source)
                function = source.split(marker, 1)[1].split("\nfn ", 1)[0]
                self.assertIn("self_host_linked_planned_expression_carrier(", function)
                for forbidden in ("while ", "match ", ".shape", ".source_name"):
                    self.assertNotIn(forbidden, function)

    def test_removed_expression_recovery_does_not_return(self):
        source = (COMPILER / "starshine_module.dew").read_text()
        for name in ("canonical_or_declared_local_carrier", "concrete_shape_carrier",
                     "static_expression_carrier", "canonical_or_static_expression_carrier",
                     "canonical_field_carrier", "canonical_branch_expected_carrier"):
            with self.subTest(helper=name):
                self.assertNotIn(f"self_host_linked_{name}(", source)

    def test_physical_shapes_use_the_checked_carrier_reader(self):
        source = (COMPILER / "starshine_expression_values.dew").read_text()
        function = source.split("fn self_host_linked_planned_expression_shape(", 1)[1].split("\nfn ", 1)[0]
        self.assertIn("self_host_linked_planned_expression_carrier(", function)
        self.assertNotIn("inferred", function)
        source = (COMPILER / "starshine_module.dew").read_text()
        for name in ("canonical_or_inferred_shape", "single_nested_special_match_result_shape",
                     "scoped_match_result_shape", "match_only_binding_falls_through",
                     "match_direct_binding_declared_shape"):
            with self.subTest(helper=name):
                self.assertNotIn(f"self_host_linked_{name}(", source)
        for name in ("inferred_final_match_result_shape", "fallback_selected_match_result_shape",
                     "recovered_match_result_shape"):
            self.assertNotIn(name, source)

    def test_local_declarations_do_not_recover_source_shapes(self):
        source = (COMPILER / "starshine_local_declarations.dew").read_text()
        for forbidden in ("self_host_physical_scalar_shape(",
                          "self_host_body_carrier_shape(",
                          "self_host_linked_local_initializer_shape(",
                          "self_host_linked_local_is_erased(",
                          "self_host_linked_callable_by_name("):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)
        self.assertIn("FuncRefBodyCarrier => self_host_linked_funcref_value_type()", source)
        self.assertIn("plan.local_slots[ordinal] != expected_slot", source)
        self.assertIn("physical_count != plan.physical_local_count", source)

    def test_removed_local_recovery_does_not_return(self):
        source = (COMPILER / "starshine_module.dew").read_text()
        for forbidden in ("fn self_host_linked_scalar_locals(",
                          "self_host_linked_scalar_append_local_type(",
                          "self_host_linked_scalar_local_carrier(",
                          "self_host_linked_local_canonical_map_payload_shape(",
                          "self_host_linked_map_match_binding_shape(",
                          "self_host_linked_map_match_initializer_shape("):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)

    def test_local_slot_reads_do_not_infer_erasure_from_shapes(self):
        source = (COMPILER / "starshine_physical_locals.dew").read_text()
        for forbidden in ("self_host_capture_has_value(",
                          "self_host_linked_body_parameter_offset(",
                          "self_host_linked_physical_local_count("):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)
        self.assertIn("self_host_local_declaration_plan(canonical, module_, body)", source)
        self.assertIn("slot < environment || slot >= limit", source)


if __name__ == "__main__":
    unittest.main()
