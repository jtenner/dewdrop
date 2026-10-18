# Decimal integer parsing

`dew.std.text` now provides `parse_u32_decimal` and `parse_i32_decimal` over
StringView. Both return Result. They accept ASCII digits and leading zeros.
I32 also accepts one leading minus, including `-0` and the exact signed minimum.
A minus without digits is `InvalidDigit(0)`. Empty input is `Empty`.
Whitespace, plus, separators, fractions, exponents, and non-ASCII digits fail.

Errors report the first invalid or overflowing digit's byte offset relative to
the view. Range checks run before multiplication/addition. Parsing is one pass,
with fixed scalar scratch state and no substring or temporary buffer. Results
use the normal Result representation; this is not a zero-allocation claim.
JSON number lexemes and SemVer's separate leading-zero rule are unchanged.

The tests initially failed with missing-function diagnostics and no parse errors
(0.243 s). The first implemented module built in 0.279 s and all three imported
tests passed under Node. Tests cover integer extrema, one-past overflow, negative
zero, nonzero view starts, leading zeros, view-relative errors, and rejected
syntax. They are in `std/tests/decimal_parse_test.dew` and run in the normal
standard-library lane. Bootstrap text-source parity is checked by
`tools/generate_text_iteration_std.py --check`.

No before/after speed gain is claimed. The API replaces user-written digit
loops; it does not replace existing SemVer scanning or alter exact JSON values.
