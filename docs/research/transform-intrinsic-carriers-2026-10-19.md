# Checked transform instruction carriers

A transform must obey the same Wasm instruction stack contract as runtime
source. Ignoring the result must not hide a bad builtin declaration.

The validation phase checks known builtin parameter and result carriers with
the existing opcode signature tables. Generic slots stay deferred. The native
driver gives those contracts to the transform plan once per opcode; the VM
does not import the semantic package. The Dew VM uses its existing signature
function directly.

Before an intrinsic runs, both VMs check known operand widths and the checked
result carrier. This happens before scalar result coercion. For `struct.get`,
the VM also uses the checked raw field storage, including reference and array
element storage. Unit and Never have explicit checked kind names.

Checked value conversion also validates the actual returned carrier, so a VM
operation outside the fixed signature table cannot hide a wrong result type.
Executed fixed scalar instructions need a concrete checked result carrier.
Unresolved generic result proofs fail with a clear diagnostic.

The checks reject bad ignored results from scalar, float, vector, reference
identity, and raw field instructions. They preserve valid i32 carrier aliases,
same-carrier unsafe casts, generic deferred defaults, and checked reference
fields. No standard-module path or declaration-name exception is used.

Native validation passed: three focused contract tests in 1.078 seconds, eight
checked transform execution tests in 13.013 seconds, and all 44 transform VM
tests in 0.086 seconds. Dew tests are in
`self_host/compiler/transform_intrinsic_contracts_test.dew`; the full Dew build
is checked by the root task. These times are not a runtime benchmark.
The root task also repeats validation after the final checked-value guard and
small allocation reductions.

The investigation report and raw probe logs are in
`.tmp/transforms-v3/intrinsic-carrier-review.md` and
`.tmp/transforms-v3/intrinsic-carrier-probes/`.
