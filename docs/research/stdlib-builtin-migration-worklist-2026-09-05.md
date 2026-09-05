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
- [x] Math: all 17 primitive helper targets use checked raw instructions;
  higher-level algorithms remain Dew. See `raw-math-instructions-2026-09-05.md`.
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
  Self-host request insertion now rejects both states, including nested products,
  with exact SPC-301 records; normalization preserves the distinction. See
  `specialization-shape-evidence-2026-09-05.md`. Native requests now reject both
  states too, and tuple keys are structural; see
  `native-specialization-shape-evidence-2026-09-05.md`. Broader fragment
  boundaries remain open. Inferred callback signatures now use a private,
  structural lowering pool and exact specialized targets; see
  `inferred-callback-signatures-2026-09-05.md`. Native nominal callback invocation
  now checks precise and erased signatures; see `nominal-callback-abi-2026-09-05.md`.
  The self-host lambda/plain-function identity collision is fixed; see
  `self-host-lambda-link-identity-2026-09-05.md`. Lambda-relative capture inference
  is fixed; see `self-host-relative-captures-2026-09-05.md`. Lambda body verification
  and missing-body checks are fixed; see `self-host-lambda-body-verification-2026-09-05.md`.
  Exact self-host generic function-reference targets now pass 18 execution checks;
  see `self-host-exact-function-references-2026-09-05.md`. The shared source now
  now passes all 66 shared callback checks. Captured closure reads,
  shared mutation, and nested forwarding now pass executable checks; see
  `self-host-captured-closures-2026-09-05.md`.
  Lambda fragment spans, parameter roles/order, Unit erasure, and owning
  declaration now have checked contracts; see `self-host-lambda-fragment-contract-2026-09-05.md`.
  Source Unit local erasure and boxed Unit product operations are fixed; see
  `self-host-erased-local-slots-2026-09-05.md` and `self-host-boxed-unit-products-2026-09-05.md`.
  Generic scalar/Unit captures and a subsequent clean bootstrap remain open.
- [ ] Require valid collected source in compiler integration fixtures. A callback
  fixture used an invalid local type annotation but checked only inference
  diagnostics. Its valid-source replacement must exercise the actual call.

## Exit checks

- Every remaining builtin maps to one Wasm instruction or an explicit unsafe cast.
- Source spelling and link order cannot select physical identities.
- Native and self-host execution cover values, bounds, effects, and expected traps.
- Generated-source checks, native tests, full integration, library runtime,
  self-host hardening, and clean A/B/C bootstrap pass.
- All commits include current documentation; no unrelated worktree changes are staged.
- Timing remains measured. Runs over 30 seconds remain visible performance bugs;
  speed work does not displace correctness work.
