# Wave 1 item 05: hex bytes

Base: 8c3b047fe633aa11c6634b929045376e9dfc7d6c.
Test checkpoint: five new tests specify empty input, case, offsets, odd length,
all bytes, size limits, views, and SHA-256 text. Not run at this checkpoint.

Contract: encode(Bytes) -> Bytes emits lower-case ASCII. Decode accepts both
ASCII cases. Odd length takes precedence. InvalidByte offsets are zero-based
and relative to the input view. No whitespace or prefixes are allowed.
encoded_length(U32) -> Option<U32> checks doubling before allocation;
encode traps on overflow. Decode halves an even U32 length without overflow.
