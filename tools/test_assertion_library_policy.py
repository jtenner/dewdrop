"""Test assertion output is a Dew function, not hidden compiler code."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class AssertionLibraryPolicyTests(unittest.TestCase):
    def test_generator_injects_an_ordinary_assertion_function(self):
        source = (ROOT / "src/dew_test_gen/main.mbt").read_text()
        self.assertTrue("builtin dew_test_assert_runtime" not in source,
                        "the test runner must not inject an opaque assertion builtin")
        self.assertTrue("fn assert(condition: Bool, message: String)" in source,
                        "test assertions must use an ordinary module-local Dew function")

    def test_compiler_has_no_test_assertion_runtime_dispatch(self):
        paths = (
            "src/backend/starshine_code.mbt",
            "src/backend/starshine_program_assembly.mbt",
            "src/backend/starshine_module_assembly.mbt",
            "src/backend/starshine_wasi_runtime.mbt",
            "src/semantic/wasmgc_fragment_plan.mbt",
            "src/semantic/program_specialization_plan.mbt",
        )
        for path in paths:
            with self.subTest(path=path):
                source = (ROOT / path).read_text()
                self.assertTrue("dew_test_assert" not in source,
                                f"opaque test assertion dispatch remains in {path}")
                self.assertTrue("starshine_test_assert_body" not in source,
                                f"compiler-owned assertion body remains in {path}")


if __name__ == "__main__":
    unittest.main()
