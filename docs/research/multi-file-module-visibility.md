# Multi-file module visibility, imports, and opens

## Status

Stable `FileId`, source provenance, manifest-ordered multi-file collection, shared cross-file name resolution, complete cross-file Wasm emission, qualified module aliases, and module-scoped opens are implemented. `global` is not reserved.

## Files and modules

A Dew file is a source container, not a namespace or visibility boundary. Every file assigned to one module contributes declarations to the same module-level namespaces:

- types;
- traits;
- values and overload sets;
- implementation evidence;
- fields and variants through their owning declarations;
- callable bodies.

Therefore these two files are intended to work without an import between them:

```dew
// helpers.dew
fn double(value: I32) -> I32 {
  value + value
}
```

```dew
// main.dew
pub fn run(value: I32) -> I32 {
  double(value)
}
```

`double` is `ModuleVisible`, so every file in the same module may call it. `pub` is required only when a declaration must be visible outside the module. Dew still has no file-private visibility.

## Deterministic collection

`collect_program_files` consumes independently parsed file event streams in one manifest-defined stable file order. Within each file, declarations retain parser source order. Module-local declaration IDs then follow:

```text
`dew.std.preamble` prefix
→ file order
→ declaration and method order within each file
```

File-system enumeration and worker completion order must never assign identities.

Physical byte offsets remain source-local. Stable source identity is represented separately:

```moonbit
pub struct SourceLocation {
  file : FileId
  offset : UInt64
}
```

`FileId` uses the packed module/local representation and is assigned by `make_program_file_id` from manifest order. `CollectedModule` freezes its file list plus declaration/body file tables. `declaration_location` and `body_location` return `SourceLocation`; parser and duplicate-name collection diagnostics retain their originating file IDs. Packing file identity into byte offsets remains forbidden.

The current API is:

```moonbit
pub struct ProgramFile {
  id : FileId
  source : Bytes
}

pub fn collect_program_files(
  ModuleId,
  Array[ProgramFile],
) -> CollectedModule
```

The first 256 module-local file-ID slots are reserved for compiler-owned preamble files. User IDs begin at the stable manifest-order offset returned by `make_program_file_id`, so adding a small preamble file does not renumber user files.

The logical `dew.std.preamble` module is mirrored under `std/preamble/` as `00-builtins.dew`, `10-traits.dew`, and `20-i32.dew`.

## Qualified imports and module-scoped opens

The preamble grammar distinguishes exact module naming from unqualified lookup:

```text
module                       = preamble declaration*
preamble                     = preamble-item*
preamble-item                = qualified-import-declaration
                             | open-import-declaration
qualified-import-declaration = "import" module-path ("as" at-identifier)? line-end
open-import-declaration      = "open" module-path ("." "*")? line-end
```

Example:

```dew
open dew.std.preamble
open dew.std.map

pub fn run() -> I32 {
  1 + 2
}
```

`import my.lib as @lib` binds one exact module namespace and contributes no unqualified names. `open my.lib` contributes public names and coherent implementation evidence to the owning Dew module's unqualified lookup. Both forms declared in any file are module-scoped, but neither affects another Dew module or re-exports declarations. Both are invalid after the first ordinary declaration in their source file, keeping preamble recognition forward-only.

## Lookup

The unqualified lookup tiers are:

1. declarations in the current module;
2. explicitly opened module interfaces;
3. compiler-owned ambient preamble interfaces.

Qualified aliases occupy a separate module-namespace table and are addressed only through `@alias.member`. A collision between distinct opened declarations is diagnostic. Source order does not select a winner. Standard operator syntax retains canonical standard-trait identities rather than silently switching to an unrelated current-module trait with the same short name.

## Preamble migration

The current bootstrap implementation parses a compiler-owned `dew.std.preamble` event stream before the user event stream in each program. Once module interfaces and evidence imports exist, this becomes semantically equivalent to an implicit:

```dew
open dew.std.preamble
```

The raw `collect_bytes` API remains useful as the no-default-preamble mode for compiler bootstrapping and focused tests.

## Current boundary

Non-callable imported values, deep file provenance, frozen standard interfaces,
installed dependency capsules, and cache recovery are implemented. Remaining
module work is `@alias` qualification in additional namespaces, duplicate
import/open/alias diagnostics across files, selective imports, re-exports, and
shadowing policy; see `docs/roadmap.md`.
