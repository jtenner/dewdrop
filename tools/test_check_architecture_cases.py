"""Focused checks for declarative architecture cases."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path


def load_checker():
    path = Path(__file__).with_name("check-architecture-cases.py")
    spec = importlib.util.spec_from_file_location("dew_architecture_cases", path)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load architecture case checker")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


checker = load_checker()
EXPECTED = {"export": "run", "result": {"type": "i32", "value": 42}}


class ArchitectureCaseTests(unittest.TestCase):
    def test_wat_count_matches_tokens_not_metadata_or_comments(self):
        wat = r'''(module
  (@custom "compiler.facts" (before first) "dewdrop drop call local.get struct.new")
  ;; drop call local.get struct.new
  (; nested (; drop ;) call ;)
  (type (;0;) (func (param i32) (result i32)))
  (import "wasi_snapshot_preview1" "fd_write" (func (type 0)))
  (func (local i32)
    local.get 0
    drop
    call 0
    return_call 0
    call_ref 0))'''
        self.assertEqual(checker.wat_count(wat, "drop"), 1)
        self.assertEqual(checker.wat_count(wat, "call "), 2)
        self.assertEqual(checker.wat_count(wat, "return_call"), 1)
        self.assertEqual(checker.wat_count(wat, "call_ref"), 1)
        self.assertEqual(checker.wat_count(wat, "local.get"), 1)
        self.assertEqual(checker.wat_count(wat, "struct.new"), 0)
        self.assertEqual(checker.wat_count(wat, "(local"), 1)
        self.assertEqual(checker.wat_count(wat, "(param i32)"), 1)
        self.assertEqual(
            checker.wat_count(wat, '(import "wasi_snapshot_preview1"'),
            1,
        )

    def test_consumer_result_requires_exact_json_equality(self):
        self.assertIsNone(
            checker.consumer_result_error(
                '{"export":"run","result":{"type":"i32","value":42}}\n',
                EXPECTED,
            )
        )
        self.assertIsNotNone(
            checker.consumer_result_error(
                '{"export":"run","result":{"type":"i32","value":420}}\n',
                EXPECTED,
            )
        )

    def test_consumer_result_rejects_non_json_output(self):
        self.assertIn(
            "invalid JSON",
            checker.consumer_result_error("not json", EXPECTED),
        )


if __name__ == "__main__":
    unittest.main()
