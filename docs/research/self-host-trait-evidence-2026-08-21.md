# Self-host trait evidence selection

Date: 2026-08-21

The Dew semantic port now selects coherent concrete trait evidence from the merged local and imported implementation index.

Implemented behavior:

- trait and target head filtering;
- local and imported implementation generic instantiation;
- structural candidate matching through the rollback-capable local solver;
- coherent and valid evidence filtering;
- deterministic specificity preference;
- explicit no-evidence, selected-evidence, and ambiguous-evidence results.

Focused tests cover imported concrete evidence and rejection of a nonmatching target.

The selector is the base for callable generic-bound checks, implementation prerequisite evidence, operator evidence, and expression evidence trees. Recursive prerequisite bounds and body-result evidence publication remain next.
