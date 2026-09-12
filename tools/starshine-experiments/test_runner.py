"""Tests for the runtime comparison and command failure records."""

import sys
import unittest
import subprocess
import tempfile
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from runner import ROOT, CommandFailure, check_output, check_runtime_output, execute, runtime, snapshot_case


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

    def test_binaryen_trap_folding_matches_only_optimized_expectations(self):
        cases = [("collections/fixed-array-get-oob-trap", "array-out-of-bounds"),
                 ("wasmgc/nullable-ref-as-non-null-trap", "null-reference")]
        folded = {"trap": "unreachable", "stdout": []}
        for fixture, trap in cases:
            original = {"trap": trap, "stdout": []}
            with self.subTest(fixture=fixture):
                self.assertTrue(check_runtime_output(fixture, original, folded, optimized=True))
                self.assertFalse(check_runtime_output(fixture, original, original, optimized=True))
                self.assertFalse(check_runtime_output(fixture, original, original))
                with self.assertRaisesRegex(AssertionError, "runtime mismatch"):
                    check_runtime_output(fixture, original, folded)

    def test_optimized_expectations_reject_other_traps_and_changed_effects(self):
        fixture = "collections/fixed-array-get-oob-trap"
        original = {"trap": "array-out-of-bounds", "stdout": []}
        # These observations violate the fixture's explicit contract.
        for actual in (["success"], [], {"trap": "null-reference", "stdout": []},
                       {"trap": "unreachable", "stdout": ["unexpected effect"]}):
            with self.subTest(actual=actual), self.assertRaisesRegex(AssertionError, "runtime mismatch"):
                check_runtime_output(fixture, original, actual, optimized=True)
        for name, expected in [("unlisted/fixture", original),
                               (fixture, {"trap": "null-reference", "stdout": []}),
                               (fixture, {"trap": "array-out-of-bounds", "stdout": ["before"]})]:
            with self.subTest(name=name, expected=expected), self.assertRaisesRegex(AssertionError, "runtime mismatch"):
                check_runtime_output(name, expected, {"trap": "unreachable", "stdout": []}, optimized=True)

    def test_runtime_retains_the_observed_folded_trap_and_match_record(self):
        source = ROOT / "tests/module-snapshots/collections/fixed-array-get-oob-trap.dew"
        expected = {"output": {"trap": "array-out-of-bounds", "stdout": []}}
        process = subprocess.CompletedProcess([], 0, '{"output":[],"trap":"unreachable"}', "")
        records = []
        def executed(command, records, **kwargs):
            records.append({"command": command, "stdout": process.stdout})
            return process
        with patch("runner.execute", side_effect=executed):
            actual = runtime(Path("optimized.wasm"), source, expected, "node", None, records, optimized=True)
        self.assertEqual(actual, {"trap": "unreachable", "stdout": []})
        self.assertEqual(records[-1]["matched_optimized_expectation"], "collections/fixed-array-get-oob-trap")

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
