#!/usr/bin/env python3
"""Keep migrated array algorithms in Dew, including the intrinsic facade."""

from pathlib import Path
import json
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
BULK_OPERATIONS = ("make", "copy", "copy_within", "fill", "slice", "extend")
CHECKED_OPERATIONS = ("get", "set", "iter_next_option")


class ArrayBuiltinPolicyTests(unittest.TestCase):
    def test_bulk_algorithms_have_no_declaration_ordinal_dispatch(self):
        registry = json.loads((ROOT / "tools/standard-builtin-registry.json").read_text())
        operations = registry["modules"]["array"]["operations"]
        for operation in BULK_OPERATIONS + CHECKED_OPERATIONS:
            name = "Array" + "".join(word.title() for word in operation.split("_"))
            self.assertNotIn(name, operations)

    def test_bulk_algorithms_are_library_functions(self):
        source = (ROOT / "std/array.dew").read_text()
        for operation in BULK_OPERATIONS:
            with self.subTest(operation=operation):
                self.assertRegex(source, rf"(?m)^fn array_{operation}_raw<t>\(")

    def test_checked_operations_are_library_functions(self):
        source = (ROOT / "std/array.dew").read_text()
        for operation in CHECKED_OPERATIONS:
            with self.subTest(operation=operation):
                self.assertRegex(source, rf"(?m)^(?:pub )?fn array_{operation}<t>\(")

    def test_no_std_module_reintroduces_bulk_builtin_aliases(self):
        forbidden = {f"dew_array_{operation}" for operation in BULK_OPERATIONS + CHECKED_OPERATIONS}
        declarations = re.compile(r'(?m)^.*\bbuiltin\b[^\n]*=\s*"([^"]+)"')
        for path in sorted((ROOT / "std").rglob("*.dew")):
            for match in declarations.finditer(path.read_text()):
                with self.subTest(path=path.relative_to(ROOT), target=match[1]):
                    self.assertNotIn(match[1], forbidden)


if __name__ == "__main__":
    unittest.main()
