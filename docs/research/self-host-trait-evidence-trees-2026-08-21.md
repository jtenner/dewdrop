# Self-host concrete trait-evidence trees

Date: 2026-08-21

Concrete trait-evidence selection now publishes reusable evidence trees instead of only validating implementation prerequisites.

The tree contains:

- the selected implementation for each node;
- deterministic postorder node IDs;
- child spans for recursive generic prerequisites;
- shape arguments for instantiated implementation generics;
- a depth limit of 64;
- transactional rollback of nodes, children, and arguments when any prerequisite is missing.

The implementation uses the same local/imported implementation recipes, generic substitution, coherence filters, specificity selection, and consumer-local resolved types as ordinary evidence selection.

This completes concrete prerequisite tree publication. Declared body-generic bound nodes and expression-root attachment still need to be merged into the production inferred-body evidence arenas before lowering.
