# Self-host WasmGC fragment planning

Date: 2026-08-22

The first self-host WasmGC fragment tranche converts program specialization requests into physical module recipes.

It adds:

- canonical Wasm scalar and reference value types;
- physical struct, foreign-marker, enum-base, and enum-subtype recipes;
- struct field storage and mutability metadata;
- imported, builtin, defined, and signature-only function kinds;
- flattened product parameters and results;
- elided generic base functions;
- concrete scalar specialization function clones;
- local and imported specialization ownership;
- declaration-indexed type and function lookup slots.

This is the ABI and nominal-type foundation. Lambda closure types, capture cells, trait dictionaries, recursive physical SCCs, runtime dependencies, module globals, body instruction emission, and final index assignment remain in later fragment/link tranches.
