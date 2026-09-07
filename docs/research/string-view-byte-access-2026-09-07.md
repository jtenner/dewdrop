# StringView access and conversion in Dew

StringView byte length and byte access now call the shared Bytes path. Conversion
to String uses the existing explicit reference casts: the view already contains
a checked UTF-8 range. It does not copy bytes or allocate a replacement wrapper.
The native rewrap builder and three runtime dispatch entries are removed.

Ordering and code-point iteration use ordinary StringView methods. The self-host
physical fixtures also use a real library helper with explicit public visibility
for cross-module calls, rather than the deleted access builtin. Their planned
body counts include that helper.

View construction and shared Bytes storage still need migration. This step does
not change their bounds checks or physical layout.

## Validation

- The expanded source policy fails before removal and all three tests pass
  afterward. Failure output identifies the path and operation, not full sources.
  The measured times are 0.036 and 0.038 seconds.
- Native stdlib 326 and all shared runtime checks pass (28.270 seconds).
- Self-host hardening passes 237 tests, 29 numeric failure records, and all
  shared runtime checks (58.607 seconds, still a performance bug).
- StringView has 12 shared checks. New cases verify byte offsets and conversion
  on a nested Unicode range, empty conversion, and exact unreachable traps for
  the end index, maximum U32 index, and an empty logical range.
- All 268 integration tests pass (66.758 seconds, a performance bug).
- Generated checks pass (15.861 seconds).
- Clean bootstrap passes (164.509 seconds). Compiler B/C raw and linked bytes
  match, SHA-256
  `b9989785ec338c991186ec360f07a5f119e255e09ccbcb05c0bc6b34ebd4e597`.
  Compiler A build takes 39.165 seconds; A and B compilation takes 43.529 and
  57.540 seconds. These remain performance bugs.
