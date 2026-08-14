# Binary compiler artifacts — August 14, 2026

## Scope

This tranche replaces JSON on hot compiler-cache paths with direct, canonical binary codecs. It covers parser events, frozen interfaces, complete inferred-module bodies, declaration-family bundles, whole-build output headers, and compiler-source fingerprint memos. The later planning-cache tranche reuses the same container for module type layouts and baseline WasmGC fragments. Package manifests, lockfiles, installed package capsules, user JSON, Dew JSON APIs, and Wasm payload bytes remain unchanged.

## Baseline before implementation

The release compiler was warmed with `moon check` before these measurements. End-to-end values are medians where the existing script reports a median. The build-output cache uses ten samples.

| Workload | Legacy result |
| --- | ---: |
| 128-file parse cache cold | 183.003 ms |
| 128-file parse cache warm median | 117.150 ms |
| 128-file parse cache one-file edit | 120.244 ms |
| 96-module workspace cold | 986.993 ms |
| 96-module workspace warm median | 320.383 ms |
| 96-module private change | 325.471 ms |
| 96-module public change | 330.834 ms |
| 192-function family cold | 201.142 ms |
| 192-function family warm median | 150.566 ms |
| 192-function family private edit | 154.154 ms |
| 192-function fresh-inference private edit median | 106.271 ms |
| 192-function family root edit | 150.444 ms |
| verified build-output hit median, 10 samples | 43.744 ms |
| ordinary build median, 10 samples | 97.078 ms |

Legacy artifact sizes from those generated workloads were:

| Artifact set | Files | Bytes |
| --- | ---: | ---: |
| legacy development parse-event JSON envelopes | 143 | 516,007 |
| standard-interface V12 binary envelope | 1 | 379,462 |
| workspace-interface V1/V12 binary envelopes | 99 | 154,066 |
| complete-body V3 JSON envelopes | 3 | 1,327,016 |
| family V1 JSON bundles | 2 | 217,453 |
| build-output V1 JSON-header artifact | 1 | 633 |

All baseline cached and uncached comparison outputs were byte-identical.

## Binary design

All hot artifacts now use canonical binary fields. Unsigned integers use minimal unsigned varints. Signed `Int` values use ZigZag varints. Fixed U32/U64 fields are little-endian. F32/F64 use exact IEEE bits. Booleans, options, and domain enums use explicit checked tags. Strings are strict UTF-8. Strings, bytes, arrays, and sections are length-prefixed and bounded.

The shared container starts with `DEWART\0\1`, then stores artifact kind, U32 version, zero flags, U64 payload length, bounded provenance digests, SHA-256 payload checksum, and exact payload bytes. Readers retain the first contextual field/byte error and reject non-canonical varints, integer overflow, impossible counts, invalid tags, truncation, trailing bytes, checksum failure, and provenance mismatch before indexing or large allocation.

| Artifact | Kind | Current version/path |
| --- | ---: | --- |
| parser events | 1 | V1, `parse-events/v1-*.dpe` |
| standard/external interfaces | 2 | V13, `interfaces/v13-*.dwi` |
| workspace interfaces | 3 | V2, `workspace-interfaces/v2-*.dwi` |
| complete inferred bodies | 4 | V4 key/envelope with V2 payload, `body-inference/v4-*.dbi` |
| declaration-family bundle | 5 | V2, `body-inference-families/v2-*.dbf` |
| whole-build output | 6 | V2, `builds/v2-*.dba` |
| compiler fingerprint memo | 7 | V4, `compiler-fingerprint-v4.dbm` |
| module type layouts | 8 | V1, `type-layouts/v1-*.dtl` |
| baseline WasmGC fragments | 9 | V1, `wasmgc-fragments/v1-*.dwf` |

Family bundles store sorted raw 32-byte fingerprints, fixed U64 offset/length records, and concatenated family sections. Lookup uses binary search and decodes only the selected bounded section. No map iteration, address, filesystem order, or worker completion order enters serialized bytes.

## Migration and corruption policy

Old filenames are stale by construction and are not decoded under new schemas. Missing current-version files are misses. Existing current-version files that are malformed, truncated, non-canonical, mismatched, or corrupt fail visibly. Publication remains same-directory, flushed/fsynced, and atomic.

Tests cover primitive golden bytes, canonical varints, overflow and allocation bombs, exact float bits, every common-envelope truncation, deterministic payload mutations, invalid tags, trailing bytes, provenance/checksum mismatch, semantic evidence validation, sorted/duplicate family indexes, and byte-identical re-encoding. Python tests exhaustively truncate and mutate whole-build and compiler-memo artifacts.

## Final artifact sizes

| Artifact set | Legacy bytes | Binary bytes | Binary/legacy |
| --- | ---: | ---: | ---: |
| parse events | 516,007 | 110,945 | 21.5% |
| standard interface | 379,462 | 268,914 | 70.9% |
| workspace interfaces | 154,066 | 97,678 | 63.4% |
| complete bodies | 1,327,016 | 124,338 | 9.4% |
| family bundles | 217,453 | 25,709 | 11.8% |
| whole-build output | 633 | 585 | 92.4% |

Every requested size gate passes: parser/body/family payloads are far below 60%, and interface artifacts are below 90%.

## Focused release microbenchmarks

| Operation | Legacy | Binary | Speedup |
| --- | ---: | ---: | ---: |
| parser encode, 128 declarations | 1.26 ms | 62.53 us | 20.2x |
| parser decode, 128 declarations | 1.23 ms | 360.91 us | 3.4x |
| complete-body encode, 192 functions | 3.04 ms | 66.90 us | 45.4x |
| complete-body decode, 192 functions | 2.05 ms | 158.16 us | 13.0x |
| family encode | 22.14 us | 512.65 ns | 43.2x |
| family decode | 18.13 us | 1.57 us | 11.5x |
| family indexed lookup plus decode | n/a | 2.07 us | n/a |
| one family miss mixed with 191 cached functions | fresh full inference 1.21 ms | 311.73 us | 3.9x faster |
| frozen-interface encode | 8.68 ms | 6.11 ms | 1.42x |
| frozen-interface decode | 9.72 ms | 6.83 ms | 1.42x |

Parser, body, family, and mixed-family timing gates pass. The strict requested 2x/4x interface timing gate does not: V12 was already a custom binary serializer rather than JSON. V13 still reduces bytes by 29.1%, improves both isolated phases, and substantially reduces end-to-end warm workspace time. The interface cache remains enabled because its existing semantic benefit is preserved; no claim is made that this one numeric gate passed.

## End-to-end results

Compiler-rebuild outliers were excluded. Final warmed results were:

| Workload | Legacy | Binary |
| --- | ---: | ---: |
| parse warm median | 117.150 ms | 105.484 ms |
| parse one-file edit | 120.244 ms | 107.532 ms |
| workspace cold | 986.993 ms | 989.892 ms |
| workspace warm median | 320.383 ms | 300.597 ms |
| workspace private change | 325.471 ms | 305.525 ms |
| workspace public change | 330.834 ms | 304.013 ms |
| 192-function family cold | 201.142 ms | 148.028 ms |
| family warm median | 150.566 ms | 103.494 ms |
| family private edit | 154.154 ms | 108.854 ms |
| fresh-inference private edit | 106.271 ms | 97.064 ms |
| family root edit | 150.444 ms | 102.784 ms |
| verified build hit median | 43.744 ms | 44.402 ms |
| ordinary build median | 97.078 ms | 86.980 ms |

The verified output-cache hit changed by +1.5%, inside the 5% regression limit, and remains 0.5105x ordinary compilation. Thin 96-module and heavier 192-closure/function workloads both preserve byte-identical outputs. Family end-to-end private edits are still 12.1% slower than disabling body caching, even though the isolated one-miss merge is 74.2% faster than fresh inference.

## Admission decision

Parser, interface, and whole-build caches keep their existing defaults. Complete-body and family caches stay opt-in. Their binary codecs pass speed and size gates, but thin end-to-end semantic-cache admission still loses to fresh inference after key construction, filesystem I/O, complete-module validation, and merge work. A future default change requires larger heavy-inference and external-package workloads to show a consistent complete-pipeline win.
