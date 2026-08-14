# 0004: Keep bootstrap and cache logic in MoonBit

- Status: Accepted
- Date: 2026-08-14

## Context

The current `tools/dew` launcher uses Python for package discovery, lockfile
handling, compiler fingerprinting, and process startup. It is temporary bootstrap
code. Adding cache-pack hashing or decoding to this host would duplicate the
MoonBit implementation and create logic that cannot move directly into the
self-hosted Dew toolchain.

## Decision

Compiler cache formats, hashing, validation, lookup, publication, and exact-result
reuse are implemented only in MoonBit. The Python launcher must not contain a
second BLAKE3 implementation or a second cache-pack decoder.

The bootstrap command will move from Python to MoonBit. Package manifests,
lockfiles, package capsules, build-output caching, compiler request creation, and
compiler launch policy will move with it. Small shell launchers may locate and
start the built MoonBit bootstrap executable, but they must not own compiler or
cache semantics.

Until that migration is complete, the Python launcher may call the MoonBit
compiler and perform its existing host duties. Exact cache-pack hits still start
the MoonBit process. This is an accepted temporary startup cost that avoids two
implementations of the persistent format.

## Consequences

- Cache-pack code remains portable to WasmGC and the future self-hosted compiler.
- One implementation owns BLAKE3, pack validation, corruption behavior, and
  provenance rules.
- The temporary Python launcher does not gain new compiler-cache behavior.
- Removing Python from the bootstrap path is active implementation work rather
  than a future optional cleanup.
- Startup optimization must occur in MoonBit or in the eventual Dew host, not by
  duplicating cache logic in Python.

## Related documents

- [`0003-unified-aligned-cache-pack.md`](0003-unified-aligned-cache-pack.md)
- [`../architecture.md`](../architecture.md)
- [`../roadmap.md`](../roadmap.md)
- [`../research/compiler-cli.md`](../research/compiler-cli.md)
