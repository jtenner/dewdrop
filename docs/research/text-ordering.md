# Deterministic text ordering

Date: 2026-08-11

`dew.std.ordering` now provides explicit `StringComparator`, `StringViewComparator`, and `BytesComparator` evidence through `string_comparator()`, `string_view_comparator()`, and `bytes_comparator()`. Ordering remains non-ambient: String, StringView, and Bytes do not gain implicit `Lt`, and ordered collections retain the comparator value selected by the caller.

All three comparators perform unsigned lexicographic comparison over logical bytes. The first differing byte determines `Less` or `Greater`; when one sequence is a prefix, the shorter sequence is `Less`; equal lengths and bytes produce `Equal`. StringView honors its logical offset/length without allocation. Valid UTF-8 preserves Unicode scalar order under unsigned bytewise lexicographic comparison, while Bytes intentionally orders arbitrary byte sequences without UTF-8 interpretation.

The implementation uses the existing allocation-free text-runtime length and byte access builtins. Dedicated ordering-module builtin declarations avoid a standard-module import cycle while sharing the same backend operations. The Node and Wago snapshot covers empty/prefix/equal/greater cases, Unicode strings, offset StringViews, and Bytes. Its WAT contains no indirect calls, globals, tables, default arrays, or array mutation.

`tools/benchmark-text-ordering.py` measured a late mismatch in 256-byte values, with 1,000 comparisons per exported call and 1,000 alternating warmed Node 26.3.0 samples in batches of 10:

| Comparator | Median | Wasm bytes |
| --- | ---: | ---: |
| String | 274.223 µs | 1,841 |
| StringView | 273.560 µs | 2,118 |
| Bytes | 274.914 µs | 1,900 |

The three carriers have effectively identical late-mismatch runtime. StringView pays only static setup/cast size in this fixture and does not copy its slice.
