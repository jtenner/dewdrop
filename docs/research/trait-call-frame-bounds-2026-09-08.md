# Trait arguments belong to the emitted caller frame

A saved operand recipe proves which indices were selected, but does not prove
that those indices belong to the emitted function's parameters. A focused
test starts from a valid relay with four parameters and a recipe using slots
2 and 3. Shortening only its frame descriptor to two parameters was accepted
by the old reader (one pass, one expected-record failure; 8.816 seconds).

Expression emission now receives an explicit parameter descriptor from the
function being emitted. It borrows the exact parameter type arena and span.
Named functions use their linked fragment; lambdas use their own selected
fragment, including the environment/direct-capture prefix and Unit erasure.
Initializers have an empty parameter frame. This does not infer a lambda's
frame from its enclosing root body's parameters.

After checking the frozen recipe, emission validates the caller parameter
span with subtraction-based bounds and checks each forwarded operand against
the caller's parameter count. Invalid spans produce ARN-101; out-of-range
operands produce ABI-704 with the operand ordinal. Records include phase 7,
caller module/body/expression, target declaration, expected bound, and actual
index. The first corrected run passes both tests in 8.672 seconds.

Expanded tests cover the first and second operands, an empty frame, negative
start/length, a near-limit start, an oversized span, and a replaced type arena.
All four focused tests pass in 9.126 seconds. The serial full checks pass:

- Native: 1,140 tests, 153.207 seconds.
- Integration: 268 tests, 57.188 seconds.
- Library: 326 tests and all shared execution corpora, 31.855 seconds.
- Self-host hardening: 450 tests, 137 exact records, 143.848 seconds.
- Clean bootstrap: 169.395 seconds; B/C core and linked bytes match at
  `577075c3e5f27f53387b4e3ed1125ae019963c47c9ff487a8eba4630196d0ec8`.
- Generated checks: 11.345 seconds; stress: 15 tests, 0.345 seconds.

No public API or codec changes are needed. The provider and generated FFI are
unchanged. Runs above 30 seconds remain speed bugs; no speed work is included.

This is an index/ownership-boundary check, not full type assignability or
logical trait-source verification. The borrowed physical types are available
for those later checks. Runtime dictionary capture for escaping lambdas is
still separate work; this change does not add such capture.
