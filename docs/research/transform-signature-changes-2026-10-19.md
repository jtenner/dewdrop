# Transform signature changes

Implemented and tested on 2026-10-20. This note records the change and its test evidence.
It is not a claim that all remaining transform work is complete.

## API

`FnNode.signature` holds `SignatureNode { parameters, return_type }`.
`with_signature(parameters, result)`, `with_parameters(parameters)`, and
`with_return_type(result)` keep the body. All body builders retain the signature
and `call_adapter`. `repair_calls_with(body)` supplies an explicit body with the
old parameters and result; its generated calls use the new signature.

The compiler keeps the original generic parameters, bounds, name and visibility.
An unchanged signature keeps its original source header. A changed signature is
rendered from structured parameter/type nodes. Type rendering accepts the parser's
named, qualified, applied, tuple, function and computed type forms, with validated
identifiers, payload shapes, depth, source size and tuple arity. Final normal
source checking remains mandatory.

## Call repair

The initial checked program exports selected function declarations and callee
source sites. Generated check-file paths map back to original declarations.
Repair uses these identities, not a source-name search. Conflicting proofs are
errors. Local function values with the same name remain unchanged. Imported
references retain their import alias while their selected final identifier can
change to the bridge.

Expansion first collects transform results, then repairs original calls and
renders generated functions in source order. The renderer restores each result's
work/allocation counters. Values retain their own array, record and text backing;
interpreter globals and memory are not reused by the renderer.

The initial `ExprNode::Source` keeps its physical identity. Only that retained
node receives original-body repairs, including through builder wrappers. A newly
constructed Source with identical text is new code and is not repaired.
Adapters are new code. Each adapter uses the old header and the explicit adapter
body; normal declaration validation checks its size and nesting before parsing.

Fresh bridge names use an identifier index once per module. The index includes
locals, so inserted names cannot bind to existing local declarations. Candidates
have short numeric suffixes. Construction is charged before allocation. The
per-file sum of inserted bridge name bytes is limited to 1 MiB before output
writes. Caller token lists and target names are reused. Callee sites and output ranges
use binary search. Only annotated declarations need saved repair targets.

## Initial and final body checking

Ordinary bodies can contain calls written for the new signature. The initial
check records exact body-owned errors at original declaration sites. Errors in
headers and imports stay fatal. Before a helper or initializer runs, both the
AST and bytecode entry paths check this saved error map, before cache reads.
A bad untaken branch or nested closure cannot evade this check. The final
normal check still rejects all remaining runtime errors, including unused code.

Native maps frontend diagnostics through checked body expression, block and
pattern ownership. Return constraints at declaration offsets also require an
exact matching checked inference diagnostic. Dew uses merged inference jobs
and their root-body IDs. Dew name and signature errors remain fatal. Its
validation view shares checked arenas and removes only covered inference
diagnostics; storage, proof and lowering invariant checks remain in force.
Invalid original call and function-value sites are excluded from adapter repair.
Checked constraint value IDs cover errors located at headers or return keywords.
The function-value regression failed in both engines before this fix. A separate
direct-call review concern was disproved by tests and withdrawn; call checking
already moves that error to the call site. Valid old calls
still use bridges; new calls pass normal checking after expansion.

## Evidence

Before implementation, the public candidate failed with missing `parameter` and
`with_signature` API members in 0.940 seconds. A new-arity call also failed before
body deferral (0.957 seconds).

Native interpreter tests: 111/111 pass (2.731 seconds). Native body guard cases:
13/13 pass (21.731 seconds). Native signature cases: 10/10 pass (19.174 seconds),
plus the existing canonical entry signature check (1.612 seconds). They cover
new arity, mixed old/new calls and values, new results, imports, generics, stacks,
same-named locals, retained original syntax, malformed types, deep adapters,
name collisions, output bounds, and range edges. Invalid helpers, untaken
branches, closures and methods cannot run. Cached bodies/globals cannot bypass
checks; unused runtime errors and invalid headers still fail normal checking.

All 215 registered Dew transform tests pass (53.387 seconds). The five changed
result cases also pass in isolation (5.691 seconds, generation 6.995 seconds,
link 1.491 seconds). The normal test command now includes signature/body guards
and imported-reference checks with their shared fixture file.

All 14 actual Native-compiled Wasm controls validate, have no imports, and
return 42 after normal initialization. They include the public example with both
an old function value and a new-arity call, generic/stacked changes, new-arity
calls, new results and returned function values. Individual builds took
2.158–2.228 seconds; whole-process maximum RSS was
499700–524204 KiB. These are controls, not speed or memory gain claims.
Final JS compiler build: 3.885 seconds. API declarations: 5.771 seconds.

Recorded performance faults: the cold Native Dew-test generator build took
31.039 seconds; two failed full harness attempts with a cold build took
40.275/38.062 seconds; the complete Dew suite took 53.387 seconds; the 14-control
Wasm batch took 31.208 seconds. Individual Wasm controls stayed below the limit.
Fresh self-host A/B/C and native Wago checks belong to the final full-feature
validation; earlier fixed-point artifacts do not prove the latest source.

Raw logs: `.tmp/transforms-v4/signatures/` and
`.tmp/transforms-v5/body-guards/` and `.tmp/transforms-v5/runtime-signatures/`. The read-only Claude review could not run:
weekly quota is exhausted until 2026-10-24 16:00 UTC. No Claude assessment was
returned. Its output and status are in `.tmp/transforms-v5/signature-review/`.
