# Unified 16-byte-aligned compiler cache pack

Date: 2026-08-14

## Status

Implemented for native persistent compilation. One `.dwp` pack now owns the hot
compiler entries that previously lived in separate parser, interface, body,
layout, and WasmGC-fragment files. It also stores exact successful check, HIR,
lowering, and Wasm outputs.

The pack is enabled by default when at least one compiler cache layer is active.
Use:

```text
tools/dew check --no-cache-pack ...
DEW_CACHE_PACK=0 tools/dew check ...
```

Exact successful result reuse is also enabled by default. Use
`--no-program-cache` or `DEW_PROGRAM_CACHE=0` to measure the lower phase entries
without the exact-result fast path.

## File layout

The 16-byte magic is:

```text
dewartv1\0\0\0\0\0\0\0\0
```

Every integer is little-endian. Every section starts on a 16-byte file boundary.
A section header is:

```text
u32 kind
u32 bytes after this header
u64 entry count
```

The section body starts with one contiguous 16-byte entry-header array:

```text
u32 owner-name hash lane
u32 direct-content hash lane
u64 logical entry bytes
```

Payloads follow in header order. Every payload starts on a 16-byte boundary.
Padding is zero and is not part of the logical entry size.

Each entry starts with a 144-byte aligned prefix:

```text
u16 schema version
u16 flags
u32 owner kind
u32 exact owner byte length
u32 aligned root offset
byte[32] full owner-name BLAKE3
byte[32] full direct-content BLAKE3
byte[32] full producer/dependency-context BLAKE3
byte[32] full payload BLAKE3
```

The owner UTF-8 bytes follow the prefix. The section-specific root starts at the
next 16-byte boundary. Existing bounded canonical semantic payload codecs remain
inside that root. The outer pack therefore removes repeated files and envelopes
without changing their validated semantic schemas.

The final `FOOT` section records total bytes, covered bytes, section count, and a
full BLAKE3 digest over all prior bytes. The strict decoder checks the complete
footer and every entry. The MoonBit native warm path opens only aligned indexes
and then checks the selected payload. The MoonBit bootstrapper does not duplicate
pack parsing or hashing; exact lookup remains in the MoonBit compiler. This prevents exact-hit startup from scaling with the
number or total bytes of unrelated module entries.

## Hash policy

The pack uses BLAKE3-256. The implementation follows the public BLAKE3
compression and tree rules and is checked against the official test vectors at
lengths spanning empty input, block boundaries, chunk boundaries, and multi-chunk
trees.

BLAKE3 uses 32-bit additions, XOR, and rotations and supports parallel/SIMD
implementations. The current MoonBit implementation is portable scalar code so
it produces identical bytes on native, Wasm, WasmGC, and JavaScript targets. A
future V128 compression implementation will not require a cache-format change.

The two U32 values in each entry header are the first little-endian digest lanes.
They are never identities. Lookup compares the full 256-bit owner, content, and
context digests and the exact owner string. Deliberate tests force equal 32-bit
lanes with different remaining digest bytes and require a miss.

Compiler producer identity is mixed into every pack context. A compiler or
standard-library source change therefore invalidates exact and phase entries even
when the module source is unchanged. Public ABI fingerprints, package integrity,
and released SHA-256 contracts do not change.

## Current section kinds

| Kind | Owner | Payload |
| --- | --- | --- |
| `PEVT` | source file | canonical parser events |
| `IFCE` | standard bundle, workspace module, or SCC | frozen interfaces |
| `BMOD` | module | complete inferred bodies |
| `BFAM` | module family bundle | indexed normalized body families |
| `LAYT` | module | type layouts |
| `FRG0` | module | baseline WasmGC fragments |
| `CHCK` | root program | exact successful check marker |
| `HIR0` | root program | exact requested HIR output |
| `LWR0` | root program | exact requested lowering output |
| `WASM` | root program | exact final Wasm bytes |
| `FOOT` | pack | total-size and whole-pack integrity data |

Module maps are still rebuilt from deterministic arrays. Final program type,
signature, function, global, and initializer indexes are not moved into module
entries. Existing fragment validation and fresh deterministic physical linking
remain the incremental fallback.

## Read and publication policy

A compiler invocation:

1. reads one pack file into one byte buffer;
2. scans section and entry headers only;
3. tests the exact program entry before parsing;
4. decodes one exact entry on a complete warm hit;
5. otherwise decodes only requested phase entries;
6. copies unchanged entries and encodes changed entries into a new canonical pack;
7. flushes, fsyncs, and atomically replaces the prior pack.

Missing entries are misses. Invalid bounds, alignment, tags, checksums, owner
identity, provenance, or selected semantic payloads fail visibly. Failed
compilations and compilations with diagnostics do not publish exact program
entries.

## Focused release-native measurements

The cache codec microbenchmarks use a 512-entry pack with 4 KiB payloads:

| Operation | Mean |
| --- | ---: |
| BLAKE3 over 1 MiB | 8.19 ms |
| aligned index open plus exact lookup | 76.88 us |
| strict full validation of all 512 entries | 47.06 ms |

Strict validation is intentionally not the warm lookup path.

`tools/benchmark-cache-pack.py` generates 100 linked source modules and takes
seven warm samples per mode. The final warmed release-native run measured:

| Mode | Cold | Warm median | Cache files | Cache bytes |
| --- | ---: | ---: | ---: | ---: |
| unified pack plus exact result | 2,020.431 ms | 71.382 ms | 1 | 3,460,096 |
| unified pack phase entries only | 1,982.064 ms | 968.707 ms | 1 | 3,459,888 |
| legacy per-artifact phase files | 2,181.468 ms | 911.378 ms | 523 | 3,423,127 |
| all compiler caches disabled | 861.791 ms | 869.660 ms | 0 | 0 |

The MoonBit bootstrap computes the producer fingerprint directly, so the cache
file counts no longer include a Python fingerprint memo. The unified compiler
data is one `.dwp` file. The exact warm pack is 92.17% faster than the legacy
phase-file warm path and 91.79% faster than fresh compilation. It is about 12.77
times as fast as the legacy warm path. Cold pack publication is 7.38% faster than
publishing 523 phase artifacts.

Phase-only pack reuse is 6.29% slower than legacy phase files on this generated
workload because it still decodes and validates every requested semantic entry.
It is retained for incremental misses, not used as the default unchanged-build
boundary. The exact `CHCK`/`WASM`/`HIR0`/`LWR0` entry is the admitted warm path.

## Validation coverage

Permanent coverage includes:

- official BLAKE3 boundary and tree vectors on all MoonBit targets;
- exact magic, section sizes, entry sizes, zero padding, and byte-identical
  re-encoding;
- lazy index opening and one-entry decoding;
- full-digest checks after forced 32-bit lookup-lane collisions;
- stale-owner replacement while unchanged entries survive repacking;
- truncation, selected-entry corruption, and whole-pack corruption;
- one physical pack for parser, interface, body, layout, and fragment entries;
- cold, exact-warm, phase-warm, disabled, and private-edit behavior;
- byte-identical pack-cold, pack-warm, legacy-cache, and cache-disabled Wasm;
- cross-target codec tests and native CLI corruption tests.
