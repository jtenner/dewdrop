"""Tests for the runtime comparison and command failure records."""

import sys
import unittest

from runner import CommandFailure, check_output, execute


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

    def test_timeout_is_a_failure_with_a_record(self):
        records = []
        with self.assertRaisesRegex(CommandFailure, "timeout"):
            execute([sys.executable, "-c", "import time; time.sleep(10)"],
                    records, timeout=0.03)
        self.assertTrue(records[0]["timeout"])


if __name__ == "__main__":
    unittest.main()
