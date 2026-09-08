# Runtime trait export admission and callback recipes

This change fixes three related correctness defects. It does not add runtime
dictionary captures to source lambdas and does not include speed work.

## Export admission is a graph proof

The old recursive support cache published a successful callee while its caller
was still being checked. For A calling B and B calling A, a later unsupported
operation in A rejected A but left B cached as supported. A visiting node was
being treated as a completed proof.

The new worklist discovers reachable declaration/evidence-class states, records
reverse call edges, then propagates each rejection to all callers. It publishes
terminal results only after the failure queue is empty. A fully supported cycle
stays supported; one unsupported member rejects the whole dependent component.
Tests check both initial query orders with a shared cache.

Admission now checks expressions owned by nested lambdas too. An escaping lambda
which needs its parent's runtime dictionary is not a proved erased external
ABI: there is still no dictionary capture recipe. The optional erased export is
not emitted in that case. Concrete Dew calls remain valid and are tested.
Public generic function-value factories retain their existing supported export.
This does not change Dew declaration visibility or invent a runtime capture.

A completely absent optional expression-evidence table means no expression
obligations. A present but truncated table is rejected. Evidence root spans use
subtraction-based bounds checks. Concrete witnesses do not need runtime forwarding.

## Closed lambdas keep exact owner keys

A lambda with no runtime dictionary use can support an erased export. It still
needs a per-owner-key function fragment: the empty template key does not find
calls recorded under the exported root's key. The new runtime lambda materializer
keeps its already-declared erased signature and layout, records exact owner
shapes/evidence/key, and verifies the stored lambda identity. It does not allocate
dictionary fields or reinterpret a root parameter as a lambda parameter.

Concrete and erased instances coexist. The backend test asserts export presence,
requires no source/link diagnostics, emits the complete module, and validates
it. The unsupported-capture test asserts only the optional export is absent;
it still requires successful emission and validation of the concrete program.

## Direct calls retain callback evidence

The closed-lambda test exposed another fault in callback directization. Both
rewrites reused a function reference's type-argument span as a call span, although
these are different arenas. They also failed to copy its trait evidence roots.
The new shared helper checks both parallel type tables and the evidence span,
copies selected arguments into the call arena, and transfers exact evidence to
the replacement call. Lowering owns copies of the arrays it now mutates, so it
does not change the inferred input. This fixes existing optimization behavior;
it does not add an optimization.

A white-box test deliberately separates the arena offsets and checks both the
logical types and trait roots. The shared execution corpus checks two traits
with the same method spelling through callback arguments and a closed generic
lambda. All prior callback forms remain in the corpus: 96 cases total.

## Measured checks

- Initial support regressions: one passed, three failed, 9.872 seconds.
- Closed function reference test first lacked an expected function type and
  had real source errors, not warnings. A typed callback parameter fixes the
  fixture. Valid source then failed UnsupportedExpression (9.117 seconds),
  then SignatureOnlyCall after owner-key repair (10.199 seconds).
- After recipe transfer, all five backend cases pass (10.069 seconds).
- Combined ten focused tests pass (12.004 seconds).
- Expanded shared native fixture builds in 5.072 seconds.
- Full native: 1,089 passed, 159.934 seconds.
- Integration: 268 passed, 57.222 seconds.
- Library: 326 tests and all shared checks passed, including 96 callback
  executions, 32.200 seconds.
- Generated checks: passed, 13.670 seconds.
- Final generated-check rerun: passed, 4.023 seconds. All 15 stress cases pass
  (0.349 seconds).

The first hardening run passed 415 tests and 114 exact numeric records but failed
the expanded callback oracle because the self-host wrapper list omitted the two
new names (143.958 seconds). Both runners now use one shared callback-name list.
The corrected self-host emission lane passes all 96 cases and the other corpora
(32.316 seconds). The full hardening rerun passes 415 tests, 114 exact numeric
records, and every execution corpus (53.927 seconds).

Clean bootstrap passes (163.602 seconds), with identical B/C raw and linked
SHA-256: `f16ccd8bfe0406e0f1b81146cfc4718b4016bb88ad9af842c3d9ffbb7231c62a`.
The pinned provider is unchanged. Runs over 30 seconds remain known timing
defects, outside this correctness task.
