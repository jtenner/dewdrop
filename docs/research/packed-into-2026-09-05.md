# Packed peer conversions use Into

All 132 ordered, distinct peer conversions now use ordinary Dew `Into<T>`
implementations: 12 in the packed 32-bit family, 30 in the 64-bit family, and
90 in the SIMD family. The generator owns these implementations. Each body uses
the checked equal-carrier unsafe cast. No compiler-owned conversion is added.

The expected result type selects the target implementation. Conversions preserve
all bits, including sign bits and floating-point NaN payloads. They are not numeric
lane conversions. Named numeric conversion operations keep their separate APIs.
Conversions between different physical widths are not supplied by this change.

Replace `value.reinterpret_as_target()` with `value.into()` in a context whose
result type is known. The old free helpers, inherent methods, and generated
`wasm_*_reinterpret_as_*` wrappers are removed. Raw carrier accessors remain.
Dew is unreleased; no compatibility aliases keep the removed API alive.

The generator policy test and native 132-conversion matrix both failed before the
implementation. All four policy tests now pass. The nine focused native tests
pass in 12.290 s; all seven lane integration tests also pass without relaxing the
existing no-extra-wrapper assertion.

All 294 library runtime tests pass (11.819 s), with byte-identical repeated test
compilation. New runtime cases cover all five requested I16x4 targets, a high-bit
32-bit round trip, and a SIMD NaN-payload round trip. Logs:
`/tmp/dewdrop-into-native.log`, `/tmp/dewdrop-into-lanes.log`, and
`/tmp/dewdrop-into-runtime.log`.

The runtime tests exposed the collection arena defect documented in
`collection-expression-arenas-2026-09-05.md`. Self-host execution exposed the
explicit generic and specialization defects documented in
`explicit-call-type-correctness-2026-09-05.md`. These are separate correctness
commits, not changes that weaken the tests.

The complete routine native suite passes 768 tests, the complete integration
suite passes 266, and self-host hardening passes 103 tests and 18 emitted probes.
Lane, intrinsic, and standard builtin registry generation checks pass.

The clean A/B/C bootstrap passes validation and reaches byte equality. Both B
and C have SHA-256
`2e88a976f767ba6484f4bc6342218caca27a15f81c26260eeebe597c195e2135`.
Log: `/tmp/dewdrop-into-bootstrap.log`. The A build and both self-host compilation
steps still exceed 30 s and remain recorded performance bugs.

This completes packed peer conversion migration, not the full standard-library
builtin migration. Array, Map, Set, buffer, text, scalar normalization, and
remaining SIMD/host-operation ownership still require separate work. The inventory
in `raw-wasm-builtins-2026-09-04.md` remains open. Correctness takes priority over
speed improvements.
