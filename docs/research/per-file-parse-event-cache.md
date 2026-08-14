# Per-file parse-event cache

Date: 2026-08-14

## Status

Implemented for every workspace source and every selected on-disk standard-library source. The compiler parses each file once per cold compilation, stores the complete ordered module-scope `ParseEvent` array, and reuses that same array for standard-library import selection, dependency/import scanning, and semantic collection. Warm compilations deserialize the per-file array instead of tokenizing and parsing the file again.

Bootstrap standard-library bytes participate only when they are selected by a compilation. Workspace files are prepared before standard-library loading so `required_standard_library_source_paths` consumes the same cached events later used by collection. Standard files are prepared after that deterministic subset has been selected.

## Content and provenance key

Each artifact key is SHA-256 over:

```text
DEW_PARSE_EVENT_KEY_V1\0
u32 owner/module-path byte length
owner/module-path UTF-8 bytes
u32 logical file-path byte length
logical file-path UTF-8 bytes
SHA-256(exact source bytes)
```

The owner path distinguishes identical logical filenames in different workspace modules and distinguishes compiler-selected standard sources from workspace sources. Source bytes remain the primary content identity. File and module order never enter the key; they continue to determine semantic IDs only when cached arrays are consumed in manifest order.

## Artifact format

The default native path stores each file as a `PEVT` entry in one
`.dew/cache/packs/v1-<graph>.dwp` file. `--no-cache-pack` retains the legacy path:

```text
.dew/cache/parse-events/v1-<key>.dpe
```

The legacy V1 envelope is the shared canonical artifact container:

```text
DEWART\0\1
u8 kind = 1
u32 version = 1
u32 flags = 0
u64 payload length
varint provenance count = 2
32-byte key digest
32-byte source digest
32-byte SHA-256(payload)
payload
```

The payload is a direct canonical V1 binary syntax graph. Every declaration,
expression, pattern, token, diagnostic, offset, string, and byte sequence uses an
explicit stable tag and bounded length. F32/F64 values use exact IEEE bits, so
non-finite payloads need no JSON marker bridge. Unsigned values use canonical
varints; signed values use ZigZag encoding.


Lookup rejects truncated or unsupported envelopes, key or source provenance mismatch, checksum mismatch, malformed UTF-8/binary data, invalid tags, and schema-invalid syntax. Existing invalid artifacts fail visibly as `corrupt parse-event cache`; they are never treated as misses. Missing artifacts are ordinary misses.

Publication writes a same-directory temporary file, flushes it, fsyncs it on POSIX, and atomically replaces the destination. Parser diagnostics are cached as ordinary events; serialization or I/O failure never publishes a partial artifact.

## Integration and controls

`ManifestFile` and `ProgramFile` may carry one optional immutable event array. `ManifestFile::events` and `ProgramFile::events` fall back to the streaming parser only for callers that did not prepare an artifact. The compiler CLI prepares workspace events before standard-source selection and passes the resulting status into `compiler_driver`; the driver prepares only the selected standard sources and then collects the program.

Controls are:

```text
tools/dew check --cache-report ...
tools/dew check --no-parse-event-cache ...
DEW_PARSE_EVENT_CACHE=0 tools/dew check ...
```

Reports use:

```text
parse event cache: hits N, misses M
parse event cache: disabled (parsed N)
```

`--no-interface-cache` and `--no-build-cache` remain independent. `dew clean` removes parse-event entries because they share `DEW_CACHE_DIR`.

The private compiler request protocol is version 4 and carries an explicit parse-event-cache Boolean before the interface-cache Boolean.

## Validation

Permanent coverage includes:

- parser-event payload round trips for declarations and diagnostics;
- byte-identical re-encoding after decoding;
- exact non-finite `F32` bit preservation;
- malformed payload rejection;
- envelope checksum and provenance rejection;
- cold miss followed by warm hit reporting;
- changed-file invalidation where only the changed file misses;
- explicit disabled reporting;
- fail-visible corruption through the CLI;
- four concurrent cold publishers leaving one valid artifact per key and no temporary files;
- byte-identical cold, warm, concurrent, and unchanged-semantic changed-file Wasm;
- native parser, semantic, standard-loader, compiler-driver, CLI, generated-source, snapshot, architecture, and full-suite checks.

A focused three-workspace-file smoke build plus the selected 14 standard files reported:

```text
cold:    hits 0,  misses 17
warm:    hits 17, misses 0
changed: hits 16, misses 1
```

All three produced byte-identical 537-byte Wasm. A separate release-mode benchmark over 128 workspace files plus 14 selected standard files measured:

```text
cold:         172.679 ms
warm median:   99.681 ms
changed-file:  99.829 ms
warm/cold:      0.5773x
```

The changed file added only whitespace and produced byte-identical 1,762-byte Wasm. Host timings are supporting evidence rather than a stable performance contract; process startup, semantic analysis, lowering, linking, validation, and encoding remain uncached by this tranche.

## Remaining work

1. Extend frozen-interface reuse to ordinary workspace modules using explicit source and dependency provenance.
2. Add body-inference, layout, and fragment artifacts where deterministic rebasing is defined.
3. After Dewdrop is self-hosted and Dew supports parallel computation, schedule independent jobs concurrently and merge diagnostics/artifacts in manifest order.
4. Add hundreds-of-files and external-package stress measurements plus allocation and peak-memory reporting.
5. Build a comment-preserving lossless syntax layer for formatting, documentation, and language-server editing; parser events intentionally preserve semantic syntax, not trivia.
