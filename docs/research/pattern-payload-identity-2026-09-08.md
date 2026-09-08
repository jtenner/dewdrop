# Pattern payload identity

Follow-up to the dead variant-lookup cleanup: active payload seeding still
recognizes user spellings Some/Ok/Err, and two branches recognize a physical
function name ending in get. The exact-map helper also reads specialization
slot one without checking which generic parameter the selected result uses.

The new focused tests start with valid lowered programs. One asks the runtime
adapter seeder to handle a user-defined Some constructor; it must leave that
constructor to declaration-based planning. The other selects a generic function
whose result is Option of its first type parameter, with a different scalar
carrier in its second parameter. Its payload must follow the declared result,
not a fixed specialization slot.

The red hardening run passes 360 existing tests and fails both new assertions
for the expected reason in 52.820 seconds. The fix retains typed adapter IDs and
substitutes the selected function's declared result payload using its own
generic-parameter map. Both get-suffix overrides are removed. The worklist's
Option/Result hint selection now uses the same declaration adapter map.

An added Result case checks both arguments of Result<b, a>, so result-argument
position and specialization position cannot be confused. A first fix run caught
an inline-block syntax error in 13.565 seconds; the statement is now on its own
line. The expanded hardening run passes 363 tests, 108 exact records, and all
shared execution corpora in 54.414 seconds. Policy checks pass in 0.056 seconds;
generated checks pass in 3.928 seconds. Bootstrap passes in 176.501 seconds;
compiler B/C raw and linked hashes all match:
`a4a18d0530f75ac40527b82a942784f30783815dc22784c786e9c47b3a0708fa`.
The added full-body plan checks also pass: the final hardening rerun passes all
363 tests, 108 exact records, and shared corpora in 52.375 seconds. Runs above
30 seconds remain speed bugs; no speed work is included.

Runtime adapter layouts and the remaining receiver-recovery heuristics are
separate from these contracts. This does not complete the full reference ABI
or eliminate every payload recovery path.
