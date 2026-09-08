# Remove obsolete Bytes provider algorithms

The native compiler already calls ordinary Dew implementations for Bytes
equality, hash, find, affixes, concatenation, UTF-8 validation, and checked
String conversion. The pinned provider still accepts the nine corresponding
`dew_bytes_*` operations. Remove that fallback surface in a Bytes-only commit;
shared code still used by String and StringView must remain for their own
removal.

The provider's UTF-8-validator function-index argument is used only by the old
checked Bytes-to-String builder. Remove it with that builder and regenerate
the provider constructor and Dew consumer together. Storage operations and
explicit unchecked representation casts are separate remaining work.

## Implementation and tests

Removed all nine runtime dispatch entries. Removed the private UTF-8 validator,
checked String conversion, byte-search builder, and four now-unused validator
helpers. Shared String/StringView helpers remain. The provider constructor
now takes two arguments, text type base and write-function index. Its public
interface, generated wrapper, and Dew call are updated together.

The policy test fails before removal (14 subtest failures, 0.036 seconds).
The bridge boundary regression fails before removal (14 pass, one failure,
6.744 seconds). Public interface refresh takes 0.966 seconds; FFI wrapper
generation takes 4.077 seconds. Three Bytes policy tests pass in 0.040 seconds;
three Map policy tests pass in 0.042 seconds.
All 15 focused bridge tests pass in 6.805 seconds.
The provider change is committed as `2c488cd1b`, including removal of orphaned
comments that described deleted functions. Initial provider rebuild takes
10.718 seconds; consumer regeneration takes 4.049 seconds. All 469 selected
signatures remain checked against the two-argument constructor. Provider SHA-256:
`c7d358f1d01f3571d66541d0d3974c09d8bc228e7989f581231a574777a0972c`.
The full self-host hardening lane passes in 70.341 seconds: 325 tests, 75 exact
failure records, and all shared execution corpora. Bytes has 14 passing checks
(0.894 seconds), StringView has 12 (0.890 seconds), and String has 13
(0.895 seconds). Removing the orphaned comments and rebuilding the provider
(10.642 seconds) leaves its Wasm bytes identical to that tested provider hash.
The consumer is regenerated against the final commit in 4.159 seconds.
Fresh native Bytes compilation takes 0.433 seconds; all 14 checks pass in
0.024 seconds. The generated-source lane passes in 3.704 seconds. Broad final
lanes remain due after the next batches. No speed work is included.
