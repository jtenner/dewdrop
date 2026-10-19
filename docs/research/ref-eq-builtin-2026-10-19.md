# `ref.eq` builtin

The compile-time interpreter must compare value references by identity. Two
separate values can have equal fields and still have different identities.

`ref.eq` is a source-declared builtin for one Core Wasm instruction. Both
compiler paths give it two equality-reference operands and one I32 result.
The native backend accepts concrete record, enum, string, and array reference
carriers under that operand rule. It rejects scalar and raw function-reference
carriers. Dew function values use closure records and are equality references.
The existing instruction effect marks reference identity as observed.
There is no standard-module path or declaration-name rule.

The native backend test covers direct and outlined calls and invalid stack
types. `tools/test-reference-identity.sh` validates and runs generated Wasm.
Its record and enum cases check the same object against itself and against a
separate object with equal fields. The outlined record case also checks a
builtin used as a function value.

Measured checks on 2026-10-19:

| Check | Result | Seconds |
| --- | --- | ---: |
| Native backend source tests | 2 passed | 10.720 |
| Release native test-generator build | passed | 29.887 |
| Identity test Wasm generation | passed | 0.247 |
| `wasm-tools` 1.262.0 validation | passed | 0.013 |
| Node Wasm runtime tests | 3 passed | 0.032 |

The runtime tests prove true for a shared record or enum reference and false
for separate references with equal fields. The native source tests reject
invalid operand types, operand counts, and result types with
`InvalidBuiltinSignature`.

Logs are in `.tmp/reference-identity/backend.log`, `generation.log`,
`validate.log`, and `execution.log`. The generated test module is
`.tmp/reference-identity/tests.wasm`. Run `tools/test-reference-identity.sh` to
repeat the runtime checks. The native backend test is
`src/backend/starshine_ref_eq_wbtest.mbt`.
