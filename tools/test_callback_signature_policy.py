"""Callback signatures retain target types and complete failure context."""

from pathlib import Path
import unittest


COMPILER = Path(__file__).resolve().parents[1] / "self_host" / "compiler"


class CallbackSignaturePolicy(unittest.TestCase):
    def test_result_recovery_helper_is_removed(self):
        for name in ("semantic_function_value_signatures.dew", "starshine_module.dew"):
            with self.subTest(file=name):
                source = (COMPILER / name).read_text()
                self.assertNotIn("self_host_linked_function_value_result_shape(", source)
                self.assertNotIn("self_host_linked_function_value_argument_shape(", source)

    def test_signature_failures_have_numeric_context(self):
        source = (COMPILER / "semantic_function_value_signatures.dew").read_text()
        self.assertNotIn("self_host_assert_compiler_invariant(", source)
        self.assertIn("self_host_call_read_failure(module_.module_id, scope.declaration, scope.body,", source)

    def test_result_metadata_comes_from_the_target_signature(self):
        source = (COMPILER / "semantic_function_value_signatures.dew").read_text()
        self.assertIn("let result_shape = match self_host_linked_append_body_function_signature(", source)
        self.assertIn("self_host_body_carrier_equal(expected, actual)", source)
        self.assertIn("self_host_array_span_is_valid(span.start, span.length, length)", source)


if __name__ == "__main__":
    unittest.main()
