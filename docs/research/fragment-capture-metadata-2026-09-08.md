# Capture metadata before fragment planning

Body boundary checks validate selected captures and their sources. Earlier and
global consumers also need a metadata preflight:

- Native fragment planning scans every capture and reads its lambda's elided
  flag before checking that lambda ID.
- Native local capture-cell lookup does the same across the module, including
  captures unrelated to the current body.
- Self-host closure storage also scans module-wide locals and captures before
  the body boundary.

Both compilers now check every lambda's stored ID/root body and capture span, then every
global capture's owner, relative ID, and membership in that owner's span.
Two lambda spans cannot share an entry with one stored owner. The global scan
catches orphan entries outside every span. Checks are linear in valid metadata
and independent of type concreteness: generic templates retain valid ownership
before physical specialization.

The existing numeric record schema retains the actual phase. Shared checks use
a real root body after validating its module/local ID and stored identity. No
fake lambda body is constructed. Public emission entry points check metadata
again to reject mutations made after fragment construction.

SelfHostLoweredChildContext now carries the phase. Existing body checks retain
phase 6; global fragment checks use phase 4; emission checks use phase 7.

The preflight also checks every global local's owning body/lambda and membership in that
owner's local span. Native compile_time_lambda_layouts reads local.lambda
before its elided flag, so capture-only validation is insufficient. Existing
local identity and capture-table methods are reused once their real-body
context is valid. A separate global capture scan detects orphan entries outside all
declared capture spans, including empty spans and elided lambdas. Query private
instances retain the original spans and IDs; generic shapes are not errors at
this metadata boundary.

Native entry points are fragment construction, private-instance
lambda-layout preparation, public code-section emission, and public program
emission (including private instances). There is no global scan inside each
per-local helper. Self-host fragment planning and emission check both ordinary
modules and private instances before storage consumers run. Lambda-local spans
also check each claimed local's owner, preventing overlapping spans from being
accepted merely because each global entry names some valid lambda.

Twelve focused native metadata tests cover valid/generic tables, wrong root
modules, missing roots, stored root/lambda identities, capture ownership and
relative IDs, overflowing/empty spans, source ownership, orphan captures and
locals, and emission-phase context. Existing capture source/ownership cases
run beside them. Self-host tests check exact numeric records, including a
public emission-entry mutation, and keep generic templates valid.

Red: the native no-op preflight passes one positive and fails six negative
checks in 11.244 seconds. The self-host no-op passes 366 tests and fails five
expected-trap tests; its exact-record check rejects the missing trap. The red
lane takes 157.558 seconds. Native implementation passes the initial 20 checks
in 12.702 seconds, and the expanded 25 checks in 13.715 seconds. API metadata
generation takes 1.375 seconds. The first self-host green lane passes 371 tests,
113 exact records, and all execution corpora in 155.301 seconds. The expanded
self-host lane passes 373 tests, 114 exact records, and all execution corpora
in 54.552 seconds.

Full checks pass: 1,079 native tests (150.223 seconds), 268 integration tests
(57.319), 326 library tests and all execution corpora (31.210), and generated
checks (16.927). Clean bootstrap passes in 164.890 seconds. B/C raw and linked
SHA-256 match:
`8f497cba77dcad1fe101b4aae75a59695b0d9db7134163fb9f6766a2ea040a28`.
The pinned provider is unchanged from its 10,991-test passing run. Native
program emission still returns existing link diagnostics before the metadata
preflight; it must not replace a prior phase's source error. The final guard
ordering check passes all 41 integration cases in 10.789 seconds. The first
file-filtered attempt skipped those cases (zero tests, 8.023 seconds); the
verified run uses `--include-skipped`. Stress passes all 15 tests in 0.362
seconds. No speed work is included.
