# Native trait search contracts

## Scope

Remove the five native inference paths that returned `false` or `None` after
depth 64. Keep ordinary missing evidence distinct from a cycle and a resource
limit, including during speculative method selection and evidence construction.

## Design

Each body has a search context with immutable, structurally interned logical
type keys. The key reader follows live solver bindings without zonking an open
transaction. It checks owned argument spans and cycles, preserves nominal and
generic parameter identities, and represents shared children once. It never
uses a physical shape as evidence of logical identity.

Active obligations contain target key, trait type key, and trait declaration.
Re-entry reports `CT-013 cyclic trait prerequisite`. A separate work budget
reports `CT-012 trait evidence search limit exceeded` at 65,536 attempts or 256
active obligations. The cycle check runs first. Failed admission does not change
the active stack. Search exits pop their own active obligation after candidate
transactions finish. No later candidate can erase a search failure.

Nested searches also save and restore the caller's candidate arguments, owner
and method generic spans, and Self binding. Instantiation work must be idle at
entry and exit. Restoration invalidates cached transaction-local IDs. This fixes
a separate bounds crash: the first method bound used to replace the arguments
needed to check the next bound.

The new native `TraitObligationFailure` retains declaration, expression, message,
and source offset. It is encoded in the V1 body codec, rebased with family
artifacts, and mapped to source diagnostics. An explicit search failure does not
also become an ordinary unsatisfied-obligation diagnostic at a direct call.

## Checks in progress

- Negative-first compile failed on the missing diagnostic variant: 0.840 seconds.
- A field was initially added to the result record instead of the inferencer;
  compilation caught this in 0.880 seconds. The field belongs only to live
  inference state and is not serialized.
- Two source tests passed in 9.322 seconds: a 65-step prerequisite chain and an
  exact cycle diagnostic at its source call.
- Five checks passed in 8.970 seconds, adding limit distinction, unchanged failed
  admission, rollback-stable keys, module identity, invalid spans, and type cycles.
- Six checks, including codec and family rebasing, passed in 9.038 seconds.
- The intermediate full native suite passed 994 tests in 123.143 seconds.
- The new sibling-method-bound test then failed with a real array-bounds abort
  (10.860 seconds). After restoring the candidate frame, all seven focused tests
  passed in 9.348 seconds. This failure was not accepted as a passing trap.
- Eight focused checks passed in 9.305 seconds. Owner and method bounds retain
  their own generic environments; a missing Bool bound is still an ordinary
  method mismatch, not a cycle or an array trap.
- Final native suite: 996 tests passed in 123.070 seconds. Semantic work took
  72.797 seconds and backend work took 38.010 seconds; both remain speed bugs.
- Integration suite: 268 tests passed, 49.357 seconds.
- Public interface regeneration: zero errors, 1.383 seconds.
- Library suite: 326 tests plus shared execution cases, 23.790 seconds.
- Generated-source and policy checks: passed, 15.577 seconds.
- Self-host hardening: 311 tests, 65 exact invariant records, and all shared
  execution corpora pass, 62.066 seconds. Generation took 22.162 seconds and
  emission probes took 22.393 seconds.

- Clean bootstrap: A/B/C builds and validation pass, 158.088 seconds. B/C core
  and linked bytes match. Linked SHA-256 is unchanged:
  `df4aa9c5ae4618ce0a1721d20cd6bffd9664df3fe102d510e0e35ba86e4b56f5`.

Timing defects above 30 seconds remain speed work. Physical evidence-key
serialization still has separate truncation and shape-identity defects; those
remain open in `agent-todo.md` and are not completion claims for this batch.
