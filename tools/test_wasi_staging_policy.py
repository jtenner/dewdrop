"""Keep byte staging in Dew, including benchmark-only entry points."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class WasiStagingPolicy(unittest.TestCase):
    def test_compilers_do_not_own_staging_algorithms(self):
        for relative in (
            "src/semantic/wasmgc_fragment_plan.mbt",
            "src/backend/starshine_program_assembly.mbt",
            "starshine-mb/src/ffi_bridge/ffi_bridge.mbt",
        ):
            source = (ROOT / relative).read_text()
            for operation in ("dew_bench_wasi_stage_write", "dew_bench_wasi_stage_read"):
                with self.subTest(path=relative, operation=operation):
                    self.assertFalse(operation in source, f"{relative} still provides {operation}")


if __name__ == "__main__":
    unittest.main()
