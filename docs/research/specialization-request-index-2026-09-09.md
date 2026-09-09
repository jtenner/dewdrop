# Specialization request index checks

Request insertion/lookup now checks request/link array lengths before lookup,
including an immediate duplicate hit. Each visited request must be in range,
belong to the selected declaration, and retain a valid concrete shape span.
Span and stored-shape checks precede arity/equality shortcuts.

Every non-sentinel next link must address an older record. Insertion already
appends records and links to the old head, so this is an inductive invariant of
valid state. Strictly decreasing indices give a termination proof without a
depth or pass limit. The check runs before an immediate cache hit too.
It validates visited links; it does not claim to scan unrelated request chains.

Seven tests start from one valid request and change one field/array. On the old
code, four did not trap; three trapped without the required numeric context.
The baseline lane failed in 58.351 seconds. The implementation passes 781
hardening tests and 388 complete failure records (58.861 seconds), including
all seven mutations and the shared execution corpus. An added positive case
walks sixteen distinct requests and reuses the oldest without adding a record.
Final hardening passes 782 tests, 388 records, and all shared execution checks.
Library checks pass (26.660 seconds); generated-source and policy checks pass
(4.196 seconds). Hardening remains over the 30-second budget. A clean bootstrap
will cover this change with the next related body-flow boundary fix.

This is the self-host request-index boundary. Other specialization work-stack
assertions, evidence graphs, and remaining numeric-context sites remain open.
