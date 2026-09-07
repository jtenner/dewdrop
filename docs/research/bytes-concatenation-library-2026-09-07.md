# Bytes concatenation in Dew

Concatenation now checks the two lengths in Dew, rejects U32 addition overflow
before allocation, and uses one pre-sized BytesBuilder. It appends each source
range in order and finishes the builder. Empty input cases return the other
immutable range without allocation. Source bytes and ranges are unchanged.

The native concatenation builder and runtime dispatch are removed. Shared copy
helpers remain because the builder storage operations still use them. Moving
builder storage into Dew remains a separate task; this change adds no new
builtin or hidden compiler operation.

## Validation

- The policy test fails before removal; both policy tests pass afterward
  (0.035 seconds).
- Native stdlib 326 and all shared runtime checks pass (28.720 seconds).
- Self-host hardening passes 237 tests, 29 numeric failure records, and all
  shared runtime checks (58.781 seconds, still a performance bug).
- Bytes has 14 shared checks. Concatenation tests cover empty inputs, NUL and
  invalid UTF-8 bytes, unchanged inputs, logical view offsets, and every vector
  alignment on both source ranges.
- All 268 integration tests pass (67.147 seconds, a performance bug).
- Generated checks pass (15.714 seconds).
- Clean bootstrap passes (162.174 seconds, a performance bug). Compiler B/C
  raw and linked bytes match, SHA-256
  `ef89107d451b9a566e3aa4b176ded2cdf2719df224a93982835c5e902a7e6230`.
- All 15 compiler stress tests pass (0.115 seconds, warm run).
