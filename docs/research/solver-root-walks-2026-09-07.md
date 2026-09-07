# Bounded solver root and binding walks

A valid parent forest does not prove that a type-binding chain terminates.
Both compilers now bound binding walks by the variable count. A cycle reports
SOL-202 with the starting body type and hop count, rather than looping forever.

Native parent walks now also check parallel variable arrays, every parent ID,
and the hop bound before any parent access. Representative reads check stored
variable identities and binding type IDs. Signed resolved-type decoding uses
`-(index + 2)` so it does not negate the minimum machine integer.

The existing path-compression rule is unchanged: compression occurs only when
there is no open snapshot. A test checks both the saved parent contents inside
a transaction and compression after rollback.

Four native contract tests pass in 8.681 seconds. They check full failure
records for cycles, invalid parents, unequal arrays, invalid bindings, and
stored identity disagreement. The self-host one-field binding-cycle mutation
also checks the complete numeric SOL-202 record in the host harness.

Final measured checks: 968 native tests pass in 123.511 seconds; 268 integration
tests in 49.330 seconds; the library lane in 14.062 seconds; generated checks in
15.621 seconds. All 294 self-host hardening tests, 64 exact failure records, and
shared probes pass in 67.376 seconds. The clean bootstrap passes in 156.266
seconds with identical B/C core and linked bytes. Runs above 30 seconds remain
speed defects; no speed changes are included.
