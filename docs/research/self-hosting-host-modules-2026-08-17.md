# Self-hosting host modules — August 17, 2026

## Decision

Do not add one broad `dew.std.host` module. Split pure contracts from host
adapters:

```text
dew.std.path
dew.std.fs
dew.std.fs.wasi
dew.std.fs.wpsi
dew.std.process
dew.std.process.wasi
dew.std.process.wpsi
```

`dew.std.path` owns relative path validation and normalization without host
calls. `dew.std.fs` owns provider-neutral path kinds, errors, filesystem
contracts, and composed operations such as bounded complete reads and atomic
publication. `dew.std.process` owns ordered arguments, environment lookup,
stdout, stderr, and explicit exit.

The WASI and WPSI modules are adapters. Compiler code receives filesystem and
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

The Core Wasm linker normally keeps Dew-defined memories before guest-defined
memories. A provider named `wpsi` is different: the provider's defined memories
must precede Dew memories so WPSI keeps memory 0. Every explicit and implicit
memory use is remapped through the same index map.

WPSI providers with imported memories are rejected. Supporting that shape would
require deterministic interleaving and coalescing rules for imported memories,
which are not defined by the current foreign-provider ABI.

## WPSI source and adapter boundary

The exact WPSI import names and signatures come from `github:jtenner/wpsi` at
commit `0eb37b13def5785fe904ac5ed73a94c297a736f1`. The WPSI 0.1 draft uses
ordinary imports from module `wpsi`, explicit memory indexes, and
representation-specific function names.

Dew uses WPSI's GC `array_i8` profile. The checked-in
`fixtures/wpsi/wpsi-adapter.wasm` converts WPSI multi-value results into exact
GC result structs that Dew foreign nominal types can bind through the static
linker. `tools/generate_wpsi_adapter.py` validates and reproduces the fixture.

## Validation

Permanent coverage includes:

- strict relative-path validation and joining;
- provider-neutral filesystem and process trait dispatch;
- selective and wildcard standard-module loading;
- frozen-interface handling for module-local foreign library namespaces;
- WPSI provider memory-zero ordering in the Core Wasm linker;
- reproducible validation of the WPSI adapter module;
- linked Dew/WPSI smoke-module validation;
- all 65 NIST CAVS SHA-256 short-message vectors.
