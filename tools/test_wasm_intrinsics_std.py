"""Intrinsic coverage comes from public source declarations and scalar metadata."""

import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import generate_wasm_intrinsics_std as generator
from wasm_scalar_intrinsics import SCALAR_INSTRUCTIONS


class WasmIntrinsicSourceCoverageTests(unittest.TestCase):
    def test_missing_scalar_and_reference_signatures_are_exact(self):
        declarations, _ = generator.intrinsic_declarations()
        by_alias = {declaration.alias: declaration for declaration in declarations}
        expected = {
            "ref.eq": ("<a, b>", "(left: a, right: b) -> Bool"),
            "i32.eqz": ("", "(value: I32) -> Bool"),
            "i64.eqz": ("", "(value: I64) -> Bool"),
        }
        for kind in ("f32", "f64"):
            for operation in ("min", "max", "copysign"):
                expected[f"{kind}.{operation}"] = (
                    "", f"(left: {kind.upper()}, right: {kind.upper()}) -> {kind.upper()}")
        for kind, operations in (
            ("i32", ("clz",)),
            ("i64", ("clz", "ctz", "popcnt", "extend8_s", "extend16_s", "extend32_s")),
        ):
            for operation in operations:
                expected[f"{kind}.{operation}"] = ("", f"(value: {kind.upper()}) -> {kind.upper()}")
        for kind in ("i32", "i64"):
            for operation in ("rotl", "rotr"):
                expected[f"{kind}.{operation}"] = (
                    "", f"(left: {kind.upper()}, right: {kind.upper()}) -> {kind.upper()}")
            for floating in ("f32", "f64"):
                for sign in ("s", "u"):
                    expected[f"{kind}.trunc_sat_{floating}_{sign}"] = (
                        "", f"(value: {floating.upper()}) -> {kind.upper()}")
        self.assertEqual(len(expected), 28)
        for target, (generics, signature) in expected.items():
            with self.subTest(target=target):
                declaration = by_alias["wasm_" + target.replace(".", "_")]
                self.assertEqual((declaration.target, declaration.generics, declaration.signature),
                                 (target, generics, signature))
                self.assertIsNone(declaration.body)

    def test_all_scalar_opcodes_have_public_declarations(self):
        declarations, _ = generator.intrinsic_declarations()
        targets = {declaration.target for declaration in declarations}
        self.assertLessEqual({name for name, _, _, _ in SCALAR_INSTRUCTIONS}, targets)
        # Existing logical signatures and aliases must keep their source meaning.
        by_alias = {declaration.alias: declaration for declaration in declarations}
        self.assertEqual(by_alias["wasm_raw_i32_wrap_i64"].signature, "(value: I64) -> I32")
        self.assertEqual(by_alias["wasm_u32_ctz"].signature, "(value: U32) -> U32")

    def test_private_helpers_tests_and_generated_output_are_not_sources(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "std/wasm/intrinsics.dew"
            source.parent.mkdir(parents=True)
            source.write_text('pub builtin generated_only(value: I32) -> I32 = "i32.clz"\n')
            (root / "std/helpers.dew").write_text(
                'struct Opaque {}\n'
                'builtin private_identity(left: Opaque, right: Opaque) -> Bool = "ref.eq"\n'
                'pub builtin __debug_internal(value: I32) -> I32 = "i32.clz"\n'
                'pub builtin public_count(value: I32) -> I32 = "i32.ctz"\n'
                'fn private_bits(value: U64) -> U64 {\n'
                '  unsafe_bitcast::<U64, U64>(value)\n}\n'
                'pub fn public_bits(value: U64) -> U64 {\n'
                '  unsafe_bitcast::<U64, U64>(value)\n}\n')
            tests = root / "std/tests"
            tests.mkdir()
            (tests / "sample_test.dew").write_text(
                'pub builtin test_only(value: I32) -> I32 = "i32.clz"\n')
            with patch.object(generator, "ROOT", root), patch.object(generator, "SOURCE", source):
                declarations = generator.standard_builtin_declarations()
            self.assertEqual({declaration.name for declaration in declarations},
                             {"public_count", "public_bits"})
            self.assertFalse(any("Opaque" in declaration.signature for declaration in declarations))

    def test_unknown_backend_opcode_keeps_missing_declaration_diagnostic(self):
        names = generator.backend_inline_names() | {"i32.unknown_coverage_probe"}
        with patch.object(generator, "backend_inline_names", return_value=names):
            with self.assertRaisesRegex(SystemExit, r"without Dew source declarations: i32\.unknown_coverage_probe$"):
                generator.intrinsic_declarations()


if __name__ == "__main__":
    unittest.main()
