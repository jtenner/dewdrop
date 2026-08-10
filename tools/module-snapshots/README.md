# Dew compiler snapshots

Fixtures are grouped by language or runtime feature:

```text
tests/module-snapshots/<feature>/<test>.dew
tests/module-snapshots/<feature>/<test>.json
tests/module-snapshots/<feature>/<test>.wat
```

The `.wat` file exists only when compilation succeeds. Failed compilations have
`output: null` and no WAT.

## Expectations

A successful fixture snapshots compiler diagnostics and ordered stdout writes:

```json
{
  "errors": [],
  "warnings": [],
  "output": [
    "abcdefghijklmnopqrstuvwxyz"
  ]
}
```

An expected runtime trap still has a compiled module and WAT:

```json
{
  "errors": [],
  "warnings": [],
  "output": {
    "trap": "memory-out-of-bounds",
    "stdout": []
  }
}
```

A failed compilation has compiler errors and no output module:

```json
{
  "errors": [
    "fixture.dew:2:3: error: NumericLiteralOutOfRange(0, I8Type, 24)\n  |\n2 |   128i8\n  |   ^"
  ],
  "warnings": [],
  "output": null
}
```

- `errors` is the ordered compiler-error snapshot.
- `warnings` is the ordered compiler-warning snapshot.
- `output` is an ordered stdout array, an expected `{ "trap", "stdout" }`
  object, or `null`.
- `output: null` means compilation failed and no WAT was produced.
- Trap names are stable harness categories such as `unreachable`,
  `memory-out-of-bounds`, `array-out-of-bounds`, and `integer-divide-by-zero`.

The return value of `main` is ignored. Fixtures that need an observable runtime
result write it to stdout. For example, `text/concat` writes the concatenated
string and verifies the exact text in its JSON output array.

Compiler diagnostics use deterministic file-aware rendering around the current
semantic `Debug` message: logical path, byte line/column, source excerpt, caret,
and any secondary labels are contractual. Failed fixtures compile twice and must
produce identical ordered diagnostics. Successful fixtures compile twice, must
produce byte-identical Wasm, execute in both Node and Wago, produce identical
normalized stdout/traps in both runtimes, and compare their sibling WAT.

The Node and Wago fixture hosts provide equivalent bounded deterministic Preview
1 `fd_write`/`fd_read` implementations. Writes to file descriptor 1 are
concatenated, decoded as strict UTF-8, and split into ordered output lines. Other
descriptors do not enter the stdout oracle. Reads return EOF unless the fixture
supplies input. Wago does not need a separately installed WASI plugin for these
fixtures: `tools/module-snapshots/wago-runner` binds the two required Preview 1
imports directly through Wago's synchronous host-function API.

A fixture may add one optional `host` object:

```json
{
  "errors": [],
  "warnings": [],
  "output": ["partial write"],
  "host": {
    "stdin_hex": "616263",
    "write_limit": 3,
    "read_limit": 2
  }
}
```

Supported fields are `stdin_hex`, `write_limit`, `read_limit`, `write_errno`,
`read_errno`, `write_zero`, `write_overreport`, and `read_overreport`. No separate
host manifest is required.

Compiler diagnostics use a framed `DEW_ERROR`/`DEW_WARNING`/`DEW_END` protocol,
so multiline source-rendered values are preserved as one JSON string. Error and
warning arrays are both compared in deterministic source order.

## Additional source conventions

The normal triplet remains the complete common case. Three optional sibling
directories extend it without adding a fixture manifest:

```text
<test>.files/*.dew
```

adds sorted files to the root `snapshot.main` module.

```text
<test>.modules/<dotted.module.name>/*.dew
```

adds sorted imported modules. The immediate directory name is the complete Dew
module name.

```text
<test>.tests/*_test.dew
```

adds test-only files and selects compiler test mode. The runner invokes emitted
`__dew_test_*` exports in export order before `main`.

## Current coverage

The suite contains 257 fixtures:

```text
feature         total   compiled   compiler errors   expected traps
calls                3          0                 3                0
collections         15         10                 5                2
control-flow       23         23                 0                1
enums               11         11                 0                0
functions           17         14                 3                0
generics            19         16                 3                0
lanes               11         11                 0                0
memory               9          9                 0                1
modules             33         25                 8                0
names                3          0                 3                0
numeric             34         30                 4                1
reachability         1          1                 0                0
structs             11          8                 3                0
tests                4          2                 2                1
text                 27         27                 0                4
types               20         10                10                0
wasi                 16         16                 0                5

total               257        213                44               15
```

One hundred twenty-two compiled fixtures assert nonempty stdout, fifteen assert normalized
runtime traps, and seventy-three intentionally remain WAT/no-trap fixtures. The
silent fixtures preserve non-WASI reachability and physical-output coverage
without forcing an observable-output import into every module.

As of August 10, 2026, all 213 compiled fixtures pass in Node; the paired Wago run is normally identical and remains required by `tools/check.sh`. Coverage includes cyclic nominal conversion helpers, recursive tuple/struct/nested enum erased adapters, nested generic struct erased adapters, carrier-specialized structural callback calls, boxed scalar erased-export adapters, root-exported erased generic fallbacks, exact nominal-reference adapters, generic structs, nested/multi-parameter generic ABI closure, generic control-flow specialization, escaping/imported generic references, module initialization, imported values, imported method/operator dispatch, cross-module recursive types, named function values, local/imported closures, every fixed-width numeric literal-pattern carrier, narrow enum carrier matching, signed-minimum narrow literals, unary operators, shift-width semantics, float specials, narrow fixed-array carriers, exact prerequisite-bearing runtime-trait flow devirtualization, and direct/control-flow/matched nominal locals passed to typed functions.

Runtime fixtures cover recursive and nested control flow, evaluation order,
literal and enum matching, aggregate construction and extraction, scalar numeric
boundaries and conversions, native SIMD and SWAR lanes, unaligned memory,
strict-UTF-8 strings and bytes, builders, ranges, search, WASI writes, non-stdout
writes, partial writes, deterministic input, short reads, errno/zero-progress/
over-report failures, normalized traps, same-module multi-file compilation,
static multi-module linking, expected-type imported overload references,
flattened local/imported closures, unboxed mutable locals, shared boxed mutable
captures, explicit test-mode execution, invalid-UTF-8 handling traps,
`to_string`/`view`/`byte_at` out-of-bounds traps, literal-range diagnostic
matrices, closed symbolic generic trait erasure with zero dispatch artifacts,
dynamic scalar/packed/SIMD symbolic erasure, recursive prerequisite dictionaries,
imported generic providers with canonical cross-module trait layouts, and imported public callback/runtime-trait wrappers whose total preludes directize without removing their external fallback bodies.

## Commands

The default `tools/check.sh` full-project validation includes this suite after
formatting, generated-source checks, all four MoonBit test targets, Dew stdlib
tests, and SWAR/UTF/WASI parity. `tools/check.sh --quick` stops after native
unit tests and does not run snapshots.

```text
# Run the complete project validation, including snapshots.
tools/check.sh

# Run every snapshot recursively in Node and Wago (the default).
# The native compiler is built once and up to min(8, CPU count) fixtures run concurrently.
tools/module-snapshots/run.sh

# Force serial execution or choose an explicit worker count.
tools/module-snapshots/run.sh --jobs 1
tools/module-snapshots/run.sh --jobs 4
DEW_SNAPSHOT_JOBS=4 tools/module-snapshots/run.sh

# Run only one runtime while debugging an engine-specific failure.
tools/module-snapshots/run.sh --runtime node
tools/module-snapshots/run.sh --runtime wago

# Select both explicitly; repeated --runtime values preserve this order.
tools/module-snapshots/run.sh --runtime node --runtime wago

# Run one fixture by its feature-relative name.
tools/module-snapshots/run.sh --fixture text/concat

# Regenerate diagnostics, stdout output, and WAT.
tools/module-snapshots/run.sh --update

# List fixture names.
tools/module-snapshots/run.sh --list
```

Ordinary runs never modify snapshots. Generated Wasm, per-fixture interface
caches, the Wago runner binary, and actual WAT files remain temporary. Isolated
fixture caches prevent concurrent writers and inherited cache configuration from
cross-contaminating the suite. Concurrent results are buffered and printed in
sorted fixture order, preserving deterministic visible output and failure
ordering. The runner's Go module resolves the sibling Wago checkout
through `tools/module-snapshots/wago-runner/go.mod`. The exact `wasm-tools`
version is pinned in `tools/module-snapshots/WASM_TOOLS_VERSION`.
