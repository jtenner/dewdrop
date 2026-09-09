# Bytes length uses a raw field read

The canonical preamble Bytes length declaration now uses `struct.get 2`.
Ordering and the self-host Facet layer use ordinary Dew calls to that shared
operation. Both runtime builders remove `dew_bytes_byte_length` and its unused
private function builder. This is an owner-checked primitive heap field read,
not a source-name or standard-module ordinal selection.

The policy baseline has six intended failures (0.032 seconds). The provider
boundary test has one intended failure out of 21 (5.957 seconds). All 21
provider tests pass after removal (6.016 seconds). Provider commit `3d0f06908`
rebuilds in 9.467 seconds; consumer refresh takes 3.906 seconds. All 476
selected signatures remain checked and unchanged. Provider SHA-256:
`f17084bb61cc1927d94637721e90f6867c682c22e20c78d4fdb89df296b1abc1`.

Initial hardening passes in 152.716 seconds. The final library lane passes in
43.212 seconds. The Bytes corpus now has 22 shared cases, including an explicit
empty/spare-capacity/nested-view length case. Final self-host hardening passes
all 801 tests, 401 exact numeric records, and shared corpora (60.118 seconds).
Generated checks pass in 17.666 seconds with no source edits during the lane.

Clean A/B/C bootstrap passes in 170.767 seconds. B/C raw and linked bytes match:
`a74371a8b81f6f5a456f8e30450e693150ae9ab126d6ca26f70a712f4c91610c`.
This also verifies the preceding raw struct-get implementation. Runs above
30 seconds remain timing bugs, not hidden test skips. Builder length, byte
access, views, conversions, and other text storage operations remain open.
