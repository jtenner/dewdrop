# StringBuilder length and lifetime checks in Dew

StringBuilder now checks consumed state in Dew, then reads its logical byte
length. The two raw `struct.get` declarations retain StringBuilder heap
identity. The native and provider dispatch entries are removed, as is the
shared private length builder now that BytesBuilder no longer uses it.

The shared String corpus checks six UTF-8 bytes for `λ😀`, live aliases,
direct/aliased use after finish, and a returned length function. This is a
byte count, not a character or UTF-16 count. Append, growth, finish, and other
storage algorithms remain open.

Provider red: 20 tests pass and one fails as intended (5.936 seconds).
All 21 provider tests pass after removal (6.064 seconds); policy checks have
four intended baseline failures and pass after migration (0.032 seconds each).
Provider commit `ba8863c6f` builds in 9.467 seconds; consumer refresh takes
3.878 seconds and retains all 476 selected signature checks.

The first library run stops with a real native import bug (33.333 seconds),
not a builder trap: private StringBuilder helpers shift exported positions,
and the BytesBuilder returned function receives another callable's type.
The independent [import identity fix](imported-callable-identity-2026-09-09.md)
addresses both native import paths. The corrected library lane passes in
37.191 seconds, including all 23 String and 26 Bytes checks. Self-host hardening
passes 801 tests, 401 exact records, and the shared corpora in 94.293 seconds
with the existing debug native profile. Generated checks pass in 18.131 seconds.

Clean bootstrap passes in 175.134 seconds. Both raw and linked B/C outputs
have SHA-256 `673b3336fd4527ff80352e07dab12dd025adff65876d1c98ee04b1e8b2f74762`.
This also covers the preceding BytesBuilder length change and native import
identity fix. Runs over 30 seconds remain timing defects, not speed work in
this patch.
