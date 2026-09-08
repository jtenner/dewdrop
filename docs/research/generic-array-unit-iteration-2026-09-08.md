# Generic Array iteration and Unit payloads

A generic copy loop over `Array<Unit>` failed with `linked tuple pattern
binding has no local`. The logical Unit parameter was correctly erased, but
emission asked only the source fragment table to certify its payload storage.
The existing Option/Result adapter types live outside that table. The lookup
also omitted the caller's generic specialization when reading the child type.

The binding check now requires the specialized child to be Unit. Declared enum
fields retain their existing checked marker rule. An existing runtime adapter
must also match the selected variant declaration, the exact Unit adapter heap
type, its one-element payload, and its payload field. An arbitrary reference or
a matching source name is not enough. This does not add another runtime adapter
or remove the remaining Option/Result representation work.

The shared Array corpus adds a generic copy loop for I64, Unit, record references,
and nested arrays. Reference identity is preserved. A focused storage test starts
with a valid selected Unit pattern, then changes one heap type, field index, or
logical child type; each invalid certificate is rejected.

## Validation

- The original shared regression failed in the self-host (3.060 seconds).
- A newline before `is` in the new condition was invalid Dew syntax. The build
  rejected it (17.107 seconds); the condition now uses a named carrier value.
- Self-host hardening passes 499 tests, 169 exact records, and all shared
  execution corpora, including all 30 Array cases (79.103 seconds).
- Native library execution passes its 326 tests and all shared corpora,
  including the same 30 Array cases (32.688 seconds).
- The new one-field mutation test rejected the first check: a stale child shape
  could hide a changed logical type (499 passed, 1 failed; 93.401 seconds).
  The check now reads the logical type before specialization, without using a
  stale concrete shape as proof.
- Final hardening passes all 500 tests, 169 exact records, and all shared
  execution corpora (74.733 seconds).
- Clean bootstrap passes (294.166 seconds). Compiler B and compiler C have
  identical raw and linked SHA-256 hashes:
  `c4840ededb814f2793a0df0d35d097612d81cb0ce22766a81a20e60b6be54bea`.

The unrelated missing logical evidence in the initial freeze copying helper
remains a separate specialization issue. Reusing `Array.copy()` for freeze
witnesses did not prove generic method-target recovery correct. All runs above
30 seconds remain timing defects, outside this correctness patch.
