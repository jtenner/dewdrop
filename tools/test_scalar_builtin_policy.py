"""Range policy belongs to Dew, not either compiler's instruction table."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class ScalarBuiltinPolicyTests(unittest.TestCase):
    def test_narrow_float_conversions_are_library_functions(self):
        source = (ROOT / "std/preamble/70-into-builtins.dew").read_text()
        native = (ROOT / "src/backend/starshine_conversion_builtins.mbt").read_text()
        hosted = (ROOT / "self_host/compiler/starshine_builtin_emit.dew").read_text()
        for width in [32, 64]:
            for target in ["i8", "i16", "u8", "u16"]:
                name = f"f{width}_into_{target}"
                with self.subTest(name=name):
                    self.assertIn(f"pub fn {name}(", source)
                    self.assertNotIn(f'"dew_{name}"', source)
                    self.assertNotIn(f'"dew_{name}"', native)
                    self.assertNotIn(f'"dew_{name}"', hosted)


if __name__ == "__main__":
    unittest.main()
