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

The basic body inferencer now accepts an existing solver and a local module-value type map. It also imports frozen product, application, and function type graphs into independent function solvers through an explicit task stack. Local functions can now consume primitive and applied module-value types. Module-value SCC inference also receives imported calls, fields, variants, implementations, and imported module-value recipes before independent function inference. Final body-job merging and lambda-family inference remain next.
