#!/usr/bin/env python3

import unittest

import generate_starshine_ffi_consumer as generator


class StarshineFfiConsumerTests(unittest.TestCase):
    def test_public_signatures_use_stable_carrier_names(self) -> None:
        bindings = [self.binding(
            "CodeSec::new", "((ref 176)) -> (ref 176)",
            parameters=(["ref", "176"],), results=(["ref", "176"],),
        )]
        rendered = generator.render_dew(bindings, "digest", {
            "StarshineFunctions": 176, "StarshineCodeSec": 176,
        })
        self.assertNotIn("StarshineRef", rendered)
        self.assertIn("pub foreign type StarshineFunctions", rendered)
        self.assertIn("pub type StarshineCodeSec = StarshineFunctions", rendered)
        self.assertIn("value0: StarshineFunctions", rendered)
        self.assertIn('-> StarshineCodeSec = "CodeSec::new"', rendered)

    def test_reference_renumbering_does_not_change_dew_declarations(self) -> None:
        def render(index: int) -> str:
            return generator.render_dew([self.binding(
                "consume", "reference", parameters=(["ref", "null", str(index)],),
            )], "digest", {"StarshineTypeMetadata": index})
        self.assertEqual(render(12), render(900))
        self.assertIn("NullableRef<StarshineTypeMetadata>", render(12))

    def test_unnamed_reference_is_a_generation_error(self) -> None:
        with self.assertRaisesRegex(ValueError, "no stable carrier name"):
            generator.render_dew([self.binding(
                "new", "reference", results=(["ref", "42"],),
            )], "digest", {})

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

    def test_source_binding_check_reports_exact_missing_reference(self) -> None:
        selected = [self.binding("present", "() -> Unit")]
        generator.validate_source_bindings(selected, [("probe.dew", "StarshineFfi.ffi_present()")])
        with self.assertRaisesRegex(ValueError, r"probe.dew:2:.*ffi_missing.*ffi-used.json"):
            generator.validate_source_bindings(selected, [("probe.dew", "\nStarshineFfi.ffi_missing()")])

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
