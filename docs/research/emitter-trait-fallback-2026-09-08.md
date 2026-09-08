# Remove emitter trait target guessing

The source emitter still has a final trait-call fallback after exact call and
constructor lookup fail. `self_host_linked_trait_call_index` recovers a method
name, scans implementation methods with that name, and returns the first linked
function if no implementation evidence is present. Even with an implementation
ID it can choose the first specialization for that method. The branch then
schedules raw logical arguments instead of the frozen operand recipe.

Bound calls now enter logical specialization whether or not they contain a
compile-time query. Valid calls therefore have a selected implementation and a
frozen recipe before emission. Delete the old search and its emitter branch.
Keep the existing missing-call diagnostic, including expression, declaration,
and source target context. Do not replace the search with a different name or
link-order rule.

Add a policy check for the deleted helper and a regression with two traits that
have the same method spelling. Each generic forwarder must select its own
requirement identity. Existing bound-call, generic receiver, Unit receiver,
trait evidence, and call recipe execution cases remain mandatory.

The search and its raw-argument emission branch are deleted. A policy test
guards against their return. The shared callback corpus adds two traits with
the same `read` method, implemented for the same I64 receiver, with different
results. Generic forwarders preserve each requirement identity inside concrete
callback factories. All six boundary values must produce the original I64.

The policy fails on the old source in 0.032 seconds. Native baseline compilation
passes in 0.395 seconds and all 72 callback checks pass in 0.023 seconds. The
existing self-host artifact passes all emission corpora, including the expanded
72 callback checks, in 32.215 seconds. The policy passes after removal in 0.039
seconds. The new self-host build passes 415 tests, 114 exact invariant records,
and every execution corpus in 53.455 seconds, including all 72 callback checks.
Generated-file checks pass in 11.126 seconds. Clean bootstrap passes in 166.089
seconds. B/C raw and linked SHA-256 match:
`f16ccd8bfe0406e0f1b81146cfc4718b4016bb88ad9af842c3d9ffbb7231c62a`.

An initial version used generic function-value factories. Native linking rejects
those in 8.327 seconds; generic lambda factories reach a missing-function error
in 0.389 seconds. These are a separate retained regression, not expected
failures. See `bound-trait-function-values-2026-09-08.md`. No speed work is
included here.
