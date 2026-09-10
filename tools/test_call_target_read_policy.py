"""Call emission consumes saved identities, not spelling-based recovery."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMPILER = ROOT / "self_host" / "compiler"


class CallTargetReadPolicy(unittest.TestCase):
    def test_saved_target_has_no_link_lookup_fallback(self):
        source = (COMPILER / "starshine_call_targets.dew").read_text()
        for forbidden in ("self_host_linked_i32_call_index(",
                          "self_host_linked_callable_by_name(",
                          "self_host_linked_call_index_lookup("):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)
        self.assertIn("handle != recipe.physical_function", source)
        self.assertIn("target.specialization != recipe.specialization", source)

    def test_main_emitter_cannot_recover_calls_by_name(self):
        source = (COMPILER / "starshine_module.dew").read_text()
        emitter = source.split("fn self_host_emit_linked_i32_expression(", 1)[1].split("\nfn ", 1)[0]
        for forbidden in ("self_host_linked_method_call_index_for_receiver(",
                          "self_host_linked_method_call_index_for_receiver_arity(",
                          "self_host_linked_callable_by_name(",
                          'method_name == "into"'):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, emitter)
        for forbidden in ("self_host_linked_callable_by_name_and_result_nominal(",
                          "self_host_linked_callable_by_name(",
                          "self_host_linked_qualified_runtime_name(",
                          "self_host_linked_unqualified_runtime_name("):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)

    def test_operator_emission_uses_the_saved_recipe(self):
        source = (COMPILER / "starshine_module.dew").read_text()
        emitter = source.split("fn self_host_emit_linked_i32_expression(", 1)[1].split("\nfn ", 1)[0]
        operator = emitter.split("            SelfHostPlannedExpressionKind::PlannedOperatorCall(", 1)[1].split("            SelfHostPlannedExpressionKind::PlannedBuiltinCall(", 1)[0]
        self.assertIn("self_host_linked_schedule_frozen_call(", operator)
        self.assertNotIn("EmitLinkedI32Call(", operator)
        self.assertNotIn("self_host_linked_i32_schedule_expression(", operator)
        planner = (COMPILER / "semantic_wasm_body_plan.dew").read_text()
        self.assertNotIn("PlannedOperatorCall(_, _, _, _, values) => values", planner)

    def test_self_host_calls_do_not_spread_tuple_arguments(self):
        for filename in ("starshine_module.dew", "semantic_wasm_body_plan.dew"):
            source = (COMPILER / filename).read_text()
            with self.subTest(filename=filename):
                self.assertNotIn("flatten_product", source)
                self.assertNotIn("self_host_linked_i32_push_physical_arguments(", source)


if __name__ == "__main__":
    unittest.main()
