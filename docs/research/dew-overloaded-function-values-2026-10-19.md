# Dew overload selection for function values

Date: 2026-10-19.

## Fault and scope

`examples/transforms/overloads.dew` passed in the native compiler, but its real
Dew source-pool request failed with `unsupported checked function reference`.
The failing value was `adjust` at source offset 211, returned from
`flag_callback() -> fn(Bool) -> Bool`.

The Dew body inferencer recorded unique callable names during initialization.
It left overloaded names as fresh type variables. Later body constraints gave
the value a complete function type, but no pass selected its declaration.
Lowering therefore produced `PlannedModuleValueGet(0)`, and the transform proof
collector correctly could not find that declaration. This was not a generated
builtin wrapper or a call-site collision.

## Fix

`semantic_basic_body_inference.dew` now checks unresolved local overloaded
function values after the body constraints. Syntactic call targets and already
selected references are excluded. Each candidate is instantiated, unified with
the expected complete function type, and rolled back before the next candidate.
Exactly one match is instantiated again and retained with its checked type
arguments. A compiler assertion checks that the committed signature still
unifies after rollback. No match and multiple matches use explicit existing
function-reference diagnostics and poison the invalid value.

The proof uses full logical parameter and result types. Names locate candidate
groups; they do not choose an algorithm or prove a physical carrier. The VM
call collector and source-spelling lookup rules are unchanged. The native
compiler already has this selection step and requires no change.

## Evidence

The first direct build with the semantic fix generated in 5.524 seconds, linked
in 1.326 seconds, and passed seven focused transform reference tests in
0.056 seconds. The actual overloaded-callback request then passed in
1.503 seconds. Logs: `.tmp/string-vm/overloads-build.log` and
`.tmp/string-vm/overloads-fixed.log`.

The added `semantic_function_value_overloads_test.dew` cases check selected
Bool/I32 declaration IDs, result types that share the same Wasm carrier,
generic type-argument retention, no matching signature, and ambiguous
signatures. All five cases passed in 0.057 seconds. The full direct module
passed 34/34 in 0.093 seconds. This final build generated in 5.583 seconds and
linked in 1.347 seconds. Logs: `overloads-tests-build.log`,
`overloads-semantic-tests.log`, and `overloads-full-tests.log` in the same
scratch directory.

Ten actual source-pool requests passed with that module: overloads, long/UTF-8
String equality, concat to source, StringBuilder output, built binding names,
checked cast-view patterns, the syntax-tree walk, the public combined String
example, floats, and nullable defaults. The added type-query request failed
later in its separate query lowering with `CT-001 type query cannot have a
runtime receiver`, at source offset 342. The eleven-request command took
13.482 seconds including that failure. This result does not claim a passing
query request. Log: `.tmp/string-vm/overloads-all-requests.log`.

The direct-source debug attempts used scratch copies of the VM call
helper to trace the bad ID. No debug assertion or fallback was added to
production call collection. The semantic patch's complete-signature checks
also leave the rejected candidate constraints out of the solver state.

No Moon command, native rebuild, commit, or bootstrap was run for this fix.
The root agent owns the final integrated bootstrap.
