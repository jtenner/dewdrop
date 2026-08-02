# Text runtime edge-case hardening

## Status

Implemented as a test-only stabilization milestone after shared ranges, builders,
flat concatenation, byte search, and substring search. No public runtime API was
added during this work.

## Deterministic matrix

`tools/utf-parity/generate_cases.py` now generates and Node executes coverage
for:

- all 256 byte values at every physical start alignment `0..15`;
- substring needle lengths `0, 1, 2, 3, 7, 8, 15, 16, 17, 18, 31, 32, 33,
  63, 64, 65`;
- match positions `0, 1, 15, 16, 17, 31, 32, 63` at every start alignment;
- an absent case for every alignment and needle length;
- Bytes range lengths `0, 1, 15, 16, 17, 31, 32, 33, 63, 64, 65` for shared
  view/subarray and exact slice/compact operations;
- String range lengths at the same boundaries for subarray, slice, and compact;
- flat concatenation for every pair of lengths around the 16- and 32-byte
  boundaries over sixteen independently varied alignment pairs;
- StringBuilder and BytesBuilder capacity/length matrices around every V128
  growth boundary;
- invalid interior UTF-8 range boundaries for two-, three-, and four-byte
  scalars at every backing alignment;
- String/String, String/StringView, StringView/StringView, and StringView/String matching for short and long Unicode needles at positions `0, 1, 15, 16, 17, 31, 32, 63` across all alignments;
- existing random arbitrary-byte, random Unicode, equality, conversion, view,
  nested-view, builder, concat, and search cases.

The current deterministic parity result is:

```text
UTF parity passed: 17,471 checks
```

## Deliberate rolling-hash collision

Long `Bytes.find` uses a base-257 rolling U64 fingerprint but verifies every
fingerprint hit exactly. The test suite constructs a collision rather than
waiting for one randomly.

The base-257 digits of `2^64` are:

```text
F9 1B C9 45 C9 1B F9 01
```

Therefore these equal-length suffixes hash identically modulo `2^64`:

```text
F9 1B C9 45 C9 1B F9 01
00 00 00 00 00 00 00 00
```

The generated and direct Dew tests prepend the same nine-byte prefix, place the
false colliding window first, and place the true needle at logical byte 18.
`find` must reject the collision through exact verification and return 18.

## Logical-tail protection

Direct tests verify that zero-padded physical V128 tails are never observable
through:

- `find_byte(0)`;
- one-byte and multi-byte `find`/`contains`;
- suffix matching;
- candidates that would cross the logical end.

Short-needle tests separately exercise candidate lanes 15 and 16, covering the
transition between one SIMD candidate mask and the next batch.

## Builder consumption traps

`tools/dew-test/builtin_traps.dew` now checks every consuming-builder family
after `finish()`:

- byte length;
- String, StringView, ASCII, scalar, and checked-Bytes append;
- arbitrary Bytes and individual-byte append;
- repeated finish;
- use through a distinct alias.

Every public export in that artifact is required to trap, so adding a new trap
probe does not require maintaining a fragile runner allowlist.

## Large stress cases

The generated parity module includes:

- present and absent long-needle search over a 65,536-byte haystack;
- 4,096-byte BytesBuilder publication from two fragments;
- 4,096-byte StringBuilder publication from two valid ASCII fragments.

These cases exercise iterative validation, lowering, encoding, and runtime
execution without recursive host-side or Dew-side traversals.

## Aggregate ABI regression

Backend tests cover nominal enum and struct results joined through `if`
expressions. Body control flow may use the common eqref carrier, but final module
and linked-program function results must be cast to their frozen non-null nominal
reference type before Starshine validation.

## Policy

The hardening suite is deterministic and diagnostic rather than performance
fail-closed. Runtime benchmarks continue to report absolute and relative costs,
but machine-dependent timing thresholds do not fail correctness suites.
