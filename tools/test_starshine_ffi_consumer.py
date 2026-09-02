#!/usr/bin/env python3

import unittest

import generate_starshine_ffi_consumer as generator


class StarshineFfiConsumerTests(unittest.TestCase):
    def binding(
        self,
        name: str,
        signature: str,
        parameters: tuple[generator.SExpr, ...] = (),
        results: tuple[generator.SExpr, ...] = (),
    ) -> generator.ExportBinding:
        return generator.ExportBinding(
            ordinal=0,
            function_index=0,
            internal_name="ffi_" + name.replace(":", "_").replace("-", "_"),
            export_name=name,
            parameters=parameters,
            results=results,
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

    def test_carrier_assertion_publishes_one_stable_alias(self) -> None:
        assertion = generator.CarrierAssertion(
            "StarshineInstructions",
            (
                generator.CarrierProbe("instructions_new", "result", 0),
                generator.CarrierProbe("instructions_push", "parameter", 0),
            ),
        )
        bindings = [
            self.binding(
                "instructions_new",
                "() -> (ref 141)",
                results=(["ref", "141"],),
            ),
            self.binding(
                "instructions_push",
                "((ref 141)) -> Unit",
                parameters=(["ref", "141"],),
            ),
        ]
        self.assertEqual(
            generator.validate_carrier_assertions(bindings, (assertion,)),
            {"StarshineInstructions": 141},
        )

    def test_carrier_assertion_rejects_inconsistent_provider_types(self) -> None:
        assertion = generator.CarrierAssertion(
            "StarshineInstructions",
            (
                generator.CarrierProbe("instructions_new", "result", 0),
                generator.CarrierProbe("instructions_push", "parameter", 0),
            ),
        )
        bindings = [
            self.binding(
                "instructions_new",
                "() -> (ref 141)",
                results=(["ref", "141"],),
            ),
            self.binding(
                "instructions_push",
                "((ref 142)) -> Unit",
                parameters=(["ref", "142"],),
            ),
        ]
        with self.assertRaisesRegex(ValueError, "compile-time carrier assertion"):
            generator.validate_carrier_assertions(bindings, (assertion,))


if __name__ == "__main__":
    unittest.main()
