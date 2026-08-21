# Self-host lowering core

Date: 2026-08-21

The Dew compiler now builds a module lowering artifact from collected HIR, resolved names and types, merged inference jobs, flow analysis, type layouts, initialization plans, and function plans.

Implemented lowering covers:

- integer, float, Bool, String, and Bytes constants;
- local, capture, and module-value reads;
- local and capture writes;
- products, Arrays, lambdas, objects, and construction selections;
- blocks, conditionals, matches, and functional loops;
- explicit loop, break, and continue control IDs;
- prefix, structural binary, and selected operator calls;
- selected direct calls, function-value calls, and unresolved calls;
- selected fields, field writes, products, indexes, and index writes;
- block items, object fields, patterns, pattern fields, and pattern arms;
- body and lambda flow summaries and diagnostics;
- body/lambda local and capture ABI shapes;
- exact source arena indexes and child arenas.

The artifact retains merged inference so later specialization and WasmGC planning can consume rebased type graphs and type-argument spans without reconstructing solver-local state.

Remaining lowering work is standard builtin operation classification, imported lowering integration tests, concrete/bound evidence arena attachment, nominal/function structural lookup, and function-value directization.
