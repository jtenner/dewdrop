"""Debug dispatch and result discard are ordinary Dew functions."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class DebugDispatchPolicyTests(unittest.TestCase):
    def test_library_dispatch(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        self.assertIn("pub fn debug<t: Debug>(value: t) -> Unit {\n  value.debug()\n}", source)
        self.assertIn("fn __dew_debug_ignore(value: U32) -> Unit {}", source)
        self.assertIn('foreign import "wasi_snapshot_preview1" as DebugOutput {', source)

    def test_removed_compiler_targets(self):
        for directory, suffix in [("std", "*.dew"), ("self_host/compiler", "*.dew"),
                                  ("src", "*.mbt")]:
            for path in (ROOT / directory).rglob(suffix):
                with self.subTest(path=path.relative_to(ROOT)):
                    source = path.read_text()
                    self.assertNotIn('"dew_debug_dispatch', source)
                    self.assertNotIn('"dew_debug_ignore', source)
        generator = (ROOT / "tools/generate_self_host_numeric_builtins.py").read_text()
        self.assertNotIn('"dew_debug_dispatch"', generator)
        self.assertNotIn('"dew_debug_ignore"', generator)


if __name__ == "__main__":
    unittest.main()
