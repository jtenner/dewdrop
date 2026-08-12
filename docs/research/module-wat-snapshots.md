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
silently truncating it at the first line. The current snapshot spelling is the
same deterministic source renderer used by the CLI: manifest-stable logical
path, byte-based line/column, severity, semantic `Debug` message, source excerpt,
caret, and any secondary labels.

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

The runner builds the native snapshot compiler once and invokes that executable
directly for every compilation. Independent fixtures run concurrently with one
temporary interface-cache directory per fixture, preventing concurrent cache
writers or an inherited `DEW_CACHE_DIR` from affecting another fixture. The
default worker count is the smaller of eight and the host CPU count. Results are
buffered and emitted in sorted fixture order, so concurrency does not change
visible output or failure ordering. `--jobs 1` restores serial fixture execution,
and `DEW_SNAPSHOT_JOBS` changes the default.

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

Fixtures are discovered recursively from the checked-in tree, and the runner
prints the authoritative totals. Counts are intentionally not duplicated here.
Every successful fixture compiles twice to byte-identical Wasm, compares
canonical WAT, and executes with identical normalized output or traps in Node
and Wago Core 3. Failed fixtures produce deterministic ordered diagnostics and
no WAT.

Coverage spans calls, collections, control flow, enums, functions, generics,
lanes, memory, modules, names, numeric operations, optimization contracts,
reachability, structs, tests, text, types, and WASI. Optimized fixtures lock in
source order, exactly-once evaluation, trap order, allocation removal, local
reuse, scalar replacement, enum-payload elimination, and exact trait-object
directization.

The import prepass selects independently collected compiler-owned standard
modules, and whole-program reachability removes dead signatures, external type
references, nominal layouts, and runtime functions before final indexing.
Generated standard byte tables remain an explicit bootstrap provider; ordinary
snapshot compilation loads the selected on-disk `dew.std` sources and may reuse
verified persistent interface caches.

## Runner performance

On August 8, 2026, on the 16-logical-CPU development host, the then-current
Node/Wago suite measured:

```text
previous moon run per compilation       36.206 s
one prebuilt compiler, serial jobs       25.377 s
one prebuilt compiler, eight jobs         6.021 s
```

The prebuilt parallel runner reduced this stage's wall time by about 83% while
retaining duplicate compilation, byte-for-byte reproducibility checks, both
runtimes, Wasm validation, WAT comparison, and deterministic result ordering.
These are host-specific development measurements rather than contractual
resource budgets.

## Commands

```text
tools/module-snapshots/run.sh
tools/module-snapshots/run.sh --jobs 1
tools/module-snapshots/run.sh --fixture text/concat
tools/module-snapshots/run.sh --update
```

## Later extensions

Continue organizing by feature: `numeric/`, `control-flow/`, `structs/`,
`enums/`, `text/`, `lanes/`, `memory/`, `wasi/`, `modules/`, and `tests/`.
Successful cases, warnings, compiler failures, and edge cases stay beside the
feature they exercise. Do not organize by output/outcome type, and do not put a
module graph into JSON.
