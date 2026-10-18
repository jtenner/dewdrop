# Constant folding must prove the selected operator

Date: 2026-10-18

## Fault

The native constant folder used the source operator and scalar operand constants,
but ignored the selected implementation declaration. A local `Add` trait with an
`impl Add for I32` returning `77` made `1 + 2` return `3`, while the same operator
with dynamic inputs returned `77`. An implementation that called `unreachable`
also lost its trap for constant inputs.

Both probes compiled without diagnostics. Before the change, Node returned
`constant=3, dynamic=77` for the result probe and `constant=3` with an
`unreachable` trap from the dynamic trap probe. Builds took 0.151 and 0.162
seconds. Raw source, Wasm, commands, compiler identity, and runtime output are in
`/tmp/dewdrop-review-2026-10-18/backend` for this session.

## Change

Native operator folding now requires a proof from the exact selected callable.
The proof starts with actual builtin metadata. It reuses the existing
single-intrinsic forwarding checker to accept a non-generic two-parameter body
only when that body forwards the original parameters in order to one intrinsic.
The checker permits only carrier-preserving identity casts. Extra statements,
changed or reversed operands, foreign calls, custom result bodies, and traps
remain ordinary calls.

The proven opcode must match the source operation, operand width, and signedness.
For example, an `Add` implementation that forwards to `i32.sub` cannot fold as
addition. Source names, standard module paths, and declaration ordinals provide
no proof. Normal intrinsic-backed integer arithmetic and comparisons still fold.
Structural Boolean operations retain their existing fold rules.

Ordinary Boolean equality methods need a second proof because the standard
library implements them with `if` and `!`. A fixed-depth evaluator accepts only
Boolean constants, original parameter reads, `if`, blocks with exactly one
expression, and logical negation. It evaluates all four Boolean input pairs and
accepts only the complete equality or inequality truth table. Signatures must
have two Boolean inputs and a Boolean result. This retains Boolean query checks
without assuming that every custom `Eq` means primitive equality.

Type-query folding uses a lazily cached proof map for the whole program, including
imported implementations. Each concrete query body shares that map; it does not
rebuild the map or lose imported operator evidence.

The self-host compiler has no matching scalar arithmetic folder. Its Boolean
query folder already checks the selected declaration's builtin metadata, and
ordinary operator emission uses the frozen selected call. Two self-host tests
cover retained custom scalar calls and retained trapping Boolean equality.

## Validation

Focused native tests cover custom scalar results, traps, custom Boolean equality,
a mismatched intrinsic opcode, reversed intrinsic arguments, and successful
folding through an arbitrarily named matching intrinsic. An eighth test checks
that a Boolean query compared with `true` still folds through ordinary source
Boolean equality.

Native validation passed:

- `moon test --target native src/semantic/operator_folding_selected_call_wbtest.mbt`: 8/8, 10.070 seconds. This includes imported integer query guards and ordinary source Boolean equality.
- `moon test --target native --include-skipped src/semantic/program_optimization_wbtest.mbt --filter '*constant folding*'`: 1/1, 0.322 seconds. Existing normal arithmetic folding remains intact.
- `moon test --target native src/semantic/compile_time_lowering_wbtest.mbt`: 3/3, 0.873 seconds.
- `moon build --target native --release src/dew_cli`: passed, 26.881 seconds.
- `moon build --target native --release src/dew_test_gen`: passed, 23.188 seconds.

The first attempted test run stopped at a concurrent parser record edit, before
running tests. A later run passed six cases and exposed an incorrect assertion
in the new query test: pruning correctly removes the condition. The corrected
test checks the selected result, `7u32`, rather than retained dead condition data.
Full stdout, stderr, and command timing are in the session evidence directory.

The operator proof itself adds no emitted runtime calls or allocations. Required
conversions in the selected implementation remain part of its runtime behavior.
The proof builds two temporary
metadata maps for operator proof. Type-query contexts build and retain one map
lazily, then share it across concrete bodies. Runtime and whole-compiler memory
gains are not claimed.

The focused self-host module includes all production compiler sources and the
imported-semantics, physical-specialization, and text-operator test owners.
Generation passed in 4.739 seconds; linking passed in 1.093 seconds. Both new
cases passed, each selecting exactly one metadata test from 91 generated tests:

- `constant scalar operators retain a selected custom result`: 0.072 seconds.
- `constant Bool equality retains a selected trapping method`: 0.060 seconds.

The linked provider retains unused file-system and Facet imports. The runner used
its existing `--allow-unused-host-imports` option. Each such import throws if it
is actually called; the tests did not call one. An initial run without that flag
stopped during instantiation, before running a test. Commands, binary identity,
full output, and timing remain in the session evidence directory.

## Result coercion follow-up

An independent source review found that the reused forwarding checker did not
inspect runtime trait-object coercions. A custom `Add for I32` can return a
`Value` trait object by forwarding its operands to an `i32.add` builtin. The
body still needs to wrap the scalar result as that trait object.

The current native compiler accepted the source but failed emission. The
constant-only program produced an `i32.const 3` where a reference local was
required. The dynamic-only program failed with `InvalidBuiltinSignature` for
`i32.add` returning `WasmNullableEqRefValue`. These builds took 0.170 and
0.162 seconds. The latter path also exposed the pre-existing forwarding fault,
independent of constant folding.

The shared forwarding proof now rejects coercions on the result and forwarded
operands. Cast stripping stops at a coercion and the caller rejects that node.
This keeps the ordinary call and its required conversion. Scalar folding also
checks the selected callable's primitive result: comparisons must return Bool,
and arithmetic must keep the operands' exact primitive type. An I32 operation
that returns U32 remains a call instead of becoming an I32 constant.

Two native regression tests check result coercion in both the forwarding proof
and constant folder, plus the signed-to-unsigned result case. Reproduction
source, exact compiler hashes, commands, output and times are saved for this
session in `/tmp/dewdrop-review-2026-10-18/compiler-perf/operator-coercion*` and
`operator-guard-*`. No new map or runtime dispatch is added.

All ten focused native tests pass in 10.689 seconds. The native release CLI
build passes in 26.828 seconds. With the fixed CLI, the combined constant and
dynamic probe builds in 0.153 seconds; isolated constant and dynamic probes
build in 0.160 and 0.153 seconds. All three Wasm modules validate and execute
in Node. Both `constant()` and `dynamic(1, 2)` return `3`. The fixed native CLI
has SHA-256 `24665a1a8605c6c51061901a2aa2a88f5eb619f561e5f45c105643970a2832a3`.
These are correctness checks and activity times, not performance gains.
