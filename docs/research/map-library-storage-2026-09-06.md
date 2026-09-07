# Map storage and algorithms in Dew

`Map<K, V>` owns a typed raw array of optional entries and a count. Each entry
stores its cached U64 hash, key, value, and next entry. All allocation, hashing,
collision checks, growth, lookup, insertion, removal, clearing, and iteration
are ordinary functions in `std/map.dew`. There are no Map runtime builtins.

Buckets start at 16 and double with an overflow check. Growth reuses entries and
their cached hashes. It does not call user hash or equality functions. An insert
hashes the key once; equality runs only after a matching cached hash. Replacement
keeps entry identity. Clear keeps Map identity and replaces its bucket array.
Removal unlinks the selected entry without changing unrelated entries.

Map asks `implements<K, Hash>()` and calls the selected trait methods in the
retained branch. A missing implementation reports the library's CT-021 static
assertion. Associated type evidence and full guarded-call signature checks use
the same rules for user libraries. Unit values keep their source effects and
logical entries; their payloads do not require scalar Wasm operands.

Native Map operation IR, special inference selection, layout overrides, index
lowering, and runtime emitters are removed. Self-host Map emission tasks,
runtime builders, scratch-local rules, and name-based call replacement are also
removed. Remaining generic carrier-recovery heuristics in the self-host emitter
are part of the separate compiler audit; this migration does not certify them.
Set still uses the legacy shared hash-table helpers until its own migration.

The shared 12-case corpus runs the real Map module in both compilers. It covers
collisions and growth, head/middle/tail removal, replacement, missing keys,
Unit and tuple values, alias-preserving clear, live entry aliases, exhausted
iterators, String/Bytes content equality, hash-call counts, references, both
float types, and iteration after growth. Unchecked missing-key reads must trap
with Wasm `unreachable`, not an arbitrary host failure.

The execution fixture loader now preserves each probe's real `.dew` filename.
It previously renamed probes to `_test.dew`, which marked their private trait
implementations test-only and made them unavailable to production library calls.
The obsolete self-host Map-builtin mock is replaced by the shared real-source
String-key check.

Map's three iterator types also expose ordinary `has_next` methods. Repeated
checks do not consume an entry. This lets Set compose the public iterator
interface without copying Map's bucket layout or adding a second peek cache.

| Check | Result | Seconds |
| --- | --- | ---: |
| Full native | 931 passed | 115.753 |
| Full integration | 266 passed | 48.139 |
| Final stdlib and shared execution | 325 stdlib tests and all shared checks passed | 21.710 |
| Final self-host hardening | 230 tests, 29 invariant records, and all shared checks passed | 53.457 |
| Self-host real Map compilation/execution | 12 passed | 1.430 |
| Final generated checks | passed | 10.463 |
| Clean A/B/C bootstrap | identical B/C output | 174.787 |

The full native, integration, hardening, and bootstrap runs exceed 30 seconds
and remain performance bugs. The semantic native package alone took 74.036
seconds. Bootstrap A build took 46.086 seconds; A and B compilation runs took
45.231 and 58.875 seconds. Speed work follows the remaining correctness work.

B/C linked SHA-256:
`82c9c90a96fb40f7968f0d04cdc27c19b48ce939f8842e8ec7ae2d180c9cd598`.
