# Specialized closure environments and entries

A lambda inside a generic source function now carries its owning specialization
request through its closure type, entry function, and mutable capture-cell type.
Generic template lambdas are not emitted as plain reference-valued functions.
Each reachable owning request gets concrete parameter, result, and capture
shapes, including Unit erasure. Nested environment field lookup is scoped to the
selected physical type's field span, not the first field with the same lambda ID.

Closure lookup requires exact lambda and request identity. Mutable capture cells
use the same key; Unit captures do not allocate a cell or emit a write operand.
Lambda parameters, results, and immutable capture storage reject unresolved or
erroneous shapes with a numeric SPC-301 record before physical emission.

Validation: 126 hardening tests and 25 numeric records pass. There are 114 focused
execution checks plus all 66 shared callback cases. New cases cover two scalar
specializations of one lambda, generic mutable I64 capture storage, and immutable
and mutable Unit captures. The fragment test checks three distinct I32/I64/Unit
environments and entries, with no unspecialized template entry.

Routine native tests also passed: 788 tests. Semantic and backend lanes took
10.211 and 20.521 seconds; the full measured command took 32.654 seconds and
reported the aggregate performance limit. Clean bootstrap at `686ed7d` remains
the latest completed fixed point; the current changes require a fresh run.

Remaining closure obligations include frozen construction targets, calls inside
generic lambda bodies, and broader mutable pattern-binding coverage. This batch
does not claim to finish the full standard-library migration.
