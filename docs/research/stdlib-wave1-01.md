# Wave 1 item 01: wide decimal parsing

Base: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Test checkpoint: three new tests mirror the narrow parser contract for U64/I64.
They require APIs absent at this checkpoint (expected red; not yet run).
ASCII digits only; unsigned has no sign; signed permits only a leading minus.
Empty input is Empty; a lone minus is InvalidDigit(0). Negative zero is zero.
Overflow and invalid-digit offsets are bytes relative to the view, at the first
failing digit. No whitespace, plus, separator, exponent or fraction is accepted.
Implementation and measured gates follow in the next checkpoint.
