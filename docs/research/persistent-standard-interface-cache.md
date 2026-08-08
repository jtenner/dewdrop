# Persistent standard and dependency frozen-interface cache

## Status

Implemented for compiler-owned `dew.std.*` interfaces and source-bundled versioned external dependency packages. The cache key combines the exact ordered standard source subset with the resolved dependency package identity/version/integrity closure. A hit injects standard and non-root dependency interfaces while continuing to collect executable bodies and run body inference, lowering, reachability, linking, Starshine validation, and encoding normally.

Root-package interfaces, body artifacts, layouts, lowering fragments, and emitted Wasm are not cached yet.

## Content key

`load_for_manifest_with_fingerprint` computes SHA-256 over a private version marker followed by every selected source's:

```text
u32 logical-path byte length
logical-path UTF-8 bytes
u32 source byte length
exact source bytes
```

Source order comes from `required_standard_library_source_paths`; neither hashing nor cache lookup enumerates a directory. The key therefore changes when:

- any required standard source byte changes;
- a required logical source path changes;
- the selected standard source set changes;
- the private cache-key ABI marker is bumped.

For versioned external dependencies, `dew.json` records only package identity/version and semantic-version or Git dependency requests. Sibling `dew.lock` records each exact resolved name/version/source/materialized path, `sha256-<hex>` package source integrity, and expected 64-hex transitive interface fingerprint. Package integrity V2 hashes identity, derived module path, conventionally discovered source paths/bytes, and dependency requests independently of lockfile placement. After freezing or cache injection, the compiler compares each resolved dependency module's transitive interface fingerprint with the lock expectation before lowering or linking. The resolver validates the complete acyclic locked dependency closure before compilation and derives a domain-separated dependency-interface key from exact lock records, combined with the standard-source fingerprint.

Generated `--bootstrap-std` providers are intentionally not cacheable. Bootstrap mode remains an independent comparison path.

## Artifact format

`serialize_frozen_interfaces` writes a private deterministic binary format beginning with:

```text
DEW_FROZEN_INTERFACES_V8\0
```

It serializes diagnostics-free `FrozenModuleInterface` records, including:

- stable module and declaration identities;
- complete resolved-type arenas and applied-type spans;
- public declarations, aggregate fields, and variants;
- callable kinds, parameters, result shapes, and receiver bits;
- public implementation evidence;
- content-sensitive nominal declaration fingerprints;
- module content/transitive interface fingerprints and direct dependency records;
- source locations and preamble declaration counts.

No maps, addresses, filesystem paths, or worker-order values enter the artifact. Arrays remain in their existing frozen semantic order. Decoding checks the version, every byte range, bounded collection counts, enum tags, Booleans, UTF-8 strings, trailing bytes, module identities, duplicate modules, and the exact expected standard-module count.

The serialized payload is wrapped in a second cache-file envelope:

```text
DEW_STD_INTERFACE_CACHE_V8\0
SHA-256(payload)
payload
```

The envelope checksum catches corruption that might otherwise remain structurally decodable. Corrupt, truncated, unsupported, identity-mismatched, duplicate, or checksum-invalid artifacts fail visibly; they are never silently treated as misses.

## Cache location and controls

The default location is:

```text
.dew-cache/interfaces/v8-<bundle-fingerprint>.dwi
```

The cache root may be changed with:

```text
DEW_CACHE_DIR=/path/to/cache tools/dew check ...
```

Cache controls are:

```text
tools/dew check --cache-report ...
tools/dew check --no-interface-cache ...
DEW_INTERFACE_CACHE=0 tools/dew check ...
```

`--cache-report` prints exactly one of:

```text
standard interface cache: miss
standard interface cache: hit
standard interface cache: disabled
```

Cache I/O errors are usage/input failures rather than silent fallback. Users can disable the cache explicitly when working with a read-only or intentionally ephemeral environment.

## Integration

`freeze_program_interfaces_with_cached` accepts manifest-indexed optional interface slots. It verifies each cached module ID and path before use. Cached interfaces are installed before SCC interface jobs, so dependent user modules can consume them through the ordinary immutable import-scope path. Uncached modules still run the existing two-pass SCC algorithm.

`analyze_program_semantics_with_cached_interfaces` then performs ordinary imported-type translation, body name resolution, and body inference from the mixed cached/fresh frozen graph. `analyze_program_with_standard_cache` owns lookup, cache-slot construction, analysis, and miss storage for CLI, test, snapshot, parity, and benchmark generators.

## Validation

Permanent coverage includes:

- deterministic encode/decode equality for frozen interfaces;
- byte-identical re-encoding after decode;
- mixed cached-standard/fresh-user interface freezing;
- invalid headers, oversized counts, truncation, trailing bytes, and checksum corruption;
- first-run miss followed by a hit;
- explicit disabled mode;
- fail-visible corrupt cache behavior;
- source-content invalidation producing a second cache artifact;
- versioned external package miss/hit behavior and `v8-*.dwi` filenames;
- fail-visible package identity, version, and integrity mismatches;
- dependency integrity changes producing a distinct bundle key;
- byte-identical Wasm between cache miss, cache hit, on-disk uncached, and generated bootstrap providers;
- the complete Node/Wago module snapshot suite with cache-enabled native generation.

Release-mode native phase benchmarks over the all-standard wildcard program currently measure:

```text
serialize all frozen interfaces       2.89 ms ± 78.76 us
decode all frozen interfaces          3.09 ms ± 64.23 us
cached-interface freeze/injection      1.77 ms ± 25.79 us
fresh interface freeze                 5.31 ms ± 191.07 us
```

A complete hit currently pays decode plus cached graph/scope injection, about 4.86 ms before cache-file I/O and checksum hashing, versus 5.31 ms for fresh interface freezing. This is a small foundation-level saving rather than a broad compilation speedup. Warm bootstrap CLI samples remain roughly 112–124 ms for both paths because launcher, source collection, body analysis, lowering, and linking dominate. The measurements must remain separated rather than presenting the cache as an end-to-end win it has not yet demonstrated.

## Remaining work

1. Add cache-file I/O and checksum-only benchmarks, allocation counts, and representative larger external-package workloads.
2. Load dependency interfaces without recollecting their source bodies once installed-package recovery and artifact provenance are reliable.
3. Define atomic artifact publication when the filesystem abstraction exposes rename/replace semantics; current deterministic same-key writers produce identical bytes, and interrupted partial artifacts remain visible checksum failures.
4. Extend caching to body, layout, fragment, and final Wasm artifacts only after their serialization schemas stabilize.
