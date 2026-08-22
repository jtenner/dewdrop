# Self-host I32 functions and calls

Date: 2026-08-22

The linked self-host emitter now writes all defined I32 functions in physical link order.

Added support:

- function parameters in Wasm signatures;
- parameter `local.get` indexes;
- non-parameter local declaration counts;
- multiple function types, function declarations, and code bodies;
- direct calls to ordinary functions;
- direct calls to specialized generic functions;
- deterministic physical function indexes.

The smoke request now compiles three functions. `main` calls `twice`, and `twice` calls `add` with two parameters.

This work also fixed a specialization bug. Ordinary call value arguments were read as generic type arguments. A two-argument non-generic call could therefore index outside the compact generic argument arena.

Validation:

- native self-host semantic tests: 223 passed;
- parser corpus: 640 files;
- semantic corpus: 629 files;
- linked self-host smoke: passed;
- repeated compiler and output bytes: identical.

Branches, loops, non-I32 scalar carriers, imports, globals, aggregates, closures, dictionaries, exports, startup, and fixed-point compiler emission remain.
