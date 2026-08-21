# Self-host body evidence publication

Date: 2026-08-21

The Dew semantic port now publishes root implementation evidence for selected trait-backed body expressions.

Implemented behavior:

- deterministic per-body expression evidence spans;
- concrete implementation identities for selected trait methods and operators;
- coherent-index filtering;
- no false trait evidence for inherent methods;
- stable body and expression ordering;
- prerequisite span storage for the recursive evidence-tree tranche.

Focused tests cover a trait-backed binary operator and an inherent method that must not publish trait evidence.

Recursive prerequisite evidence nodes, declared generic-bound evidence, callable-bound evidence, and final result compaction remain next.
