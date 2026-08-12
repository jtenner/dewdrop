# Dew test infrastructure

## Syntax

Dew follows MoonBit's filename convention: every source file whose path ends exactly in `_test.dew` is a test-only file. Such files may contain test declarations and private/public helper declarations; all their callables are analyzed normally but excluded from production interfaces, reachability, bodies, and exports. Dew supports MoonBit-style top-level tests inside those files:

```dew
test "String byte length" {
  assert("abc".byte_length() == 3u32, "wrong byte length")
}
```

A test has no parameters and has an implicit `Unit` result. Its quoted name, file, source offset, and declaration identity are retained in first-class `CollectedTest` metadata and propagated into callable and Wasm fragment plans. Test-mode emission assigns deterministic manifest-order entry points:

```text
__dew_test_<ordinal>
```

The reserved prefix is compiler-owned, and source byte offsets are not part of the export identity. Default compilation analyzes `_test.dew` bodies but excludes every callable originating in those files from callable reachability and exports. `WasmGCPlanningOptions::test_mode()` makes test-file callables roots and exports explicit `test` declarations. Test-file declarations are never frozen as package interface values. Ordinary-file type and body resolution cannot see test-only values, nominal types, traits, or impl evidence; test files retain access to their own test-only declarations. Production physical planning also omits test-only nominal layouts and refuses to follow reachability edges into test callables. A `test` declaration in any other filename is diagnosed.

The standard runner compiles each sorted `_test.dew` source as a distinct manifest file. After Starshine validation and encoding, the compiler appends one deterministic `dew.tests` Wasm custom section carrying the versioned `DEW_TESTS_V3` payload: export names, logical modules, logical file paths, exact strict-UTF-8 display names, and optional expected-trap categories. Stable identity is module + logical file + display name. Collection diagnoses duplicate file/display-name pairs within one module, and the runner rejects duplicate complete metadata identities. Source scanning, assembled-offset reconstruction, and metadata sidecars are no longer used. Production binaries contain no `dew.tests` section.

The runner supports exact `--module`, `--file`, and `--name` filters, an identity substring `--filter`, and metadata-only `--list`. Filters compose deterministically and selecting no tests is an error.

## Assertions and traps

A test may declare a stable expected trap directly:

```dew
test "divide by zero" expect_trap "integer-divide-by-zero" {
  consume_division_result()
}
```

Collection accepts only `unreachable`, `memory-out-of-bounds`,
`array-out-of-bounds`, `integer-divide-by-zero`, `integer-overflow`, and
`invalid-conversion-to-integer`. The V3 metadata transports the category. The
runner counts a matching normalized Wasm trap as a pass and continues with the
remaining tests; no trap, a different trap, an unknown runtime message, or a
JavaScript exception remains a visible failure.

The standard preamble defines:

```dew
pub builtin assert(condition: Bool, message: String) -> Unit = "dew_assert"
pub builtin unreachable() -> Never = "dew_unreachable"
```

`assert` evaluates both arguments and emits a Wasm trap when the condition is false. CLI/standard test compilation injects a private `dew_test_assert` runtime: on failure it converts the runtime `String` to a sharing `Bytes` view, writes the exact current bytes to WASI Preview 1 descriptor 1 through the bounded reusable staging page, and then traps. The Node runner provides `fd_write`, captures each test's stdout writes, decodes them as strict UTF-8, and attaches the dynamic message to an unexpected assertion failure. No assertion IDs, globals, or static message metadata are emitted. Production compilation retains the direct zero-I/O inline trap. `unreachable` directly emits the Wasm `unreachable` instruction without writing a message.

Starshine validates the test-only runtime, GC-to-linear staging, WASI import, memory, and final trap path. The external runner reports the test identity and exact runtime-computed assertion message.

## Standard-library runner

Tests live under:

```text
std/tests/*_test.dew
```

Run them with:

```text
tools/dew-test/run.sh
```

The runner:

1. sorts standard test files deterministically;
2. compiles them as distinct manifest-ordered files;
3. appends compiler-owned versioned display-name/file/export metadata as a `dew.tests` custom section;
4. compiles through the complete Dew semantic and Starshine pipeline;
5. instantiates the WasmGC module in Node;
6. invokes every `__dew_test_*` export;
7. reports all failures rather than stopping at the first;
8. separately invokes every public export in the dedicated trap artifact and requires each one to trap, covering assertions, unreachable, range failures, invalid UTF-8 producers, and every consumed-builder operation through direct and aliased references.

The generated suite covers every currently public `dew.std.string` operation, assertion success, all 100 ordered scalar `Into<T>` pairs, typed memory roundtrips for every scalar/SWAR/V128 carrier, scalar arithmetic across all widths, narrow canonicalization, floating arithmetic, and splat/extract/replace/add smoke checks for all 20 packed-lane types. The text hardening layer adds exhaustive byte/alignment and boundary-length matrices, deliberate rolling-hash collision verification, invalid UTF-8 interior edges, nominal aggregate ABI joins, and large search/builder stress. Existing UTF and SWAR differential harnesses remain deeper algorithmic oracles while direct MoonBit-style coverage expands module by module.

## Deliberate limitations

- Dynamic assertion messages use stdout by design. A test that deliberately writes unrelated stdout before an unexpected assertion currently contributes those bytes to the reported assertion output; a future framed test-output protocol may separate them if workloads require it.
- Test bodies are analyzed in normal compilation but emitted only in explicit test mode.
- Frozen interfaces exclude test-only implementation evidence, and production reachability/startup exclude test-only callables, nominal layouts, module values, and initialization steps.
- The initial custom-section payload retains the textual V3 record encoding; a denser binary payload is unnecessary until measurements justify a version change.
- Async tests, fixtures, parameterized tests, snapshots, coverage, and benchmark tests are deferred; metadata-driven filtering and expected traps are implemented.
- **Optional arguments are a future language improvement.** They are not part of the initial test or assertion syntax; APIs must currently supply every declared argument explicitly.
