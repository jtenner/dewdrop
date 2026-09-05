# Native Wasm boundary fixes

The self-host audit exposed three native backend boundary defects:

- Unit and Never arguments have no physical operand. Do not emit a reference
  cast for these erased arguments; it would consume another argument or
  underflow the stack.
- Nested pattern bindings need defaultable reference locals across control
  frames. Store nullable references and narrow them at reads.
- Early returns need the same reference narrowing as body tails. Use the exact
  linked function and specialization to choose the return type.

Regression tests cover nested reference bindings across control frames and an
early array return. The routine `tools/test-native.sh` lane passes all 754 tests.
The final run's slowest package was semantic at 9.820 seconds; backend took
7.488 seconds. The self-host hardening lane also exercises erased arguments.

Lambda early-return narrowing remains a separate audit item. This change does
not claim to prove every reference or closure ABI case.
