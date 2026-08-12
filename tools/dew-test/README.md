# Dew standard-library test runner

Dew follows MoonBit-style file ownership: files ending exactly in `_test.dew` are test-only compilation units. Helpers declared in those files are available in test mode but are stripped from production interfaces and code. Dew tests use MoonBit-style syntax:

```dew
test "test name" {
  assert(true, "failure message")
}
```

Run all standard-library tests, run explicit test files through the compiler
CLI, or select tests only through compiler metadata:

```text
tools/dew-test/run.sh
tools/dew test --module dew.std std/tests/core_test.dew
tools/dew test --module dew.std --name "assertion trap can be expected" std/tests/core_test.dew
tools/dew-test/run.sh --module dew.std
tools/dew-test/run.sh --file std/tests/00_string_test.dew
tools/dew-test/run.sh --name "String byte_length counts UTF8 bytes"
tools/dew-test/run.sh --filter "dew.std::std/tests/00_string_test.dew"
tools/dew-test/run.sh --list
```

Exact module, file, and display-name filters compose. `--filter` applies a
substring match to the stable `module::file::display-name` identity. A filter
that selects no tests is an error. Filtered runs execute exactly the selected
metadata tests; the separate all-exports builtin-trap probe runs only during the
default unfiltered suite.

The runner discovers `std/tests/*_test.dew` in sorted manifest order and passes the files individually to the compiler. It compiles them with `WasmGCPlanningOptions::test_mode()` through the complete Dew and Starshine pipeline, instantiates the WasmGC module in Node, and invokes every compiler-described test export. It reports all failing display names and logical files in one run. Normal compilation analyzes but does not emit or export tests.

Test exports use deterministic manifest ordinals such as `__dew_test_0`; source byte offsets are no longer part of their identity. The compiler appends one `dew.tests` Wasm custom section whose versioned `DEW_TESTS_V3` payload contains each export, logical module, logical source path, strict-UTF-8 display name, and optional expected-trap category. Stable logical identity is `module + file + display name`. Collection diagnoses duplicate file/display-name pairs within a module, while the runner also rejects duplicate complete identities in metadata. The Node runner reads the custom section from the compiled module and does not scan Dew source or consume a sidecar.

Expected traps are declaration metadata rather than source-runner conventions:

```dew
test "assertion trap can be expected" expect_trap "unreachable" {
  assert(false, "expected assertion trap")
}
```

Supported categories are `unreachable`, `memory-out-of-bounds`,
`array-out-of-bounds`,
`integer-divide-by-zero`, `integer-overflow`, and
`invalid-conversion-to-integer`. Unsupported categories are compiler
diagnostics. A matching trap passes and the runner continues to later tests; a
missing, unexpected, or differently categorized trap fails the test.

For ordinary failed assertions, CLI/standard test compilation injects a private
runtime that converts the current runtime `String` message to sharing `Bytes`,
writes it to WASI stdout through the bounded staging page, and then traps. The
runner captures descriptor-1 writes per test and strict-UTF-8 decodes the exact
dynamic output, allowing diagnostics such as:

```text
unexpected trap unreachable: assertion failed: visible assertion λ
```

There is no `dew.assertions` section or assertion-ID global. Production modules
retain the direct zero-I/O inline assertion trap and do not gain WASI imports or
memory from this test-only transport.

`builtin_traps.dew` is compiled separately to verify that false assertions, `unreachable()`, out-of-bounds typed memory access, invalid, reversed, or out-of-bounds String/StringView/Bytes ranges, invalid StringBuilder ASCII/scalar/checked input, and every post-`finish()` StringBuilder/BytesBuilder operation—including use through aliases and repeated finish—produce Wasm runtime traps. Every public export in the dedicated trap artifact is required to trap, so new probes remain visible without a runner allowlist.

`tools/dew test` creates a temporary self-describing Wasm artifact under `.tmp`,
invokes the same V3 Node runner, and removes the artifact after the run. Explicit-file mode requires at least one `_test.dew` input. Package mode discovers root-package tests from `dew.json`; `--manifest dew.modules.json` supports explicit statically linked multi-module test graphs. Both modes support package-wide metadata filters.

Generated standard-suite files are:

```text
tools/dew-test/stdlib_tests.wasm
tools/dew-test/builtin_traps.wasm
```

They are build artifacts and must not be committed. The assembler compiles the
standard test module twice and requires byte-identical self-describing Wasm.
Production compiler CLI smoke tests require that ordinary binaries contain no
`dew.tests` section.

The runner prints the authoritative discovered test count; it is intentionally not duplicated here. Coverage includes core assertions and expected traps, text/bytes operations, all ordered scalar `Into<T>` pairs, scalar/SWAR/V128 typed memory carriers, arithmetic widths, narrow wrapping canonicalization, floating arithmetic, lane smoke coverage, and the implemented collection/formatting/cleanup surface. Continue following AssemblyScript-style coverage: organize tests by standard module, test every public operation directly, include edge and cross-chunk cases, and add explicit trap coverage for checked operations.
