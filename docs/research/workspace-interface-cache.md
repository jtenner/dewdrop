# Persistent workspace frozen-interface cache

## Status

Implemented for ordinary non-root workspace modules, including multi-module and self-recursive interface dependency SCCs. The cache supplements the existing standard/dependency interface bundle: dependencies are resolved in deterministic SCC order, then each eligible workspace module is looked up immediately before interface freezing. Executable body collection still runs normally; body inference may now be reused by the independently versioned module-body cache, while lowering, linking, validation, and encoding still run normally.

## Artifact identity

Artifacts live at:

```text
.dew/cache/workspace-interfaces/v1-<key>.dwi
```

The key is SHA-256 over a private V1 marker, the exact module source fingerprint, and sorted direct dependency records. The source fingerprint commits to:

- logical module path;
- stable manifest-derived module ID;
- manifest-ordered logical file paths;
- exact file bytes.

Each dependency record commits to the dependency module path and public `content_fingerprint`. Consequently, a private implementation-only change reparses and refreezes the changed module but keeps downstream keys valid when its public interface is unchanged. A public interface change invalidates direct dependents, and changed dependent content fingerprints propagate transitively in dependency order.

Module IDs remain in the source key because frozen declaration identities are manifest-indexed. Reordering modules therefore cannot accidentally reuse an artifact with incompatible declaration IDs. File order is also preserved rather than normalized because collection identity is defined by manifest order.

## Validation and publication

Workspace artifacts reuse the deterministic frozen-interface V11 serializer and checksum envelope, but contain exactly one module. Lookup validates:

- envelope checksum and schema;
- exactly one decoded module;
- module path and module ID;
- direct dependency path/content-fingerprint provenance.

Checksum, schema, identity, and malformed-payload failures are visible cache errors. A well-formed artifact whose dependency fingerprints no longer match is an ordinary deterministic miss, because it is a valid artifact for a previous dependency state rather than corruption.

Publication uses the native cache platform's same-directory temporary file, flush, `fsync`, and atomic replacement path shared with parser-event artifacts. Unsupported non-native targets leave persistent workspace caching disabled. Multi-module and self-importing SCCs use one SCC-level key and artifact; lookup validates and injects every member together, and partial SCC reuse is rejected.

## Reporting

`--cache-report` now reports aggregate interface artifact counts:

```text
standard interface cache: hits <n>, misses <n>
```

The count includes the standard/dependency bundle plus eligible workspace-module artifacts. Disabled mode remains:

```text
standard interface cache: disabled
```

The historical label is retained for CLI compatibility even though the count now covers each module loaded or missed through the standard/dependency bundle plus each workspace artifact.

## Validation

Permanent validation covers:

- exact source and dependency key sensitivity;
- root and compiler-owned standard exclusion;
- complete cyclic-SCC and self-cycle aggregate eligibility;
- cold and warm multi-module builds;
- private implementation changes yielding downstream hits;
- public interface changes invalidating direct and transitive dependents;
- byte-identical cached and uncached outputs for changed builds;
- fail-visible workspace-artifact corruption;
- atomic publication through the shared native cache writer.

`tools/benchmark-workspace-interface-cache.py` generates a 96-module chain. A representative run measured approximately 543 ms cold, 361 ms warm, 372 ms after a private leaf change, and 383 ms after a public leaf change. Including the two compiler-owned ambient standard interfaces in the aggregate report, the private change produced 98 hits and one miss; the public change produced 97 hits and two misses. These figures are supporting measurements rather than release thresholds.

## Remaining work

- Refine module-level body inference reuse into declaration/lambda jobs after exact module-value, capture, and evidence dependencies are fingerprinted.
- Cache layouts and WasmGC fragments under independently versioned schemas.
- Schedule independent SCC/body jobs in parallel and merge outputs deterministically.
- Add allocation and peak-memory measurements to cache benchmarks.
