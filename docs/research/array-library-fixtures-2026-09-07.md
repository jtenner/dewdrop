# Array tests use library bodies

The self-host stack and iterator probes no longer declare removed `dew_array_*`
builtins. Their fixture declares typed raw storage, Array fields, and ordinary
Dew growth, access, truncation, and iteration methods. The backing type is
declared before Array, so declaration position cannot identify Array.

The size-method probe constructs its declared empty struct. The link test checks
an ordinary specialized capacity constructor instead of the removed runtime
builder. A source-policy test prevents these fixtures from restoring old aliases.

The updated stack probe exposed a missing raw `unreachable` instruction in both
emitters. The [Never instruction change](never-raw-instruction-2026-09-07.md)
fixes that boundary before this fixture migration.

This is test migration, not completion of Array literal planning. The fixture
still has the three fields expected by the old literal recipe. That recipe and
the remaining unused Array fallback code must still be removed.

Measured checks: Array source policy 10 passed (0.063 seconds); self-host
hardening 238 tests, 29 failure records, and all shared probes passed (58.856
seconds); generated checks passed (15.777 seconds). The first fixture run
exposed the missing raw opcode instead of silently selecting an old runtime.
The hardening duration remains a performance bug.
