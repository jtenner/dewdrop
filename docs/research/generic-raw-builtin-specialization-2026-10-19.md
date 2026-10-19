# Checked generic raw builtin specialization

A normal runtime call to `builtin same<a, b>(left: a, right: b) -> Bool =
"ref.eq"` failed with `UnsupportedProgramGenericCall`, even for two function
closure references. Transform execution had accepted the same checked source.

The Native materializer permitted generic source functions, `unsafe.bitcast`,
and raw array reads. It returned no instance for every other raw builtin. The
linker's missing-instance diagnostic was correct for that incomplete plan.

The materializer now also accepts inline or outlined builtins from the exact
`raw_wasm_builtin_signature` catalog. It still substitutes the checked generic
arguments and records the normal selected instance. The backend then checks
all concrete operands, arity, and results against that instruction contract.
Scalar `ref.eq` operands and wrong results remain errors. Generic `ref.cast`
still needs its separate heap proof and retains its existing rejection. No
standard module path, declaration spelling, or host import chooses behavior.

Dew already had concrete generic builtin fragments and instruction validation.
Its new five-test file checks direct and outlined reference equality, function
reference operands, scalar addition, bad carriers/results, and bad arity. It is
registered in `tools/test-transforms.sh`.

Evidence is in `.tmp/transforms-v4/generic-builtins/`:

- `native-red.log`: new Native tests failed 0/3 before the gate fix, 9.287 s.
- `native-green.log`: 3/3 pass after the fix, 12.096 s. Later rerun 3/3, 2.230 s.
- `native-existing.log`: raw intrinsic tests 20/20, 10.892 s; reference equality
  tests 2/2, 2.020 s. This includes the generic heap-cast rejection.
- `dew-tests.log`: current Dew source tests 5/5. Generation 6.311 s, link 1.458 s,
  pinned Wasm validation 0.026 s, execution 0.163 s. The existing Native test
  generator was used; no fresh generator build is claimed.

These checks exposed separate normal function-reference singleton faults after
the formerly blocked source could compile. Their runtime fixes and controls are
recorded in [Exact runtime function reference identity](runtime-function-reference-identity-2026-10-19.md).
No measured speed or retained-memory gain is claimed for this planner fix.
