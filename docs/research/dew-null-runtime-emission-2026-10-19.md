# Dew runtime null instruction emission

A real compile request for a raw default `NullableRef<foreign Handle>` read,
followed by `wasm_ref_is_null`, failed with `self-host smoke: ref_is_null`.
An explicit `wasm_ref_as_non_null` boundary control failed with the matching
`ref_as_non_null` message. Both failures occur in normal runtime code, outside
transform execution. Neither produces a Wasm output. Compiler A was
`1b59e1d1ea6762157d2bd0da2da304d6c55eb69524a8060b48fa82eb9523f6aa`.

The generated builtin emitter omitted both one-to-one Wasm instructions. The
runtime raw-intrinsic contract table also omitted them, so the checked carrier
pass could not verify their inputs and results. The emitter generator now maps
both names to the existing Starshine `Instruction::ref_is_null` and
`Instruction::ref_as_non_null` exports. The generated FFI consumer selects those
exports and updates its fingerprint. No provider export or host capability was
added. Runtime contracts require one reference input and an i32 null-test
result, or one reference input and a reference non-null assertion result.

`semantic_raw_null_test.dew` checks inline and outlined emission with validated
Wasm, rejects scalar operands and wrong result carriers, and rejects incorrect
operand counts. The raw-array runtime request and explicit non-null assertion
remain the actual runtime controls: a null test must return true and let main
return 42; an explicit non-null assertion of a null default must trap.

Before-fix evidence and timings are in
`.tmp/transforms-v3/raw-defaults-fresh-a/` and
`.tmp/transforms-v3/raw-default-boundaries/`. The ten-case compile range was
1.3182–1.4998 seconds; the six boundary cases took 1.3861–1.4653 seconds.
Final generated-data checks, focused Dew tests, and fresh runtime controls are
pending the shared build lane.

## Source-test validation

All three isolated null opcode tests pass in the 120-test Dew suite. Generation
took 7.514 seconds, linking 1.468 seconds, and execution 25.997 seconds. The full
75.148-second lane includes a cold host generator build and exceeds the activity
bound. The tests cover inline and outlined emission, malformed result/input
carriers, and malformed arities. The emitter validates each generated module.
Log: `.tmp/transforms-v4/identity/dew.log`. Fresh compiler request checks remain
pending after the FFI fingerprint update.
