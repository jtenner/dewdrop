# Convention-based compiler snapshots

## Status

Fixtures use a feature-oriented convention:

```text
tests/module-snapshots/<feature>/<test>.dew
tests/module-snapshots/<feature>/<test>.json
tests/module-snapshots/<feature>/<test>.wat
```

There are no fixture manifests, configured module graphs, root-module fields,
entry-point fields, or planning-mode switches. Each source is one production
module and `main` is the successful-compilation entry point.

A WAT file exists only when compilation succeeds. Compiler-error fixtures have
`output: null` and no WAT.

## JSON oracle

Successful compilation:

```json
{
  "errors": [],
  "warnings": [],
  "output": [
    "abcdefghijklmnopqrstuvwxyz"
  ]
}
```

Failed compilation:

```json
{
  "errors": [
    "NumericLiteralOutOfRange(11872, I8Type, 24)"
  ],
  "warnings": [],
  "output": null
}
```

`errors` and `warnings` are ordered compiler diagnostics. `output` is an ordered
strict-UTF-8 stdout array, a normalized runtime-trap object carrying stdout
before the trap, or `null` when no executable module was produced. The return
value of `main` is ignored.

For example, `text/concat` snapshots the generated WAT and writes the complete
concatenated string to stdout:

```json
{
  "errors": [],
  "warnings": [],
  "output": [
    "abcdefghijklmnopqrstuvwxyz"
  ]
}
```

## Diagnostic protocol

The native fixture compiler emits a framed machine protocol:

```text
DEW_ERROR
<deterministic possibly multiline Debug representation>
DEW_END

DEW_WARNING
<deterministic possibly multiline Debug representation>
DEW_END

DEW_INTERNAL <harness failure>
```

Framing preserves a multiline diagnostic as one ordered JSON string rather than
silently truncating it at the first line. Compiler diagnostic enums derive
`Debug`, so the current implementation uses `@debug.to_string` as the exact
snapshot spelling. A future user-facing renderer can intentionally replace these
strings and refresh the fixtures in one reviewable change.

Internal harness failures are never accepted as expected compiler errors.

## Minimal extensions

The common fixture remains one `.dew`/`.json`/`.wat` triplet. Optional behavior
uses one small JSON object or one convention-based sibling directory:

- `host` configures hexadecimal stdin, read/write chunk limits, errno, zero
  progress, and host over-reporting.
- `<test>.files/` adds files to `snapshot.main`.
- `<test>.modules/<dotted.module>/` adds statically linked imported modules.
- `<test>.tests/*_test.dew` selects test mode and adds test-only files.

Expected traps use:

```json
{
  "trap": "unreachable",
  "stdout": []
}
```

The Node and Wago harnesses normalize only the same five known Wasm runtime
trap categories. JavaScript exceptions, untyped Wago errors, and unknown runtime
messages remain harness failures rather than snapshots. The Wago harness enables
`CoreFeaturesV3` explicitly and binds deterministic Preview 1 `fd_write` and
`fd_read` callbacks directly; it does not depend on an installed WASI plugin.

## Pipeline

Successful fixture:

```text
<test>.dew
  -> immutable semantic analysis
  -> lowering and linking
  -> Starshine validation
  -> Starshine binary encoding
  -> wasm-tools validation
  -> invoke test exports/main in Node with deterministic fd_read/fd_write
  -> invoke the same exports in Wago CoreFeaturesV3 with equivalent host callbacks
  -> require identical normalized stdout and traps across both runtimes
  -> render and compare sibling <test>.wat
```

Failed fixture:

```text
<test>.dew
  -> compiler diagnostics
  -> compare ordered errors and warnings
  -> require output: null
  -> require no sibling <test>.wat
```

Every fixture is compiled twice. Successful fixtures must produce byte-identical
Wasm and identical Node/Wago runtime observations. Failed fixtures must produce
identical ordered diagnostics and the same success/failure state. `--runtime`
may select one engine for focused debugging, but ordinary and full-project runs
execute both.

Generated Wasm and actual WAT remain temporary. `--update` refreshes diagnostics,
stdout output, and WAT, or removes stale WAT after an expected compilation
failure.

## Canonical rendering

The exact external printer version is pinned in:

```text
tools/module-snapshots/WASM_TOOLS_VERSION
```

No normalization removes physical types, indices, exports, or instructions. A
future Starshine-owned WAT renderer can replace the pin without changing fixture
layout.

## Current coverage and observation

The suite now contains 156 fixtures: 139 compiled WAT/runtime snapshots and 17
compiler-error snapshots. On August 2, 2026, all 139 compiled fixtures pass with
identical output/traps in Node and Wago.

```text
feature         total   compiled   compiler errors   expected traps
calls                2          0                 2                0
collections         14          9                 5                2
control-flow       18         18                 0                1
enums               11         11                 0                0
functions            1          0                 1                0
generics             1          1                 0                0
lanes               11         11                 0                0
memory               9          9                 0                1
modules              4          4                 0                0
names                2          0                 2                0
numeric             28         26                 2                1
reachability         1          1                 0                0
structs             11          8                 3                0
tests                3          2                 1                1
text                 23         23                 0                1
types                1          0                 1                0
wasi                 16         16                 0                5

total               156        139                17               12
nonempty stdout fixtures        85
WAT/no-trap-only fixtures       42
checked-in WAT lines        92,544
checked-in WAT bytes      2,685,603
```

Successful runtime coverage includes recursive and nested calls, scalar,
guarded-enum, Unit, nested, and return-producing functional loops, evaluation
order, Boolean/integer/float literal matching, guarded and dense enum dispatch,
unit/tuple/struct payloads, nested and reordered aggregate construction, all
scalar carrier widths, wrapping, conversion, comparison, floating arithmetic,
native SIMD, SWAR saturation and population counts, unaligned scalar/vector
memory, exact UTF-8 output, builders, shared/copied ranges, short and long
search, non-stdout writes, complete and partial stdout writes, deterministic stdin,
short reads, errno, zero-progress and over-report traps, the 65,521-byte staging
boundary, a 100,000-byte multi-window write, same-module multi-file compilation,
static imported-module linking, and explicit passing/failing test-mode execution.

The 42 empty-output fixtures intentionally preserve compiler-output and no-trap
coverage without forcing WASI reachability into every module. This is important
for import, memory, helper, and dead-callable elimination snapshots.

Compiler-error coverage includes unknown names and types, wrong call arity,
invalid call targets, return mismatches, unknown and missing fields, duplicate
declarations and construction fields, out-of-range numeric literals, and
homogeneous operator mismatch. Multiline diagnostic structure is retained.

Bool literal-pattern emission is now successful. Match scratch locals use the
scrutinee's physical scalar carrier instead of an unconditional nullable
`eqref`, and literal conditions emit carrier-specific equality instructions.
`control-flow/bool-match` exercises both `true` and `false`, writes `"10"`, and
now has a validated deterministic WAT snapshot.

The import prepass now selects independently collected compiler-owned standard
modules and user modules consume only their frozen interfaces. Whole-program
reachability removes elided signature slots, dead external type references,
unused standard nominal layouts, and unreachable runtime functions before final
indices. Across 139 compiled fixtures, checked-in WAT is now 92,544 lines and
2,685,603 bytes, down from the original 431,150 lines and 21,839,923 bytes while
retaining deterministic diagnostics and runtime behavior. The generic fixture
covers ambient `Option`/`Result` construction and pattern matching across scalar
and reference carriers.

Generated byte tables remain a portable explicit bootstrap source provider and
are never injected into user declaration arenas. Ordinary snapshot compilation
loads the import-selected source subset from the resolved on-disk `dew.std`
package. Persistent content-addressed frozen-interface caching remains future
work.

## Commands

```text
tools/module-snapshots/run.sh
tools/module-snapshots/run.sh --fixture text/concat
tools/module-snapshots/run.sh --update
```

## Later extensions

Continue organizing by feature: `numeric/`, `control-flow/`, `structs/`,
`enums/`, `text/`, `lanes/`, `memory/`, `wasi/`, `modules/`, and `tests/`.
Successful cases, warnings, compiler failures, and edge cases stay beside the
feature they exercise. Do not organize by output/outcome type, and do not put a
module graph into JSON.
