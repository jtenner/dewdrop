# Self-host program lowering and specialization

Date: 2026-08-22

The Dew compiler now aggregates module lowering into a deterministic program artifact and plans concrete generic specialization demands before WasmGC fragment planning.

Program lowering adds:

- manifest-indexed module slots;
- exact module, declaration, and body ownership lookup;
- sorted, deduplicated import dependency edges;
- deterministic dependency-first module SCCs;
- cyclic-module grouping in source order;
- per-module imported name resolution, module-value inference, body/lambda inference, flow analysis, and lowering;
- retained resolved-type arenas for later physical ABI planning.

Program specialization adds:

- public/compiler-root and module-initializer reachability;
- transitive direct, builtin, operator, and index call reachability;
- nominal type reachability from lowered values and constructors;
- canonical Wasm carrier classes for signed/unsigned scalar aliases;
- stack-safe canonical product shape trees;
- deterministic deduplication by declaration and canonical shape vector;
- local and imported generic call requests;
- transitive generic request closure;
- caller-specialization-to-target-specialization call edges.

Generic bodies are not scanned through their erased form. They are scanned only for a concrete specialization request. This prevents an early `eqref` request from hiding a later scalar request.

The current plan is backend-neutral. It does not yet assign Wasm type, function, global, table, or dictionary indexes. Those belong to the WasmGC fragment and physical link planners.
