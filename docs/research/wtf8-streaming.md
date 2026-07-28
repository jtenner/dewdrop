# Streaming WTF-8 decoding

Date: 2026-07-28

## Encoding model

WTF-8 extends UTF-8 by permitting code points in the UTF-16 surrogate range U+D800 through U+DFFF. It otherwise retains UTF-8's structural restrictions: overlong encodings and values above U+10FFFF are not valid WTF-8.

Reference:

- https://simonsapin.github.io/wtf-8/

Dew additionally preserves malformed raw bytes using tagged `UInt` sentinel values above Unicode's maximum code point:

```text
0x000000..0x10FFFF  decoded WTF-8 code point, including surrogates
0x110000..0x1100FF  malformed raw byte; low 8 bits contain the byte
0x120000..0x12FFFF  source I/O error; low 16 bits contain the errno value
```

This representation keeps each yielded unit and byte offset scalar, distinguishes malformed bytes from a literal U+FFFD, and allows string literals to retain arbitrary source bytes without allocating an error object per byte.

## Refillable buffer

`Utf8Cursor::from_fd` allocates one mutable `Bytes` buffer, normally using the host page size. The same buffer is reused for every descriptor read.

Before a refill, at most three unconsumed bytes from an incomplete four-byte sequence are moved to the front of the same buffer. The next descriptor read writes directly after those bytes. No second page buffer is allocated.

The cursor tracks an absolute UTF-8 byte offset independently from the buffer-relative position, so compaction and refill do not change yielded offsets.

## Error handling

The native read helper retries interrupted system calls. EOF is represented by normal iterator exhaustion. Other descriptor errors produce one tagged I/O-error sentinel and then exhaust the iterator.

## Allocation model

- One reusable `Bytes` page for descriptor input.
- One cursor object retaining that page.
- No decoded strings and no per-refill page allocation.
- The callback traversal uses scalar callback arguments without source-level tuple/option construction per unit.
- The `next` and `Iter2` convenience APIs retain tuple/option semantics requested by the public API.
