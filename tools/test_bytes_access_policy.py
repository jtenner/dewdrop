"""Byte reads are Dew algorithms over declared storage and Core instructions."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BytesAccessPolicy(unittest.TestCase):
    def test_byte_access_uses_raw_array_and_lane_instructions(self):
        source = (ROOT / "std/text_runtime.dew").read_text()
        match = re.search(r"pub fn bytes_byte_at\([\s\S]*?\n}", source)
        self.assertIsNotNone(match)
        body = match.group(0)
        self.assertNotIn("__dew_text_byte_at", body)
        self.assertIn("wasm_array_get", body)

    def test_access_entry_points_are_ordinary_functions(self):
        for file, name in (("std/preamble/110-debug.dew", "__dew_text_byte_at"),
                           ("std/ordering.dew", "ordering_bytes_byte_at"),
                           ("self_host/compiler/facet_runtime.dew", "self_host_facet_bytes_byte_at")):
            with self.subTest(file=file):
                source = (ROOT / file).read_text()
                self.assertRegex(source, rf"\bfn {name}\(")
                self.assertNotIn("dew_bytes_byte_at", source)

    def test_old_runtime_dispatch_and_body_are_removed(self):
        for file in ("src/semantic/wasmgc_fragment_plan.mbt",
                     "src/backend/starshine_text_runtime.mbt",
                     "starshine-mb/src/ffi_bridge/text_runtime.mbt"):
            with self.subTest(file=file):
                source = (ROOT / file).read_text()
                self.assertNotIn('b"dew_bytes_byte_at"', source)
                self.assertNotIn("fn starshine_text_byte_at_type_body(", source)


if __name__ == "__main__":
    unittest.main()
