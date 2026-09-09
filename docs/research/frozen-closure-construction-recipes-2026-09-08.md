# Frozen closure construction recipes

Ordinary lambda construction now has a retained entry function, closure heap
type, and capture recipe. Each logical capture records its source identity,
erasure, destination field/storage, optional cell type, and operand source.
The operand is explicitly absent, a physical local slot, or a capture forwarded
from the enclosing closure. Planning requires exactly one source; emission no
longer searches locals, recomputes erasure, or selects the first outer capture.

Mutable captures retain the exact existing cell slot and heap type. Nested
closures forward that same cell reference without reading its current scalar
value. Unit captures remain logical entries but contribute no physical field
or operand. Packed fields retain their signed/unsigned storage certificate.

The verifier reconstructs only the small recipe tables from the existing
source/fragment/physical records. The body freeze witness owns separate copies
of both arrays and compares every field. The emitter uses the retained entry
and operand sequence. Source-body diagnostics, including the existing BOD-607
wrong-entry diagnostic, are preserved before derived recipe verification;
they prevent emission and are not cleared or converted into valid plans.

The old capture-source search is removed. Two now-unused object-constructor
heuristic helpers left by the preceding migration are removed too.

This completes ordinary capture construction, not runtime trait-dictionary
capture, full reference assignability, tuple-style variant recipes, or the
general instruction shadow stack. Those tasks remain open.

## Tests and measurements

- The new positive record test fails as intended when its tables are empty:
  676 existing tests pass, 1 fails (75.092 seconds).
- The first implementation passes its new test but replaces an existing
  BOD-607 source diagnostic with an earlier trap (68.224 seconds). Verification
  order is corrected; the existing diagnostic test is unchanged.
- Four positive recipe cases cover mutable cells, erased Unit, nested capture
  forwarding, and signed packed storage. All 680 tests and shared corpora pass
  (67.652 seconds).
- Twenty-two one-field/one-entry negative cases check all nine numeric fields
  for target identity, spans, source identity, storage, cells, erasure, operand
  kind/slot, missing records, duplicate records, and before-freeze agreement.
- Final hardening: 702 tests, 328 exact records, and all shared corpora pass
  (66.560 seconds).
- Shared callback checks grow from 96 to 120. New execution cases cover nested
  immutable captures, shared mutable cells across two returned closures,
  Unit erasure with an observable argument effect, and signed/unsigned packed
  fields. Each runs six I64 values, including both extremes, in both compilers.
- Native library: 326 tests and all shared corpora pass (28.668 seconds).
- Generated checks pass (4.608 seconds).
- Clean bootstrap passes (197.433 seconds). B/C raw and linked outputs match:
  `adb4ad981ef69f4bcd454ebbcf70c3e76f0ef4d2b08c000fb70cbe21e73ef1bb`.

Native compiler, integration, stress, and pinned-provider code are unchanged
from the validated `6de4b36` batch. Runs above 30 seconds remain timing defects;
no speed work is included.
