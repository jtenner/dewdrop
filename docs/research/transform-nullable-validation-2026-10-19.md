# Checked nullable transform values

The native and Dew compile-time interpreters must use the checked nullable
reference type identity. A builtin opcode does not grant nullable type status to
an ordinary generic struct.

Dew formerly collected every nominal generic base returned by a `ref_null`
builtin into a nullable map. This let `Foo<U32>` and `Foo<Handle>` return a null
value through an invalid builtin declaration and then hide it in an ignored
macro result. The runtime controls trap on those calls. Dew now uses the same
canonical semantic `NullableRef` type identity as native. The existing standard
builtin registry generator emits both identity helpers. Instruction selection
still uses the builtin opcode; no standard path selects an algorithm.

Validation used to append its stop builtin to the first source file in each
module. A standard module can start with an import-only file. In that case the
helper moved the local IDs of later original declarations and broke the checked
type identity. Validation now appends the helper to the last original file.
Generated validation function files still follow all original files. A
regression checks canonical type identity with a leading import-only file.

Both interpreters also reject `ref_is_null` results with a non-i32 carrier before
running the instruction. The accepted checked result kinds are Bool, I8, U8,
I16, U16, I32, and U32. In particular, ignored String and Unit results cannot hide
an invalid instruction signature. The diagnostic is `Wasm null test requires
an i32 result carrier`.

The Dew unit tests cover forged wrapper metadata, canonical IDs through
validation, invalid checked results, and all seven valid i32 result kinds.
Actual source requests cover Foo<U32>, Foo<foreign Handle>, String and Unit null
test results, an unused forged constructor beside a raw Foo default read, and a
valid NullableRef<foreign Handle> control.

Native source regressions first passed two of four checks, then all four after
the result guard; the final native run took 10.462 seconds. Raw evidence is in
`.tmp/transforms-v3/null-native-{red,green}.log`. The final Dew build generated
its test module in 5.485 seconds and linked in 1.348 seconds. All 11 focused tests and all 37 module tests passed.
All six required source probes passed in 1.4241–1.5334 seconds each. Raw final
logs are `.tmp/null-review/final-build.log`, `final-full-tests.log`, and
`final-samples.json`. Research harnesses and full inputs are in
`.tmp/null-review/`; the current test-module and tool identities are recorded
there. No Moon build was needed for the Dew verification.
