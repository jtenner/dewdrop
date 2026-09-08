# Self-host lowered child ownership

The self-host physical planner now checks source child ownership before it
builds carrier cells or a work graph. Final body-table verification repeats
the same checks. A source mutation after planning cannot bypass this boundary.

The checker validates the five body spans first. It then checks every lowered
expression variant explicitly, including runtime calls, unresolved call/field
forms, evaluation sequences, and constructor source metadata. Only the exact
U32 missing sentinel erases optional edges. Arguments, constructor fields,
block items, pattern lists/fields, and match-arm members retain body ownership.
Lambda IDs and logical local uses have arena checks too.

The failure path writes a complete phase-6 record and immediately traps. It
does not allocate a failure record on the valid path or format a message at the
failure boundary. ARN-101 and ARN-104 tags match the native lowered-child
checker, except that self-host capture lists are stored on lambda records,
not the closure-expression node. Those capture identities remain separate work.

Nine tests mutate a valid linked body or its child list. Eight expose old
acceptance of invalid state; the old block-item case already trapped without
the required child record. The host verifies all nine complete records.
One test re-enters planning to prove the check precedes work-graph construction;
the others re-enter final verification after a source mutation.

Measured checks:

- Before the fix: 338 tests pass, eight fail, in 69.165 seconds. The exact-record
  checker also fails, as required.
- With the fix: all 346 tests and 95 exact records pass in 70.193 seconds,
  including typed FFI smoke and all shared library/type-query/semantic probes.
- Fresh clean bootstrap: 178.920 seconds. A build: 44.583 seconds; A execution:
  48.243 seconds; B execution: 64.026 seconds. B/C core and linked bytes match.
  Linked SHA-256:
  `989a5cff9b279fde95bdcdc261dc696a00b4fe42df0d6ffe0ce1b5a91707e8ef`.
- Generated-file and policy checks pass. The native compiler and pinned
  provider are unchanged from their preceding full-lane checks.

The preceding native batch passed 1,046 native tests, 268 integration tests,
326 library tests and all shared corpora. These checks do not complete capture
identity, control scope, IR cycle, full reference-type, or shadow-stack proofs.
Speed work is excluded; runs over 30 seconds remain recorded speed bugs.
