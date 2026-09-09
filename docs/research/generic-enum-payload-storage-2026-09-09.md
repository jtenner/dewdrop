# Generic enum payload storage

## Existing ABI and defect

The self-host fragment planner uses reference storage for a declared generic
tuple-variant payload. Native generic enum layouts can specialize those fields;
the self-host source fragment remains erased. Previously, ordinary enum
construction did not box scalar payloads and pattern planning copied reference
storage into scalar binding carriers. The reference template was admitted at
link verification only for the standard Option/Result adapters.

The first shared `GenericEnvelope<I64>` execution case fails with preserved
eqref/I64 carrier conflicts. It is not an expected runtime trap. The existing
source probe is recorded in
[the earlier investigation](variant-payload-storage-2026-09-09.md).

## Explicit storage certificate

Erasure is certified by one selected variant declaration and payload ordinal:

- The physical field role and stored declaration must agree.
- The ordinal must belong to the declared tuple payload span.
- That exact declared payload type must be generic.
- The physical field must have reference storage.

Only this certificate permits a scalar box. The five existing full-width box
types cover I32, I64, F32, F64, and V128. Construction emits a `struct.new` for
the proven scalar box. Extraction casts to that exact box and reads its field.
References keep reference storage. Unit uses the checked null marker, not a
scalar box or a physical local. Unknown, conflicting, and Never carriers cannot
gain a scalar-box certificate.

This shares the existing declared-generic struct boxing operation; it does not
map Generic or Error specialization requests to Ref. Pattern planning keeps
unresolved generic binding evidence unknown until specialization provides the
binding carrier. Direct binding and nested-path emission both check the adapter
against the frozen local carrier. Nested literal comparisons unbox their
selected payload before comparison.

The same declared-payload lookup supplies Unit marker checks. Link verification
no longer requires a standard-module adapter merely to admit a declared generic
payload field. Existing Option/Result runtime adapters are not removed here.

## Tests and remaining obligations

The shared callback corpus adds ordinary enums with all five scalar carriers,
references, function values, generic readers, nested bindings and literals,
empty variants, Unit readers, and mixed concrete/generic/Unit payload positions.
An effect trace checks source-order evaluation exactly once, including a Unit
argument between scalar arguments. I64 checks include both limits. Internal
tests reject slot reuse, contradictory stored declaration IDs, unknown/conflict
carriers, and scalar boxing for concrete or Unit slots.

This completes execution of the tested erased generic tuple payloads, not
frozen tuple-variant constructor recipes, generic named-field pattern adapters,
full reference assignability, or Option/Result runtime removal. The self-host
erased layout allocates scalar boxes; no allocation or speed parity with native
specialized enum layouts is claimed. Physical phase snapshots must retain that
ABI distinction rather than discard physical information.

## Validation record

The initial implementation passes the first six new I64 cases and all existing
hardening tests (66.187 seconds). The first expanded corpus passes 156 callback
checks (68.120 seconds). A further test draft used unsupported explicit generic
function-reference syntax and failed parsing (72.293 seconds); the corrected
test uses a typed function factory. The corrected all-carrier corpus passes
192 callback checks. After the source-order case and shared certificate
refactor, hardening passes 705 internal tests, 328 numeric records, and all
shared corpora including 198 callback checks (63.503 seconds). The native
library lane passes the same 198 callback checks and all other corpora
(31.447 seconds). Generated checks pass (5.002 seconds). Clean bootstrap passes
(201.514 seconds); B/C raw and linked hashes match:
`89efa1882d4bcd9754f5e6589bebfa287d2b15209961d66b7800123718e576b0`.
Runs over 30 seconds remain timing bugs, not speed work.
