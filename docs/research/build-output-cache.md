# Verified build-output cache

Date: 2026-08-14

`dew build` publishes successful Wasm, HIR, and lowering outputs into
`.dew/cache/builds/` and restores them on an exact subsequent request without
invoking the native Dew compiler. `--no-build-cache` forces ordinary compilation.
`--cache-report` reports the deterministic output-cache key and whether the
request hit or missed.

The SHA-256 key commits to normalized compiler arguments excluding only the
destination path and report flag, every explicit Dew source payload, custom
standard-root Dew sources, dependency-interface environment state, and the Dew
compiler/standard-library/workspace-dependency source trees. Changing source,
compiler, generated standard source, standard root, module graph, emit mode, ABI
expectation, or relevant package environment invalidates the entry. Different
output destinations share one artifact.

## Compiler fingerprint fast path

Compiler-source content hashes use a checksummed version 1 binary memo under the configured cache root. On
an ordinary hit, the host:

1. walks only compiler-relevant path classes (`*.mbt`, package descriptors,
   compiler-host files, and standard `*.dew`) and compares the exact sorted path
   list, so additions and removals cannot hide behind directory timestamp
   resolution;
2. directly validates every regular file's size, modification time, and change
   time;
3. validates a SHA-256 over the complete memoized manifest and fingerprint;
4. returns the memoized exact-content fingerprint only when all checks match.

Any path or metadata change rehashes every exact file payload and atomically
publishes a new binary memo. Missing, malformed, incomplete, unordered, or
checksum-invalid memos are rebuilt rather than trusted. This removes repeated
`Path.resolve`, recursive glob, and content hashing from the common hit while
retaining conservative source invalidation.

Each host `.dba` entry is a single atomically published version 1 binary envelope inside the common `DEWART\0\1` container. Its fixed body contains emit
kind, raw request key, raw payload digest, U64 payload size, and payload. The native compiler also stores exact successful check/HIR/lowering/Wasm results in the unified aligned `.dwp` pack; this path is used when the host output cache is bypassed or for `check`. Missing entries are misses;
malformed, mismatched, truncated, or checksum-invalid entries are fail-visible
corruption and are never treated as misses. Cache hits are atomically copied to
the requested destination. Failed compilations and missing outputs are never
published. `dew clean` removes build entries together with interface and
installed-package caches.

`tools/benchmark-build-output-cache.py` measured ten warmed builds of a 422-byte
Wasm fixture:

| Path | Before memo fast path | After version 1 memo fast path |
| --- | ---: | ---: |
| verified output-cache hit median | 88.465 ms | 43.832 ms |
| ordinary compile with output cache disabled | 100.160 ms | 98.705 ms |

The hit path improved by **50.5%** and now measures 0.4441x ordinary compile time.
All outputs were byte-identical and exactly one verified artifact was published.
Atomic destination publication and `fsync` are now a visible part of the remaining
hit time and were intentionally retained. Per-file parsing, interfaces, optional
semantic reuse, and layout fragments remain separate layers. Parallel module
scheduling is deferred until Dewdrop is self-hosted and Dew supports parallel
computation.
