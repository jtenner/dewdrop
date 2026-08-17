# Self-hosting UTF-8 standard module — August 17, 2026

## Finding

The self-hosting library audit missed an explicit UTF-8 codec package. The
production compiler has 61 direct calls to MoonBit's UTF-8 package in the
compiler scope:

- 39 `encode` calls;
- 17 `decode_lossy` calls;
- 5 strict `decode` calls.

The calls appear in parser artifacts, semantic identities and diagnostics,
backend import/export names, cache codecs, the standard loader, and compiler
requests. Existing Dew text primitives could express these operations, but they
did not provide the reusable fallible and lossy codec boundary needed by the
port.

## Delivered module

`dew.std.encoding.utf8` now provides:

```dew
pub enum Utf8DecodeError {
  InvalidSequence(U32)
}

pub fn encode(value: String) -> Bytes
pub fn encode_view(value: StringView) -> Bytes
pub fn validate(value: Bytes) -> Result<Unit, Utf8DecodeError>
pub fn decode(value: Bytes) -> Result<String, Utf8DecodeError>
pub fn decode_lossy(value: Bytes) -> String
```

Encoding shares the strict UTF-8 backing bytes in O(1). Successful strict decode
also shares the Bytes backing after runtime validation. Invalid strict input
reports the byte offset where the first malformed sequence begins.

Lossy decode keeps the valid fast path allocation-free. The malformed path emits
one U+FFFD replacement for each malformed subsequence. A valid multibyte lead
consumes its immediately following continuation bytes up to its declared width;
invalid standalone lead and continuation bytes consume one byte.

## Validation policy

Strict decoding rejects:

- invalid leading bytes;
- unexpected continuation bytes;
- truncated sequences;
- overlong encodings;
- UTF-16 surrogate scalars;
- scalar values above U+10FFFF.

Tests cover empty input, all scalar widths, exact encoding, strict errors and
offsets, lossy replacement, embedded NUL, and Unicode boundary scalars.

## Compiler integration

The module is registered for selective `open dew.std.encoding.utf8` loading and
for `open dew.std.*`. Its exact source is included in the bootstrap standard
library and therefore in the bootstrap standard-library identity.

`tools/generate_utf8_std.py` owns the embedded MoonBit source. Generated-source
checks reject stale output.
