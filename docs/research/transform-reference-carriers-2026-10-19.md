# Compile-time reference carriers

## Problem and controls

A builtin null test with a `(I32, I32)` or `(String, String)` parameter could run in a transform, even though the same runtime call failed Wasm validation. The VM stored the tuple in one `Sequence` value. The backend put each tuple member on the Wasm stack. A generic null test instantiated with a tuple had the same gap.

A stored function reference also compared unequal to itself in the VM. A runtime control passed Wasm validation and returned true. The VM reference-equality match had no Function or Closure identity case.

The follow-up control `builtin add_pair(value: (I32, I32)) -> I32 = "i32.add"` exposed the other side of the tuple issue. The backend accepted this declaration and returned 42 for `(40, 2)`. The new declaration contract correctly counted two i32 operands, but the VM still passed one Sequence operand.

The read-only report and exact before-fix sources, build hashes, and logs are in `.tmp/transforms-v3/reference-carrier-review.md` and `.tmp/transforms-v3/reference-carrier-probes/`.

## Change

Both compilers now validate concrete null-test declaration shapes before transform execution. The input must lower to one reference value, and the result must lower to one i32 value. This special check does not turn the null instruction into an eqref-only operation.

An executed null test on a Sequence value without a checked reference wrapper fails with a visible diagnostic. General reference identity and internal nullable coercion retain Sequence support. This keeps the narrow instruction check separate from the VM storage model.

The intrinsic entry helper expands explicit Product parameter syntax in field order. It recurses for nested products. Generic and reference parameter types keep their original values. Calls without a Product parameter return the original argument array, with no new array allocation. Product expansion needs one output array and linear work in its fields. This change does not add resolved shape metadata for aliases or generic arguments; those remain subject to the existing visible unsupported-operation checks.

Stored function and closure aliases compare true. Follow-up runtime controls found that two expressions for one named function also share a runtime singleton. Checked non-generic named functions now carry their semantic declaration identity; see `transform-function-identity-2026-10-19.md`. Fresh closures retain instance identity. Function names and source text do not establish identity.

## Validation

- Native VM tests: 50 passed, 1.163 seconds.
- New Native compiler source tests: 6 passed, 13.152 seconds. They cover function alias equality, valid function null tests, tuple arithmetic, two concrete bad tuple null declarations, and an executed generic tuple null test.
- Native release generator build: passed, 27.618 seconds.
- Dew test generation passed in 5.636 seconds; link and validation passed in 1.157 seconds. All 47 Dew tests passed in 0.147 seconds. The 13 tests in the reference test file also passed when run on their own.
- Six direct Dew source probes passed in 9.483 seconds in total. Function alias equality, tuple addition, and function null tests expand to 42. Both concrete tuple null declarations fail before execution. The executed generic tuple null test fails with a checked-reference diagnostic.

Logs are `native-vm-after.log`, `native-source-after.log`, `native-generator-after.log`, `dew-after.log`, `dew-all-after.log`, and `dew-source-after.log` under `.tmp/transforms-v3/reference-carrier-probes/`. The private after-fix test module has SHA-256 `fc2df508daa9b4d265b382c4fbcb4a98a98acf939f1d373cc5adda46c2d02cc4`.

Each compiler activity uses `self_host_measure`. The before-fix runtime tuple-add control passed `wasm-tools validate` and returned 42. These checks establish behavior, not a stable performance benchmark.
