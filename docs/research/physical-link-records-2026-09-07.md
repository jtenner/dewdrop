# Physical link record checks

Date: 2026-09-07

The self-host link validator and physical body entry now verify link records
before body lookup maps consume them. Checks cover:

- SCC-ordered, contiguous module type bases and complete type table coverage;
- stored physical type indices, owning modules, and fragment indices;
- function table positions, import/definition counts and import order;
- declaration, specialization, lambda, and fragment identity;
- unique function fragments and unique source body identities;
- parameter/result span ownership and required defined-function bodies.

Successful checks allocate no failure messages. Two temporary maps track body
owners and used fragments; all other checks are linear walks. Contradictory
entries cannot silently overwrite an earlier owner. Missing source bodies now
fail at phase 5 with BOD-610, before the old phase-6 body check. The record holds
the required body ID in both `body` and `expected`, and the function table slot
in `expression`. The existing negative test was updated to this earlier exact
record; its invariant code remains BOD-610.

The native compiler has a different table layout: inline and elided entries
remain in its function table. Its new LNK-502 checker therefore verifies a
total, duplicate-free set of emitted function indices, not equality with table
positions. It includes initializer and startup functions and validates the import
prefix. It rejects count overflow before adding counts or allocating the set.

The mutation corpus starts from a passing record-construction fixture. Its first
version had invalid single-line Dew field syntax and trapped before checking
anything; a positive fixture test exposed that error. With valid syntax, the old
link checker accepted all seven corrupt plans. The new tests check exact numeric
records, not just traps. Native tests locate emitted entries explicitly instead
of assuming the first table entries are emitted functions.

Early validation:

- Valid-fixture red run: 1 passed, 7 failed as intended, 37.328 seconds.
- Native index tests: 2 passed, 8.761 seconds before the final two count cases.
- Self-host checks: 277 passed, 60 exact records. Cold generation:
  95.221 seconds; aggregate 156.676 seconds including a shared-lock delay.
- The overlapping Starshine run was cancelled after 33.601 seconds and is not
  counted as a pass. Final test lanes run sequentially to avoid shared-lock waits.

Final sequential checks:

- Hardening: 278 tests and 61 exact records, all shared probes pass, 37.420 s.
- Native: 955 tests pass, 130.429 s. Semantic: 80.810 s; backend: 37.475 s.
- Integration: 268 tests pass, 48.846 s.
- Clean bootstrap: passes in 160.571 s. A build: 43.407 s; A execution:
  41.839 s; B execution: 53.823 s. B/C core and linked hash:
  `ca72bb2ab0074995e305b2b9321c5cd6945d9230cc29bccefae9c4a5bae9be1f`.
- Library: 326 tests plus all execution probe corpora pass, 22.560 s.
- Generated sources, policy checks, and CLI fixtures pass, 10.457 s.
- Stress: 15 tests pass, 0.114 s.
- Pinned Starshine: all 10,982 tests pass, 253.672 s.

Every run above 30 seconds remains a performance defect. No slow case was
removed or disabled to obtain these results.

This does not close the complete linker audit. Native physical type/fragment
identity checks, removal of the emitter's synthetic import offsets, and frozen
call-to-emitted-index agreement still need work. Existing numeric body/ABI checks
remain in place; these table checks do not replace full reference assignability
or the instruction shadow stack.
