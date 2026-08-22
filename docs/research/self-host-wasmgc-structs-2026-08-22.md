# Self-host WasmGC structs

Date: 2026-08-22

The linked emitter now materializes scalar-field WasmGC struct types before function types.

Added support:

- deterministic physical type indexes in the final type section;
- immutable and mutable scalar field declarations;
- I32, I64, F32, and F64 field storage;
- struct construction in physical field order;
- struct field reads and writes;
- function type indexes rebased after physical types.

Starshine now exposes typed field-array bridge helpers for the Dew consumer.

The smoke module emits a `(struct (field i32) (field i64))`, constructs it with `struct.new 0`, and reads its first field with `struct.get 0 0`.

Reference fields, enum subtype relationships, arrays, closure objects, and reference-valued locals and signatures remain.
