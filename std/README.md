# Dew standard modules

Standard-library tests use MoonBit-style declarations:

```dew
test "descriptive name" {
  assert(condition, "failure message")
}
```

Run all current standard tests with:

```text
tools/dew-test/run.sh
```

Tests belong under `std/tests/*_test.dew`. The `_test.dew` suffix is semantic, not merely a runner glob: every declaration in such a file is test-only and `test` declarations in ordinary `.dew` files are diagnosed. Every new public standard operation should add direct passing, boundary, and failure-path coverage. Generated scalar conversion, typed-memory, and lane baseline tests are refreshed with:

```text
python3 tools/generate_std_tests.py
python3 tools/generate_std_tests.py --check
```

`assert(condition, message)` is an ambient standard preamble function. A false condition preserves the dynamic UTF-8 message through the test assertion transport and traps; standard runtime tests should prefer descriptive assertions over ad hoc `if`/`unreachable` checks.

Optional function arguments are not yet supported and remain a documented future improvement.

Text, collection, byte, and Wasm APIs are split into focused `dew.std` modules:

```text
dew.std.preamble        ambient primitives, operators, Into, Hash, and Debug
dew.std.option          ambient generic Option<t>
dew.std.result          ambient generic Result<t, e>
dew.std.fixed_array     fixed-length mutable generic arrays
dew.std.map             mutable Hash-keyed generic maps
dew.std.set             mutable Hash-keyed generic sets
dew.std.string          String and StringView
dew.std.string_builder  consuming StringBuilder
dew.std.bytes           immutable Bytes ranges and search
dew.std.bytes_builder   consuming BytesBuilder
dew.std.wasi            Preview 1 Bytes I/O
dew.std.wasm.intrinsics explicit compiler-known WebAssembly intrinsics
```

The ambient `Debug` trait and `debug(value)` facade stream deterministic output through bounded partial-write-safe WASI stdout. Primitive implementations cover Unit, Bool, all fixed-width numeric types, String, Bytes, SWAR carriers, and V128. Structs and enums may use postfix `derive(Debug)`; `derive(Eq)` and `derive(Hash)` are also implemented with conditional generic prerequisites and ordinary coherence/import rules. `Show` and `show(value) -> String` remain future work.

The ambient `Hash` trait provides `hash(self) -> U64` plus collision equality through `hash_eq(self, right) -> Bool`. A complete Hash implementation is sufficient for Map and Set key eligibility; a U64 alone cannot distinguish arbitrary collisions. `Map<key, value>` provides empty/singleton construction, safe optional lookup, trapping index lookup, insertion/replacement, Boolean collision-chain removal, alias-visible clear, membership, length, and indexed setting. `Set<key>` provides empty/singleton construction, length, emptiness, membership, idempotent Boolean insertion, collision-chain removal, and clear. Both use a deterministic separate-chaining runtime with sixteen initial buckets and measured load-1 geometric growth that relinks entries from stored hashes without user calls. Iteration remains follow-up work.

`FixedArray<t>` uses carrier-specialized unboxed WasmGC backing. `get(index)` returns `Option<t>`; index syntax, indexed setting, `set`, `get_unchecked`, and `set_unchecked` trap on out-of-bounds indices. `container[key]` and block-item-only `container[key] = value` select the ambient `Index<key, value>` and `IndexSet<key, value>` traits, so the syntax is not array-specific.

`BytesBuilder` remains the name of the one-shot, consuming construction type. A future `Buffer` would imply a reusable mutable/random-access abstraction and should be designed separately rather than aliasing the builder.

The compiler performs a deterministic leading-import prepass, loads only selected on-disk `dew.std` source paths from a fixed compiler registry, independently collects the selected compiler-owned modules, freezes their immutable interfaces, and resolves user code only through those interfaces. `dew.std.preamble`, `dew.std.option`, and `dew.std.result` are ambient unless `--no-default-preamble` is used; text, builder, bytes, WASI, and lane modules remain selective. Private text-runtime declarations live in their own compiler-owned module, and immutable range-copy implementations call private raw intrinsics rather than depending on public builder modules. Unused imported signatures, functions, and nominal layouts are removed before final Wasm type/function indexing.

Direct compiler-known WebAssembly operations are source-addressable only through `dew.std.wasm.intrinsics`; `@identifier` is reserved for imported module aliases rather than raw intrinsic names:

```dew
import dew.std.wasm.intrinsics as @wasm

let narrowed = @wasm.i64_trunc_i32(value)
```

The module currently contains the first migrated conversion. Complete generated parity with every backend-supported WebAssembly Core 3 intrinsic remains roadmap work.

All public standard modules may be selected explicitly:

```dew
open dew.std.*
```

The wildcard expands over the compiler's deterministic public module registry, including all lane modules, while excluding the private `dew.std.text_runtime` module from direct user scope. It does not enumerate the `std/` directory.

```dew
open dew.std.string
open dew.std.string_builder
open dew.std.bytes
open dew.std.bytes_builder

let bytes = text.as_bytes()
let valid = bytes.is_valid_utf8()
let checked_text = bytes.to_string() // traps when bytes are not strict UTF-8
let byte_count = text.byte_length()
let utf16_units = text.utf16_length()
let same = text.equals("expected")
let first_byte = bytes.byte_at(0u32)
let view = text.view(2u32, 8u32) // shared start + length
let shared = text.subarray(2u32, 10u32) // shared start + exclusive end
let copied = text.slice(2u32, 10u32) // exact copied String
let retained = view.compact() // exact copy releases oversized backing
let joined = text.concat(" suffix") // exact flat String copy
let joined_view = text.concat_view(view)
let packet = b"header".concat(b"\x00\xFFpayload") // arbitrary flat Bytes copy
let found = packet.find_byte(255u8) // Option::Some(index) or Option::None
let has_zero = packet.contains_byte(0u8)
let payload_index = packet.find(b"payload")
let has_payload = packet.contains(b"payload")
let header = packet.starts_with(b"header")
let payload = packet.ends_with(b"payload")
let text_index = text.find("needle")
let view_index = text.find_view(view)
let view_has_text = view.contains_string("needle")
let text_prefix = text.starts_with_view(view)
let view_suffix = view.ends_with_string("suffix")
let builder = StringBuilder::new()
let sized_builder = StringBuilder::with_capacity(64u32)
builder.append("prefix: ")
builder.append_view(view)
builder.append_ascii(33u8)
builder.append_scalar(127757u32)
builder.append_checked(b" checked UTF8")
let built = builder.finish() // consumes the builder
let binary = BytesBuilder::with_capacity(32u32)
binary.append(b"header")
binary.append_byte(255u8)
let bytes = binary.finish() // consumes the BytesBuilder
```

`String`, `StringView`, and `Bytes` use distinct WasmGC wrappers over shared zero-padded `array<v128>` storage plus byte start and exact byte length. `view(start, length)` and `subarray(start, end)` share storage; `slice(start, end)` and `compact()` exact-copy into start-zero storage. `String.concat`, `String.concat_view`, and `Bytes.concat` check total-length overflow and exact-copy both logical ranges into flat start-zero storage. Ranges use U32 byte offsets, are end-exclusive where applicable, and trap instead of clamping. Strings and views are strict UTF-8; Bytes are arbitrary. `String.view()` checks bounds and UTF-8 scalar boundaries, then shares backing in O(1). `Bytes.to_string()` validates once, traps on malformed input, and shares the same backing on success. Equality compares exact logical bytes and uses logical V128 chunks with dynamic unaligned assembly. `byte_at` is byte-oriented and traps when the unsigned index is outside the exact logical length. `String` and `StringView` provide allocation-free find, contains, prefix, and suffix operations for every String/View operand combination; returned positions are UTF-8 byte offsets and valid text cannot match inside a scalar. `Bytes.find_byte` and `contains_byte` use allocation-free SIMD scanning and report logical byte positions through `Option<U32>`.

WASI Preview 1 integration accepts GC-owned Bytes directly:

```dew
open dew.std.wasi

let written = wasi_fd_write(1u32, payload)
let input = wasi_fd_read(0u32, 65536u32)
```

WASI marshalling uses the 65,520 data bytes remaining in one reusable 64 KiB linear-memory page. Writes continue through valid partial host writes. Reads continue after full windows and stop at the requested limit, EOF, or a short read. Nonzero errno and invalid host progress trap; linear memory never owns the resulting Bytes. `Bytes.find` and `contains` specialize empty and one-byte needles, use SIMD candidate filtering for short needles, and rolling fingerprints with exact verification for long needles. `starts_with` and `ends_with` compare exact logical ranges without wrappers or copies. `StringBuilder` and `BytesBuilder` grow private GC storage geometrically, publish with `finish()`, and trap on later use. StringBuilder accepts String/StringView, checked ASCII bytes, Unicode scalar values, and strictly validated Bytes; BytesBuilder accepts arbitrary Bytes and individual U8 values.

After editing the text or WASI standard sources, regenerate their portable bootstrap providers:

```text
python3 tools/generate_string_std.py
python3 tools/generate_wasi_std.py
```

Typed packed-lane modules are organized as one generated source file per public type:

```dew
open dew.std.i8x16
open dew.std.u8x16
open dew.std.i16x8
open dew.std.u16x8
open dew.std.i32x4
open dew.std.u32x4
open dew.std.i64x2
open dew.std.u64x2
open dew.std.f32x4
open dew.std.f64x2

open dew.std.i8x8
open dew.std.u8x8
open dew.std.i16x4
open dew.std.u16x4
open dew.std.i32x2
open dew.std.u32x2
open dew.std.i8x4
open dew.std.u8x4
open dew.std.i16x2
open dew.std.u16x2
```

The package driver loads requested lane files from the selected on-disk `dew.std` package. Generated lane byte tables remain portable bootstrap providers selected only by `--bootstrap-std` or compiler-only APIs. Diagnostics-free standard frozen interfaces are cached persistently by exact selected source content under `.dew-cache/interfaces`; executable bodies and later lowering artifacts are still analyzed normally.

Physical carriers are:

```text
I8x4 U8x4 I16x2 U16x2                         -> i32
I8x8 U8x8 I16x4 U16x4 I32x2 U32x2            -> i64
I8x16 U8x16 I16x8 U16x8 I32x4 U32x4
I64x2 U64x2 F32x4 F64x2                       -> v128
```

Same-carrier reinterpretation is explicit and emits no instruction:

```dew
let integers = floats.reinterpret_as_i32x4()
let bytes = words.reinterpret_as_u8x16()
```

Numeric lane conversion uses separately named operations, for example:

```dew
let floats = f32x4_convert_i32x4_s(integers)
let integers = i32x4_trunc_sat_f32x4_s(floats)
```

Native lane extraction and replacement use fixed-index functions and methods because Wasm encodes lane indices as immediates:

```dew
let lane = value.extract_3()
let changed = value.replace_3(lane)
```

For byte-oriented string processing, `I8x16` and `U8x16` also provide `reverse`, zip/unzip, dynamic swizzle, and `concat_shift_1` through `concat_shift_15`. Native views provide scalar-splat loads, fixed-index lane loads/stores, widening loads, and 32/64-bit zero loads.

`F32x2` and relaxed SIMD are intentionally unsupported: neither fits Dew's deterministic, server-oriented packed-data policy.

Regenerate the lane modules, embedded preamble, fixed-lane, memory, shuffle, cross-lane backend mappings, and typed parity exports with:

```text
python3 tools/generate_lane_std.py
```
