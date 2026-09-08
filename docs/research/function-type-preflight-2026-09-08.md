# Native function type preflight

Before signature interning, the native linker now checks every source function
type, including signatures that later share a canonical representative. It also
checks the parameter/result spans of named physical functions. This preflight
runs before the older generic arena validator, so numeric source context is not
replaced by a generic string error.

Checks cover parameter/result spans, full local reference bounds and kinds,
raw array carrier bounds, ordinary signature indices, stored resolved-type
identity, unique fragments, reverse lookup coverage, and parallel callback maps.
Synthetic closure entry and erased signatures legitimately use resolved ID -1;
other negative IDs are not accepted. A source fragment cannot hide behind -1,
because its reverse entry would become orphaned.

The structural function-reference graph is checked with an explicit enter/leave
stack and three colors before the interning comparison expands it. A back edge
reports ARN-108. Shared acyclic children are legal. Nominal heap references are
leaves, so this does not reject recursive structs or treat them as structural
function cycles. It does not add support for recursive function-type aliases.

New numeric roles are 77/78 (parameter/result span), 79 (signature index),
80/81 (resolved ID and lookup identity), 82/83 (unique fragment and reverse
coverage), 84/85 (callback map length and target), and 86 (structural cycle).
Existing reference roles 49/51/52 retain their meaning. Named signatures retain
their declaration; anonymous signature fragments retain the source module and
table slot. All records use phase 5, body zero, and the missing expression ID.

## Validation

The valid fixture has clean diagnostics and contains both a logical function
type and a synthetic closure entry. Nine negative cases failed against the old
check while the valid case passed (15.350 seconds). The first implementation
passed those ten tests (14.600 seconds). Five additional tests cover shared
children, signature reference bounds, synthetic impersonation, missing callback
entries, and named declaration context. All 1,216 native tests pass (219.544
seconds), including all 15 new cases. All 268 integration tests pass (62.410
seconds). Self-host hardening passes all 521 tests, 184 exact numeric records,
and all shared execution corpora (164.690 seconds). Generated checks pass
(13.673 seconds). Clean bootstrap passes (212.953 seconds); B/C raw and linked
SHA-256 hashes all match:
`edd279eeb93dabefddde9b808be418ffda8c7e1361672bb17468fb8b3f53e66d`.
Runs above 30 seconds remain timing defects; no speed work is included.

This closes the pre-interning source-table gap, not all late adapter recipes,
full plan freeze, or full reference assignability at every emitted instruction.
