# Nominal payload names do not select physical layout

Nominal payload heap selection now uses only the selected declaration and
its declared struct/enum fragment. The spelling exclusions for String,
StringView, Bytes, Array, and Map are removed. Raw-array owners still require
their explicit raw-storage contract rather than a nominal struct layout.

The new Map test passed even before removal: the old spelling check used a
callable-name lookup on a nominal type declaration, which returned an empty
name in this valid fixture. This was stale policy code, not a demonstrated
runtime failure. The baseline run passed 766 tests in 59.593 seconds.

The focused test checks the exact declared heap and frozen payload cast for
a user-defined Map. Shared callbacks now also store and read user-defined
Map and generic Array payloads at six 64-bit boundary values. A policy test
prevents restoring spelling checks in nominal payload heap selection.

Other container-element shape heuristics, including the separate Map suffix
test, remain open; this change does not claim to remove them. Compiler lanes
are timed, and durations above 30 seconds remain timing bugs.

Validation passed: 766 hardening tests, 376 complete error records, all shared
source checks, and 264 callback boundary checks (59.399 seconds). Native
stdlib checks passed (26.575 seconds); generated checks passed (4.107 seconds).
Clean bootstrap passed (171.607 seconds), with identical B/C raw and linked
SHA-256: `08636befdfdd6302ca0dd323abc2300d39f1d857b1b894cd70665d1b5e415ce3`.
