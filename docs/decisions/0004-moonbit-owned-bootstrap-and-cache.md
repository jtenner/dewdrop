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

The bootstrap command is implemented in MoonBit. Package manifests,
lockfiles, package capsules, build-output caching, compiler request creation, and
compiler launch policy will move with it. Small shell launchers may locate and
start the built MoonBit bootstrap executable, but they must not own compiler or
cache semantics.

`tools/dew` now starts the MoonBit bootstrap command. The old Python bootstrap
and explicit-test launchers are removed. Exact cache-pack hits still start the
MoonBit compiler process, which avoids a second pack implementation.

## Consequences

- Cache-pack code remains portable to WasmGC and the future self-hosted compiler.
- One implementation owns BLAKE3, pack validation, corruption behavior, and
  provenance rules.
- The bootstrap and compiler can move toward self-hosting without translating a
  Python package/cache implementation.
- Startup optimization must occur in MoonBit or in the eventual Dew host, not by
  duplicating cache logic in Python.

## Related documents

- [`0003-unified-aligned-cache-pack.md`](0003-unified-aligned-cache-pack.md)
- [`../architecture.md`](../architecture.md)
- [`../roadmap.md`](../roadmap.md)
- [`../research/compiler-cli.md`](../research/compiler-cli.md)
