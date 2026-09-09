"""A module-value read cannot recover a function target from its name."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMPILER = ROOT / "self_host" / "compiler"


class GlobalReadPolicy(unittest.TestCase):
    def test_missing_globals_do_not_become_function_references(self):
        source = (COMPILER / "starshine_module.dew").read_text()
        self.assertNotIn("self_host_linked_function_reference_index(", source)
        self.assertNotIn("self_host_linked_global_initializer(", source)
        self.assertIn("self_host_required_global_initializer(link, module_, body, expression)", source)

    def test_global_lookup_checks_selected_identity(self):
        source = (COMPILER / "starshine_module_globals.dew").read_text()
        self.assertIn("self_host_checked_relative_index(", source)
        self.assertIn("initializer.declaration != declaration", source)
        self.assertIn("selected is Option::Some(_)", source)
        for forbidden in ("self_host_linked_callable_by_name(",
                          "self_host_linked_callable_function_index(",
                          "ffi_lib_Instruction_ref_func("):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, source)


if __name__ == "__main__":
    unittest.main()
