# Bytes-to-String conversion through a raw cast

The text library and JSON parser now declare their unchecked Bytes-to-String
conversion as `ref.cast`. The checked Dew function still validates UTF-8 before
the cast. The new `Into<String> for Bytes` implementation calls that checked
function, so it does not turn invalid bytes into a valid-looking String.

The native runtime entry and cast-body helper, self-host conversion dispatch,
and provider entry and shared rewrap helper are removed. All three text
representation conversions now use typed raw recipes. This does not complete
text storage, builder allocation/growth, or byte-access migration.

Shared tests cover a returned unchecked cast, nested Unicode byte ranges,
empty values, raw byte preservation without validation, successful checked
Into conversion, and the exact unreachable trap for invalid UTF-8 through Into.
The direct instruction test checks one cast to the concrete String heap.

The provider baseline has one intended failure out of 21 tests (7.179 seconds).
All 21 pass after removal (7.425 seconds), in provider commit `c286b7b7e`.
The targeted source baseline rejects the new Into call with NoMatchingMethod
in 0.449 seconds. Policy tests have six intended baseline failures in 0.042
seconds. The provider build passes in 11.646 seconds; consumer regeneration
takes 4.120 seconds. The full native lane passes 1,282 tests in 220.915 seconds,
and all 270 integration tests pass in 63.078 seconds. The native library lane
passes in 49.358 seconds, including all 31 Bytes cases. Self-host hardening
passes 821 tests, 414 exact failure records, and the shared corpus in 98.669
seconds. Generated checks pass in 21.053 seconds; all 15 stress tests pass in
0.370 seconds. Clean bootstrap passes in 223.598 seconds, covering both the
StringView and Bytes migrations. B/C raw and linked bytes match at SHA-256
`54b8c9ef8294a8c0587b728569851633acbee76b9d48f2dbe5a891c1c02e4e1b`.
Runs over 30 seconds remain timing defects; speed work is deferred.
