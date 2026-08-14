# Dew package definition and lockfile

## Status

Implemented for `dew check`, `build`, `test`, and `run`. Package intent and
resolution state are separate:

- `dew.json` contains only package identity, version, and dependency requests;
- `dew.lock` contains exact resolved package locations and compatibility data;
- Dew source ownership follows deterministic conventions rather than file lists.

The earlier explicit root/module/file graph remains available as a bootstrap
module manifest, conventionally named `dew.modules.json`. It is not a package
definition and cannot contain package identity or dependency records.

## Package definition

`dew.json` is strict UTF-8 JSON:

```json
{
  "name": "@fixture/application",
  "version": "1.0.0",
  "dependencies": {
    "@fixture/library": "^1.2.0",
    "@fixture/git-library": "git+https://example.test/fixture/git-library.git#abc123"
  }
}
```

`name` and `version` are required. `dependencies` is optional and defaults to an
empty object. Package names use `@scope/name`; package versions are exact semantic
versions. Dependency values accept exact versions, `^` ranges, `~` ranges, `*`,
or Git URLs. Duplicate JSON keys, unknown fields, invalid package names, invalid
versions, and invalid requirements fail before source collection.

The package definition never contains resolved paths, integrity hashes, ABI
fingerprints, module names, root selection, or source lists.

## Source and module conventions

One package defines one Dew module. Its module path is derived from its package
name by removing `@`, replacing `/` with `.`, and replacing `-` with `_`:

```text
@fixture/application      -> fixture.application
@fixture/package-callback -> fixture.package_callback
```

If `src/` exists, source files are the lexicographically sorted recursive
`src/**/*.dew` set. Otherwise, source files are the lexicographically sorted
immediate `*.dew` files beside `dew.json`. The fallback keeps small packages
minimal without accidentally collecting nested dependency checkouts.

`check`, `build`, and `run` exclude `_test.dew`; `test` includes it only for the root package, not dependencies. Package integrity covers both production and test sources so changing any published Dew
source changes the package digest.

Running `tools/dew` in a directory containing `dew.json` discovers the package
automatically:

```text
tools/dew check
tools/dew build -o application.wasm
tools/dew test
tools/dew run
```

`--manifest PATH` remains available for automation and may name either a package
directory, `dew.json`, or an explicit `dew.modules.json` bootstrap graph.

## Lockfile

A package with dependencies requires sibling `dew.lock`:

```json
{
  "lockfileVersion": 1,
  "packages": [
    {
      "name": "@fixture/library",
      "version": "1.2.3",
      "source": "file:dependency",
      "path": "dependency",
      "integrity": "sha256-...",
      "interface": "64 lowercase hexadecimal digits"
    }
  ]
}
```

The root lockfile owns the complete transitive resolution. Each package record
contains:

- exact package identity and semantic version;
- resolution source, equal to the dependency Git URL for Git requirements;
- relative path to the materialized package checkout;
- canonical package source integrity;
- expected transitive Dew interface fingerprint.

The current bootstrap resolver consumes already materialized package paths; it
does not perform network or registry installation. A future installer may choose
the package-store path, but compilation continues to consume the same lockfile
record.

Resolution rejects missing lock entries, duplicate records, unsupported lockfile
versions, paths outside the workspace, semantic-version mismatches, Git-source
mismatches, package identity mismatches, source-integrity mismatches, dependency
cycles, module-name collisions, and compiler-observed interface mismatches.
Dependency modules are ordered before dependents deterministically.

## Integrity and cache identity

```text
tools/dew package-integrity path/to/package
tools/dew package-integrity path/to/package/dew.json
```

Package integrity V2 hashes package identity/version, derived module identity,
ordered conventional logical paths and exact source bytes, and sorted dependency
requests. It intentionally does not hash `dew.lock`: changing only where an
identical dependency is materialized does not change package source identity.

The persistent interface-cache key separately hashes every resolved dependency's
name, exact version, source, package integrity, and expected interface fingerprint.
Changing lock resolution or dependency content therefore creates a different V13
cache artifact.

## Explicit module manifests

Compiler fixtures that require multiple hand-authored modules may use a strict
`dew.modules.json` graph:

```json
{
  "root": "fixture.main",
  "modules": [
    { "name": "fixture.library", "files": ["library.dew"] },
    { "name": "fixture.main", "files": ["main.dew"] }
  ]
}
```

This format preserves exact listed order and performs no discovery. It is an
explicit compiler-input graph, not package metadata, and cannot declare package
versions or dependencies.
