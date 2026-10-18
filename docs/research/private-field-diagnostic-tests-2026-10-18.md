# Exact native private-field diagnostics

The independent frontend review found that native private-field tests accepted
any nonempty diagnostic list. An unrelated error could therefore satisfy them.

The negative cases now compare the complete ordered list of diagnostic kinds
and field names. Reads, writes, qualified reads, and cached-interface reads must
report `UnknownFieldForType` for `value`. Explicit and inferred construction must
report the expected `MissingConstructionField` and `UnknownConstructionField`
errors for `value`. Construction that omits the private field must report only
its missing-field error. Named private-field patterns must report
`UnknownPatternField` for `value`.

A new case omits the private field from a pattern without `...`. It requires
exactly one `MissingImportedPatternField` diagnostic naming `value`. The existing
positive rest-pattern test still requires no diagnostics. Unexpected diagnostic
kinds retain their full debug text in assertion output.

This is a test-only change. No production compiler code changed.

Validation used `tools/test-native.sh` with
`DEW_NATIVE_TEST_PACKAGES=semantic/module_private_fields_wbtest.mbt` and isolated
`--target-dir /tmp/dewdrop-implementation-2026-10-18/recovery-build`. All nine
tests ran and passed in 10.277 seconds. The log is
`.tmp/malformed-escape-recovery/native-exact-privacy-tests.log`.
