# BytesBuilder default capacity in Dew

The default constructor is now an ordinary Dew function that calls the
explicit-capacity constructor with 64 bytes. This preserves the previous
four V128 chunks. The native and provider default dispatch entries are gone;
capacity allocation, growth, and finish still need separate migrations.

The shared corpus returns the constructor as a function value, checks an
empty finish, retains an alias, and grows to 129 bytes. It checks values on
both sides of the initial 64-byte boundary. This does not expose capacity as
logical length.

Policy baseline: four intended failures (0.033 seconds). Provider baseline:
20 tests pass and one fails as intended (5.955 seconds). All 21 provider tests
pass after removal (6.018 seconds). Provider commit `3611ea074` builds in
9.454 seconds; consumer refresh retains the selected signatures (3.973 seconds).
The native library lane passes all 28 Bytes checks in 44.212 seconds.

Self-host hardening passes 801 tests, 401 exact records, and all shared checks
in 87.672 seconds with the existing debug native profile. Generated checks
pass in 18.073 seconds. The matching StringBuilder default change also passes
both shared execution lanes; clean bootstrap is due with the next call-index batch.
Runs over 30 seconds remain timing defects; speed work is not part of this
change.
