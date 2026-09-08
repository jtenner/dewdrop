# Byte staging belongs to Dew

The parity harness declared two special builtins which asked both backends to
generate complete copy loops. Benchmark-only callers do not make runtime
algorithms valid compiler intrinsics. Both stage functions now have ordinary Dew
bodies in `tools/wasi-parity/staging.dew`; the benchmark generator includes that
same source. This is policy/correctness work, not speed tuning.

The functions use the existing Bytes access/BytesBuilder APIs and one-to-one
byte memory operations. They check the 65,520-byte scratch bound before copying.
Writes retain the logical view offset. Reads construct owned immutable Bytes,
so a later scratch write cannot change the result. The iovec and result area
at addresses 0..15 is not touched. Text storage underneath the library APIs
remains a separate open migration.

Native runtime admission and both runtime dispatchers no longer accept the old
`dew_bench_wasi_stage_write/read` operations. Both old builders and their unused
copy loops are removed. Debug text has its own separate remaining path. The
provider's public FFI signatures and constructor parameters are unchanged.

The parity generator's raw host probes also called obsolete pre-migration
wrapper names. They now call the actual `dew.std.wasm.wasi` foreign declarations.
No host operation is simulated or silently skipped.

## Tests and timings

- The new source-policy check fails in all six old dispatcher/name positions
  (0.037 seconds). After removal it passes (0.032 seconds).
- The provider boundary test first fails because the old runtime is accepted:
  17 pass, one fails (6.679 seconds). After removal all 18 pass (6.570 seconds).
- The 54-case shared functional corpus first passes against the original
  implementation (build 1.851 seconds; execution 0.051 seconds). The first host
  run correctly failed because a standalone CLI build did not export memory;
  the existing memory-export test helper exposes memory and validates the module.
- The Dew implementation builds in 5.800 seconds and passes the same 54 cases
  (0.050 seconds). It covers exact bytes, every source alignment, boundary sizes,
  header/tail preservation, read lifetime, and invalid ranges before mutation.
- Shared tests are wired into the routine library and self-host hardening lanes.
- The full provider suite passes all 10,992 tests in 261.056 seconds. The
  provider removal is committed as `6b2e564ba` before the consumer pin refresh.
- FFI rebuild passes in 10.679 seconds; consumer regeneration takes 4.170
  seconds. The named carrier declarations do not change, only provider identity
  and generated physical metadata. The native boundary test passes (9.329 seconds).
- The parity generator first fails to compile due to two obsolete filesystem
  error conversions (2.282 seconds). They now match the actual error payload,
  and source diagnostics are printed before failure. The full host parity suite
  then passes all 196 checks (87.079 seconds).
- The full library lane passes 326 tests and all shared corpora, including the
  new 54 staging checks (33.114 seconds).
- Self-host hardening passes 415 tests, 114 exact invariant records, and every
  execution corpus (142.423 seconds). Its 54 staging checks pass with the new
  provider in 1.306 seconds.
- Full native: all 1,090 tests pass (151.193 seconds).
- Integration: all 268 tests pass (57.183 seconds).
- Generated checks pass (16.149 seconds).
- Clean self-host bootstrap passes (164.903 seconds). Compiler B and C have
  identical raw and linked SHA-256:
  `e299c97ccac25b37fd922befc461ebb0d82094b82b2ad2438a01711ae60a07e1`.
- All 15 stress tests pass (0.347 seconds).

The consumer pin and generated files use provider commit `6b2e564ba`. Runs
exceeding 30 seconds stay visible as timing defects; this change does not attempt
to fix them.
