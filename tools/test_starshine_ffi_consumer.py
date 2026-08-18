#!/usr/bin/env python3

import unittest

import generate_starshine_ffi_consumer as generator


class StarshineFfiConsumerTests(unittest.TestCase):
    def binding(self, name: str, signature: str) -> generator.ExportBinding:
        return generator.ExportBinding(
            ordinal=0,
            function_index=0,
            internal_name="ffi_" + name.replace(":", "_").replace("-", "_"),
            export_name=name,
            parameters=(),
            results=(),
            signature=signature,
            unsupported_reason=None,
        )

    def test_select_bindings_preserves_requested_order(self) -> None:
        available = [
            self.binding("second", "() -> Unit"),
            self.binding("first", "() -> Unit"),
        ]
        selected = generator.select_bindings(available, ["first", "second"])
        self.assertEqual([item.export_name for item in selected], ["first", "second"])

    def test_select_bindings_rejects_missing_export(self) -> None:
        with self.assertRaisesRegex(ValueError, "missing"):
            generator.select_bindings([self.binding("present", "() -> Unit")], ["missing"])

    def test_fingerprint_prefix_changes_with_signature(self) -> None:
        first = generator.fingerprint_prefix(
            "abc123",
            [("src/lib/pkg.generated.mbti", bytes.fromhex("11" * 32))],
            [self.binding("value", "() -> i32")],
        )
        second = generator.fingerprint_prefix(
            "abc123",
            [("src/lib/pkg.generated.mbti", bytes.fromhex("11" * 32))],
            [self.binding("value", "() -> i64")],
        )
        self.assertNotEqual(first, second)
        self.assertTrue(first.startswith(b"DEW_SELF_HOST_COMPILER_FINGERPRINT_V1\x00"))


if __name__ == "__main__":
    unittest.main()
