# Transform memory and packed integers

## Behavior

Both interpreters execute the exact 88 memory operations in the current compiler
catalog. The memory descriptor tables include exact lane spellings. Unknown
instructions and invalid immediates retain the existing unsupported path.
The normal compiler's default memory starts at one page; the interpreter uses
one lazy, zeroed 64 KiB packed byte buffer. It is separate from host memory.
There is no second Wasm instance and no new host API.

The handler checks argument count, address/value carriers, and the whole range
before touching memory. Addresses use unsigned memory32 bits. It checks the
allocation ledger before creating the first buffer. Scalar values use little
endian storage; float bit patterns pass through unchanged. Vector accesses cover
full vectors, splats, signed/unsigned extending loads, zero loads and lanes.
An annotation starts with no buffer, even when an earlier annotation used one.

Swar32/Swar64 retain their logical type in checked source metadata and type
queries. VM scalar proofs use their U32/U64 physical carriers. Raw record storage
uses i32/i64. This supports the existing source algorithms, generic raw-array
defaults, record fields and array literals without library-name dispatch.

## Checks

- Before the change, the public memory source failed visibly on unsupported
  `i32.store` (1.595 seconds).
- Native interpreter: 98/98 tests pass (2.360 seconds).
- Native checked memory/packed source cases: 5/5 pass (16.452 seconds including
  the incremental test build). This includes a rejected float read from a
  packed integer field with an exact carrier diagnostic.
- Dew memory/packed cases: 10/10 selected from 161 pass (4.310 seconds for
  execution; 16.853 seconds for generation, link and execution).
- All 88 operations have independent fixed byte goldens. They use unaligned
  addresses and exact float/vector bits.
- All 88 operations also test their last valid address, first invalid address,
  and the maximum memory32 address. Invalid stores use different values and
  must keep the old last-page bytes.
- Allocation failure, invalid carriers/arity, invalid lane immediates and state
  reset have separate checks.
- The packed source test calls every one of the 55 public core helpers and four
  cast builtins, with 64 lane/type checks. Type queries distinguish Swar32,
  Swar64 and U32.

Raw logs, exact compiler identity, byte models and measured runtime controls are
under `.tmp/transforms-v4/memory/`. The Native interpreter/source group took
19.155 seconds, and its Dew follow-up took 18.511 seconds; their combined
37.666-second run exceeds the project's 30-second activity rule. The later page
boundary lanes each stayed below that limit. No speed gain is claimed.

The independent source review found no confirmed correctness defect. Its byte
model agrees with all 88 goldens and both tables match the normal catalog.
The page-edge gap raised in that review was then covered for all instructions.
Claude remained quota-blocked until 20:50 UTC, so no Claude assessment is claimed.

## Memory limits

The backing buffer has exactly 65,536 byte elements and is absent for transforms
that do not use memory. A single buffer is retained per active application; no
raw memory view escapes to source values. VM code caching does not retain it
between applications. The 64 KiB ledger charge is a logical allocation measure,
not a measured total-heap limit. The records under `runtime-results.json` include
whole compiler process peak RSS; that includes the frontend, runtime and GC and
cannot establish the buffer's total heap overhead.


The four public macro examples validate and return 42. The final build also
compiled ordinary runtime counterparts for memory, all packed helpers and packed
storage; each validated with no host imports and returned 42 after optional
Native startup. Final macro control: 2.131 seconds; ordinary controls:
1.021–1.162 seconds. Whole compiler peak RSS was 374,948–502,560 KiB across
these different inputs. This is an absolute process sample, not a gain claim.
The final JS compiler SHA-256 is `3670801b462bdcbca272a61ad39bb8e8a6c73827d883244dd751b7dab4e6eae8`.
All raw samples and output hashes are in `runtime-results.json`.
