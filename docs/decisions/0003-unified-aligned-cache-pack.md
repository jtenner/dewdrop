# 0003: Use one aligned compiler cache pack

- Status: Accepted
- Date: 2026-08-14

## Context

Per-file and per-module cache artifacts caused one filesystem lookup, open, read,
envelope decode, and checksum path for every cached phase. Layout planning was
cheaper than its standalone artifact read. A 100-module build could use hundreds
of cache files before useful compiler work started.

## Decision

Native compilation uses one V1 cache pack per stable workspace/module graph,
target mode, and root policy. The file starts with
`dewartv1\0\0\0\0\0\0\0\0`. Every section header, entry header, entry payload,
and fixed table boundary is 16-byte aligned.

Section entry headers contain 32-bit BLAKE3 lookup lanes. They are only fast
filters. Full 256-bit BLAKE3 owner, content, context, and payload digests remain
authoritative. The MoonBit implementation is portable across native, Wasm,
WasmGC, and JavaScript targets. Its add/XOR/rotate compression can gain a V128
implementation later without changing stored bytes.

The compiler reads the pack once. It scans aligned indexes without decoding all
payloads. A selected entry is decoded and checked on demand. Changed entries are
published by a flushed, fsynced, same-directory atomic replacement. Legacy
per-artifact files remain available only when the pack is explicitly disabled.

Exact successful check, HIR, lowering, and Wasm results are pack sections. They
form the default warm-start boundary. Module phase sections remain available for
incremental misses and explicit phase-cache measurements.

## Consequences

- A warm 100-module exact hit uses one pack read instead of hundreds of artifact
  reads.
- Source, compiler, standard-library, root, mode, and dependency changes miss the
  exact result.
- Entries use exact full digests even when two 32-bit lookup lanes collide.
- A corrupt selected entry fails visibly. A complete validation path checks every
  entry and the whole-pack footer.
- The pack can be disabled with `--no-cache-pack` or `DEW_CACHE_PACK=0`.
- Exact result reuse can be disabled with `--no-program-cache` or
  `DEW_PROGRAM_CACHE=0` while retaining module phase entries.
- Body and layout/fragment phase reuse stays opt-in. Exact program reuse is
  enabled by default because it has a measured end-to-end win.

## Evidence and related documents

- [`../research/unified-aligned-cache-pack.md`](../research/unified-aligned-cache-pack.md)
- [`../architecture.md`](../architecture.md)
- [`../compile-request.md`](../compile-request.md)
- [`../../tools/benchmark-cache-pack.py`](../../tools/benchmark-cache-pack.py)
