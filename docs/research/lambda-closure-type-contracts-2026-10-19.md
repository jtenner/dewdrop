# Lambda closure type contracts

The native emitter used lambda closure and capture lookup entries after range
checks only. A wrong in-range closure entry could select the common closure
type for `struct.new`. A wrong capture field entry could read another capture
with the same Wasm type and change the result without a validation error.

`verify_module_lambda_closure_types` checks base and selected closure map
dimensions, type family and lambda identity, reverse type coverage, field spans,
the immutable nullable function entry at field zero, and capture field identity,
order, position, and mutability. A lambda subtype must have a common closure
base. These checks run before type or body emission.

`verify_lambda_capture_layout` checks only one selected lambda. The lowering
record supplies capture spans and source shapes that the fragment record does
not contain. The check requires exact capture ownership, erased slots, field
map order, field roles and storage, complete field coverage, and direct capture
parameter order and types. Scalar checks need no worklist. Its work is linear
in that lambda's captures and their shape leaves. Callers must use the selected
lowering and fragment view. An admitted public generic export retains generic
source shapes. The check resolves those shapes from its exact mapped lambda
fragment, nonempty ABI key, root owner, and checked specialization shape span.
The erased reference ABI remains valid. Saved Error shapes remain errors.

The self-hosted compiler already checks selected lambda type identity, immutable
entry fields, capture roles and order, field counts, and storage carriers in
`semantic_capture_access_plans.dew`. No self-hosted change is required for this
lookup defect.

Numeric detail roles 100 through 119 belong to this contract. Failures keep
phase 5 in semantic checks and use phase 7 at the emission gate.

Tests and command logs are in `.tmp/lambda-closure-contracts`. The first test
run failed because the verifier was absent. A later compile-only pass selected
zero tests due to an incorrect test-name filter; that pass is not test evidence.

Final focused validation passed all 23 tests with this command:

```sh
DEW_NATIVE_TEST_PACKAGES='semantic/lambda_closure_type_invariants_wbtest.mbt backend/starshine_lambda_closure_contracts_wbtest.mbt backend/starshine_capture_cell_lookup_wbtest.mbt backend/starshine_capture_cell_agreement_wbtest.mbt backend/starshine_capture_cell_shapes_wbtest.mbt' tools/test-native.sh
```

| Test file | Tests | Time (seconds) |
| --- | ---: | ---: |
| Semantic lambda closure contract | 7 | 13.598 |
| Backend lambda closure contract | 3 | 10.927 |
| Existing capture cell lookup | 4 | 1.407 |
| Existing capture cell agreement | 6 | 4.937 |
| Existing capture source shapes | 3 | 3.375 |

The backend cases include valid public generic closures with selected I64,
Unit, and erased reference exports. The source-shape and agreement cases keep
their prior diagnostic records. All measured file lanes remain below 30 seconds.
These are test-lane timings, not a standalone allocation or throughput benchmark.

## Error priority follow-up

The review found that the shared specialization shape walker returns the first
Generic or Error leaf in stack order. With saved shape
`Product([Error, Generic])`, the Generic leaf was returned first. Resolving a
valid tuple `capture.type_` then rebuilt both fields and removed the saved Error.
The regression used an admitted public `make<t>(value: (t, t))` closure with its
stored reference ABI. Before the fix the layout check returned `Ok(())` instead
of code 301, reason 2, detail role 117. The red test took 9.653 seconds; its logs
are `.tmp/lambda-closure-contracts/error-priority-red.stdout` and `.stderr`.

The local `lambda_capture_shape_error` walker now gives Error priority. Generic
is returned only after the complete product walk finds no Error. Scalar shapes
return before any array is allocated. Concrete saved shapes are checked once;
only a resolved generic shape needs another walk. The tests retain the valid
tuple type and check both leaf orders and both nested Error positions. The
public generic success cases remain in the backend test file.

The follow-up green run passed 67 tests in eleven files. The file counts were
8 lambda closure, 8 common closure, 9 lambda function lookup, 8 capture cell,
8 physical alias, 3 backend lambda closure, 7 backend common closure, 3 backend
lambda function lookup, 4 backend cell lookup, 6 cell agreement, and 3 source
shape tests. Times were 13.206, 2.432, 3.044, 3.231, 2.689, 9.390, 2.879, 1.069,
1.341, 5.103, and 3.406 seconds, respectively. Logs are
`.tmp/lambda-closure-contracts/error-priority-green.stdout` and `.stderr`.

Five related tests also passed: generic lambda instances (1 test, 0.367 seconds),
compile-time lambda instances (2 tests, 1.128 seconds), and product capture
scratch storage (2 tests, 0.747 seconds). Their logs are
`.tmp/lambda-closure-contracts/error-priority-generic.stdout` and `.stderr`.
The final follow-up total is 72 passing tests in fourteen files.

A later behavioral red run disabled only the new lambda closure module and
per-source layout guards. The new common closure and lambda function guards
stayed active. Both wrong in-range lambda/capture-map tests failed because
emission returned `Ok`; the valid public generic case passed. The result was
3 tests, 1 passed, 2 failed, in 11.246 seconds at 1,066,292 KiB peak child RSS.
All three modified source files were restored byte for byte in `finally`.
This isolates the guards; it is not a clean baseline rebuild. Raw logs and
source hashes are in `.tmp/core-lookup-checks/lambda-behavior-red*`.

The guard-disabled red run preceded the final `moon fmt`. Its stored before
hashes for the backend assembly and code files differ from the final build
hashes. Exact restoration describes that run's source, not byte identity with
the later formatted build. The completed final lanes use the final build
hashes. The red evidence does not prove an isolated clean baseline or a
guards-disabled run of the byte-identical final source.
