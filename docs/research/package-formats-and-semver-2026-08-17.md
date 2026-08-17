# Package formats and SemVer — August 17, 2026

## Result

Dew now owns the bounded data model and codecs needed to read, write, and
validate its package-manager files. The public modules are:

```text
dew.std.format
dew.std.semver
dew.std.package
dew.std.package.artifact
```

Encoding and decoding are separate standard-library capabilities:

```dew
pub trait Encode<t_err> {
  fn encode(self) -> Result<Bytes, t_err>
}

pub trait Decode<t, t_err> {
  fn decode(bytes: Bytes) -> Result<t, t_err>
}
```

They live in `dew.std.encode` and `dew.std.decode`. Encoding validates before it
emits bytes. Decoding is always fallible; there is no trusted trapping decode
operation. `dew.std.format` retains the shared package-format error types and
receiver-based validation evidence.

## Supported files and limits

| file | Dew type | maximum encoded size |
|---|---|---:|
| `dew.json` | `PackageManifest` | 1 MiB |
| `dew.lock` | `PackageLock` | 8 MiB |
| `dew.modules.json` | `ModuleManifest` | 4 MiB |
| installed `.dpa` capsule | `PackageArtifact` | 256 MiB |

Additional bounds are:

- 255 bytes per package name;
- 2,048 bytes per dependency requirement or source identity;
- 4,096 bytes per logical path;
- 256 direct dependency requests;
- 4,096 locked package records;
- 1,024 explicit modules;
- 4,096 files per explicit module;
- 65,536 files per installed package capsule;
- 16 MiB per source file in an installed capsule.

JSON formats use strict UTF-8, reject duplicate JSON object keys through
`dew.std.json`, reject unknown fields, and produce compact deterministic JSON
with one trailing newline. The installed capsule remains compatible with the
existing `DEWPKG1\0` binary layout and its trailing SHA-256 checksum.

## SemVer

`SemVer` implements bounded Semantic Versioning 2.0.0 parsing and precedence.
Major, minor, patch, and numeric prerelease identifiers are U32 values. The
complete encoded version is limited to 255 bytes. Parsing rejects missing core
parts, leading zeroes, overflow, empty identifiers, invalid identifier bytes,
and repeated build separators.

Build metadata is retained in canonical output but ignored for precedence.
Package requirements support:

- exact versions;
- caret ranges;
- tilde ranges;
- `*`;
- `git+...#revision` sources.

Prerelease versions do not enter wildcard, caret, or tilde ranges unless the
range base selects that same prerelease precedence point.

## Validation

Permanent standard-library tests cover:

- valid, malformed, overflowing, prerelease, release, and build SemVer cases;
- exact, caret, tilde, wildcard, and Git requirements;
- all four package file round trips;
- duplicate package and source records;
- module/file order preservation;
- package capsule checksum rejection;
- the published byte and count limits.
