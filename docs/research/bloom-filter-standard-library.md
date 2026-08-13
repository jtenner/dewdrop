# Bloom filter standard library

Date: 2026-08-13

## Scope

`dew.std.bloom_filter` provides a reusable, allocation-free probabilistic membership prefilter. `BloomFilter` is a transparent alias of `U64`, so one filter occupies one scalar carrier and updates return a new value rather than mutating shared storage.

The module exposes both `Hash`-driven and precomputed-hash methods:

- `BloomFilter::empty()`
- `filter.is_empty()`
- `filter.add(value)`
- `filter.maybe_contains(value)`
- `filter.add_hash(hash)`
- `filter.maybe_contains_hash(hash)`

## Policy

Each hash selects two bits: one from the low six hash bits and one from bits 32 through 37. Insertion sets both bits. A query is definitely absent when either bit is clear and possibly present when both bits are set.

A positive result is never exact membership evidence. Callers that require exact semantics must verify a positive result against their authoritative collection or equality relation. False negatives are not permitted for values queried with the same deterministic hash. The two probes may select the same bit, and collisions are expected as the fixed 64-bit filter fills.

The module stores no values, has no removal operation, and does not estimate cardinality. Returning to an empty filter uses `BloomFilter::empty()`; clearing individual values is impossible without counters because shared bits may represent multiple inserted hashes.

## Architecture

The implementation is ordinary Dew source over `U64`, bitwise operators, shifts, and the ambient `Hash` protocol. It adds no compiler builtin, runtime helper, allocation, table, or host dependency. Inherent methods declared on the transparent alias retain its scalar carrier; precomputed-hash methods let hot callers avoid repeated hashing when the hash is already available.

The module uses reserved standard-library slot 52 and is included in deterministic `open dew.std.*` expansion. Its generated bootstrap mirror is owned by `tools/generate_bloom_filter_std.py`.

## Validation

Direct standard-library tests cover empty filters, insertion, definite misses, immutable value behavior, generic `Hash` evidence, parity between value and precomputed-hash operations, and a deterministic false-positive collision between distinct strings. Module-selection tests cover explicit and wildcard loading. JSON integration remains a separate measured tranche so the general primitive lands independently of one consumer.
