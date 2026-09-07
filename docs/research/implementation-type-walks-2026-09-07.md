# Checked implementation signature comparison

## Contract

Both signature graphs are checked before equality, mismatch, or Error recovery.
The graph includes generic and Self substitutions as edges. An active node
revisited before completion reports EVD-211. A completed shared child is reused.
IDs and owned argument spans are checked before access (ARN-104 and ARN-101).
Failures retain module, root type, expected, actual, and detail fields.

The postorder walk returns a context-specific map of final substituted roots.
Signature comparison uses a pair work queue over those checked maps. It has no
semantic depth limit. It visits structured children even when both sides have
the same type ID: the generic contexts can still differ. Product, function,
application, and member projection children all participate. Nominal declaration
references remain leaves; recursive nominal declarations are not type-arena
cycles.

Error types retain ordinary diagnostic recovery only after both graphs pass
validation. A malformed sibling or the other root cannot disappear behind Error
or an equal-ID fast path. Internal contract failures remain diagnostics, not
ordinary `false` results.

## Checks

- Native negative-first test compilation failed on the not-yet-defined checked
  API (0.844 seconds). A later test annotation error failed in 1.518 seconds.
- Four native graph tests passed in 9.067 seconds: depth 1,025 with shared
  children, equal-ID/different-context comparison, structural cycles and bad
  spans, and substitution cycles and invalid target IDs.
- Full native suite: 988 tests passed in 123.071 seconds. This remains a speed
  defect; this batch changes correctness, not speed.
- Integration suite: 268 tests passed in 49.423 seconds.
- Self-host hardening: 311 tests and 65 exact trap records passed, together with
  every shared execution corpus, in 70.801 seconds. Generation took 30.872
  seconds; that is also a speed defect. The new real cycle trap is checked by
  the host decoder, not merely accepted as an arbitrary trap.
- Library suite: 326 tests plus shared execution cases, 14.877 seconds.
- Generated-source and builtin policy checks: passed, 15.659 seconds.

- Clean bootstrap: A/B/C build and validation passed in 159.718 seconds. B/C
  core and linked bytes match, linked SHA-256
  `df4aa9c5ae4618ce0a1721d20cd6bffd9664df3fe102d510e0e35ba86e4b56f5`.
  A build took 38.864 seconds; A execution 42.946 seconds; B execution 56.149
  seconds. These are recorded speed defects and remain outside this work.
