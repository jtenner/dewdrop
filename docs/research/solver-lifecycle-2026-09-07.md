# Solver operation boundaries and complete self-host undo checks

## Defects

Three native regression tests failed against the old solver in 9.471 seconds:
failed unification left pending pairs, early search results left pending type
work, and zonk kept its returned value in the work-result array. Reset could
erase damaged parallel state, and a later operation could silently clear work
left by an earlier operation.

The self-host solver validated undo entries while applying them. A bad older
entry could therefore trap after newer restoration writes. Commit validated
only parallel array lengths and could discard an invalid complete record.

## Changes

Both solvers now give each operation an explicit owner for its work arrays.
Entry checks reject existing work. A normal positive or negative return drains
that operation's work; unification keeps its source diagnostic. Zonk returns
its result and releases its scratch/result arrays. Reset, snapshot, commit,
rollback, and zonk check parallel state and idle work at their boundaries.
Reset and zonk require closed snapshots. An undo record with no open snapshot
is an error, not resettable scratch.

Native snapshot operations also check saved arena lengths before truncation or
commit. Numeric records distinguish LIFO, owned-array, work-state, and arena
failures. The supplied snapshot's complete token is retained in the native
failure text as well.

Self-host rollback and commit now preflight the whole undo range before any
restoration write or snapshot pop. The preflight returns the existing full
numeric failure record. Saved kinds, indexes, sizes, parents, and type bindings
are checked, including the negative resolved-type encoding. Both commit and
rollback check the saved arena lengths.

## Tests and limits

Native tests check successful recovery, ordinary mismatch cleanup, exact
numeric mutation records, LIFO, saved arena bounds, and unowned undo entries.
Self-host tests check operation cleanup, non-mutating preflight, successful
rollback after correcting one bad field, and exact trap records for invalid
commit, aligned pending work, and unowned undo records.

This batch checks lifecycle and undo state. It does not claim a full audit of
every type/child arena consumer, structural zonk graph, or phase freeze point.
Those remain in the active solver/arena task. No speed work is included.

## Measured checks

- Initial native operation tests: three failures, 9.471 seconds.
- Fixed native operation tests: three pass, 9.181 seconds.
- Native suite with six lifecycle tests: 1,018 pass, 137.088 seconds. The
  semantic lane took 85.309 seconds and backend took 39.457 seconds. Both
  exceed 30 seconds and remain speed bugs.
- First self-host check stopped on an incorrect scratch field name in the new
  code, 35.978 seconds (generation 28.159 seconds). The name is corrected.
- Corrected self-host hardening: 316 tests, 68 exact invariant records, and all
  shared execution corpora pass in 62.500 seconds (aggregate speed bug).
  Generation took 22.367 seconds; emission probes took 22.604 seconds.
- Native integration: 268 pass in 51.149 seconds (aggregate speed bug).
- Library: 326 tests and all shared execution corpora pass in 15.668 seconds.
- Generated-source and policy checks pass in 15.648 seconds.
- Clean bootstrap: A/B/C validation and probes pass in 160.553 seconds. B/C
  core and linked bytes match, SHA-256
  `1e71bc66bf3e79c3ed9a7260de2af657daee7d2b33ee40f6fb12ed9ac2040062`.
  A build took 38.974 seconds; A execution took 43.324 seconds; B execution
  took 56.543 seconds. These and the aggregate lane remain speed bugs.
