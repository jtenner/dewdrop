# Initial Dew compiler CLI

## Status

`tools/dew` now provides deterministic `check` and `build` commands over
explicitly ordered source paths and statically linked module groups, plus an
explicit-file `test` command driven by compiler-owned V3 metadata. It resolves
the compiler-owned `dew.std` package from ordered package roots, loads the exact
import-selected source subset from disk, and reuses content-addressed persistent
standard frozen interfaces. General external dependencies, `run`, human source
excerpts, user-package caching, and installed release binaries remain pending.
Strict minimal `dew.json` manifests are supported for checking, building, and
self-describing multi-module tests.

## Commands

```text
tools/dew check [--root NAME] [--module NAME] FILE ...
tools/dew build [--root NAME] [--module NAME] -o OUTPUT FILE ...
tools/dew test [--module NAME] [filters] FILE ...
tools/dew check --manifest PATH
tools/dew build --manifest PATH -o OUTPUT
tools/dew test --manifest PATH [filters]
tools/dew check --package-root ROOT FILE ...
tools/dew check --no-default-preamble FILE ...
tools/dew check --bootstrap-std FILE ...
tools/dew check --cache-report FILE ...
tools/dew check --no-interface-cache FILE ...
```

The default module name is `main`. Repeating `--module NAME` starts another
statically linked module, and `--root NAME` selects the link root (the first
module is the default). Module and file order are manifest order; the CLI never
depends on filesystem enumeration. Every path is retained as its logical source
path, including `_test.dew` ownership.

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

The default cache location is `.dew-cache/interfaces/`; `DEW_CACHE_DIR` changes
the root, `--no-interface-cache` or `DEW_INTERFACE_CACHE=0` disables it, and
`--cache-report` prints `miss`, `hit`, or `disabled`. Keys are SHA-256 hashes of
the exact ordered selected standard logical paths and source bytes plus a
private compiler cache ABI marker. Cache payloads use deterministic semantic
serialization and an envelope checksum. Corrupt or identity-mismatched cache
artifacts fail visibly instead of silently recompiling. See
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

Compiler diagnostics currently retain the deterministic framed debug transport:

```text
DEW_ERROR
<deterministic debug representation>
DEW_END
```

Exit status is:

- `0` for successful checking or building;
- `1` for compiler, link, validation, or emission diagnostics;
- `2` for CLI usage, input I/O, or output I/O failures.

File-aware line/column rendering, excerpts, carets, secondary labels, warning
severity, and stable human diagnostic codes remain separate roadmap work.

## Validation

The full `tools/check.sh` workflow checks a valid scalar fixture through default
and explicit package roots, compiles the standard wildcard fixture, requires
on-disk/generated/cache-miss/cache-hit providers to produce byte-identical Wasm,
verifies miss/hit/disabled reporting, source-content invalidation, and
fail-visible corruption, builds the multi-module linking fixture, verifies
framed compiler failures, runs explicit and manifest test packages, and
requires failed assertions to report their exact dynamic Unicode message
without leaking a Python traceback.

## Next steps

1. Add versioned external package identities, dependency integrity metadata,
   and dependency-interface fingerprints without weakening manifest order.
2. Extend persistent interface caching from compiler-owned `dew.std` to external
   user packages and add phase-only cache benchmarks.
3. Add `dew run` after entry-point and host semantics stabilize.
4. Replace debug diagnostics with stable file-aware rendering and expose
   deterministic `--emit` artifacts.
