# Complete physical trait evidence keys

## Defects

The native lowering-key and resolved-request-key writers replaced every node at
depth 64 with `!`. Two trees with different leaves therefore had the same key.
Both writers also encoded any product shape as just shape code 18, losing its
field shapes. A third request writer used `invalid` for a missing node and had
unchecked recursive traversal.

## Contract

One writer now handles lowering evidence and specialization requests. It checks
the complete reachable evidence graph before returning any key: node IDs,
argument spans, child spans, active-node cycles, and the absence of children on
bound/guarded/runtime leaf records. Completed shared children are valid.

The key includes declaration identity, argument kind, every recorded scalar
shape kind, nested product field order, and ordered prerequisite keys. It does
not canonicalize an unresolved shape to Ref or confuse U32 with I32. This key
preserves recorded data; it does not replace the separate physical-carrier
certificate checks.

Graph validation and serialization use explicit work stacks. A 65,536-node/work
budget reports EVD-213, never a partial key. Work-list growth is checked before
wide lists are pushed. A shared DAG can expand to exponential tree text, and a
malformed mutable product-shape array can contain itself; both terminate with a
resource diagnostic. Invalid spans use ARN-101, missing nodes ARN-104, evidence
cycles EVD-211, and malformed leaf prerequisites EVD-212. Failures retain module,
root, expected, actual, and detail fields.

## Checks in progress

- All three initial collision tests failed (8.771 seconds).
- The common writer made all three pass (9.294 seconds).
- Six tests passed (9.144 seconds), including exact negative records, valid
  sharing, explicit expanded-output limits, and malformed runtime children.
- Eight focused tests passed (9.130 seconds), including exact nested/scalar key
  text and a bounded failure for recursive shape storage. The shape mutation is
  then undone and the valid key is checked again.
- Full native suite: 1,004 tests passed in 132.637 seconds. Semantic work took
  82.040 seconds and backend work took 38.343 seconds; both remain speed bugs.
- Integration suite: 268 tests passed, 49.321 seconds.
- Library suite: 326 tests plus shared execution cases, 23.555 seconds.
- Generated-source and policy checks: passed, 15.649 seconds.
- Self-host hardening: 311 tests, 65 exact invariant records, and every shared
  execution corpus passed, 61.492 seconds. Generation took 21.577 seconds;
  emission probes took 22.286 seconds.

- Clean bootstrap: A/B/C builds and validation pass in 157.745 seconds. B/C core
  and linked bytes match; linked SHA-256 is unchanged:
  `df4aa9c5ae4618ce0a1721d20cd6bffd9664df3fe102d510e0e35ba86e4b56f5`.
  A build took 39.097 seconds, A execution 41.825 seconds, and B execution
  54.513 seconds. These remain speed bugs.

The separate native concreteness predicates still have recursive/depth-based
fallbacks. They are the next evidence-check task, not covered by this key fix.
