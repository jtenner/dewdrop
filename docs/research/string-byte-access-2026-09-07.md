# String byte access uses Dew calls

String byte length and byte access now use the ordinary Bytes library path
through the explicit String-to-Bytes reference cast. Text iteration, ordering,
and the compiler's Facet adapter use String methods rather than redeclaring
opaque builtins.

The self-host emitter no longer selects a primitive text runtime from a method
name and argument count. String methods must keep their selected declaration.
Both compiler runtime dispatch tables no longer list the two String access
builtins. The unused native String/Bytes boolean dispatch wrappers are removed.

This is not yet the Bytes storage migration: the shared Bytes access operations
still need their storage representation expressed through checked intrinsics.

## Validation

- The source-policy test failed on the old builtin declarations and shortcut
  (0.047 seconds). All four policy tests pass after removal (0.040 seconds).
- All 326 native stdlib tests and shared runtime checks pass (29.079 seconds).
  String now has 13 shared checks. New checks cover logical Unicode byte
  offsets, the exact end index, the maximum U32 index, and an empty String.
  Negative cases require the expected Wasm unreachable trap.
- Self-host hardening passes 237 tests, 29 numeric failure records, and all
  shared runtime checks, including 13 String checks (66.821 seconds).
- Generated checks pass (16.030 seconds).
- The first full integration run exposed a transitive import-loading defect in
  the tree test. The [dependency closure fix](standard-source-dependency-closure-2026-09-07.md)
  follows actual library imports; all 268 integration tests now pass (49.227
  seconds).
- Clean bootstrap passes (168.137 seconds). Compiler B and C raw and linked
  bytes match, SHA-256
  `88b4360a7e6982f0e5cc799467ef04e178bd1e35b2eb981632c1e1d7fa28d33b`.
  Compiler A build takes 43.655 seconds; A and B compilation takes 44.027 and
  55.966 seconds. Slow stages remain performance bugs.
- The full native semantic run passed 502 tests and exposed one stale test
  using a hard-coded runtime declaration ordinal (70.714 seconds). That test
  now obtains the selected cast declaration from collection by name, then checks
  reachability using its actual ID. No compiler ordinal fallback was added.
- The corrected test passes (9.045 seconds). All 942 routine native tests
  pass across the serialized runs. Backend 93, loader 19, and driver 2 tests
  pass in 29.868, 1.532, and 8.437 seconds. Final generated checks pass
  (10.508 seconds).
