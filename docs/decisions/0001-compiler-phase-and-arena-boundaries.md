# 0001: Compiler phase and arena boundaries

- Status: Accepted
- Date: 2026-08-10

## Context

Dewdrop prioritizes generated-program performance, low memory use, deterministic
compilation, and clear compiler phases. Its compiler representations use compact
IDs, flat arrays, and spans into companion arrays. These representations reduce
allocation and make deterministic ordering explicit, but broad result structs
and whole-program rewrites can make ownership unclear.

Replacing the arenas with object graphs would make subsystem ownership more
visible at the cost of memory, locality, and additional allocation. Leaving all
arrays publicly interpreted by every consumer would preserve the representation
but make future optimization, incremental compilation, and post-self-hosting
parallel scheduling harder to reason about safely.

## Decision

Dewdrop will preserve flat arena storage by default while making phase ownership
and mutation explicit.

1. A returned phase result is immutable to its consumers.
2. A phase may use mutable scratch arrays while constructing its result.
3. An optimization that rewrites a prior representation must own an explicit
   copied or newly produced result rather than mutate a result already exposed to
   other phases.
4. Cross-subsystem access should use logical arena views, indexes, or query
   functions when the consumer does not need the full physical contract.
5. Span, sentinel, imported-identity, and cached-artifact validation occurs at
   phase boundaries; validated hot loops may then use direct indexed access.
6. Architecture refactors must not replace compact storage with allocation-heavy
   abstractions without representative measurements.

The intended whole-program sequence is module lowering, explicit program
optimization, specialization planning, physical linking, and backend emission.
Extraction of those concepts may be incremental, but new work should not further
blur their ownership.

## Consequences

- File or package extraction alone is insufficient; each extraction needs a
  coherent input/output contract.
- Arena view types should normally be zero- or low-allocation wrappers over
  existing arrays.
- Baseline lowering can remain available independently of later optimization,
  enabling separate snapshot and performance contracts.
- Backend emission should consume completed semantic/link plans rather than
  rediscover semantic relationships.
- Temporary duplication is acceptable during characterized migrations, but the
  old path should be deleted once equivalence and performance are established.

## Evidence and related documents

- [`../architecture.md`](../architecture.md)
- [`../research/deterministic-performance-budgets.md`](../research/deterministic-performance-budgets.md)
- [`../research/compiler-interface-freezing-performance.md`](../research/compiler-interface-freezing-performance.md)
- [`../research/dewdrop-code-optimization-opportunities.md`](../research/dewdrop-code-optimization-opportunities.md)
