# Reference field writes from raw storage

The Map growth probe loads an Option entry from raw storage and assigns it to
an entry's next field. Raw reference storage yields eqref, while the declared
field requires the linked Option heap type. Native field assignment omitted
the storage adapter that constructors already use.

Field selection now retains the owning physical type and storage certificate.
Assignment applies the same declared-storage cast as construction, after the
source value and before struct.set. The source and receiver are not repeated.
The rule applies to user structs, not Map names or standard module IDs.

Checks:

- Minimal native emitted-byte regression: red 9.341 seconds, green 9.285 seconds.
- Native ordinary Map candidate: eight execution checks pass (0.028 seconds),
  including collision growth, Unit, tuples, live entry aliases and exact traps.
- Native stdlib and shared cases pass (12.382 seconds).
- Self-host hardening and shared cases pass (57.303 seconds), including the new
  raw-storage reference field assignment. The full lane exceeds 30 seconds and
  remains a performance bug.

This fix does not complete full reference assignability or frozen-plan checks.
Those remain explicit work in agent-todo.md.
