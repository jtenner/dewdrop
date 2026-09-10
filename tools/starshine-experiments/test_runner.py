"""Tests for the runtime comparison and command failure records."""

import sys
import unittest
import subprocess
import tempfile
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from runner import ROOT, CommandFailure, check_output, execute, snapshot_case


class RunnerTests(unittest.TestCase):
    def test_output_and_trap_are_both_checked(self):
        check_output(["42"], ["42"])
        check_output({"trap": "unreachable", "stdout": ["before"]},
                     {"trap": "unreachable", "stdout": ["before"]})
        with self.assertRaisesRegex(AssertionError, "runtime mismatch"):
            check_output({"trap": "unreachable", "stdout": ["before"]},
                         {"trap": "unreachable", "stdout": []})
        with self.assertRaisesRegex(AssertionError, "runtime mismatch"):
            check_output(["42"], ["43"])

    def test_process_failure_keeps_diagnostics_and_time(self):
        records = []
        with self.assertRaisesRegex(CommandFailure, "broken output"):
            execute([sys.executable, "-c", "raise RuntimeError('broken output')"], records)
        self.assertEqual(records[0]["returncode"], 1)
        self.assertIn("broken output", records[0]["stderr"])
        self.assertGreater(records[0]["seconds"], 0)

    def test_compiler_crash_keeps_the_invariant_and_stack(self):
        source = ROOT / "tests/module-snapshots/crash.dew"
        expected = {"errors": ["expected source error"], "warnings": [], "output": None}
        process = subprocess.CompletedProcess([], -6, "arena invariant 301", "PanicError stack")
        with tempfile.TemporaryDirectory() as directory, \
                patch("runner.snapshots.load_expectation", return_value=expected), \
                patch("runner.snapshots.fixture_sources", return_value=[("snapshot.main", "fixture.dew", source)]), \
                patch("runner.execute", return_value=process):
            args = SimpleNamespace(output=Path(directory), from_wat=False, compiler=Path("compiler"))
            result = snapshot_case(source, args, {})
        self.assertEqual(result["status"], "baseline-failed")
        self.assertIn("arena invariant 301", result["error"])
        self.assertIn("PanicError stack", result["error"])

    def test_timeout_is_a_failure_with_a_record(self):
        records = []
        with self.assertRaisesRegex(CommandFailure, "timeout"):
            execute([sys.executable, "-c", "import time; time.sleep(10)"],
                    records, timeout=0.03)
        self.assertTrue(records[0]["timeout"])


if __name__ == "__main__":
    unittest.main()
