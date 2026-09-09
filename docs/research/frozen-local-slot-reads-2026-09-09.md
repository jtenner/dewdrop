# Frozen local slot reads

Local slot and erasure queries now share the local declaration reader's
required-plan, source-span, and parallel-table checks. A missing body plan
cannot count source locals to reconstruct a slot. A short slot table cannot
fall back to the source shape to decide whether storage exists.

The reader requires the requested local identity, matching saved carrier
records, and a slot consistent with physical erasure. Stored values require
concrete carriers and a slot within the frozen local range, excluding a
lambda's environment slot. The physical count is checked before computing
the range. Ordinary fast local-ID lookup is retained.

Declaration emission still verifies exact slot order once per body, and the
body freeze witness checks the saved tables. The per-read check is not a new
full source-arena freeze or a replacement for those checks.

Six new tests failed for the intended reasons on the old code (58.820 seconds):
missing plans, a short slot table, an unknown local ID, an out-of-range slot,
and a stored scalar changed to the erased sentinel. They now check all nine
numeric fields. A positive Unit-local test verifies that valid erasure still
returns no slot. Policy checks forbid the removed source-shape/count fallbacks.

The unused source-based physical-local counter and lambda-offset guess are
removed. Complete reference assignability and remaining non-local emission
fallbacks remain separate work. Runs above 30 seconds remain timing bugs;
speed work is deferred.

Validation passed: 765 hardening tests, 376 complete failure records, and all
shared source checks (59.313 seconds). Native stdlib checks passed (26.626
seconds); generated/policy checks passed (4.113 seconds). Clean bootstrap
passed in 171.495 seconds. Compiler B/C raw and linked output hashes match:
`be72d77a73f1cb00c61de4cd04310761f4b6697aefc70e83c930412e25bc8065`.
