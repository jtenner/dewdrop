"""Runtime assertions use Dew control flow, not a multi-instruction builtin."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class ProductionAssertionPolicyTests(unittest.TestCase):
    def test_preamble_assertion_is_an_ordinary_function(self):
        source = (ROOT / "std/preamble/00-builtins.dew").read_text()
        self.assertTrue("pub builtin assert(" not in source,
                        "assert is not a one-to-one Wasm instruction")
        self.assertTrue("pub fn assert(" in source,
                        "the public runtime assertion function must remain available")

    def test_no_opaque_assertion_emission_or_intrinsic_alias(self):
        for path in ("src/backend/starshine_code.mbt",
                     "self_host/compiler/starshine_builtin_emit.dew",
                     "tools/generate_self_host_numeric_builtins.py",
                     "std/wasm/intrinsics.dew"):
            with self.subTest(path=path):
                self.assertTrue("dew_assert" not in (ROOT / path).read_text(),
                                f"opaque assertion target remains in {path}")


if __name__ == "__main__":
    unittest.main()
