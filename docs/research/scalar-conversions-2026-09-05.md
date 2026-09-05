# Scalar conversion migration

All 100 scalar `Into` implementations now call ordinary Dew conversion functions.
The remaining 92 compiler-owned conversion targets have been removed. There are
23 raw Wasm conversion instructions with checked physical input and result types
in both compilers. Raw forwarding uses that same signature inventory.

## Semantics

Integer conversions preserve the existing modular narrowing and signed/unsigned
widening rules. Dew performs narrow masks and composes wrapping and sign extension.
Equal-carrier changes use explicit `unsafe.bitcast`; they cannot change a Wasm
carrier or convert a reference. Floating truncation uses real Wasm instructions;
the eight narrow range checks remain Dew code from the preceding fix.

The compatibility intrinsic generator no longer publishes removed conversion
targets or copies preamble wrappers that depend on private raw declarations.
Its existing `i64_trunc_i32` alias now targets `i32.wrap_i64`. The public scalar
conversion functions and all `Into` implementations remain available. The
generated compatibility surface has 1,100 declarations covering 734 backend
targets; other families still need migration.

## Tests

The policy test first failed on all 92 remaining declarations. It now checks all
100 functions and verifies that each of the 23 backend entries emits exactly one
instruction. Native tests validate all 23 signatures and reject wrong inputs.
Self-host tests independently reject the same invalid input signatures.

A shared integer-arithmetic oracle runs 750 checks across all 100 scalar `Into`
implementations in each compiler. Cases cover signed and unsigned limits,
negative zero, fractional truncation, NaN, infinities, and traps. These tests run
the actual library code, not copied conversion implementations. Test-module host
imports cannot execute silently. Missing exports, invalid Wasm, or compile errors
cannot satisfy an expected-runtime-trap check.

The existing 72 narrow-float checks also remain enabled. The raw signature and
scalar execution tests are part of the routine native/library/hardening lanes.
Adding 23 explicit raw declarations changes the checked preamble size from 1,309
to 1,332; namespace and deterministic-prefix tests retain exact count checks.

## Final validation

- 769 native tests and 266 full integration tests passed.
- 296 library runtime tests and 750 native scalar conversion checks passed
  (2.886 seconds for the measured library lane).
- 104 self-host hardening tests, 16 invariant records, 21 existing emitted
  execution probes, 72 narrow-float checks, and 750 scalar conversion checks
  passed. The scalar self-host matrix took 1.298 seconds; hardening generation
  took 18.201 seconds after the native compiler rebuild.
- Generated-source and scalar policy checks passed.
- Clean B/C bootstrap passed with identical SHA-256
  `1407d59bfb1fc145779aad31adc5fd002ebe028383d2ee56904d306e49c404f0`.

Performance bugs remain visible: the cold native signature-test build took
26.846 seconds, compiler A build took 42.138 seconds, and B/C compilation took
63.624/66.882 seconds. The latter three exceed the 30-second limit. Correctness
work continues with the other builtin families in the worklist.
