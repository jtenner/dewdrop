# Self-host implementation index and coherence

Date: 2026-08-21

The Dew semantic port now builds a first local implementation index.

Implemented behavior:

- iterative primitive and nominal implementation-head extraction;
- trait-head extraction through applied types;
- inherent and trait implementation records;
- invalid trait and target-head diagnostics;
- package ownership and orphan checks;
- iterative generic-pattern import into the rollback-capable local solver;
- structural overlap checks for generic and concrete trait implementations;
- deterministic later-implementation overlap diagnostics;
- duplicate inherent-method diagnostics;
- missing and unknown trait-method diagnostics;
- duplicate trait-method diagnostics;
- receiver, parameter-count, and method-generic-count conformance checks;
- iterative parameter and return signature comparison with trait-generic, method-generic, and `Self` substitution;
- strict specialization ranking for generic implementation patterns;
- indexed implementation methods and coherent method/trait dispatch entries;
- coherent and valid state on every indexed implementation.

Generic overlap checking maps each implementation's generic parameters to a separate family of fresh local inference variables. Products, applications, and function types are imported with an explicit task stack.

Focused tests cover distinct concrete implementations, a generic/concrete overlap, duplicate inherent methods, imported orphan evidence, and invalid generic target heads.

Imported implementation merging, indexed-trait overlap rules, dispatch ordering/search spans, inferred obligations, and selected evidence remain in the next tranche.
