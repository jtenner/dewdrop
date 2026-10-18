# Physical type invariant fixture scope

Standard constructor wrappers add valid canonical function types to the physical
invariant fixture. This changed the first signature kind, the signature count,
and the relocation schedule that reports a forged index first.

The unmodified link passes the production verifier before every mutation.
Inspection confirms that canonical source signatures and function types are
both valid entries; grouped physical schedules check their node ownership before
per-module relocations. No production verifier change was needed.

The tests now select the source `read` function by semantic declaration identity,
count all canonical signatures when removing the table, and derive the exact
relocation diagnostic slot from the active grouped schedule. They retain the
real standard imports and check every corruption's full diagnostic record.

The first fixture experiment isolated standard imports and passed 21 of 23 tests
in 14.597 seconds; it was replaced by these identity-based checks. The root
then ran the complete corrected file: all 23 tests passed in 14.470 seconds.
The command and full output are in
`/tmp/dewdrop-implementation-2026-10-18/validation/physical-fixture-final.json`
and `physical-fixture-final.log`.
