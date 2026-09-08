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


if __name__ == "__main__":
    unittest.main()
