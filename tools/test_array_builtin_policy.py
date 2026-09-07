#!/usr/bin/env python3
"""Keep migrated array algorithms in Dew, including the intrinsic facade."""

from pathlib import Path
import json
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
BULK_OPERATIONS = ("make", "copy", "copy_within", "fill", "slice", "extend")
CHECKED_OPERATIONS = ("get", "set", "iter_next_option")
SIZE_OPERATIONS = ("length", "capacity")
CORE_OPERATIONS = (
    "new", "with_capacity", "get_unchecked", "set_unchecked", "push", "pop",
    "clear", "iter", "iter_has_next", "iter_next", "reserve", "shrink_to_fit", "truncate",
)


class ArrayBuiltinPolicyTests(unittest.TestCase):
    def test_array_specialization_has_no_runtime_lookup_or_erased_adapter(self):
        source = (ROOT / "self_host/compiler/semantic_program_specialization.dew").read_text()
        self.assertFalse("dew_array_" in source,
                         "Array specialization must use selected library declarations")
        source = (ROOT / "self_host/compiler/starshine_runtime_emit.dew").read_text()
        self.assertFalse("unit_array_adapter" in source or "erased_array_adapter" in source,
                         "Unit storage must use the checked raw-array contract")

    def test_native_inline_builtins_do_not_inspect_array_wrappers(self):
        source = (ROOT / "src/backend/starshine_code.mbt").read_text()
        self.assertFalse("dew_array_" in source,
                         "Native inline instructions must not inspect Array fields")

    def test_array_probes_use_declared_library_bodies(self):
        for path in ("self_host/compiler/semantic_physical_specialization_test.dew",
                     "self_host/compiler/semantic_program_link_plan_test.dew"):
            with self.subTest(path=path):
                self.assertFalse("dew_array_" in (ROOT / path).read_text(),
                                 f"{path}: obsolete Array runtime fixture")

    def test_native_array_algorithms_have_no_legacy_ir(self):
        source = (ROOT / "src/semantic/lowering_plan.mbt").read_text()
        legacy = re.findall(r"\bPlannedArray[A-Za-z]+", source)
        self.assertEqual(set(legacy), {"PlannedArrayLiteral"})

    def test_array_has_no_compiler_owned_algorithms(self):
        source = (ROOT / "std/array.dew").read_text()
        self.assertNotRegex(source, r"\bbuiltin\b")
        registry = json.loads((ROOT / "tools/standard-builtin-registry.json").read_text())
        self.assertEqual(registry["modules"]["array"]["operations"], {})
        for dispatch in ("methods", "index", "index_set"):
            self.assertNotIn(dispatch, registry["modules"]["array"])

    def test_raw_array_intrinsics_use_wasm_instruction_names(self):
        source = (ROOT / "std/wasm/intrinsics.dew").read_text()
        for operation in ("new", "len", "get", "set", "new_default", "copy"):
            self.assertRegex(source, rf'pub builtin wasm_array_{operation}<t>\([^\n]+ = "array\.{operation}"')

    def test_fixed_array_methods_have_no_declaration_ordinal_dispatch(self):
        registry = json.loads((ROOT / "tools/standard-builtin-registry.json").read_text())
        self.assertNotIn("fixed_array", registry["modules"])
        operations = registry["modules"]["wasm_intrinsics"]["operations"]
        self.assertFalse(any(name.startswith("WasmArray") for name in operations))

    def test_fixed_array_has_only_library_functions(self):
        source = (ROOT / "std/fixed_array.dew").read_text()
        self.assertNotRegex(source, r"\bbuiltin\b")
        for method in ("make", "length", "get", "get_unchecked", "set", "set_unchecked", "indexed_get", "indexed_set"):
            self.assertRegex(source, rf"\bfn {method}\(")

    def test_bulk_algorithms_have_no_declaration_ordinal_dispatch(self):
        registry = json.loads((ROOT / "tools/standard-builtin-registry.json").read_text())
        operations = registry["modules"]["array"]["operations"]
        for operation in BULK_OPERATIONS + CHECKED_OPERATIONS + SIZE_OPERATIONS:
            name = "Array" + "".join(word.title() for word in operation.split("_"))
            self.assertNotIn(name, operations)

    def test_bulk_algorithms_are_library_functions(self):
        source = (ROOT / "std/array.dew").read_text()
        for operation in BULK_OPERATIONS:
            with self.subTest(operation=operation):
                self.assertRegex(source, rf"(?m)^fn array_{operation}_raw<t>\(")

    def test_checked_operations_are_library_functions(self):
        source = (ROOT / "std/array.dew").read_text()
        for operation in CHECKED_OPERATIONS + SIZE_OPERATIONS:
            with self.subTest(operation=operation):
                self.assertRegex(source, rf"(?m)^(?:pub )?fn array_{operation}<t>\(")

    def test_no_std_module_reintroduces_array_builtin_aliases(self):
        forbidden = {f"dew_array_{operation}" for operation in BULK_OPERATIONS + CHECKED_OPERATIONS + SIZE_OPERATIONS + CORE_OPERATIONS}
        declarations = re.compile(r'(?m)^.*\bbuiltin\b[^\n]*=\s*"([^"]+)"')
        for path in sorted((ROOT / "std").rglob("*.dew")):
            for match in declarations.finditer(path.read_text()):
                with self.subTest(path=path.relative_to(ROOT), target=match[1]):
                    self.assertNotIn(match[1], forbidden)


if __name__ == "__main__":
    unittest.main()
