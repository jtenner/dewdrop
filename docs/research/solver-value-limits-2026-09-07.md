# Native solver value limits

Union now checks its two roots and their sizes before the first parent write.
Sizes must be positive, fit the variable arena, and have a sum no larger than
that arena. The subtraction check prevents integer overflow. A failed proof
reports SOL-203 with the module, expected value, actual value, and root detail.

Resolved-type encoding now checks the I32 encoding limit before negation and
checks that the source ID belongs to the resolved arena. The error type still
maps to the solver's poison type. Machine-limit errors report SOL-207; invalid
source IDs report ARN-104. No invalid ID becomes a valid-looking body type.

Two focused tests pass in 8.819 seconds. They check exact numeric failure
records for oversized/zero/overlapping root sizes, non-root inputs, duplicate
roots, encoding overflow, negative IDs, and the first ID beyond the arena.
The tests use small valid arenas and single-field changes, not huge allocations.

All 974 native tests pass in 122.532 seconds. All 268 integration tests pass in
48.992 seconds; 326 stdlib tests and all shared execution checks pass in 23.039
seconds. The clean bootstrap passes in 158.728 seconds. B/C core and linked
bytes match; linked SHA-256 remains
`6cc687c2c9b37e725e27f05986091e17c5fc73f23fcaa85c8bac44aebbc0b6ec`.
Runs above 30 seconds remain recorded speed defects.
