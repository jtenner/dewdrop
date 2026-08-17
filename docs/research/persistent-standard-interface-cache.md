# Persistent standard and dependency frozen-interface cache

## Status

Implemented for compiler-owned `dew.std.*` interfaces, versioned external dependency packages, and ordinary non-root workspace modules, including self-recursive and multi-module SCCs. The standard/dependency bundle key combines the exact ordered standard source subset with the resolved dependency package identity/version/integrity closure. Workspace entries use exact manifest source identity plus direct public dependency content fingerprints. Hits inject frozen interfaces while continuing to collect executable bodies and run body inference, lowering, reachability, linking, Starshine validation, and encoding normally.

Installed dependencies additionally receive content-addressed V1 package capsules. When a locked dependency tree is unavailable, the CLI verifies the capsule against the complete lock provenance and atomically restores its exact ordered package payload at the locked path before compilation. The ordinary interface-cache hit then avoids refreezing that dependency interface, while restored executable bodies keep static linking and emitted Wasm byte-identical. Root-package interfaces, collected-body artifacts, layouts, lowering fragments, and emitted Wasm are not cached by this layer yet.

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

For versioned external dependencies, `dew.json` records only package identity/version and semantic-version or Git dependency requests. Sibling `dew.lock` records each exact resolved name/version/source/materialized path, `sha256-<hex>` package source integrity, and expected 64-hex transitive interface fingerprint. Package integrity version 1 hashes identity, derived module path, conventionally discovered source paths/bytes, and dependency requests independently of lockfile placement. After freezing or cache injection, the compiler compares each resolved dependency module's transitive interface fingerprint with the lock expectation before lowering or linking. The resolver validates the complete acyclic locked dependency closure before compilation and derives a domain-separated dependency-interface key from exact lock records, combined with the standard-source fingerprint.

Generated `--bootstrap-std` providers are intentionally not cacheable. Bootstrap mode remains an independent comparison path.

The package capsule key is independently domain-separated over exact locked package name, version, source, integrity, expected interface fingerprint, and derived module path. The integrity digest already commits to the ordered package source payload and dependency requests, so any package or transitive request change selects a different artifact.

## Artifact format

`serialize_frozen_interfaces` writes a private deterministic binary format beginning with:

```text
DEW_FROZEN_INTERFACES_V1\0
```

It serializes diagnostics-free `FrozenModuleInterface` records, including:

- stable module and declaration identities;
- complete resolved-type arenas, applied-type spans, resolved generic-bound types,
  canonical explicit-call type arguments, one ordered bound span per generic
  parameter, and owner generic spans for frozen implementations;
- public declarations, aggregate fields, and variants;
- callable kinds, parameters, result shapes, and receiver bits;
- public implementation evidence;
- content-sensitive nominal declaration fingerprints;
- module content/transitive interface fingerprints and direct dependency records;
- source locations and preamble declaration counts.

No maps, addresses, filesystem paths, or worker-order values enter the artifact. Arrays remain in their existing frozen semantic order. Decoding checks the version, every byte range, bounded collection counts, enum tags, Booleans, UTF-8 strings, trailing bytes, module identities, duplicate modules, package ownership of every frozen implementation, and the exact expected standard-module count. Implementation ownership validation uses bounded type-head traversal and rejects out-of-range IDs, invalid applied-type spans, and cyclic heads with `Err` rather than indexing malformed cache data and aborting.

The serialized payload is wrapped in a second cache-file envelope:

```text
DEW_STD_INTERFACE_CACHE_V1\0
SHA-256(payload)
payload
```

The envelope checksum catches corruption that might otherwise remain structurally decodable. Corrupt, truncated, unsupported, identity-mismatched, duplicate, or checksum-invalid artifacts fail visibly; they are never silently treated as misses.

Installed package capsules use:

```text
DEW_PACKAGE_ARTIFACT_V1\0
64 lowercase hexadecimal SHA-256 bytes
newline
canonical JSON payload
```

The payload binds artifact version, exact lock identity/version/source/integrity/interface fingerprint, derived module path, sorted dependency requests, and sorted conventional `.dew` files. Every file carries its logical relative path, SHA-256 digest, and base64 bytes. Recovery rejects duplicate or unordered entries, unsafe paths, malformed encodings, per-file checksum failures, envelope checksum failures, lock-provenance mismatches, and a recomputed package-integrity mismatch. Publication uses a same-directory temporary file plus atomic replacement. Recovery stages the complete package beside the locked destination and atomically renames it only after validation; a nonempty partial source tree fails visibly rather than being overwritten.

## Cache location and controls

The default locations are:

```text
.dew/cache/interfaces/v1-<bundle-fingerprint>.dwi
.dew/cache/packages/v1-<package-artifact-key>.dpa
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
standard interface cache: hits <n>, misses <n>
standard interface cache: disabled
```

Cache I/O errors are usage/input failures rather than silent fallback. Users can disable the cache explicitly when working with a read-only or intentionally ephemeral environment.

## Integration

`freeze_program_interfaces_with_cached` accepts manifest-indexed optional interface slots. It verifies each cached module ID and path before use. Cached interfaces are installed before SCC interface jobs, so dependent user modules can consume them through the ordinary immutable import-scope path. Uncached modules still run the existing two-pass SCC algorithm. Fresh modules without an exported top-level `let` skip interface-time body inference because only exported module-value semantic types are consumed by freezing; modules with exported values retain the ordinary inference path. Final ABI construction precomputes sorted content records once and reuses them for every transitive interface fingerprint without changing bytes or hashes.

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
- versioned external package miss/hit behavior and `v1-*.dwi` filenames;
- installed package capsule publication, source-tree removal, verified atomic recovery, and byte-identical pre/post-recovery Wasm;
- fail-visible corrupt package capsules and refusal to overwrite nonempty partial package trees;
- rejection of injected ordinary orphan evidence before a cache hit can expose it;
- rejection of malformed implementation type IDs without a compiler process abort;
- fail-visible package identity, version, and integrity mismatches;
- dependency integrity changes producing a distinct bundle key;
- byte-identical Wasm between cache miss, cache hit, on-disk uncached, and generated bootstrap providers;
- the complete Node/Wago module snapshot suite with cache-enabled native generation.

Release-mode native phase benchmarks for the version 1 binary format measure:

```text
serialize all frozen interfaces       4.63 ms ± 0.17 ms
decode all frozen interfaces          6.69 ms ± 0.07 ms
cached-interface freeze/injection     52.57 ms ± 0.63 ms
fresh interface freeze               683.49 ms ± 2.64 ms
```

A complete hit currently pays decode plus cached graph/scope injection, about 59.26 ms before cache-file I/O and checksum hashing, versus 683.49 ms for fresh interface freezing. This is a substantial interface-phase saving rather than a claim about complete compilation speed. Warm bootstrap CLI samples remain roughly 112–124 ms for both paths because launcher, source collection, body analysis, lowering, and linking dominate. The measurements must remain separated rather than presenting the cache as an end-to-end win it has not yet demonstrated.

## Remaining work

1. Add allocation counts and representative larger external-package workloads.
2. Measure whether serializing collected dependency bodies is worth avoiding restoration-time syntax collection; package-tree lookup and interface refreezing are already removed from the recovery path.
3. Extend caching to collected bodies, layouts, fragments, and final Wasm only after their serialization schemas stabilize.
