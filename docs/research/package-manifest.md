# Dew package definition and lockfile

## Status

Implemented for `dew check`, `build`, `test`, and `run`. Dew-native bounded
codecs and validation are also available through `dew.std.package` and
`dew.std.package.artifact`; see
[`package-formats-and-semver-2026-08-17.md`](package-formats-and-semver-2026-08-17.md).
Package intent and resolution state are separate:

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
empty object. Package names use `@scope/name`; package versions are exact bounded
Semantic Versioning 2.0.0 values represented by `dew.std.semver`. Dependency values accept exact versions, `^` ranges, `~` ranges, `*`,
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

`src` selects recursion only when it is a real directory. A regular file named
`src` uses the root fallback. An empty `src` directory does not fall back.
Sort complete logical paths by UTF-8 byte order. Selected files and directories,
package paths, and their ancestors must not be symbolic links. Read errors stay
visible. Source paths must be safe relative slash paths that end in `.dew`.
They cannot have empty, `.` or `..` parts, NUL, backslashes, absolute drive
roots, duplicate entries, or file/directory conflicts. `dew.json/` is reserved.
Source paths have a 4,096-byte limit. Each source has a 16 MiB limit.

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

Package integrity version 1 hashes package identity/version, derived module identity,
ordered conventional logical paths and exact source bytes, and sorted dependency
requests. It intentionally does not hash `dew.lock`: changing only where an
identical dependency is materialized does not change package source identity.

Phase 1 aligns byte ordering across JavaScript and the bootstrap. Old local
locks or cache artifacts made with length-first ordering can need regeneration.
The unreleased format stays version 1.

## Local package preparation

```text
tools/dew pack --manifest path/to/dew.json --output new-pack-directory
tools/dew publish --dry-run --manifest path/to/dew.json --output new-pack-directory
```

Both commands build and check one private source snapshot. They also capture
the materialized dependency graph and standard-library sources used by the
build. They do not read credentials or make a network request. The compiler and
its installed dependencies must already be available. Use `--help` for options.

The output directory must be new; its parent must exist. It contains:

- `package.dpa`: the checked version 1 source capsule.
- `INPUTS.json`: local identity, source and interface hashes, source inventory,
  capsule hash and byte count, validation graph, standard source identity, and
  build output data.

The CLI prints these checked inputs. The compiler build identity is currently
unavailable in ABI metadata and is marked absent. The input record is not a
public release descriptor. GitHub source/tag checks and public release metadata
belong to the publish phase. A public release requires a public GitHub repository
and an existing remote version tag; local pack does not prove those facts.

The complete publish capsule has a 64 MiB bound, including framing and checksum.
Local compiler artifacts keep their separate 256 MiB codec bound. Manifest input
has a 1 MiB bound, local locks have an 8 MiB bound, direct dependencies have a
256-record bound, and local lock graphs have a 4,096-record bound. No network
install, version resolver, or auth change is part of Phase 1.

The persistent interface-cache key separately hashes every resolved dependency's
name, exact version, source, package integrity, and expected interface fingerprint.
Changing lock resolution or dependency content therefore creates a different version 1
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
