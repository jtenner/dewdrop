# Module preambles, manifests, interfaces, and dependency graphs

## Status

Initial immutable implementations are complete for the first four module-system roadmap milestones:

1. qualified imports, module-scoped opens, aliases, and terminal open wildcard prefixes;
2. deterministic in-memory manifests and module/file identity assignment;
3. frozen public module interfaces;
4. deterministic import dependency graphs and iterative SCC scheduling.

Cross-module public type, trait, alias, and direct function resolution is now implemented on top of these artifacts; see `cross-module-semantic-imports.md`.

## Preamble imports

The parser accepts:

```dew
open dew.std.preamble
open dew.std.*
open app.features.*
```

The parsed representation retains:

```moonbit
pub struct ImportDeclaration {
  open_ : Bool
  path : Array[String]
  wildcard : Bool
  import_alias : String?
  import_alias_offset : UInt64
  offset : UInt64
}
```

Qualified `import` and unqualified `open` declarations are accepted only while a file's contiguous preamble remains open. The first ordinary declaration permanently closes preamble mode for that file; a later import/open produces `ImportAfterDeclaration` while parsing continues. `global` is no longer reserved.

Dotted paths require one or more identifier segments. `import module.path` derives `@path` from the final segment, and `import module.path as @alias` overrides it. Qualified imports reject wildcards and contribute no unqualified names. `open module.path` contributes public names only to the owning Dew module's unqualified lookup; `open prefix.*` expands terminal wildcards. Opens reject aliases. Neither form re-exports declarations.

Collection joins path segments into a canonical dotted string and retains the import's `FileId`, open/qualified mode, wildcard flag, optional alias, and source offsets. Dependency planning expands open wildcard prefixes only over deterministic paths already present in `CollectedProgram`; it never discovers modules from disk. The private `dew.std.text_runtime` module is excluded from direct wildcard scope.

## In-memory manifests

The initial driver-neutral manifest model is:

```moonbit
pub struct ManifestFile {
  path : String
  source : Bytes
}

pub struct ManifestModule {
  path : String
  files : Array[ManifestFile]
}

pub struct ProgramManifest {
  modules : Array[ManifestModule]
}
```

`collect_program_manifest` assigns:

```text
ModuleId = module_id_base + manifest_module_index
FileId   = packed ModuleId + manifest_file_index offset
```

Module and file identities therefore depend only on explicit manifest order. Directory enumeration and worker completion order cannot affect them.

The collector diagnoses empty and duplicate module/file paths. Strict explicit compiler graphs are now named `dew.modules.json`; convention-first `dew.json` package definitions derive modules and sorted sources, while exact transitive resolution lives in `dew.lock`. Ordered compiler-owned `dew.std` roots, versioned/Git dependency requests, source integrity, interface expectations, and V9 dependency-interface caching are implemented by the bootstrap driver.

## Frozen module interfaces

`freeze_module_interface` consumes:

- `CollectedModule`;
- `ResolvedModuleTypes`;
- `PlannedModuleFunctions`.

It publishes a `FrozenModuleInterface` containing:

- module identity and path;
- the immutable resolved-type arena required to interpret exported type IDs;
- public user type, trait, and value declarations;
- public function/builtin signatures;
- requirements of public traits;
- flattened parameter signature records;
- non-foreign user implementation evidence.

Compiler-owned `dew.std.preamble` declarations are excluded from each user's exported interface. Module-visible functions and types are also excluded.

The interface retains no parser AST and no executable body HIR. Callable body identities are erased into interface callable kinds. Lookup helpers provide declaration and overload lookup by public name.

`freeze_program_interfaces` executes interface jobs in dependency-SCC order but stores final interfaces in stable manifest order.

## Dependency graph

`build_module_dependency_graph` resolves collected import paths against the manifest path table. It publishes:

- stable module IDs;
- one dependency span per module;
- sorted dependency module indices;
- dependency-first SCC spans and members;
- missing and duplicate import diagnostics with source file and offset.

Compiler-owned `dew.std` modules do not require manifest entries. The default user scope imports preamble, Option, and Result; `--no-default-preamble` disables those implicit edges while preserving explicit exact and wildcard imports.

SCC discovery is iterative and does not recurse on the host stack. Members inside one SCC are source/manifest ordered. Module cycles are represented rather than immediately rejected because signature/type cycles and eager runtime initialization cycles require different policies.

## Current boundary

The remaining boundaries are narrower than the initial implementation plan:

- imported module aliases qualify function calls and non-callable public values; qualification of imported types, traits, variants, patterns, and static impls remains pending;
- external selected calls are statically linked rather than exposed as separate Wasm imports;
- registry/network package installation and installed artifact-only interface recovery remain pending; exact locked dependency resolution, integrity checks, interface fingerprints, and persistent external-interface caching are implemented.

Imported aggregate construction/access, implementation-evidence merging, module-value inference, and cross-module eager-initialization-cycle analysis now build on the frozen parser, identity, interface, and graph artifacts described above.

## Validation

Tests cover:

- qualified imports, module-scoped opens, explicit/default aliases, and terminal open wildcard expansion;
- rejected aliases on opens and rejected wildcards on qualified imports;
- imports after declarations;
- import collection with `FileId` provenance;
- deterministic module and file IDs;
- missing imports;
- duplicate imports;
- a two-module dependency cycle;
- dependency-first SCC ordering;
- public-interface filtering;
- public trait requirement signatures;
- program-wide interface freezing in SCC order.
