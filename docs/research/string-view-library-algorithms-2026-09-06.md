# StringView library algorithms

StringView equality, hashing, searches, affixes, and UTF-16 length now have Dew
bodies. Scans reuse the Bytes algorithms; mixed String/View operations keep the
same byte offsets. Native runtime dispatch for those nine operations is removed.

The UTF-16 counter processes complete SIMD chunks and a scalar tail. For valid
UTF-8, the result is byte length minus continuation bytes plus four-byte lead
bytes. The new `wasm_u32_popcnt` builtin maps to exactly `i32.popcnt` in both
compilers. Its signature rejects a wrong input or result carrier. The typed
Starshine consumer adds that instruction export without changing the provider.

StringView-to-Bytes uses an explicit unsafe reference cast under an ordinary
library wrapper. It emits one `ref.cast`, not a new wrapper allocation. This is
valid for the current identical immutable text record structures; it does not
permit casts between arbitrary records. The old native rewrap helper remains
only for text conversions that have not yet moved.

## Equality defect found by the shared tests

The self-host compiler's primitive fallback excluded five numeric type ranks,
but forgot StringView and both builder types. It treated StringView `==` as
reference identity, even though `.equals()` correctly called the Dew body.
Two different views of equal bytes therefore compared unequal.

The fallback now positively selects its numeric/vector primitive kinds.
Reference primitives go through normal trait selection. Tests check that
StringView equality retains a `PlannedOperatorCall`, and that a missing builder
equality implementation reports `NoMatchingOperator` instead of emitting
`ref.eq`. Remaining scalar/vector operator fallback policy is a separate audit
task; this change does not claim to remove it.

The eight shared execution cases passed against the old native implementation
before migration. They cover empty values, all byte alignments, Unicode,
different backing offsets, short and long search, mixed affixes, nested views,
and stable hashes. Equality failures identify the exact comparison that failed.

StringView bounds, storage access, view construction, and final String wrapping
still require the complete text storage migration. The pinned provider's dead
legacy builders also remain to be removed with that work.

| Check | Result | Seconds |
| --- | --- | ---: |
| Native baseline before migration | 8 shared view cases passed | 13.343 |
| Native text integration and cast checks | 19 passed | 13.451 |
| Final stdlib and shared native execution | 326 tests and all shared checks passed | 13.124 |
| Self-host hardening | 234 tests, 29 invariant records, all shared checks passed | 54.184 |
| Generated checks | passed | 15.195 |
| Clean A/B/C bootstrap | identical B/C bytes | 160.756 |

The hardening and bootstrap times remain performance bugs. Compiler A build
took 39.037 seconds; A and B compilation took 42.713 and 55.126 seconds. B/C
SHA-256 is `26cc2195171bac785550ef661056b18a1fc0fe23362c392d369c9ef73dc89530`.
