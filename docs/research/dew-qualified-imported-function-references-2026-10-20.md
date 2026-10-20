# Dew qualified imported function references

The Dew compiler now accepts ordinary `@alias.function` values. Native support was added in the [Native reference note](qualified-imported-function-references-2026-10-20.md). This fix uses the checked imported declaration scope and the existing function-reference target format. It adds no dispatch on a module path or source spelling.

## Change

`select_qualified_module_value` still checks imported module data first. If the checked binding names a callable, a single callable uses `imported_callable_function_type`, which keeps its generic instantiation and saved type arguments. A valid callable lookup consumes the alias root. Missing or private names do not enter this path.

Dew previously had late expected-type overload reference selection only for local names. The same pass now checks qualified alias references. It limits candidates to visible top-level callables in the selected declaration module and checks complete function signatures under solver rollback. It retains one declaration only for a unique match. Wrong or ambiguous signatures use the existing reference diagnostics. If the expected signature is still unresolved, final type checks retain the existing unresolved-type diagnostic behavior.

The lowering bridge now reads checked call targets for `QualifiedExpr` as well as `NameExpr`. Without this change, a valid checked alias reference would still lower to poison. Module data and constructor selections keep their existing handling.

## Validation

Baseline: `4f7803ddebeb704dd66ad968a1f971310727feda`. Separate uncommitted transform work was frozen during all compiler steps and was not staged with this fix. The private harness used the saved Native generator and linker. Their identities and the final source hashes are in `build-identity.txt` under `.tmp/transforms-v5/dew-qualified-refs/`. The production `tools/test-transforms.sh` was not changed by this fix.

The valid red run had six test wrappers: two passed and four failed on missing qualified references. Generic and overload coverage initially shared one wrapper; they were split before the green run. Earlier attempts failed in the draft test syntax/API and are not red evidence. See `red-valid.log` for the valid failure run.

All seven final tests passed. They check exact imported declarations after a private callable; local, parameter, and return contexts; retained generic type arguments; overload choice; no-match and ambiguity diagnostics; private visibility; module data priority; and equal logical file paths in distinct modules. The ordinary cases also require a checked function reference to reach program lowering.

The same artifact passed all 41 tests: the seven new cases plus 34 existing imported-semantic, imported-selection, and function-value-overload cases. The new-case harness took 12.471 seconds: generation 6.262 seconds, link 1.485 seconds, test execution 0.072 seconds. Running all 41 cases in the built artifact took 0.092 seconds. No measured step exceeded 30 seconds. Evidence: `green-first.log` and `existing-green.log` in the private directory.

No separate Dew public-source Wasm control was run. The current test artifact does not export a source compilation entry; `artifact-exports.log` records that check. The prior Native-produced local, plain passed, and generic passed callback controls all return 42 when the host calls optional `__dew_init` exactly once before `main`. The earlier cast-error claim was a runner error and was corrected in the Native note.

## Cost and scope

The fix adds no candidate array, deferred queue, or retained metadata field. Candidate scans use index loops. A qualified callable reference adds scans proportional to imported callable count; overloaded references also use the existing solver snapshot and rollback machinery. No speed or heap gain is claimed. No allocation profile or controlled before/after timing sample was taken.

Register `self_host/compiler/semantic_qualified_function_references_test.dew` in the normal Dew test harness. This commit includes the file but leaves production harness registration to the separate transform work. Claude review was not retried because the recorded weekly quota is exhausted until October 24 at 16:00 UTC.
