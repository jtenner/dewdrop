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
    "NumericLiteralOutOfRange(11872, I8Type, 24)"
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

Compiler diagnostics use deterministic MoonBit `Debug` representations. Failed
fixtures compile twice and must produce identical ordered diagnostics. Successful
fixtures compile twice, must produce byte-identical Wasm, execute in both Node
and Wago, produce identical normalized stdout/traps in both runtimes, and compare
their sibling WAT.

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
so multiline deterministic `Debug` values are preserved as one JSON string.

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

The suite contains 175 fixtures:

```text
feature         total   compiled   compiler errors   expected traps
calls                2          0                 2                0
collections         14          9                 5                2
control-flow       18         18                 0                1
enums               11         11                 0                0
functions            8          5                 3                0
generics             1          1                 0                0
lanes               11         11                 0                0
memory               9          9                 0                1
modules             16         14                 2                0
names                2          0                 2                0
numeric             28         26                 2                1
reachability         1          1                 0                0
structs             11          8                 3                0
tests                3          2                 1                1
text                 23         23                 0                1
types                1          0                 1                0
wasi                 16         16                 0                5

total               175        154                21               12
```

Ninety-one compiled fixtures assert nonempty stdout, twelve assert normalized
runtime traps, and fifty-one intentionally remain WAT/no-trap fixtures. The
silent fixtures preserve non-WASI reachability and physical-output coverage
without forcing an observable-output import into every module.

As of August 2, 2026, all 154 compiled fixtures pass in Node, including module
initialization, imported values, imported method/operator dispatch,
cross-module recursive types, named function values, and local/imported
closures. Wago execution is temporarily skipped while its checkout is rebased.

Runtime fixtures cover recursive and nested control flow, evaluation order,
literal and enum matching, aggregate construction and extraction, scalar numeric
boundaries and conversions, native SIMD and SWAR lanes, unaligned memory,
strict-UTF-8 strings and bytes, builders, ranges, search, WASI writes, non-stdout
writes, partial writes, deterministic input, short reads, errno/zero-progress/
over-report failures, normalized traps, same-module multi-file compilation,
static multi-module linking, expected-type imported overload references,
flattened local/imported closures, unboxed mutable locals, shared boxed mutable
captures, and explicit test-mode execution.

## Commands

The default `tools/check.sh` full-project validation includes this suite after
formatting, generated-source checks, all four MoonBit test targets, Dew stdlib
tests, and SWAR/UTF/WASI parity. `tools/check.sh --quick` stops after native
unit tests and does not run snapshots.

```text
# Run the complete project validation, including snapshots.
tools/check.sh

# Run every snapshot recursively in Node and Wago (the default).
tools/module-snapshots/run.sh

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

Ordinary runs never modify snapshots. Generated Wasm, the Wago runner binary,
and actual WAT files remain temporary. The runner's Go module resolves the
sibling Wago checkout through `tools/module-snapshots/wago-runner/go.mod`. The
exact `wasm-tools` version is pinned in
`tools/module-snapshots/WASM_TOOLS_VERSION`.
