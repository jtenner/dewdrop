# Option uses declared enum storage

## Change

The self-host compiler no longer registers an Option runtime adapter. Both
variants use the linked fragments of their selected source declarations.
Generic `Some` payloads use the same explicit scalar box or Unit marker as
ordinary generic enums. `None` uses its normal zero-field constructor recipe.
Opened imports preserve the exact same declaration identity.

Removed the Option adapter tags, special constructor/pattern selections,
receiver-based Option payload hints, the empty-Option object recipe exception,
and Some/None/Option spelling-based physical recovery. Reference-constructor
classification now uses selected constructor metadata instead of a variant
name. Parser desugaring for iterator syntax still creates ordinary source
Option patterns; it does not select a private physical representation.

The eight unused Option runtime types are deleted too. Result, pair, scalar-box,
and packed-array type groups now have named dependent base helpers. Removing a
type group therefore updates downstream bases without another hard-coded
72/77-entry prefix. Existing Result and collection runtime work remains open.

## Frozen operand defect exposed by the migration

The first implementation passed all internal tests but failed Wasm validation
in `circular_buffer_peek_front` and `FixedArray.get`. Variant emission used a
second result-shape lookup for a raw array read. It returned reference shape
even though the frozen expression plan and emitted instruction were I64, so
the required scalar box was omitted.

Source-fragment variant operands now require their frozen expression plan and
use its carrier for Unit markers, scalar boxes, and storage agreement. They do
not recompute the carrier during emission. A missing operand plan is reported
as BOD-610. Complete frozen variant constructor/operand records are still a
separate remaining task.

## Regression evidence

Two source-selection tests reject private Option adapters and require exact
declared fragments. Before the change, both fail with 703 tests passing
(68.048 seconds). The first implementation exposes the two missing-box Wasm
failures above (70.303 seconds). Frozen operand carriers fix both
(70.710 seconds). Removing the remaining Option spelling paths passes
(66.592 seconds). Deleting the eight runtime types and using dependent bases
passes all 705 tests, 328 full numeric records, and all shared corpora
(75.680 seconds), including 198 callback, 20 ring, and 13 FixedArray checks.

The new generated-lane policy test rejects Option adapter tags, spelling
dispatch in physical selectors, and the unused runtime type group. Its two
checks pass (0.038 seconds). Native library checks pass (31.356 seconds).
Generated-file checks pass (4.903 seconds). Clean Node bootstrap passes
(204.212 seconds), including compiler B semantic probes. Compiler B and C raw
and linked outputs have the same SHA-256:
`91bb6b20963aef1e0ccaa1747f2a68335a5385eb1cbd3d92316644b407072758`.
Runs above 30 seconds remain timing bugs; no speed or allocation-parity claim
is made.
