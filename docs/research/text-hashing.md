# Deterministic text hashing

Date: 2026-08-11

String, StringView, and Bytes now implement the ambient `Hash` trait through one allocation-free WasmGC runtime loop. The algorithm is 64-bit FNV-1a over each value's logical byte range, with offset basis `14695981039346656037` and prime `1099511628211`.

String hashes strict UTF-8 bytes, StringView hashes only its shared logical range, and Bytes hashes arbitrary bytes without validation or conversion. Equal byte sequences intentionally produce the same U64 hash across all three nominal types, although `Hash.hash_eq` remains same-type because map/set key types are static. Equality delegates to the existing allocation-free String, StringView, and Bytes comparisons.

The implementation reads carrier chunks directly, advances physical and logical indices without allocating, and preserves deterministic overflow through Wasm i64 multiplication. Empty input returns the FNV offset basis.

`tools/benchmark-text-hash.py` measured 256-byte inputs on x86-64 Node 26.3.0 with 500 warmed samples:

| Type | Median | Wasm bytes |
| --- | ---: | ---: |
| String | 0.551 µs | 1,026 |
| StringView | 0.491 µs | 1,270 |
| Bytes | 0.501 µs | 1,025 |

The runtime snapshot also exercises String, StringView, and Bytes as hash map/set keys, unaligned shared ranges, UTF-8 text, arbitrary bytes, and cross-type hash parity. Hash collection iteration order remains unspecified.
