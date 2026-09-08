# Physical body table completeness

## Static review follow-up

`self_host_verify_one_physical_body` checks that local slots and local values
are parallel, but does not yet compare both lengths with the owning source
body's local count. Its local loop condition can skip a missing tail.
The expression table is indexed by body-relative expression identity; its
complete length and stored-ID order must be checked before reading source
expressions or running individual transfer/call checks.

Add one-mutation witnesses from a valid plan: remove matching local-table tails,
remove an expression-table tail, use an expression outside the body, and swap
stored expression IDs. Require exact numeric arena/identity records before an
unchecked lookup. Check the native planner's corresponding boundary too.

## Implementation

The self-host verifier now checks all five source spans again at the read
boundary. It compares all three local tables with the logical local count,
including Unit and elided entries. It checks the expression table's full length,
then membership and ordered stored identity before reading source expressions.
All four control tables must cover the source loop-index extent. These checks
run before flow, pattern, call, local, and result verification.

The local loop no longer silently skips a missing table entry. ARN-103 retains
the previous detail 710 for slot/value disagreement. Details 711–717 identify
local values, local carriers, expressions, control states, control-state values,
control results, and control-result values. ARN-102 uses the checked relative
index record; ARN-106 identifies an in-range expression stored in the wrong slot.

Twelve tests start from successfully planned source. Eleven corrupt one table
or identity (one truncation removes corresponding tails from the three local
tables). The host checks the complete numeric record, not merely the trap.
The positive test proves erased Unit parameters still have logical entries.

The native emitter does not have this separate dense expression-carrier plan.
It allocates local indices from the source body count in `starshine_body_locals`.
Its source-span and later child/identity consumers remain separate audit work;
this change does not claim to have completed that native audit.

## Measured checks

- Before the fix: 328 tests passed and nine new tests failed in 69.948 seconds.
  Two invalid global IDs already trapped, but that alone was not accepted as
  proof of the required numeric failure.
- After the fix: all 337 self-host tests and all 86 exact invariant records pass
  in 70.726 seconds. The typed FFI smoke and all emission/semantic probes pass.
- Fresh `tools/check-self-host-bootstrap.sh --clean --fast`: 165.971 seconds.
  Compiler A build: 40.051 seconds; A execution: 44.187 seconds; B execution:
  57.401 seconds. B/C core and linked bytes match. The linked SHA-256 is
  `b59741bceb31675079ee96a24e9f5296c065df77cfb60a756db77ab00cfc7895`.
- Generated-file and policy checks pass. Full native/integration/library/stress
  lanes remain due after the following native body-arena batch. The preceding
  provider batch passed all 10,990 pinned Starshine tests.

No speed work is included. This closes the table-completeness gap, not the
remaining full reference-type, freeze, child-list, or shadow-stack obligations.
