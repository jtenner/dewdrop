# Self-host module-value inference

Date: 2026-08-21

The Dew semantic port now infers module-level `let` values in dependency-first SCC order.

Implemented behavior:

- one shared local type solver for all module-value SCCs;
- fresh type slots for every member before an SCC is constrained;
- forward acyclic references;
- constraint sharing across mutual cycles;
- stable `UnresolvedModuleValue` diagnostics for every unconstrained member;
- unresolved-member detection before poisoning, so one poisoned representative does not hide another member of the same SCC;
- frozen module-value type terms and argument spans;
- iterative 1,024-value dependency-chain coverage.

The basic body inferencer now accepts an existing solver and a local module-value type map. Normal function jobs still need import and rebasing of the frozen module-value graph into their independent solvers. Imported module-value inference, final body-job merging, and lambda-family inference remain next.
