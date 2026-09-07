# Checked native solver undo records

Native rollback used to pop three parallel arrays before checking the entry.
A bad kind produced an anonymous abort; bad indices and old values could reach
array writes. The self-host solver already checks these records.

The native solver now checks array lengths, the restoration range, every record
kind, target index, and saved parent, size, or binding value. Encoded resolved
bindings are checked without overflowing on the minimum I32 value. The entire
range is checked before the first write or pop. Recording and opening snapshots
check parallel lengths; commit checks records before dropping the transaction.

The root-walk failure record is now named `SolverInvariantFailure`, since undo
checks use the same numeric code, module, expected, actual, and detail fields.
Undo failures use SOL-205. Invalid parallel variable arenas retain SOL-201.
The compiler reports the record before it aborts.

Tests begin with real union records and change one field at a time. They check
the exact failure fields, no mutation during failed validation, and complete
saved type/argument/variable/binding/diagnostic contents after nested rollback.
This does not claim that generation-numbered traversal caches are byte-identical
after rollback. Their safety checks and other native solver boundaries remain
part of the open solver audit.

Four focused tests pass in 8.594 seconds. All 972 native tests pass in 122.253
seconds; all 268 integration tests pass in 48.845 seconds. The clean bootstrap
passes in 158.723 seconds, with identical B/C core and linked bytes. Linked
SHA-256 remains `6cc687c2c9b37e725e27f05986091e17c5fc73f23fcaa85c8bac44aebbc0b6ec`.
Runs above 30 seconds remain speed defects; speed work is out of this batch.
