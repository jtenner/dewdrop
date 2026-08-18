# Self-hosting host modules — August 17, 2026

Updated on August 18, 2026 for the Facet provider and current `facet-spec` ABI.

## Decision

Do not add one broad `dew.std.host` module. Split pure contracts from host
adapters:

```text
dew.std.path
dew.std.fs
dew.std.fs.wasi
dew.std.fs.facet
dew.std.process
dew.std.process.wasi
dew.std.process.facet
```

`dew.std.path` owns relative path validation and normalization without host
calls. `dew.std.fs` owns provider-neutral path kinds, errors, filesystem
contracts, and composed operations such as bounded complete reads and atomic
publication. `dew.std.process` owns ordered arguments, environment lookup,
stdout, stderr, and explicit exit.

The WASI and Facet modules are adapters. Compiler code receives filesystem and
process capabilities explicitly and does not select a host with ambient global
state. This split was implemented on August 17, 2026.

## First fixed-point scope

Filesystem operations:

- path kind: missing, file, or directory;
- bounded complete file read;
- complete partial-write-safe file write;
- recursive directory creation;
- same-directory temporary write, sync, close, and rename;
- remove an explicitly owned file or empty directory.

Process operations:

- ordered arguments;
- environment lookup with missing distinct from empty;
- separate stdout and stderr;
- explicit exit status.

Process spawning, package download, recursive general-purpose deletion, WAT
rendering, and runtime selection remain launcher work.

## Linker memory policy

The Core Wasm linker keeps Dew-defined memories before guest-defined memories and
remaps every explicit and implicit memory use through the same index map. Facet
has no memory-zero exception. The Facet ABI passes an explicit memory index to
every linear-memory operation, and the GC-array profile used here requires no
linear-memory index.

## Facet source and adapter boundary

The exact Facet import names and signatures come from `github:jtenner/facet-spec` at
commit `c6014e7f086f3d3d7ff5e1e7d65a7e6f24e1dcab`. The Facet 0.1 draft uses
ordinary imports from module `facet`, explicit memory indexes, and
representation-specific function names.

Dew uses Facet's GC `array_i8` profile. The checked-in
`fixtures/facet/facet-adapter.wasm` converts Facet multi-value results into exact
GC result structs that Dew foreign nominal types can bind through the static
linker. The adapter uses strict UTF-8 argument and environment length/copy
imports. Scratch filesystem allocation and string-resource handles are absent;
filesystem access starts from an indexed preopen. `tools/generate_facet_adapter.py`
validates and reproduces the fixture.

## Validation

Permanent coverage includes:

- strict relative-path validation and joining;
- provider-neutral filesystem and process trait dispatch;
- selective and wildcard standard-module loading;
- frozen-interface handling for module-local foreign library namespaces;
- ordinary Dew-first memory ordering for Facet providers;
- reproducible validation of the Facet adapter module;
- linked Dew/Facet smoke-module validation;
- all 65 NIST CAVS SHA-256 short-message vectors.
