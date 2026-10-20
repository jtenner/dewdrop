# Qualified imported function references

Native semantic lookup now accepts ordinary `@alias.function` values. It uses the imported callable scope and saves the checked declaration in `FunctionReferenceSelection`. A single nongeneric function supplies its signature at once. Generic and overloaded references use the existing expected-type selection step. The change has no module-path or source-name special cases. Module data lookup keeps its existing priority.

## Checks

The starting commit was `b98fc23bf61985bf0db981ae8cc5d99a1dc22d8a`. The working tree also held separate signature-transform changes. Those files are outside this fix and its commit.

The saved red test exposed `UnsupportedExpressionInference` for the ordinary qualified function value. The final routine Native run used `DEW_NATIVE_TEST_PACKAGES=semantic tools/test-native.sh --filter '*reference*'`: all 36 selected tests passed in 19.130 seconds. The new tests check untyped local callbacks, expected parameter and return signatures, generic type arguments, overload choice, private function visibility, equal logical file paths in distinct modules, and absent or wrong expected types. Tests check collection errors and chosen declarations, not only absence of inference errors.

A public Native CLI build emitted a 679-byte Wasm file for `let callback = @lib.answer; callback(42i32)`. Node ran its `main` and returned 42. The warm source build took 0.202 seconds; the run took 0.028 seconds. The cold release CLI build and combined control build took 32.804 seconds. The timing helper correctly flagged this as a compiler activity over 30 seconds. This is a tool-build cost, not evidence of a regression in this lookup change.

Logs and source controls are in `.tmp/transforms-v4/qualified-function-refs/`. The corrected initial red log is `red-corrected.log`; final Native evidence is `references-final.log`. `plain-build.log` and `plain-run.log` hold the successful Wasm control. The initial `red.log` selected zero tests and is not validation evidence.

## Cost

The patch adds no arrays, queues, or retained metadata fields. Qualified members already need expression-selection storage. Single nongeneric references use the same selection representation as open-import references. Generic and overloaded references use the existing candidate solver. The existing final reference scan now also checks qualified import-alias expressions. No compiler speed or heap gain is claimed; no before/after allocation profile was taken.

## Limits and follow-up

Native block `let` syntax currently requires `=` after the binding. `let callback: fn(I32) -> I32 = @lib.answer` is a parser error, independent of imported reference lookup. Expected types in supported parameter and return positions are covered here. An early draft used this unsupported syntax; the final tests remove it and check collection errors to prevent empty-body false passes.

The Dew compiler has the same qualified-reference gap. `select_qualified_module_value` in `self_host/compiler/semantic_basic_body_inference.dew` checks imported module data types but does not call the imported callable reference path. Its qualified expression step then rejects the value. Open-import names already use `imported_callable_function_type`. This commit does not change Dew.

Actual callback passing has a separate runtime defect in the current shared source. Both `apply(@lib.answer)` and existing `open app.library; apply(answer)` compile but trap with `RuntimeError: illegal cast`. Their emitted 944-byte Wasm files are byte-identical. Generic `apply(@lib.identity)` and open-import `apply(identity)` also emit byte-identical 986-byte files and trap. Thus semantic expected-type coverage here does not prove callback ABI execution. See `parameter{,-open}-{build,run}.log` and `generic{,-open}-{build,run}.log`. This needs a separate callback carrier/signature investigation; it is not repaired by this lookup change.

A read-only Claude review was attempted with normal authentication and restricted Read/Glob/Grep tools. It returned the weekly usage limit, which resets on October 24 at 16:00 UTC. It returned no assessment. Its output and exit status are saved beside the test logs.
