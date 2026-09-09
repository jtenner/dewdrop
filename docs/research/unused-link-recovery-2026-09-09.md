# Remove unused linker recovery

Removed 46 private functions from the self-host linker and body planner.
Before removal, each name occurred only at its definition across the Dew
compiler, native sources, and JavaScript/Python tools. No public entry point
was removed. The list is retained in
`tools/test_removed_link_recovery_policy.py`.

The removed code included source-name recovery for collection operations,
unused carrier-based target selection, and an eight-step local lookup that
treated a consumed expression as its previous arena entry. These routines had
no callers; this change removes stale code, not a demonstrated runtime fault.
Still-used recovery paths remain separate open tasks.

The policy test failed against the old definitions (three source files,
0.070 seconds). It now guards against restoring any of the removed helpers.
Validation: hardening passed 766 tests, 376 numeric records, and all shared
execution checks (59.245 seconds); Dew library checks passed (26.710 seconds);
generated-source and policy checks passed. The hardening lane exceeds the
30-second budget and remains a timing bug; no speed work was included.
A clean bootstrap will cover this cleanup with the next related boundary fix.
