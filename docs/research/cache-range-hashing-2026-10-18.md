# Cache footer range hashing

## Change

`blake3_range(input, start, length)` hashes a checked byte range. It does not
copy the input. It returns an error for negative values, a start past the input,
or a length past the available bytes. Its bounds checks avoid integer overflow.
An empty range at the end is valid. The full-input `blake3` function uses the
same compression code. Chunk count calculation also avoids addition overflow.

The strict artifact decoder and the lazy pack footer check use this function.
Each check no longer makes a copy of the full covered part of the pack. Entry
decoding and the pack format stay the same.

## Tests

Run:

```sh
DEW_NATIVE_TEST_PACKAGES=cache_binary tools/test-native.sh
moon bench --target native --release --no-parallelize src/cache_binary/range_hash_bench_test.mbt
python3 docs/research/data/cache-range-hashing-2026-10-18/measure-allocations.py
```

All 26 cache tests passed. The package test build and run took 0.378 seconds.
Official BLAKE3 digest vectors test zero and nonzero range offsets. They include
lengths 0, 63, 64, 65, 1023, 1024, 1025, and 4096, plus larger tree cases. Tests
also check empty ranges at the end, invalid bounds, overflow-sized arguments,
covered-byte corruption, corrupt footer digests, and invalid saved ranges.
Existing strict, lazy lookup, and materialization tests also passed.

The footer corruption test now rebuilds a FOOT entry with a one-bit wrong
covered-range digest. Its entry payload checksum, content lane, and metadata
are consistent. Strict decoding must report exactly
`artifact pack FOOT digest mismatch`. Lazy opening must pass its metadata
checks, then deferred footer verification must report that same error. This
checks the range digest itself instead of accepting an unrelated entry-checksum
error. No production cache rule changed.

A private native package containing both pack test files passed all ten tests
in 0.393 seconds. The [validation record](data/cache-range-hashing-2026-10-18/footer-diagnostics-validation.json)
contains its command, exact source hashes, result, and scope. It used separate
build output while the main compiler tests were active.

## Native measurements

The host was an AMD Ryzen 7 8845HS on x86-64 Linux. Moon was
`0.1.20261012 (748b63c)`; moonc was `v0.10.15+943464bfa`. These are native release
measurements. No cross-compilation or emulation was used.

The focused benchmark holds one 1 MiB plus 16-byte input. The control copies the
first 1 MiB, then hashes it. The candidate hashes those bytes directly. Both use
the same compression code and keep the digest. Input creation is outside the
timed body. Five process runs gave these mean times in milliseconds:

| Run | Copy control | Checked range |
| --- | ---: | ---: |
| 1 | 7.68 | 7.47 |
| 2 | 7.47 | 7.42 |
| 3 | 7.49 | 7.49 |
| 4 | 7.58 | 7.43 |
| 5 | 7.47 | 7.43 |

Each mean uses ten samples of fourteen calls. The median process mean changed
from 7.49 ms to 7.43 ms. This small change is too close to the noise to support a
strong speed claim. Process times, including any build work, were 5.302, 2.579,
2.602, 2.602, and 2.582 seconds. None exceeded 30 seconds.

The separate probe also records 21 one-call samples per version with
`CLOCK_MONOTONIC`. Their order alternates and allocation tracking is disabled
for this part. It compares the exact baseline source with the candidate. Median
times were 7.546075 ms for copy and 7.513614 ms for range. The copy range was
7.528632 to 7.570283 ms; the candidate range was 7.492013 to 7.553681 ms. The
full 32-byte digest matched the baseline on every call. These overlapping
samples support the same limit on a speed claim.

The separate allocation probe compiles the baseline BLAKE3 source from commit
`43fd2930435868228c7289fdfe6c4aa678b9d80b` and the new source in one executable.
The baseline symbols have a prefix to keep them separate. It wraps the native
runtime's `mi_malloc` and `mi_free` calls with GNU linker wrappers. Seven pairs
alternate execution order. All pairs gave the same counts:

| Per 1 MiB hash | Baseline copy | Checked range |
| --- | ---: | ---: |
| Allocation calls | 212,017 | 212,017 |
| Total requested bytes | 14,606,362 | 13,557,793 |
| Peak live requested bytes after start | 1,122,705 | 74,120 |
| Largest allocation request | 1,048,585 | 8,200 |
| Live requested bytes at end | 41 | 41 |

The full-size byte allocation is gone. Total requested bytes fell by
1,048,569. Peak live requested bytes during the call fell by 1,048,585. The
range API adds a small `Result` value, so the total allocation call count stays
the same. These counts include runtime object headers and byte-array trailing
storage. The shared source input was allocated before each measured region.
The probe build took 0.675771 seconds. Its combined executable was 517,736 bytes
with SHA-256 `d536dd33a06d4d1a0a4b6e2dbee69346ad106c327664d6ea2c46bf4a74601243`.

The allocation probe uses a fixed table to track live requests. Its own table
storage is outside the counted requests. It does not measure allocator page
retention, process RSS, or total compiler peak memory. The normal timing
benchmark has no allocation tracking. No process memory or code-size gain is
claimed. The probe's executable contains both versions and is not a production
code-size comparison.

## Evidence

The [evidence directory](data/cache-range-hashing-2026-10-18/) contains the raw
test log, five benchmark outputs, allocation output, source hashes, environment,
and the full probe script. `source-identity.json` identifies the measured
candidate files. The probe output records baseline and candidate source hashes,
generated harness hashes, executable identity, and measured build time.
`blake3-candidate.mbt.txt` preserves the measured hash source. Pass its path to
the probe with `--candidate-source` to repeat that exact source after later
formatting changes.
