# StringView-to-Bytes conversion through a raw cast

StringView now uses a typed `ref.cast` for its Bytes representation. Existing
methods keep their Dew forwarding bodies, and `Into<Bytes> for StringView`
uses the same conversion. The native runtime, self-host runtime, and provider
no longer accept `dew_string_view_as_bytes`. The self-host runtime's remaining
cast compatibility path now has only the Bytes-to-String target.

Shared cases cover a returned cast function, nested Unicode ranges, empty
input, source preservation, and the new Into call. The native instruction test
uses the same checked source-declaration helper as String and requires exactly
one non-null cast to the Bytes heap. Four self-host specialization fixtures now
declare the raw operation instead of the removed runtime operation.

The provider baseline has one intended failure out of 21 tests (7.356 seconds).
The shared library baseline rejects the new Into method in 21.343 seconds.
Policy checks have five intended baseline failures (0.043 seconds) and pass
after removal. All 21 provider tests pass in 7.697 seconds. Provider commit
`18afda8e8` builds in 11.566 seconds; consumer regeneration takes 4.147 seconds.

The shared native test helper initially lacked its error declaration; native
checking exposed that test-only issue in 15.014 seconds. After correction,
all 40 raw tests pass in 48.946 seconds. The native library lane passes in
49.307 seconds, including 14 StringView cases. Self-host hardening passes 821
tests, 414 exact failure records, and all shared cases in 100.455 seconds.
Generated checks pass in 21.513 seconds. The following Bytes-to-String batch
also passes clean bootstrap in 223.598 seconds with matching B/C raw and linked
bytes; see the [Bytes conversion log](bytes-string-cast-library-2026-09-09.md).
Runs over 30 seconds remain timing defects; speed work is deferred.
