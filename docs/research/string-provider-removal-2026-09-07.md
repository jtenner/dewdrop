# Remove obsolete String provider algorithms

The native and self-host compilers already call ordinary Dew bodies for String
byte access, equality, hash, UTF-16 length, searches, affixes, and concatenation.
The pinned provider still contains 13 corresponding runtime entries. Remove
those entries and private helpers no longer used after their removal.

StringView algorithms and text storage still need separate work. Keep their
shared helpers until the owning operations are removed. Preserve the real
String and String-pattern execution corpora through provider regeneration.

## Implementation and tests

Removed all 13 runtime entries, the private concatenation builder, and four
unused String wrappers. The two remaining Bytes access entries use the same
type-specific helpers as the native backend. StringView and storage helpers
remain; the public provider API is unchanged.

The policy regression fails before removal (18 subtest failures,
0.043 seconds). The bridge regression fails before removal (15 pass,
one failure, 6.848 seconds). All five policy tests pass in 0.040 seconds.
All 16 focused bridge tests pass in 6.631 seconds. The provider change is
committed as `70224a398`. Provider rebuild takes 10.620 seconds; consumer
regeneration takes 4.070 seconds. Fresh native String compilation takes
0.458 seconds and all 13 checks pass in 0.024 seconds. The full self-host
hardening lane passes in 70.007 seconds: 325 tests, 75 exact failure records,
and all shared corpora. String passes 13 checks (0.889 seconds), String patterns
pass five (0.864 seconds), StringView passes 12 (0.891 seconds), and Bytes
passes 14 (0.879 seconds). The generated-source lane passes in 3.780 seconds.
Broad final lanes remain due after the next batches. No speed work is included.
