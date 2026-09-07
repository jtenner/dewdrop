# Guarded trait call signatures

Map's migration exposed an imported-trait contract gap. Evidence search could
select a method with the right requirement identity but a different result
type. In that case a guarded call could pass specialization with an invalid
physical signature.

Both compilers now compare the selected method's full logical signature with
the trait requirement before they replace the guarded call. The check binds
trait arguments, implementation arguments, method arguments, and both Self
types to their concrete values. It checks receiver presence, parameter count,
method type-argument count, every parameter type, and the result type.

Self owners and generic parameters use separate binding channels. Their numeric
IDs come from different arenas and can have the same value. Both readers now
carry the explicit Self binding through nested products, applied types,
functions, and projections. A one-field identity-collision test uses ID 42 for
both namespaces and requires `(Self, T)` to become `(I64, I32)`.

Mismatch reports `CT-040 guarded implementation signature mismatch`. Missing
methods retain their distinct `CT-040 trait implementation has no required
method` error. The check does not use source names or scalar carrier equality.

A native regression and a self-host regression use an imported trait whose
requirement returns I32 while its implementation returns I64. The self-host
compiler catches this imported invalid implementation earlier with CT-015; the
native guarded-call boundary reports CT-040. Both tests require the exact code.
Existing valid generic and associated-trait tests remain positive checks.
Native focused tests passed: 12 tests in 15.514 seconds. Full self-host
hardening passed: 230 tests, 29 exact invariant records, and all shared
execution corpora in 57.584 seconds. The full run exceeds 30 seconds and remains
a performance bug. These runs include the pending Map migration in the worktree.

This is a call-boundary fix. Completing imported implementation validation for
all queries, including unused methods, remains part of the wider trait audit.
