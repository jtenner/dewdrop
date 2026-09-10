"""Check that benchmark timing cannot accept a wrong Wasm result."""

import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from runner import HERE, ROOT


class BenchmarkTests(unittest.TestCase):
    def run_sample(self, expected):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            wasm = directory / "constant.wasm"
            # (module (func (export "main") (result i32) i32.const 42))
            wasm.write_bytes(bytes.fromhex("0061736d010000000105016000017f03020100070801046d61696e00000a06010400412a0b"))
            spec = directory / "spec.json"
            spec.write_text(json.dumps({"export": "main", "inputs": [{"args": [], "expected": expected}],
                                        "variants": [{"name": "baseline", "wasm": str(wasm)}]}))
            return subprocess.run(["node", str(HERE / "benchmark.mjs"), str(spec), "5", "0.1"],
                                  cwd=ROOT, text=True, capture_output=True, timeout=5)

    def test_correct_result_has_five_timed_samples(self):
        result = self.run_sample(42)
        self.assertEqual(result.returncode, 0, result.stderr)
        values = json.loads(result.stdout)["variants"]["baseline"]["ns_per_call"]
        self.assertEqual(len(values), 5)
        self.assertTrue(all(value > 0 for value in values))

    def test_identical_modules_share_samples_with_an_explicit_alias(self):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            data = bytes.fromhex("0061736d010000000105016000017f03020100070801046d61696e00000a06010400412a0b")
            for name in ["first", "copy"]:
                (directory / f"{name}.wasm").write_bytes(data)
            spec = directory / "spec.json"
            spec.write_text(json.dumps({"export": "main", "inputs": [{"args": [], "expected": 42}],
                "variants": [{"name": name, "wasm": str(directory / f"{name}.wasm")} for name in ["first", "copy"]]}))
            result = subprocess.run(["node", str(HERE / "benchmark.mjs"), str(spec), "5", "0.1"],
                                    cwd=ROOT, text=True, capture_output=True, timeout=5)
            self.assertEqual(result.returncode, 0, result.stderr)
            measured = json.loads(result.stdout)
            self.assertEqual(measured["unique_modules"], 1)
            self.assertEqual(measured["variants"]["copy"]["equivalent_to"], "first")
            self.assertEqual(measured["variants"]["first"]["ns_per_call"],
                             measured["variants"]["copy"]["ns_per_call"])
            self.assertIsNone(measured["variants"]["copy"]["compile_ms"])

    def test_wrong_result_has_diagnostic_and_no_measurement(self):
        result = self.run_sample(43)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("wrong result", result.stderr)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
