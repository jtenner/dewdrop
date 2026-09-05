# Standard library builtin migration worklist

The user requested the full migration, with correctness before speed. This list
tracks remaining implementation work; passing one batch is not completion of the
whole request. Each library family must keep its own bounded implementation commit
and regression tests. No new compiler-owned library algorithm is permitted.

## Completed before this worklist

- Packed carrier helpers are Dew functions using checked equal-carrier casts and
  raw bitwise/load/store operations.
- All 132 packed peer conversions use `Into` implementations.
- Explicit self-host call types and combined owner/method generic slots are retained.
- Collection expression arenas remain parallel for assignments and index sets.
- Raw array calls preserve argument order and do not dispatch on API spelling.
- The latest clean bootstrap before this tranche has identical B/C SHA-256
  `bf43e8f1a8e24f1e249557dc70dc0100f4bca551fef3880fc092f89a7cd18b30`.

## Required implementation queue

- [x] Scalar conversions: all 100 conversion functions now use Dew normalization
  and range policy with 23 checked raw Wasm conversion instructions. All 100
  `Into` implementations remain in use. See `scalar-conversions-2026-09-05.md`
  and `narrow-float-conversions-2026-09-05.md`.
- [x] Scalar arithmetic, comparison, and memory helpers: 64 narrow functions now
  use Dew normalization; full-width operations use 66 checked arithmetic opcodes.
  Scalar and whole-V128 memory operations use 16 checked instructions. See
  `raw-arithmetic-instructions-2026-09-05.md` and
  `raw-memory-instructions-2026-09-05.md`.
- [ ] Remaining SIMD operations: explicit instruction/immediate contracts; express
  compositions, permutations, and convenience algorithms in Dew.
- [ ] Math: use raw instructions for primitive operations and Dew for algorithms.
- [ ] Array: move mutable length/capacity, growth, mutation, iteration, and bulk
  operations out of compiler runtime builders.
- [ ] Map and Set: move hashing, buckets, growth, lookup, and iteration into Dew.
- [ ] Queue, circular buffer, and deque: move storage algorithms into Dew.
- [ ] Text, Bytes, views, and builders: remove compiler-owned representation and
  algorithm dispatch, while preserving UTF and lifetime checks.
- [ ] Remaining host operations: use foreign declarations, not opaque builtins.
- [ ] Remove standard module path/ordinal/name dispatch after its owning library
  migration. Physical type choices must use explicit declaration metadata.
  Interface cache membership now uses recorded module origin, not `dew.std.`
  name prefixes; see `interface-cache-module-origin-2026-09-05.md`.
- [ ] Remove legacy builtin emission paths and enforce a complete opcode/unsafe
  cast inventory across every source module and generator.
- [ ] Finish physical-boundary checks for missing/error specialization evidence;
  neither state may become a valid reference certificate.

## Exit checks

- Every remaining builtin maps to one Wasm instruction or an explicit unsafe cast.
- Source spelling and link order cannot select physical identities.
- Native and self-host execution cover values, bounds, effects, and expected traps.
- Generated-source checks, native tests, full integration, library runtime,
  self-host hardening, and clean A/B/C bootstrap pass.
- All commits include current documentation; no unrelated worktree changes are staged.
- Timing remains measured. Runs over 30 seconds remain visible performance bugs;
  speed work does not displace correctness work.
