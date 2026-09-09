# StringBuilder default capacity in Dew

StringBuilder now requests its 64-byte starting capacity in an ordinary Dew
function. The native and provider default runtime entries and the allocator's
unused default-mode branch are removed. The explicit-capacity allocator remains;
this is not yet a complete storage migration.

The shared corpus returns the constructor as a function value, checks an empty
finish, retains an alias, and grows with repeated `λ😀` text. It checks 390
UTF-8 bytes and 195 UTF-16 code units, rather than confusing the two lengths.

The provider baseline has one intended failure out of 21 tests (5.944 seconds).
All 21 pass after removal (6.000 seconds). Provider commit `e4f42f7e8` builds in
10.006 seconds; consumer refresh takes 4.119 seconds. Core FFI signatures are
unchanged. The native library lane passes all 25 String and 28 Bytes checks
in 46.457 seconds. Self-host hardening passes 801 tests, 401 exact records,
and the shared corpora in 93.013 seconds; generated checks pass in 18.928
seconds. The later call-index batch passes clean bootstrap in 182.686 seconds,
with identical raw and linked B/C bytes; see its
[validation log](linked-call-index-contracts-2026-09-09.md). Runs over 30 seconds
remain timing defects, with speed work deferred.
