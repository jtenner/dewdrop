#!/usr/bin/env python3
"""Set composes the public Dew Map API; it has no compiler runtime."""

import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SetBuiltinPolicyTests(unittest.TestCase):
    def test_declared_storage_and_ordinary_functions(self):
        source = (ROOT / "std/set.dew").read_text()
        self.assertIn("values: Map<key, Unit>", source)
        self.assertIn("inner: MapKeyIter<key, Unit>", source)
        self.assertNotRegex(source, r"\bbuiltin\b")

    def test_no_set_identity_or_operation_dispatch(self):
        registry = json.loads((ROOT / "tools/standard-builtin-registry.json").read_text())
        self.assertEqual(registry["modules"]["set"], {
            "slot": 12, "path": "dew.std.set", "operations": {},
        })
        for name in ("src/semantic/lowering_plan.mbt", "src/backend/starshine_code.mbt"):
            self.assertNotRegex((ROOT / name).read_text(), r"\bPlannedSet\w*")


if __name__ == "__main__":
    unittest.main()
