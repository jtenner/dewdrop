# Remove obsolete StringView provider algorithms

The library already implements StringView access, conversion, UTF-16 length,
equality, hash, searches, and affixes in Dew. The provider still has 12 old
runtime entries. Their removal makes the remaining shared scan/search/hash
builders unused after the Bytes and String provider removals.

Remove only unused algorithm builders and their owned comments. Retain exact
storage/view construction, unchecked representation casts, builder operations,
and the SIMD storage bridge for their separate migration. Check all text
corpora and the full pinned provider after this last algorithm-removal batch.

## Implementation and tests

Removed all 12 StringView algorithm entries and eight unused shared text
builders/helpers, including their owned comments. The remaining provider
surface is storage, view construction, builder operations, SIMD storage access,
Debug output, and transport. Its public interface is unchanged.

The policy regression fails before removal (20 subtest failures,
0.037 seconds). The bridge regression fails before removal (16 pass,
one failure, 6.649 seconds). All four policy tests pass in 0.034 seconds.
All 17 focused bridge tests pass in 6.691 seconds.

## Verification

- Provider build passed; its elapsed-time output was lost when the session
  ended. The complete build log reports 4,188 exports and zero errors.
- Consumer regeneration: 4.069 seconds. All 469 selected signatures agree.
- Self-host hardening: 70.810 seconds; 325 tests, 75 exact invariant records,
  typed FFI smoke, and all shared execution corpora pass. StringView has 12
  checks, taking 0.902 seconds in this run.
- Fresh native StringView compile: 0.418 seconds; all 12 execution checks pass
  in 0.024 seconds.
- Generated-file and policy checks: 3.773 seconds, passing.
- Full pinned Starshine suite: all 10,990 tests pass in 256.752 seconds. Its
  expected invalid-module diagnostic is from a negative test, not a failure.

The parent pins provider commit `312d8a308`. No speed work is included. Slow
test lanes remain recorded defects. Full native/integration/stress and clean
bootstrap lanes will be rerun after the next compiler correctness batch; this
provider-only change does not claim those additional runs.
