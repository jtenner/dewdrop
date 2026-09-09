# Linked call index contracts

The previous call index stored parallel keys, targets, and next links. Its
reader checked only the selected array index, returned as soon as a key matched,
and did not bound a link walk. A self-link could be hidden by a matching key or
cause a later absent-key lookup to loop forever. A longer parallel arena was
also accepted. The chain had no stored body identity.

The implemented contract is one body/key to one physical target. Every visited
entry must retain its body, each non-sentinel link must point to an older entry
of that body, and all parallel arrays must have equal lengths before lookup
or insertion. A decreasing index bounds a walk by the entry count without a
fixed depth cap. Duplicate identical insertions must not grow the index;
different targets must report SPC-303 before a write.

This is the phase-5 linked-index contract. Its failure context retains the
caller module, body, and expression decoded from the lookup key. Target-table
identity and complete physical call verification remain separate checks.

The reader now checks the stored body and outgoing edge before returning an
exact hit. The physical body index retains the complete linked index instead
of four separate aliases. The owner array adds one U64 per entry while keeping
flat arrays, not one allocated object per call. Insertions use the same checked
lookup, with no separate unchecked writer. Plain-function lookup is unchanged.

The baseline run takes 88.236 seconds: three mutations fail to trap, and two
traps have anonymous records. The first corrected run passes 810 tests and
409 exact records in 91.965 seconds. The expanded corpus has ten one-mutation
negative tests, including an edge into a different body and a forward edge.
Every host-side probe compares all nine numeric failure fields. A positive
test checks independent sixteen-entry chains, duplicate identity, and absence
for another body or specialization. Final hardening passes 812 tests, 411 exact
records, and shared execution checks in 87.908 seconds. Generated checks pass
in 4.501 seconds.

Clean bootstrap passes in 182.686 seconds. Raw and linked compiler B/C outputs
share SHA-256 `2d2b2cb1476740bd8bcec1431e7cc9f4efbac130089a987af9965067593faa1c`.
This also covers both preceding builder-default migrations. All 1,275 native
tests pass in 206.662 seconds, all 270 integration tests pass in 60.639 seconds,
all 15 stress tests pass in 0.357 seconds, and all 10,994 pinned Starshine tests
pass in 252.368 seconds. The provider's invalid-module diagnostic is expected
output from a negative test; the command exits successfully with zero failures.
Runs over 30 seconds remain timing defects; no speed work is included.
