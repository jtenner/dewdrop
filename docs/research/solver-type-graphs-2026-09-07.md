# Checked solver type graphs

## Scope

Solver type reads now distinguish the missing sentinel from a real Error term.
Both compilers validate local and encoded resolved IDs before indexing. Decoding
adds two before negation, including at the signed minimum.

Unification, occurs checking, unresolved-variable search, and zonk validate their
complete input graphs before equality, Error recovery, or normal traversal.
The check uses an explicit DFS worklist with active and completed states. Shared
nodes are visited once. Nominal declarations are leaves; their permitted nominal
recursion is not confused with a cycle in a structural type graph.

Products, function parameters/results, application bases/arguments, projections,
and local/resolved arena ownership are covered. Variable-root and binding walks
are bounded. The self-host preflight also checks stored variable identities and
reads without path compression. A later bad sibling cannot be hidden by an
earlier Error term. Numeric failures retain the offending type or span.

The public self-host representative read also validates the complete binding
walk and stored variable identity before retaining its normal path-compression
behavior. One old self-host test explicitly required missing-ID-to-Error
recovery. It now checks the missing-ID diagnostic separately from legitimate
recovery using an explicit Error term. Separate trap probes check real invalid
type reads and unification calls; no test accepts an unexpected trap.

This does not yet claim that every other phase's child/arena consumer or frozen
physical boundary has been audited. The active solver/arena task stays open.
No speed work is included.

## Regression coverage

- Native exact-record tests: later structural cycle after Error, invalid owned
  span, invalid child ID, missing sentinel, encoded resolved IDs, and a depth-2048
  shared product graph.
- Self-host cases: actual zonk and unification traps with exact numeric records,
  missing sentinel reads, and a depth-1024 shared graph with a one-child mutation
  and recovery.

## Measured checks

- Four focused native tests pass in 9.358 seconds.
- Native suite: 1,022 tests pass in 144.285 seconds. Semantic tests took 89.936
  seconds; backend tests took 41.949 seconds. These exceed 30 seconds and remain
  speed bugs.
- First self-host generation stopped on multiline Dew syntax errors in the new
  fixtures/helper, 36.381 seconds (generation 28.560 seconds). These are fixed.
- The next self-host run passed 319 tests and 71 exact records, but failed the
  old missing-sentinel recovery test, 64.132 seconds. That contract test has
  been replaced as described above, with two more exact trap probes.
- Final self-host hardening: 322 tests, 73 exact invariant records, and all shared
  execution corpora pass in 64.465 seconds (aggregate speed bug). Generation
  took 23.338 seconds.
- Native integration: 268 tests pass in 54.089 seconds (aggregate speed bug).
- Library: 326 tests and all shared execution corpora pass in 17.220 seconds.
- Generated-source and policy checks pass in 15.856 seconds.
- Clean bootstrap: A/B/C validation and probes pass in 162.152 seconds. B/C
  core and linked bytes match, SHA-256
  `ee37766cff0bb07944bb28b08a2e8605a71a849bcfe252d5c09d37fa39a051b3`.
  A build took 39.430 seconds; A execution took 44.333 seconds; B execution
  took 56.480 seconds. These and the aggregate lane remain speed bugs.
