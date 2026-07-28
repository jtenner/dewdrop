# Tokenizer implementation notes

Date: 2026-07-28

## Current scope

The `jtenner/dewdrop/tokenizer` package implements a forward-only WTF-8 decoder with two source modes:

- `Utf8Cursor::from_fd(fd)` allocates one reusable mutable `Bytes` buffer, defaulting to the host page size, and repeatedly rewrites that same buffer from the descriptor.
- `Utf8Cursor::new(bytes)` retains an existing in-memory `Bytes` value without copying it, primarily for tests and already-buffered sources.

Public interfaces include:

- `Utf8Cursor::next() -> (UtfCodepoint, ByteOffset)?`
- `Utf8Cursor::each((UtfCodepoint, ByteOffset) -> Unit)`
- `Utf8Cursor::iter() -> Iter2[UtfCodepoint, ByteOffset]`
- `Utf8Cursor::read_error() -> Int?`
- `codepoints(Bytes) -> Iter2[UtfCodepoint, ByteOffset]`

The cursor borrows its file descriptor and never closes it.

## Refill behavior

The cursor tracks a buffer-relative position and an absolute `UInt64` byte offset. When more bytes are required:

1. Unconsumed bytes are moved to the front of the same buffer with `memmove`.
2. The absolute base offset advances by the number of consumed bytes.
3. `read` writes directly into the free suffix of the same buffer.
4. Interrupted reads are retried.

At a WTF-8 boundary, at most three bytes need to survive compaction. No second page buffer is allocated, and code points split across reads retain their original absolute byte offsets.

## WTF-8 and sentinel policy

Decoded values use a tagged `UInt` representation:

```text
0x000000..0x10FFFF  WTF-8 code point, including U+D800..U+DFFF
0x110000..0x1100FF  malformed source byte; low 8 bits preserve the byte
0x120000..0x12FFFF  terminal descriptor error; low 16 bits preserve errno
```

The decoder rejects overlong sequences, values above U+10FFFF, invalid leading bytes, invalid continuation structure, and truncated sequences. Unlike strict UTF-8, WTF-8 surrogate code points are accepted.

A malformed byte consumes exactly one input byte. This guarantees forward progress without backtracking and preserves arbitrary bytes for string literals. The lexer can distinguish malformed bytes from literal U+FFFD and decide whether a sentinel is accepted by the current lexical context.

## Allocation model

- One reusable `Bytes` page for descriptor input.
- One cursor object retaining that page.
- No decoded strings and no per-refill page allocation.
- `each` calls the scalar-only internal decoder and passes two primitive callback arguments without source-level tuple/option construction per unit.
- `next` and `Iter2` expose tuple/option values as required by the requested public API; their backend representation should be benchmarked separately.

## Verification

The test suite covers ASCII, one- through four-byte sequences, WTF-8 surrogates, malformed-byte preservation, literal U+FFFD distinction, overlong and out-of-range encodings, truncated input, callback iteration, page-boundary compaction, malformed sequences crossing refills, and descriptor errors.
