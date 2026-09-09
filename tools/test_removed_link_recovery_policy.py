"""Removed private linker recovery helpers must not return."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
REMOVED = (
    "self_host_linked_runtime_function_index_for_carrier",
    "self_host_linked_runtime_function_index_for_carriers",
    "self_host_linked_import_function_index",
    "self_host_linked_emitted_i32_function_index",
    "self_host_linked_default_conversion_target",
    "self_host_linked_root_expression_identity",
    "self_host_linked_call_target_runtime_receiver",
    "self_host_linked_type_has_physical_fields",
    "self_host_linked_constructor_field_names_match",
    "self_host_linked_canonical_call_result_is_unit",
    "self_host_linked_append_function_shape_candidates",
    "self_host_linked_expression_specialized_shape",
    "self_host_linked_variant_first_payload_expression",
    "self_host_linked_named_variant_count",
    "self_host_linked_named_variant_at",
    "self_host_linked_variant_payload_shape_at",
    "self_host_linked_type_field_count",
    "self_host_linked_module_field_name",
    "self_host_linked_body_count",
    "self_host_linked_body_at",
    "self_host_linked_i32_main_expression",
    "self_host_linked_array_literal_receiver_element_shape",
    "self_host_linked_is_unresolved_iterator_next",
    "self_host_linked_is_unresolved_map_contains_key",
    "self_host_linked_is_direct_map_get_candidate",
    "self_host_linked_array_push_item_expected_nominal",
    "self_host_linked_unresolved_call_first_argument_shape",
    "self_host_linked_let_value_usage_shape",
    "self_host_linked_let_value_nominal",
    "self_host_linked_match_uses_reference_patterns",
    "self_host_linked_call_base_has_no_struct_layout",
    "self_host_linked_call_target_module_id",
    "self_host_linked_call_returns_generic_ref",
    "self_host_linked_specialized_function_index_for_carriers",
    "self_host_linked_qualified_owner_name",
    "self_host_linked_missing_call_error",
    "self_host_linked_physical_type_owner_module_id",
    "self_host_linked_scalar_storage_value_type",
    "self_host_linked_lowering_module_count",
    "self_host_linked_lambda_closure_type_count",
    "self_host_linked_lambda_closure_type_at",
    "self_host_linked_resolved_first_type_argument_shape",
    "self_host_linked_callable_receiver_nominal_declaration",
    "self_host_linked_canonical_pattern_local_container_owner_module_id",
    "self_host_linked_expression_expected_nominal",
    "self_host_body_wrapped_local_get",
)


class RemovedLinkRecoveryPolicy(unittest.TestCase):
    def test_removed_helpers_have_no_compiler_definitions_or_calls(self):
        names = set(REMOVED)
        for path in (ROOT / "self_host" / "compiler").glob("*.dew"):
            found = names.intersection(re.findall(r"\bself_host_\w+\b", path.read_text()))
            with self.subTest(path=path.name):
                self.assertEqual(sorted(found), [], "removed private recovery is present")


if __name__ == "__main__":
    unittest.main()
