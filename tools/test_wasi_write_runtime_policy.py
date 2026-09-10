"""WASI Bytes writes belong to Dew, including provider-side legacy copies."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class WasiWriteRuntimePolicyTests(unittest.TestCase):
    def test_no_old_write_builtin_declaration(self):
        source = (ROOT / "std/preamble/110-debug.dew").read_text()
        self.assertTrue("dew_wasi_fd_write" not in source,
                        "Debug must not retain the unused opaque Bytes write builtin")

    def test_compiler_owned_write_files_are_removed(self):
        for path in ("src/backend/starshine_wasi_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/wasi_runtime.mbt"):
            with self.subTest(path=path):
                self.assertFalse((ROOT / path).exists(),
                                 f"obsolete write and formatting builders remain in {path}")

    def test_no_legacy_write_dispatch_or_dependency_roots(self):
        for path in ("src/backend/starshine_module_assembly.mbt",
                     "src/backend/starshine_program_assembly.mbt",
                     "src/semantic/wasmgc_fragment_plan.mbt",
                     "src/semantic/program_specialization_plan.mbt",
                     "self_host/compiler/semantic_program_link_plan.dew",
                     "starshine-mb/src/ffi_bridge/ffi_bridge.mbt"):
            with self.subTest(path=path):
                self.assertTrue("dew_wasi_fd_write" not in (ROOT / path).read_text(),
                                f"legacy write dispatch remains in {path}")

    def test_derive_does_not_generate_the_removed_write_call(self):
        for path in ("src/parser/derive.mbt",
                     "self_host/compiler/parser_derive_format.dew"):
            with self.subTest(path=path):
                self.assertTrue('"__dew_debug_write"' not in (ROOT / path).read_text(),
                                f"derive still generates a removed transport call in {path}")


if __name__ == "__main__":
    unittest.main()
