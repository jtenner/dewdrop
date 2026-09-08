#!/usr/bin/env python3
"""Map storage and runtime algorithms belong to the Dew library."""

import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MapBuiltinPolicyTests(unittest.TestCase):
    def test_provider_has_no_old_map_or_array_layout(self):
        for path in (ROOT / "starshine-mb/src/ffi_bridge").glob("*.mbt"):
            if path.name.endswith("test.mbt"):
                continue
            source = path.read_text()
            for name in ("dew_map_", "bridge_map_", "bridge_array_"):
                with self.subTest(path=path.name, name=name):
                    self.assertTrue(name not in source, f"{path.name} retains {name}")
        interface = (ROOT / "starshine-mb/src/ffi_bridge/pkg.generated.mbti").read_text()
        self.assertTrue(
            "pub fn runtime_function_builder_new(Int) -> RuntimeFunctionBuilder" in interface,
            "the runtime builder accepts only its text base, not old layout or write arguments",
        )

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
