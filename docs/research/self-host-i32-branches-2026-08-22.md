# Self-host I32 branches

Date: 2026-08-22

The linked self-host emitter now emits result-producing I32 `if` expressions.

The emitter keeps one iterative work stack. Each task carries its destination Starshine instruction array. This lets nested branch bodies be built without recursive compiler calls.

Starshine now provides a small typed bridge for an `if` with a present alternative. The Dew consumer does not need to construct a MoonBit `Option<Array<Instruction>>` value.

The smoke program now checks a function result and emits an `if (result i32)` with deterministic then and else instruction lists.

Validation:

- self-host semantic tests: 223 passed;
- parser corpus: 640 files;
- semantic corpus: 629 files;
- linked self-host smoke: passed;
- repeated compiler and output bytes: identical.

Functional loops, matches, early returns, and branch transfers remain.
