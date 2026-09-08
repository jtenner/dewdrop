# Native lowered-body arena checks

The native emitter allocates logical local slots from a lowered body and then
reads its block, expression, and local spans. Earlier HIR checks do not certify
these later spans after specialization or lambda-body selection.

The new checked boundary belongs to the semantic package, which owns the
read-only lowered records. All four backend paths share `starshine_body_locals`;
it now checks the body before allocation. The checker validates five owned
spans with subtraction-based bounds, expression/block root ownership, and each
local's stored body and relative ID. Unit and elided locals are not exempt.

Failures retain the complete `BodyArenaFailure` numeric context. The backend
uses phase 7. Span tags 1–5 match the self-host physical checks; ARN-102 root
records pack the arena tag and owned length. ARN-106 local records identify the
global local slot, using tag 2 for relative ID and tag 6 for body identity.

Seven tests include valid named/lambda bodies, five overflow mutations,
negative starts and lengths, cross-body expression/block roots, and wrong local
IDs/owners. They compare complete failure records. The first test draft was
moved from the backend to semantic tests because lowered records are read-only
outside their owning package; no public mutators were added for tests.

Measured checks so far:

- Initial test-draft type errors: 2.313 seconds (not a regression result).
- Corrected test placement, before the new API: 1.455 seconds; the checker was
  unbound. This is an API-first red test, not an executed old-emitter failure.
- All seven checker tests pass in 10.407 seconds.
- Public API regeneration: 1.401 seconds; one checked-boundary function added.
- Routine native lane: 1,031 tests pass in 152.159 seconds (585 semantic tests
  in 95.063 seconds and 95 backend tests in 44.237 seconds).
- Full integration lane: 268 tests pass in 57.766 seconds.
- Library lane: 326 tests and all shared execution corpora pass in 30.082 seconds.
- Stress lane: all 15 tests pass in 0.345 seconds.
- Self-host hardening: 337 tests, 86 complete invariant records, typed FFI smoke,
  and all shared execution/semantic corpora pass in 70.401 seconds.
- Fresh `tools/check-self-host-bootstrap.sh --clean --fast`: 166.277 seconds.
  A build: 45.135 seconds; A execution: 43.511 seconds; B execution: 55.977
  seconds. B/C core and linked bytes match, with linked SHA-256
  `b59741bceb31675079ee96a24e9f5296c065df77cfb60a756db77ab00cfc7895`.
- Generated-file and policy checks pass. The unchanged pinned provider also
  passed all 10,990 tests in the preceding StringView provider batch.

This is not a proof of every expression child, call recipe, or Wasm reference
type. Those audit tasks remain open. Speed work is excluded.
