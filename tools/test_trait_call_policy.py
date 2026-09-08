"""An emitter cannot infer trait identity from method spelling or link order."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class TraitCallPolicyTests(unittest.TestCase):
    def source_function(self, name):
        source = (ROOT / "self_host/compiler/starshine_module.dew").read_text()
        start = source.index("fn " + name + "(")
        end = source.find("\nfn ", start + 1)
        return source[start:] if end < 0 else source[start:end]

    def test_exact_expression_results_use_the_selected_signature(self):
        source = self.source_function("self_host_linked_exact_expression_shape")
        self.assertNotIn("self_host_linked_direct_get_result_shape", source)
        self.assertNotIn("self_host_linked_unresolved_get_result_shape", source)
        self.assertNotIn("self_host_linked_method_call_index_for_receiver", source)
        self.assertNotIn("method_name", source)
        self.assertNotIn(".ends_with(", source)

    def test_result_verification_has_no_method_name_exemption(self):
        source = self.source_function("self_host_emit_linked_i32_expression")
        start = source.index("let actual = self_host_linked_physical_function_result_shape(")
        end = source.index("let tasks = []", start)
        self.assertNotIn(".ends_with(", source[start:end])

    def test_function_signature_emission_uses_the_fragment(self):
        source = self.source_function("build_self_host_linked_i32_module")
        start = source.index("let parameters = StarshineFfi.ffi_ffi_bridge_val_types_new()")
        end = source.index("let function_type = StarshineFfi.ffi_lib_CompType_func(", start)
        self.assertNotIn(".ends_with(", source[start:end])
        self.assertNotIn("self_host_linked_function_returns_array_element", source[start:end])

    def test_emitter_does_not_recover_missing_trait_targets(self):
        source = (ROOT / "self_host/compiler/starshine_module.dew").read_text()
        self.assertTrue("self_host_linked_trait_call_index(" not in source,
                        "missing trait targets must not select a same-named implementation")
        self.assertNotIn("self_host_linked_direct_get_result_shape(", source)
        self.assertNotIn("self_host_linked_direct_get_emitted_result_shape(", source)


if __name__ == "__main__":
    unittest.main()
