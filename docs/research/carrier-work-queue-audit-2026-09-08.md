# Carrier work queue completion audit

The self-host body planner now uses one explicit work-queue state machine:
propagation, a full transfer audit, then completion. The audit runs the same
block and expression transfer code as propagation. Hubs do not enqueue work
during the audit. A transfer which still changes a fact reports BOD-604 at the
owning body and expression; it cannot repair the state and then claim success.

A changing transfer also schedules itself. This is required when a rule reads
its own output and no neighboring rule will wake it again. Completion requires
an empty queue, no active transfer, and an audit count equal to the node count.
A completion flag alone is not a certificate.

The queue checks its active-item protocol, pending flags, item bounds, and graph
table lengths. Graph edge links must point to an earlier edge or the missing
sentinel. Thus each adjacency walk strictly decreases and cannot cycle. Source
and destination node IDs are checked before use. Missing semantic dependencies
are detected by the final transfer audit, not guessed from array lengths.

Graph node totals use U64 before conversion to U32. Scheduling an empty work set
returns without subtracting one from zero. The progress resource guard also uses
U64 (`64 * node_count`), not an overflowing U32 product. Reaching that guard is
an explicit BOD-604 resource diagnostic, not normal completion and not a claim
that a fixed number of propagation passes suffices.

## Numeric records

All records include phase 6 and the original module, declaration, and body.
The expression is the owning source expression when the item identifies one;
otherwise it is the missing sentinel. Detail packs the role in the upper 32
bits and the work item or edge index in the lower 32 bits.

| Role | Contract |
| --- | --- |
| 0 | An audited transfer cannot change a fact |
| 1–2 | Start/finish uses exactly one active transfer |
| 4 | Progress resource guard |
| 5 | Pending flag agreement |
| 6–7 | Queue cursor and item bounds |
| 8 | All rules were audited before completion |
| 10 | Parallel edge arrays |
| 11–12 | Edge head and target bounds |
| 13 | Strictly decreasing adjacency links |
| 14 | Block and expression node coverage |
| 15 | Wide node count before U32 conversion |

## Tests

A ten-cell carrier chain uses the production scheduler, carrier join, and audit.
It requires nine strict increases. Removing one dependency from the valid graph
leaves an unfinished fact; the same final audit reports the exact BOD-604 record.
Tests also cover a self-dependent rule, empty work, graph corruption, queue
protocol failures, false completion, and an explicitly nonconverging rule.
The node-count overflow probe starts from a valid small body and changes only
the supplied control count. Numeric tests check all nine record fields.

The first hardening run passes 513 tests and 179 exact records (75.666 seconds).
The final run also includes the node-count overflow probe: all 514 tests, 180
exact records, and all shared execution corpora pass (70.875 seconds).

Clean bootstrap passes (240.686 seconds). Compiler B and compiler C have
identical raw and linked SHA-256 hashes:
`a906c81e7333a3e081c1e737762827ce74bb7bff9b8741c1dbb584c03d500d3e`.
The broader serial regression run also passes:

- Native: all 1,201 tests (185.319 seconds).
- Integration: all 268 tests (67.075 seconds).
- Library: 326 tests and all shared execution corpora (27.492 seconds).
- Generated checks (4.560 seconds).
- Stress: all 15 tests (0.360 seconds).

Runs above 30 seconds remain timing defects; no speed work is included.

This is a runtime post-fixed-point check, not a mechanized proof of every
transfer's monotonicity or full Wasm reference typing. Those separate
obligations remain visible.
