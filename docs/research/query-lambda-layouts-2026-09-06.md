# Exact layouts for query-sensitive lambdas

Native CT-038 is removed. Each selected root-function instance now has its own
lambda signatures and capture lookup tables. Unit parameters, results, and
captures occupy no physical slot. Scalar captures keep scalar storage. Mutable
captures use a cell whose slot agrees with the owning local and the lambda.

Escaping closures get a separate physical type when their capture layout
changes. New physical types precede the module's signatures, so the planner
rebases every existing signature reference as one operation before linking.
No emitter changes a layout. Directized lambdas pass their retained captures
as leading parameters; ordinary closures pass one environment reference.

Private instances copy capture arrays as well as locals. Layout comparison uses
the shared template, not a previously changed private instance. Planning twice
from the same lowering therefore produces the same physical types and fields.
Duplicate lambda targets for one logical instance are invariant failures.

The version-1 fragment codec preserves the selected layout tables in sorted
key order. Its reader rejects duplicate keys; arena validation checks table
lengths and closure identities. Module-only caches reject program-instance
layout tables rather than silently losing them.

The self-host indirect-call signature table was keyed only by module and
expression. It now also uses the caller specialization and visits the selected
body of each linked function. Signature parameters and results use that exact
request's types. Initializers have explicit plain scopes. The emitted branch
type uses the selected result, including Unit. This fixes a real call_ref stack
underflow on a generic lambda with a Unit parameter.

Validation so far:

- Native and self-host shared execution: 45 checks. New cases cover generic
  Unit/I64 parameters, immutable captures, returned closures, and mutable cells.
- Native IR test: exact closure fields and result types, binary codec round trip,
  repeated planning, valid linking, and a one-field invalid-table mutation.
- Routine native suite: 844 tests passed. Total 72.038 seconds; backend lane
  31.017 seconds exceeds the 30-second budget. Semantic lane: 29.077 seconds.
- Self-host hardening: 191 tests, 29 numeric invariant records, all emission and
  semantic probes passed. Cold total 37.982 seconds; emission checks 7.174 seconds.
- Full B/C bootstrap passed in 146.851 seconds. A build: 36.273 seconds; A-to-B:
  44.897; B-to-C: 46.766. All three exceed the time budget. Both linked outputs
  have SHA-256 `de5d7cb0861ebc6afdc2eb5046ad82245912528b6d7f3bc8645aab0fd03cbdbb`.

Deferred generic member queries and branch-local type checking remain separate
open work. These lambda tests do not mark those tasks complete.
