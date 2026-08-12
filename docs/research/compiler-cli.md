# Initial Dew compiler CLI

## Status

`tools/dew` provides deterministic `check`, `build`, `run`, and `test` commands
over explicitly ordered source paths and statically linked module groups. The
explicit-file test command is driven by compiler-owned V3 metadata. The CLI
resolves the compiler-owned `dew.std` package from ordered package roots, loads
the exact import-selected source subset from disk, and reuses content-addressed
persistent standard and versioned external dependency frozen interfaces. It
also publishes verified installed-package capsules and can recover a removed
locked dependency tree from those artifacts without changing emitted Wasm.
Network package acquisition and installed release binaries remain pending.
Stable file-aware diagnostics already include source excerpts, carets, and
secondary labels. Convention-discovered `dew.json` packages, exact
`dew.lock` resolution, `run`, and explicit `dew.modules.json` compiler graphs
are supported.

## Commands

```text
tools/dew check [--root NAME] [--module NAME] FILE ...
tools/dew build [--root NAME] [--module NAME] -o OUTPUT FILE ...
tools/dew test [--module NAME] [filters] FILE ...
tools/dew check                         # discovers ./dew.json
tools/dew build -o OUTPUT               # discovers ./dew.json
tools/dew test [filters]                # discovers ./dew.json
tools/dew check --manifest PATH
tools/dew build --manifest PATH -o OUTPUT
tools/dew test --manifest PATH [filters]
tools/dew check --package-root ROOT FILE ...
tools/dew check --no-default-preamble FILE ...
tools/dew check --bootstrap-std FILE ...
tools/dew check --cache-report FILE ...
tools/dew check --no-interface-cache FILE ...
```

The default explicit-file module name is `main`. Repeating `--module NAME` starts another statically linked module, and `--root NAME` selects the link root. Explicit `dew.modules.json` graphs preserve listed module/file order. Package mode instead derives one module from `@scope/name` and deterministically sorts conventional `src/**/*.dew` or immediate sibling `*.dew` sources. Production commands exclude `_test.dew`; package tests include it.

`--package-root ROOT` is repeatable and resolves `dew.std` from either
`ROOT/dew.std/std/...` or the checkout-compatible `ROOT/std/...` layout.
`DEW_PACKAGE_ROOTS` supplies an ordered platform-path-separated root list when
no command-line roots are present. Explicit or environment roots fail closed if
none contains the package; only the no-option bootstrap launcher falls back to
the compiler checkout root. Source loading uses a fixed compiler registry and
reads only paths required by implicit defaults and leading imports.

`--bootstrap-std` selects generated source providers for bootstrap/compiler
comparisons and disables persistent standard-interface caching. For `check` and
`build`, `--no-default-preamble` disables implicit user imports of
`dew.std.preamble`, `dew.std.option`, and `dew.std.result`; explicit imports,
including `open dew.std.*`, remain available. `dew test` does not
accept this option because its compiler-owned assertion runtime requires the
standard test preamble.

The default cache locations are `.dew-cache/interfaces/` for frozen bundles and
`.dew-cache/packages/` for installed package capsules; `DEW_CACHE_DIR` changes
the shared root. `--no-interface-cache` or `DEW_INTERFACE_CACHE=0` disables
frozen-interface reuse, and
`--cache-report` prints `miss`, `hit`, or `disabled`. Keys are SHA-256 hashes of
the exact ordered selected standard logical paths and source bytes plus a
private compiler cache ABI marker. Cache payloads use deterministic semantic
serialization and an envelope checksum. Corrupt or identity-mismatched cache
artifacts fail visibly instead of silently recompiling. Package capsules bind
exact lock provenance, dependency requests, ordered source payloads, per-file
checksums, and an envelope checksum. Missing locked package trees are restored
through a staged atomic rename; corrupt, mismatched, or unsafe capsules and
nonempty partial destinations fail visibly. See
`docs/research/persistent-standard-interface-cache.md`.

`check` executes collection, frozen interfaces, module analysis, lowering, and
static WasmGC link planning without encoding a binary. `build` executes the same
pipeline, validates through Starshine, encodes deterministic WasmGC, and writes
the requested output only after diagnostics are empty.

The bootstrap launcher uses a release native MoonBit executable:

```text
tools/dew ...
```

`dew test` requires at least one `_test.dew` path, compiles every supplied file
in manifest order, and invokes only compiler-described exports. It supports the
same exact file/name and identity-substring filters plus `--list`; matching
expected traps pass without aborting the remaining run.

A future installed `dew` binary should replace the `moon run`/Python bootstrap
launchers without changing command semantics.

## Diagnostics and exits

`dew check`, `dew build`, and the test compiler render diagnostics with stable
logical paths, one-based byte line/column positions, the owning source line, a
caret, and deterministic secondary labels where related source locations exist.
Diagnostics retain their current deterministic semantic `Debug` value as the
message until stable human diagnostic codes and prose are defined. For example:

```text
tests/compile-fail/unknown-value.dew:2:3: error: UnknownValueName(2, 0, 25)
  |
2 |   missing_value
  |   ^
```

The compiler retains immutable path/source records independently from parser
tokens, so parser-token eviction cannot erase later semantic excerpts. HIR
expressions, patterns, blocks, block items, object/pattern fields, arms, lambda
parameters, and type syntax retain aligned `FileId` provenance. Final diagnostics
sort by module order, manifest file order, byte offset, and deterministic rank.
Duplicate declarations/fields/tests, return-type mismatches, implementation
conflicts, and cross-file initialization cycles add stable secondary labels.
The snapshot compiler keeps its framed `DEW_ERROR`/`DEW_WARNING` transport so
multiline rendered diagnostics remain one JSON string; the user CLI prints the
rendered text directly.

Exit status is:

- `0` for successful checking or building;
- `1` for compiler, link, validation, or emission diagnostics;
- `2` for CLI usage, input I/O, or output I/O failures.

## Validation

The full `tools/check.sh` workflow checks a valid scalar fixture through default
and explicit package roots, compiles the standard wildcard fixture, requires
on-disk/generated/cache-miss/cache-hit providers to produce byte-identical Wasm,
verifies miss/hit/disabled reporting, source-content invalidation,
fail-visible corruption, installed dependency removal/recovery, and
byte-identical recovered Wasm, builds the multi-module linking fixture, verifies
file-aware compiler failures, runs the `compile-pass`, `compile-fail`, and
`run-pass` CLI fixture directories, runs explicit and manifest test packages,
and requires failed assertions to report their exact dynamic Unicode message
without leaking a Python traceback.

## Next steps

1. Add registry lookup, Git checkout, and deterministic lockfile generation
   without weakening exact installed-package provenance.
2. Measure cache-file/package-capsule I/O and representative external-package
   workloads; serialize collected bodies only if restoration-time syntax
   collection is a measured bottleneck.
3. Replace semantic `Debug` messages with stable human diagnostic codes and
   prose without changing source ordering or labels.
4. Improve entry-point and host diagnostics as runtime semantics continue to
   stabilize.
