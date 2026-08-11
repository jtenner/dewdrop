# Stack collection design

Date: 2026-08-11

## Decision

`dew.std.collections.stack` is a standard-library abstraction over the existing carrier-specialized `Array<t>` runtime. The public surface uses top-level generic functions because imported ordinary inherent methods are not yet part of frozen standard interfaces.

The compiler maps Stack builtins directly to the corresponding Array lowering operations. This preserves the six unboxed carrier families, deterministic geometric growth, reference-slot clearing, and mutable reference identity without introducing a second backing-store implementation.

## Semantics

- `stack_new` starts empty and `stack_with_capacity` reserves exactly.
- `stack_push` appends at the top.
- `stack_pop` removes the most recently pushed value and returns `Option::None` when empty.
- `stack_peek` returns the top without changing logical length and returns `Option::None` when empty.
- `stack_clear` preserves allocated capacity through the Array contract.
- aliases observe all mutations.
- `stack_iter` traverses bottom-to-top insertion order because it reuses `ArrayIter<t>`.

## Representation and lowering

`Stack<t>` and `StackIter<t>` are public type aliases for `Array<t>` and `ArrayIter<t>`. Constructor, length, push, pop, clear, and iterator builtins have stable standard-module declaration IDs in module slot 14. During semantic lowering their typed Stack operations are translated to existing Array plans, so backend emission and physical runtime demands remain shared.

Generic collection wrappers exposed a backend gap: generic planned carriers previously failed Array runtime emission. Generic carriers now select the nullable `eqref` fallback carrier, consistent with specialization planning and generic WasmGC storage. Direct Stack calls retain concrete unboxed carrier selection.

## Validation

Coverage includes stable registry identities, selective standard-module discovery, semantic and lowering diagnostics, empty pop/peek, LIFO behavior, alias-visible mutation, non-mutating peek, clear, iteration, deterministic Wasm generation, and Node execution. Wago validation is temporarily blocked by the installed Wago source mismatch recorded in the active roadmap context.
