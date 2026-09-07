#!/usr/bin/env python3
"""Map storage and runtime algorithms belong to the Dew library."""

import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MapBuiltinPolicyTests(unittest.TestCase):
    def test_declared_storage_and_ordinary_functions(self):
        source = (ROOT / "std/map.dew").read_text()
        self.assertIn("pub struct Map<key, value>", source)
        self.assertIn("pub struct MapEntry<key, value>", source)
        self.assertIn("WasmArray<Option<MapEntry<key, value>>>", source)
        self.assertNotRegex(source, r"\bbuiltin\b")

    def test_no_map_identity_or_operation_dispatch(self):
        registry = json.loads((ROOT / "tools/standard-builtin-registry.json").read_text())
        self.assertEqual(registry["modules"]["map"], {
            "slot": 11, "path": "dew.std.map", "operations": {},
        })
        for name in ("src/semantic/lowering_plan.mbt", "src/backend/starshine_code.mbt"):
            self.assertNotRegex((ROOT / name).read_text(), r"\bPlannedMap\w*")
        emitter = (ROOT / "self_host/compiler/starshine_module.dew").read_text()
        self.assertNotIn("EmitLinkedMap", emitter)
        runtime = (ROOT / "self_host/compiler/starshine_runtime_emit.dew").read_text()
        self.assertNotIn("fn self_host_emit_linked_map_", runtime)


if __name__ == "__main__":
    unittest.main()
