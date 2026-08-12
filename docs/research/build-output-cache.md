# Verified build-output cache

Date: 2026-08-11

`dew build` now publishes successful Wasm, HIR, and lowering outputs into `.dew/cache/builds/` and restores them on an exact subsequent request without invoking the native Dew compiler. `--no-build-cache` forces ordinary compilation. `--cache-report` reports the deterministic output-cache key and whether the request hit or missed.

The SHA-256 key commits to normalized compiler arguments excluding only the destination path and report flag, every explicit Dew source payload, custom standard-root Dew sources, dependency-interface environment state, and the Dew compiler/standard-library/workspace-dependency source trees. Compiler-source content hashes are memoized only while the exact sorted path, size, modification-time, and change-time manifest remains unchanged. Consequently, changing source, compiler, generated standard source, standard root, module graph, emit mode, ABI expectation, or relevant package environment invalidates the entry. Different output destinations share one artifact.

Each `.dba` entry is a single atomically published V1 envelope containing emit kind, key, payload size, and payload SHA-256. Missing entries are misses; malformed, mismatched, truncated, or checksum-invalid entries are fail-visible corruption and are never treated as misses. Cache hits are atomically copied to the requested destination. Failed compilations and missing outputs are never published. `dew clean` removes build entries together with interface and installed-package caches.

`tools/benchmark-build-output-cache.py` measured ten warmed builds of a 422-byte Wasm fixture:

| Path | Median |
| --- | ---: |
| verified output-cache hit | 68.026 ms |
| ordinary compile with output cache disabled | 94.220 ms |

The hit path measured 0.7220x the ordinary compile time, about 27.8% faster. All outputs were byte-identical and exactly one verified artifact was published. This is a whole-request cache; per-file parsing, HIR reuse, transitive invalidation graphs, and parallel module scheduling remain separate milestones.
