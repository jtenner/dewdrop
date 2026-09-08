# Unit branch result disposal

The native emitter built a void `if` for a Unit expression but kept the
then-block's tail value on the stack. A Boolean-returning call in an `if`
without `else` therefore failed Wasm validation. Compile-time selection exposed
the same mismatch: a selected block retained its Boolean tail even though the
enclosing rewritten expression was Unit. Both minimal native regressions fail
on the old emitter (0/2 pass, 8.913 seconds).

The emitter now schedules explicit tail disposal at Unit block and branch
boundaries. It uses the selected tail's specialized physical shape, not the
enclosing Unit shape, to count drops. This preserves scalar, reference, and
flattened product results. Unit and Never add no drop. The work task changes
only the completed instruction fragment, not the frozen semantic plan. Body
root disposal shares the block-tail shape helper. Both regressions pass in
8.975 seconds.

The shared native/self-host corpus checks 20 cases: branch entry/skip, exactly
one side effect, scalar/reference/product/Unit results, nested branches,
early return, Unit body roots, constant folding, and compile-time type queries.
The first library generation rejected one-line object fields; the fixture now
uses the required newlines. That parse failure is not a passing regression.
The native shared corpus passes all 20 cases (8.155 seconds to compile,
0.025 seconds to run). The self-host corpus then exposes 26 physical-planning
diagnostics (144.895 seconds for the cold hardening lane). Its transfer rules
forced the Unit parent carrier onto live scalar/reference child calls, then
merged the resulting conflicts back into the parent. This is a wrong equality
constraint, not evidence that the calls have Unit ABIs.

Unit block/if boundaries now preserve child facts independently. The predicate
uses the selected logical type after generic substitution. No conflict is reset
or suppressed, and call verification remains active. The emitter's existing
discard schedule handles these boundaries. A focused plan test checks both
the parent's Unit carrier and the child's I64 carrier. Complete validation is
in progress. The first repaired self-host run passes all 450 plan tests and
137 numeric records, then catches a corpus-harness mistake (56.598 seconds):
the smoke emitter exports only `main`, not each public function. The shared
corpus now dispatches its cases through `main` in both lanes. No missing export
or planning failure is counted as a passing case. The final hardening run passes
all 450 tests, 137 exact records, and every execution corpus, including all 20
Unit branch checks (56.444 seconds). The full native lane passes 1,100 tests in
150.710 seconds; all 268 integration tests pass in 57.321 seconds. The library
lane passes 326 tests and every shared corpus, including the final 20-case
dispatcher, in 24.566 seconds. Clean bootstrap passes in 170.281 seconds;
compiler B and C both hash to
`577075c3e5f27f53387b4e3ed1125ae019963c47c9ff487a8eba4630196d0ec8`.
Generated checks pass in 11.296 seconds; all 15 stress tests pass in 0.348
seconds. Runs above 30 seconds remain speed bugs. The pinned provider and FFI
bindings are unchanged. No speed changes are included.
