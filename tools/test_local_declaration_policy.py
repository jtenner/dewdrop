"""Wasm local declarations consume frozen physical carriers only."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMPILER = ROOT / "self_host" / "compiler"


class LocalDeclarationPolicy(unittest.TestCase):
    def test_discard_reads_do_not_recover_from_source_shapes_or_names(self):
        source = (COMPILER / "starshine_physical_locals.dew").read_text()
        for forbidden in ("self_host_linked_expression_emits_value(",
                          "self_host_linked_callable_by_name(",
                          "self_host_linked_function_has_result("):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)
        self.assertIn("self_host_body_plan_expression(plan, expression)", source)

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
