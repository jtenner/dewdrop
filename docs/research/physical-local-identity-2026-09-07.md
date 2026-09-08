# Physical local identity

Range checks alone do not prove that a local-table entry has the requested ID
or owner. The native boundary already checked relative IDs and body IDs, but
not lambda IDs. The self-host boundary checked local uses and table sizes,
but did not validate all three stored local identity fields.

Both physical boundaries now check relative local ID, source body, and exact
lambda owner, including Unit and elided locals. Named functions explicitly use
the missing-lambda sentinel. Native lambda emission forwards the selected
lambda ID through local planning instead of inferring it from parameter count.
The self-host planner and final verifier both pass their selected lambda ID.

ARN-106 retains full numeric context. Detail's high half uses tag 2 for a wrong
relative ID, tag 6 for a wrong body, and tag 7 for a wrong lambda. The low half
identifies the global local slot. Native phase is 7; self-host phase is 6.

Measured checks so far:

- Native red run: seven pass and one fails in 10.777 seconds. A named-body
  local with a lambda owner was wrongly accepted.
- Self-host red run: 346 pass and three fail in 75.966 seconds. The exact-record
  checker also fails. Wrong local, body, and lambda IDs were all accepted.
- Native green: all 24 body/child/list checks pass in 13.529 seconds, including
  an additional mutation of an actual lambda's owner.
- The self-host suite passes all 350 tests (0.341 seconds execution), including
  a mutation of a real lambda local. Test generation takes 33.309 seconds.
  The new lambda record initially expected its parent declaration, but the
  self-host lambda body deliberately has no declaration ID. With that exact
  expected sentinel corrected, all 99 records pass in 0.309 seconds. No compiler
  assertion was changed or weakened. All shared emission corpora also pass.
- Native API regeneration: 1.378 seconds.
- Full native lane: 1,048 tests pass in 164.456 seconds.
- Integration lane: 268 tests pass in 70.145 seconds.
- Library lane: 326 tests and all shared corpora pass in 25.204 seconds.
- Clean bootstrap: 210.146 seconds. Compiler A builds in 52.537 seconds and
  compiles B in 60.391 seconds. B compiles C in 73.333 seconds.
  B/C core and linked bytes match, SHA-256
  `78024b30d55f9a0c8fb117613b70d95c946f2b01e74bfa5596f5bffbc567abe9`.
- Generated-source checks pass in 14.337 seconds. The pinned provider is unchanged;
  its previous full 10,990-test run remains the provider checkpoint.
- All 15 stress tests pass in 0.375 seconds. Runs above 30 seconds remain
  recorded speed defects; this batch does not change their implementation.

This check does not yet prove capture-source identity or full Wasm reference
assignability. Those tasks remain open. No speed work is included.
