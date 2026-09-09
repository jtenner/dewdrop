# Callback type graph checks

Function and applied types become physical references. The former signature
builder checked only their resulting shape, so an Error child or a structural
cycle could disappear behind a valid-looking Ref. Four one-mutation tests show
this in both resolved and inferred nested callback results: the baseline passes
850 tests but misses all four required traps in 89.034 seconds.

A checked graph walk now runs before shape conversion. It follows product,
application, function, and resolved-link children in both type arenas. Separate
arena tags keep identical numeric indices distinct. Active nodes detect cycles;
completed nodes retain shared subgraphs without false cycle reports. There is
no fixed depth cutoff. Every child span, type index, and signed resolved-type
encoding is checked before access. Generic leaves require their selected
specialization, and Error, unzonked variables, unresolved projections, and runtime
compile-time-type values are rejected.

The graph is finite and each node is expanded once per check. Nominal types are
leaves: this is a logical type-graph check, not recursive expansion of declared
fields or a complete physical heap-layout proof. Failures retain the calling
signature's parameter/result position and all numeric source context.

The first fix passes 854 tests, 444 exact records, and shared runtime checks in
91.551 seconds. Expanded tests add a shared graph deeper than 65 function nodes,
bad nested spans, resolved-link encoding overflow, pending projections, and
unzonked variables. Final hardening passes 859 tests, 448 exact records, and
shared runtime checks in 90.888 seconds. Generated checks pass in 4.672 seconds.
Clean bootstrap passes in 214.564 seconds; raw and linked compiler B/C outputs
share SHA-256 `79c107c22d90ab5dbbd8f7c8f5a7036f96b827a2bff8298450c7f881c65d369b`.
Runs above 30 seconds remain timing defects; no speed work is included.
