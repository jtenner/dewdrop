"""Physical variant selection uses declarations and explicit adapter metadata."""

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

    def test_runtime_constructor_adapters_do_not_dispatch_on_strings(self):
        source = SOURCE.read_text()
        start = source.index("fn self_host_linked_expression_variant_type(")
        end = source.index("\nfn ", start + 3)
        function = source[start:end]
        self.assertTrue("let adapter = match link.runtime_variant_adapters.get(variant_declaration)" in function,
                        "constructor adapter must retain its typed declaration metadata")
        self.assertTrue("let name =" not in function,
                        "constructor adapter must not turn its identity into a spelling")

    def test_body_payload_seeding_uses_adapter_identity(self):
        source = (ROOT / "self_host/compiler/semantic_wasm_body_plan.dew").read_text()
        start = source.index("fn self_host_body_seed_match_payload_binding(")
        end = source.index("\nfn ", start + 3)
        function = source[start:end]
        self.assertTrue("self_host_pattern_runtime_payload_argument(" in function,
                        "runtime payload seeding requires a selected adapter")
        for heuristic in ("self_host_linked_pattern_name(", 'ends_with(b"get")',
                          "self_host_linked_physical_function_specialization_shape_at("):
            with self.subTest(heuristic=heuristic):
                self.assertTrue(heuristic not in function,
                                f"payload seeding contains a spelling or slot guess: {heuristic}")

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
