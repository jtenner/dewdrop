# GC-backed V128 UTF-8 strings

## Decision

Dew `String`, `StringView`, and `Bytes` are WasmGC values backed by a mutable-at-the-physical-level `array<v128>`, a byte start, and an exact byte length. Publication makes the backing semantically immutable. `String` and `StringView` require strict RFC 3629 UTF-8; `Bytes` remains arbitrary. `StringBuilder` and `BytesBuilder` privately own mutable backing until one consuming `finish()` publication.

The runtime types appended after program-owned types are conceptually:

```wat
(type $chunks (array (mut v128)))
(type $string (struct (field (ref $chunks)) (field i32) (field i32)))
(type $bytes  (struct (field (ref $chunks)) (field i32) (field i32)))
(type $view   (struct (field (ref $chunks)) (field i32) (field i32)))
(type $string_builder
  (struct
    (field (mut (ref $chunks)))
    (field (mut i32))
    (field (mut i32))))
(type $bytes_builder
  (struct
    (field (mut (ref $chunks)))
    (field (mut i32))
    (field (mut i32))))
```

The two integer fields on published text values are byte start and byte length. Constants have start zero and use `v128.const`, `array.new_fixed`, and `struct.new`, so they allocate in the GC heap and no longer use `stringref`. Builder storage is zero initialized, grows geometrically, and becomes immutable after `finish()` marks the builder consumed.

## Standard API

The public API is split by ownership and construction role:

```text
dew.std.string          String and StringView
dew.std.string_builder  StringBuilder
dew.std.bytes           Bytes
dew.std.bytes_builder   BytesBuilder
```

The bootstrap leading-import prepass selects these source modules independently and injects one private `std/text_runtime.dew` intrinsic declaration file whenever any are selected. Immutable range-copy methods call private raw builder intrinsics, so `String` and `Bytes` do not pull the public builder method modules. The final standard loader will freeze and cache the interfaces instead of reparsing embedded mirrors. `BytesBuilder` intentionally remains distinct from a future reusable mutable `Buffer` abstraction.

The modules currently provide:

```dew
String.byte_length() -> U32
String.as_bytes() -> Bytes
Bytes.byte_length() -> U32
String.utf16_length() -> U32
String.equals(String) -> Bool
String.byte_at(U32) -> U8
Bytes.is_valid_utf8() -> Bool
Bytes.to_string() -> String
Bytes.equals(Bytes) -> Bool
Bytes.byte_at(U32) -> U8

String.view(U32, U32) -> StringView
String.subarray(U32, U32) -> StringView
String.slice(U32, U32) -> String
String.compact() -> String
String.concat(String) -> String
String.concat_view(StringView) -> String
String.find(String) -> Option<U32>
String.find_view(StringView) -> Option<U32>
String.contains(String) -> Bool
String.contains_view(StringView) -> Bool
String.starts_with(String) -> Bool
String.starts_with_view(StringView) -> Bool
String.ends_with(String) -> Bool
String.ends_with_view(StringView) -> Bool
StringView.byte_length() -> U32
StringView.byte_at(U32) -> U8
StringView.to_string() -> String
StringView.as_bytes() -> Bytes
StringView.utf16_length() -> U32
StringView.equals(StringView) -> Bool
StringView.view(U32, U32) -> StringView
StringView.subarray(U32, U32) -> StringView
StringView.slice(U32, U32) -> String
StringView.compact() -> String
StringView.find(StringView) -> Option<U32>
StringView.find_string(String) -> Option<U32>
StringView.contains(StringView) -> Bool
StringView.contains_string(String) -> Bool
StringView.starts_with(StringView) -> Bool
StringView.starts_with_string(String) -> Bool
StringView.ends_with(StringView) -> Bool
StringView.ends_with_string(String) -> Bool

StringBuilder::new() -> StringBuilder
StringBuilder::with_capacity(U32) -> StringBuilder
StringBuilder.byte_length() -> U32
StringBuilder.append(String) -> Unit
StringBuilder.append_view(StringView) -> Unit
StringBuilder.append_ascii(U8) -> Unit
StringBuilder.append_scalar(U32) -> Unit
StringBuilder.append_checked(Bytes) -> Unit
StringBuilder.finish() -> String

BytesBuilder::new() -> BytesBuilder
BytesBuilder::with_capacity(U32) -> BytesBuilder
BytesBuilder.byte_length() -> U32
BytesBuilder.append(Bytes) -> Unit
BytesBuilder.append_byte(U8) -> Unit
BytesBuilder.finish() -> Bytes

Bytes.view(U32, U32) -> Bytes
Bytes.subarray(U32, U32) -> Bytes
Bytes.slice(U32, U32) -> Bytes
Bytes.compact() -> Bytes
Bytes.concat(Bytes) -> Bytes
Bytes.find_byte(U8) -> Option<U32>
Bytes.contains_byte(U8) -> Bool
Bytes.find(Bytes) -> Option<U32>
Bytes.contains(Bytes) -> Bool
Bytes.starts_with(Bytes) -> Bool
Bytes.ends_with(Bytes) -> Bool
```

`String.as_bytes()` allocates only a distinct nominal wrapper and shares the chunk array. `Bytes.to_string()` calls the strict validator, traps on malformed input, and constructs a nominal String wrapper sharing the same chunk array and exact length on success. Source String literals are validated during semantic collection; malformed UTF-8 remains legal only through `Bytes` literals. UTF-16 length is intentionally a `String` operation so invalid arbitrary bytes cannot silently produce a meaningless count.

Equality rejects unequal exact lengths, scans scalar bytes until both operands are physically V128 aligned, compares aligned full vectors, and handles the remaining logical tail bytewise. Dynamic `byte_at` adds the published start, uses swizzle plus fixed lane-zero extraction, and traps before array access when the unsigned logical index is out of bounds.

`view(start, length)` uses a checked start plus byte length and shares backing. `subarray(start, end)` uses checked end-exclusive byte offsets and also shares backing. `slice(start, end)` uses the same strict range checks but copies the exact logical range into start-zero, exactly sized builder storage. String and StringView ranges additionally verify that both interior edges are UTF-8 scalar boundaries; Bytes permits every byte boundary. Ranges trap rather than clamp when start or end is invalid or reversed. `compact()` exact-copies the complete logical value, allowing oversized retained backing to become collectable. `String.concat`, `String.concat_view`, and `Bytes.concat` check total U32 length overflow before allocation, allocate exactly the required zeroed V128 chunks, copy both logical ranges with dynamic aligned/unaligned SIMD operations plus scalar tails, and publish a flat start-zero result. Empty operands still follow this exact-copy contract, so concatenation never retains oversized source backing or creates rope nodes.

String and StringView matching use the same allocation-free logical-range engine for every String/StringView operand combination. Results are UTF-8 byte offsets. Since both operands preserve strict UTF-8, a complete needle cannot begin or end inside a continuation sequence; no post-match boundary scan is required. Empty needles match at zero, and matching remains byte-exact without normalization or case folding.

`Bytes.find_byte` returns `Option::Some(U32)` with a logical byte index or `Option::None`; the private runtime sentinel never enters the public API. It scans at most fifteen scalar prefix bytes to physical alignment, compares complete chunks with `i8x16.eq` plus `i8x16.bitmask`, selects the first matching lane with `i32.ctz`, and handles the exact tail scalarly. `contains_byte` shares that runtime scan. `Bytes.find` and `contains` preserve the empty-needle-at-zero rule and delegate one-byte needles to that SIMD path. Needles through sixteen bytes filter sixteen candidate positions at once using SIMD first/last-byte masks before exact verification. Longer needles use a base-257 rolling U64 fingerprint for linear scanning work and verify every fingerprint hit byte-for-byte, so wrapping-hash collisions cannot alter correctness. `starts_with` and `ends_with` compare exact logical ranges allocation-free with dynamic V128 loads and scalar tails; empty patterns match and overlong patterns fail.

`StringBuilder` and `BytesBuilder` use private mutable V128 arrays. `StringBuilder.append_ascii` accepts only 0x00 through 0x7F; `append_scalar` directly encodes one Unicode scalar into one through four strict UTF-8 bytes and rejects surrogates or values above U+10FFFF; `append_checked` validates Bytes once before append. Capacity is rounded to chunks and doubled when required, copying only used chunks. StringBuilder appends exact logical bytes from either `String` or `StringView`; BytesBuilder appends arbitrary `Bytes` ranges and individual `U8` values. `finish()` publishes a start-zero nominal value sharing builder backing and permanently invalidates that builder. Reading, appending, or finishing a consumed builder traps.

## Algorithms

The implementation is derived from `JairusSW/utf-as` at commit:

```text
fe082b498f4b72bdbd1bf1e081acc9f45e200af9
```

The strict validator implements the same RFC 3629 ranges used by utf-as:

- reject stray continuation bytes and C0/C1 overlong leads;
- enforce E0 second-byte lower bound;
- reject ED surrogate encodings;
- enforce F0 lower and F4 upper bounds;
- reject F5 and higher leads and truncated sequences.

Aligned ASCII blocks are skipped with one `i8x16.bitmask`. Dirty blocks retain stack-safe iterative control and dynamically select bytes from GC-resident V128 chunks. UTF-16 length uses the utf-as identity:

```text
utf16_units = utf8_bytes - continuation_bytes + four_byte_leads
```

Full chunks count both classes with SIMD masks and population counts; only the final partial chunk is scalar.

## Validation

`tools/utf-parity/run.sh` compiles real Dew source to WasmGC and executes 17,471 strict valid, invalid, exhaustive single-byte, every-chunk-offset, checked-conversion, conversion-trap, byte-length, UTF-16-length, equality, byte-index, view, StringBuilder ASCII/scalar/checked producers, BytesBuilder, view/subarray/slice/compact, flat String/StringView/Bytes concatenation, byte and substring search, prefix/suffix matching, out-of-bounds-trap, consumed-builder-trap, shared-backing, deterministic random-byte, and random-Unicode checks in Node.

## WASI staging

`wasi_fd_write` and `wasi_fd_read` now marshal GC-owned Bytes through the 65,520-byte data region of one reusable 64 KiB memory32 page. Writes handle partial host progress; reads publish start-zero immutable Bytes after full-window, short-read, EOF, or limit termination. See `docs/research/wasi-bytes-marshalling.md`.

## Deferred work

- measured growth/retained-capacity policy for both builders;
- measured automatic retained-backing policy, if explicit `compact()` proves insufficient;
- inline one-V128 representation for values up to 16 bytes;
- full UTF-8 decoding/iteration, code-point indexing, hashing, ordering, and normalization;
- Keiser-Lemire four-chunk validation after the direct-GC-array baseline is benchmarked.
