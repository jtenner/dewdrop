# Lambda function lookup checks

Baseline: `f427d03938`. This bounded change checks native lambda function and
entry-signature lookup tables. Capture layouts and common closure types have
separate checks in this batch.

## Reproduced fault

The source fixture returns one of two escaping `fn() -> I32` lambdas. One
returns 1 and the other returns 2. Both have the same entry signature.
Changing only `lambda_function_indices[0]` to the second lambda's valid
function index was accepted by `verify_program_physical_type_fragments`.
Program emission also accepted that change and emitted `RefFunc(FuncIdx(2))`
for both source branches. A valid signature did not prove lambda identity.

The phase-5 red test failed in 8.758 seconds. The phase-7 red test failed in
8.686 seconds. Both failures reached the intended assertion. An earlier
8.707-second run found a malformed test fixture: Dew requires a newline after
the lambda body opener. Its separate `red-setup-semantic` record is not bug
evidence. Raw stdout, stderr, commands, exit status, and elapsed time are in
`.tmp/lambda-function-lookups/`.

## Checked contract

`verify_module_lambda_function_lookups` runs before later consumers read these
tables. It returns a complete `ProgramPhysicalTypeFailure`. The shared native
module check uses phase 5; module-only and linked emission retain phase 7.
The source module identifies the failure. Declaration and body are zero,
because this lookup does not have an owning source callable. Expression is
the missing sentinel. No declaration-ID encoding is used to infer a lambda ID.

The function, entry-signature, and closure-type lookup tables must have the
same length. Each selected function index must be in bounds. The selected
function's stored lambda and `PlannedWasmDefinedLambdaFunction` kind must both
match the lookup slot. Its signature must equal the saved entry signature.
Present entries must be in the function-signature range, after physical data
types. A data type cannot become an entry signature even if both saved
signature fields are changed to agree.

Every retained lambda fragment must have a valid stored lambda ID and kind.
Each plain lambda has one base fragment and an exact reverse lookup. A
selected view may instead name a specialized instance of the same lambda;
other valid instances remain in the function arena without separate base-map
entries. A deferred template has absent function and entry lookups. An
elided base fragment that remains in the arena keeps its real entry signature.
The default `selected_key=""` checks base tables. Selected views pass their
exact owner key explicitly. A selected nonempty key must match that key;
another instance of the same lambda cannot replace it.

Failure detail packs the role in the high 32 bits and the affected lookup or
function slot in the low 32 bits:

| Role | Check |
| --- | --- |
| 120 | Parallel table lengths; slot 0 is functions, slot 1 is signatures |
| 121 | Selected function index bounds |
| 122 | Selected function's stored lambda identity |
| 123 | Selected function kind and lambda identity |
| 124 | Exact selected entry-signature agreement |
| 125 | Function-signature bounds and count arithmetic |
| 126 | Retained lambda fragment's lambda ID bounds |
| 127 | Retained fragment kind and lambda identity |
| 128 | Duplicate plain lambda fragment |
| 129 | Missing or wrong reverse lookup for a plain fragment |
| 130 | Entry signature with no selected function |
| 131 | Selected lambda instance key differs from the requested owner key |

The checker takes O(functions + lambdas) time. Its scratch table has one
`Int32` per lambda. It does not scan all signatures for each lambda or change
generated instructions for valid programs. Existing signature and function
preflights retain responsibility for parameter/result spans and their types.

## Validation

All focused runs pass. Each command used `tools/test-native.sh` with
`DEW_NATIVE_TEST_PACKAGES` set to the exact file below. The five files ran
serially. Commands, raw stdout/stderr, status, and times are saved under
`.tmp/lambda-function-lookups/green-*`; `green-summary.json` records the batch.

| File | Passed | Seconds |
| --- | ---: | ---: |
| `semantic/lambda_function_lookup_invariants_wbtest.mbt` | 9 | 12.962 |
| `backend/starshine_lambda_function_lookup_wbtest.mbt` | 3 | 9.295 |
| `backend/starshine_closure_type_contract_wbtest.mbt` | 7 | 2.666 |
| `semantic/closure_type_invariants_wbtest.mbt` | 8 | 2.280 |
| `semantic/program_physical_alias_invariants_wbtest.mbt` | 8 | 2.671 |

The nine new semantic tests cover same-signature substitution, parallel table
lengths, function and signature bounds, function kinds, missing entries,
reverse coverage, duplicate plain fragments, retained instance identities,
and selected generic views. Both deferred `(-1, -1)` base lookups and elided
plain templates with real signatures pass. Selected Unit and I64 views pass
with the exact requested key; a same-lambda key change reports the complete
role-131 failure. The three new backend tests cover program and module-only
emission, plus a changed saved entry signature. All 35 focused tests pass.
No individual run exceeded 30 seconds. Final full-lane validation belongs to
the complete compiler-check batch.
