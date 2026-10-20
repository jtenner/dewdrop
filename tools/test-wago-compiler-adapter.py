#!/usr/bin/env python3
"""Small text checks for the pinned compiler host adapter."""
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("wago_adapter", Path(__file__).with_name("prepare-wago-compiler.py"))
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)


class WorkerMemoryTests(unittest.TestCase):
    def test_unbounded_compiler_memory_gets_a_maximum(self):
        self.assertEqual(adapter.bound_worker_memory("  (memory (;0;) 1)\n"), "  (memory (;0;) 1 256)\n")

    def test_memory_export_is_not_a_second_memory(self):
        source = '  (memory (;0;) 1)\n  (export "memory" (memory 0))\n'
        expected = '  (memory (;0;) 1 256)\n  (export "memory" (memory 0))\n'
        self.assertEqual(adapter.bound_worker_memory(source), expected)

    def test_smaller_existing_maximum_stays(self):
        source = "  (memory $scratch (;0;) 1 8)\n"
        self.assertEqual(adapter.bound_worker_memory(source), source)

    def test_larger_existing_maximum_is_capped(self):
        self.assertEqual(adapter.bound_worker_memory("  (memory (;0;) 1 65536)\n"), "  (memory (;0;) 1 256)\n")

    def test_invalid_memories_remain_visible(self):
        for source in ["", "  (memory (;0;) 257)\n", "  (memory (;0;) 1 2 shared)\n", "  (import \"env\" \"memory\" (memory 1 2))\n", "  (memory (;0;) 1)\n  (memory (;1;) 1)\n"]:
            with self.subTest(source=source), self.assertRaises(ValueError):
                adapter.bound_worker_memory(source)


if __name__ == "__main__":
    unittest.main()
