# BytesBuilder storage algorithms in Dew

The capacity constructor, append, byte append, and finish are ordinary Dew
functions. A private mutable struct declares the V128 array, byte length, and
consumed flag. Explicit typed reference casts retain the shared builder object.

Reserve checks consumed state and U32 length overflow before allocation or
mutation. Chunk counts use division and a remainder, not overflowing byte
rounding. Growth is geometric and caps the doubled chunk count at the maximum
needed for a U32 byte length. Core array copy preserves existing storage.

Aligned appends copy whole array elements. Unaligned appends load and write
sixteen bytes through lane swizzles and masks; exact tails use byte writes.
Writes preserve the prefix and zero padding outside their logical range.
Finish consumes all aliases and returns an immutable logical view sharing
the backing array. No compiler path selects these algorithms by source name.

The shared Bytes corpus grows from 43 to 53 cases. It includes all 256 pairs
of source and destination alignments with nine copy lengths, zero-capacity
growth, returned operation functions, argument order, consumed aliases, and
two invalid-length witnesses that must trap before touching storage.

Measured checks:

- Policy baseline: 17 assertion failures in 0.038 seconds; final three tests
  pass in 0.036 seconds.
- Existing runtime with new cases: native build 0.483 seconds, 53 execution
  checks pass in 0.031 seconds.
- Dew implementation: native build 10.017 seconds, 53 execution checks pass
  in 0.030 seconds.
- Provider: 19 tests pass and one fails before removal in 5.966 seconds;
  all 20 pass after removal in 6.788 seconds. Commit `8df505c98` removes four
  dispatcher entries and the private byte/vector copying helpers.

Initial fixture syntax and an incorrect array-length intrinsic spelling were
corrected before recording the passing native implementation. Failed builds
did not reuse stale output as pass evidence.

The provider build takes 11.051 seconds; consumer regeneration takes 4.306
seconds. Public FFI types remain unchanged; physical metadata and fingerprints
are refreshed. The full native library lane passes in 46.705 seconds.

The first self-host build fails in 41.476 seconds because Facet still declared
three old BytesBuilder builtins. Those helpers now call the ordinary library.
The policy regression detects that stale declaration before the fix; all four
policy tests pass afterward in 0.036 seconds. Final hardening passes 873 tests,
457 exact failure records, and all shared execution probes in 98.798 seconds,
including all 53 Bytes cases. Runs over 30 seconds remain timing defects.

Integration passes all 270 tests in 118.383 seconds. Generated checks pass in
21.167 seconds. Clean bootstrap passes with identical core, raw linked, and
final compiler B/C bytes. The original run stopped after preparing B's request;
its saved compiler/request were resumed without source changes. The resumed
C build, linking, validation, and three byte comparisons take 80.552 seconds.
The final linked artifact has no unresolved provider or Preview 1 imports.
Both linked outputs have SHA-256
`9453f7aab258f96b9a969111d9800dc5dfe1038a4ec2f0ae2e746fb27cebaed5`.
The routine native packages passed
at the preceding byte-access commit; they will be rerun for final combined
builder signoff. Three StringBuilder runtime entries remain open.
