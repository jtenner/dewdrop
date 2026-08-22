# Self-host physical program linking

Date: 2026-08-22

The first self-host physical linker now freezes deterministic program indexes from WasmGC fragments.

It assigns:

- dependency-first physical type indexes and module type bases;
- imported function indexes before defined function indexes;
- concrete generic specialization function targets;
- specialized call-site links;
- dependency-first module initializer order;
- module-value global indexes;
- stable link diagnostics for missing specialization targets.

The linker keeps manifest module identity while type order follows the dependency SCC graph. Generic base fragments stay elided; only concrete specialization fragments receive executable indexes.

The current link artifact does not yet include recursive type groups, closure entry functions, trait dictionaries, body instructions, exports, startup code, or final Starshine encoding.
