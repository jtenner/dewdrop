# Minimal Dew package manifest

## Status

Implemented for bootstrap `dew check`, `dew build`, and self-describing
multi-module `dew test`. Compiler-owned `dew.std` package-root resolution and
explicit default-preamble opt-out are implemented outside the strict manifest
schema. General external dependencies, package publication metadata, versions,
and source globs remain pending.

## File and schema

The initial manifest is strict UTF-8 JSON, conventionally named `dew.json`:

```json
{
  "root": "app.main",
  "modules": [
    {
      "name": "app.library",
      "files": [
        "library.dew"
      ]
    },
    {
      "name": "app.main",
      "files": [
        "main.dew"
      ]
    }
  ]
}
```

Only the shown fields are accepted. Duplicate JSON keys, duplicate module names,
duplicate source paths, unknown fields, missing fields, empty module/file lists,
undeclared roots, absolute paths, non-`.dew` paths, missing files, paths outside
the manifest directory, and paths outside the compiler workspace are rejected
before compilation.

## Determinism

Module array order is semantic manifest order. Each module's file array is its
semantic file order. The loader performs no filesystem enumeration, globbing,
or hash-order traversal. Paths are resolved relative to the manifest directory
and passed to the compiler as stable workspace-relative logical paths.

The `root` field selects the static-link root independently of module order.
Imports inside Dew sources continue to use canonical dotted module names.
Wildcard imports expand only over deterministic module paths already collected;
they do not discover manifest files or modules from disk.

## Commands

```text
tools/dew check --manifest path/to/dew.json
tools/dew build --manifest path/to/dew.json -o output.wasm
tools/dew test --manifest path/to/dew.json
tools/dew check --package-root /opt/dew/packages --manifest path/to/dew.json
tools/dew check --no-default-preamble --manifest path/to/dew.json
```

Explicit `--module` and `--root` arguments cannot be mixed with `--manifest`.
Explicit ordered-file mode remains available for compiler fixtures and bootstrap
workflows.

## Convention-based successor

The current explicit JSON graph remains the bootstrap format while a strict TOML package format is implemented. The successor manifest will contain package identity/version/edition and dependencies rather than ordinary module/file lists. Modules are derived from deterministic sorted `src/**/*.dew` paths beneath the root package or `.dew/packages/<package-name>/`, with the package name prepended and path separators converted to dots. For example, `.dew/packages/custom/src/sub/package.dew` defines `custom.sub.package`; `package_test.dew` is the test-only companion of that module.

Imports derive the final path segment as a default `@alias`, and `import my.lib as @custom` selects an explicit alias. Direct `@intrinsic` expressions are removed; compiler-known WebAssembly operations are declared in `dew.std.wasm.intrinsics`. The bootstrap may use host TOML parsing initially, but `dew.std.toml`, `dew.std.json`, and `dew.std.yaml` are all roadmap-owned Dew implementations.

## Boundaries

This schema intentionally omits version ranges, external dependencies, package
identity, source discovery, generated sources, resources, target profiles,
features, editions, and host permissions. The bootstrap launcher resolves only
the compiler-owned `dew.std` identity from ordered `--package-root` values or
`DEW_PACKAGE_ROOTS`, using a fixed source registry rather than directory
enumeration. Its standard frozen interfaces are persisted by exact source
content, but general dependency fields should be added only when the compiler
can assign versioned external package identities, integrity hashes, and
dependency-interface fingerprints without weakening deterministic builds.

Manifest-driven `dew test` compiles every listed module/file in exact manifest
order. Program linking assigns globally unique `__dew_test_<ordinal>` exports in
manifest module/file/declaration order, embeds complete V3 identities in
`dew.tests`, and supports package-wide filters and listing without source
scanning or filesystem discovery.
