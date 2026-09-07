# Solver work stacks and snapshot identity

Date: 2026-09-07

The self-host solver no longer returns ordinary failure when parallel unification
or zonk stacks disagree. It checks these stacks before reuse and at each pop.
Type/cache arenas must remain parallel. Zonk checks task kinds, source term kinds,
argument spans, child result spans, and its single final result. Local type IDs
must fit the signed encoding.

Rollback validates stored sizes and type bindings before restoring them. Saved
arena sizes cannot exceed the current arena sizes: truncate must not manufacture
missing snapshot contents. New mutation tests check complete numeric records for
SOL-204, SOL-205, SOL-206, and ARN-101, rather than accepting an arbitrary trap.

The native solver had a separate identity defect: nested snapshots with no
intervening mutation compared equal. Snapshots now have monotone UInt64 tokens.
Reset does not reuse a token. Tests check nested handles, committed handles,
handles from earlier jobs, and exact rollback of parents, sizes, bindings,
variable types, type terms, arguments, diagnostics, and undo lengths. A shared
self-host test checks nested committed mutations and restored variable contents.

Validation:

- Native regression first failed snapshot identity (1/2 tests passed), 8.755 s.
  With the fix, both tests pass, 8.638 s.
- Initial self-host mutation corpus found five silent failures, 38.398 s.
- Final hardening: 269 tests, 53 exact records, and all shared emission probes
  pass, 133.526 s. Cold native generation: 99.001 s. An earlier warm run with
  the first seven mutation probes passed in 37.974 s.
- Generated sources and policy checks pass, 17.466 s.
- Full routine native suite: 951 tests pass, 139.035 s. Semantic: 71.511 s;
  backend: 40.066 s. These runs overlapped integration and shared a build lock.
- Clean bootstrap passes, 358.593 s including build-lock waits. A build:
  137.237 s; A execution: 42.425; B execution: 56.506. B/C core and linked hash:
  `d4846eae5267a010217b90170d53bf4694ef26ef07699e771b59f5465a0108f5`.

Runs above 30 seconds remain performance defects. The cold native C compilation
and a shared Moon build lock delay other compiler lanes. Generation marks are
scratch state, not covered by the exact semantic rollback-content test. The
larger solver/arena audit remains open; this is not a claim that every consumer
or traversal now has a checked boundary.
