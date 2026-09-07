# Readable FFI carrier identity

Date: 2026-09-07

The pinned Starshine provider has 4,191 exports; the consumer selects 472.
Generated declarations already use stable names with checked heap identity.
The remaining numbered Dew reference was the smoke test's `StarshineRef0`.
It now uses `StarshineValue`, as proved by the instruction constructor signature.
`ffi_lib_I32_new` remains `(I32) -> I32`.

The audit found that a named constructor alias could erase result nullability.
Generation now preserves `NullableRef<Alias>`. Identity proofs reject empty
probe lists, negative probe indices, conflicting aliases, duplicate export
names, and heap indices outside U32. Source validation rejects numbered carrier
names in both compiler and FFI Dew files with file/line context.

Validation:

- Generator tests: 17 pass, 0.044 seconds. New tests first exposed six failures
  and one error in the old validation behavior.
- Pinned provider regeneration check: all four artifacts current, 4.016 seconds.
  Provider revision: `7a58886305102c0575949cefc790a3678c0be292`.
  Provider SHA-256:
  `3f4879ffd673222b37f0f0c7570bfc9b6f312c8e8355c63f5bb1343ef46e1ebb`.
- Standalone Dew FFI smoke compilation: 0.137 seconds.
- Hardening: 257 tests, 42 exact failure records, all shared checks, and the
  linked typed FFI smoke pass. Test generation: 7.147 seconds; link: 5.157;
  emission probes: 18.938. The aggregate lane still exceeds 30 seconds and
  remains a performance bug.

The hardening lane compiles and runs the actual smoke against the pinned
provider. This checks more than spelling: the scalar input and named reference
result must link and execute. Synthetic tests also check heap renumbering and
signature disagreement. No generated artifact or provider source was changed.
