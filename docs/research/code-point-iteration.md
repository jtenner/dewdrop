# UTF-8 code-point iteration

Date: 2026-08-11

`dew.std.text` (standard module ID 46) adds `StringCodePoints` and `StringViewCodePoints`. `string_code_points(value)`, `string_view_code_points(value)`, and the corresponding `.code_points()` methods return ambient `Iter<U32>` implementations. `has_next()` is the non-trapping boundary; exhausted `next()` traps like the other standard iterators.

Each iterator decodes directly from the source's logical UTF-8 byte range and returns Unicode scalar values as `U32`. The decoder accepts one- through four-byte shortest-form sequences, rejects stray continuation bytes, overlong encodings, surrogate encodings, values above U+10FFFF, and truncated sequences. String values are valid UTF-8 by construction. StringView can describe arbitrary byte boundaries, so iteration over a split or otherwise invalid sequence traps deterministically instead of substituting a replacement scalar.

Iterator construction does not copy text. The initial implementation allocates one nominal iterator and one single-element scalar `FixedArray<U32>` cursor. Copies alias the same cursor under Dew's mutable reference semantics. Each successful `next()` performs no allocation, evaluates the current sequence once, advances by its encoded width, and returns one scalar. A future compiler-known iterator carrier could remove the cursor allocation, but should be adopted only if measurement justifies additional backend surface.

The Node and Wago snapshots cover ASCII, two-byte, three-byte, and four-byte scalars, empty ranges, offset StringViews, alias-shared cursor advancement, exhausted iteration, and invalid view boundaries. The runtime WAT contains no indirect calls, globals, tables, default arrays, array-length queries, or mutable struct fields.

`tools/benchmark-code-points.py` measured 256 scalars per exported call over 2,000 alternating warmed Node 26.3.0 samples in batches of 20:

| Source | Content | Median | Per scalar | Wasm bytes |
| --- | --- | ---: | ---: | ---: |
| String | ASCII | 1.277 µs | 4.987 ns | 1,987 |
| StringView | ASCII | 1.285 µs | 5.019 ns | 2,235 |
| String | mixed 1/2/3/4-byte | 1.628 µs | 6.360 ns | 2,419 |
| StringView | mixed 1/2/3/4-byte | 1.728 µs | 6.749 ns | 2,667 |

StringView remains allocation-free per scalar and pays a small range-access overhead rather than copying the viewed bytes.
