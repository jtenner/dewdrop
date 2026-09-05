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
dew.std.iter            eager consuming iterator combinators over Iter<t>
dew.std.math            explicit checked/wrapping integer and IEEE float math
dew.std.io              portable byte Reader/Writer contracts and in-memory streams
dew.std.path            validated workspace-relative paths
dew.std.fs              provider-neutral filesystem contract
dew.std.fs.wasi         WASI Preview 1 filesystem adapter
dew.std.process         provider-neutral process contract
dew.std.process.wasi    WASI Preview 1 process adapter
dew.std.facet           shared Facet handles and error aliases
dew.std.facet.imports   all raw Facet adapter imports
dew.std.facet.core      ABI and generic handle operations
dew.std.facet.fs        all filesystem operations
dew.std.facet.process   process, stdio, arguments, and environment
dew.std.facet.clock     clocks and sleep
dew.std.facet.random    scalar and buffer randomness
dew.std.facet.poll      readiness and timer polling
dew.std.facet.net       sockets, datagrams, and DNS
dew.std.json            strict bounded JSON values, I/O facades, and serialization
dew.std.encode          fallible receiver-based Bytes encoding evidence
dew.std.decode          fallible Bytes decoding evidence
dew.std.format          package format errors and validation evidence
dew.std.semver          bounded Semantic Versioning 2.0.0 and package ranges
dew.std.package         dew.json, dew.lock, and dew.modules.json formats
dew.std.package.artifact installed DEWPKG1 package capsule format
dew.std.bloom_filter    allocation-free U64 probabilistic membership prefilter
dew.std.testing         explicit assertion helpers over compiler-owned test primitives
dew.std.option          ambient generic Option<t>
dew.std.result          ambient generic Result<t, e>
dew.std.fixed_array                 fixed-length mutable generic arrays
dew.std.array                       growable mutable generic arrays and iterators
dew.std.map                         mutable Hash-keyed generic maps and iterators
dew.std.set                         mutable Hash-keyed generic sets and iterators
dew.std.queue                       mutable circular-buffer FIFO queue
dew.std.ordering                    explicit Ordering and Comparator evidence
dew.std.show                        deterministic side-effect-free formatting
dew.std.disposable                  explicit cleanup evidence
dew.std.collections.stack           mutable LIFO stack
dew.std.collections.circular_buffer bounded/growable ring buffer
dew.std.collections.deque           growable double-ended queue
dew.std.collections.binary_heap     comparator-driven binary heap
dew.std.collections.priority_queue  priority/value heap wrapper
dew.std.collections.red_black_tree  ordered balanced-tree core
dew.std.collections.ordered_map     comparator-ordered map
dew.std.collections.ordered_set     comparator-ordered set
dew.std.string                      String and StringView
dew.std.string_builder              consuming StringBuilder
dew.std.bytes                       immutable Bytes ranges and search
dew.std.bytes_builder               consuming BytesBuilder
dew.std.encoding.utf8               strict and lossy UTF-8 codecs
dew.std.blake3                       portable BLAKE3-256
dew.std.integrity.sha256              portable one-shot SHA-256
dew.std.wasi                        Preview 1 Bytes I/O
dew.std.wasm.wasi                   raw complete Preview 1 imports
dew.std.wasm.intrinsics             explicit compiler-known WebAssembly intrinsics
```

The ambient `Debug` trait and `debug(value)` facade stream deterministic output through bounded partial-write-safe WASI stdout. Primitive implementations cover Unit, Bool, all fixed-width numeric types, String, Bytes, SWAR carriers, and V128. Structs and enums may use postfix `derive(Debug)`; `derive(Eq)`, `derive(Hash)`, and `derive(Show)` are also implemented with conditional generic prerequisites and ordinary coherence/import rules. `Show` remains non-ambient and side-effect free: `show(value) -> String` and builder-backed composition use explicit evidence with deterministic depth and byte limits. Array, FixedArray, Option, and Result have structural deterministic Show forms. `render_compiler_diagnostic` produces bounded `path:line:column: level[code]: message (byte offset)` output without ambient Debug.

The ambient `Hash` trait provides `hash(self) -> U64` plus collision equality through `hash_eq(self, right) -> Bool`. A complete Hash implementation is sufficient for Map and Set key eligibility; a U64 alone cannot distinguish arbitrary collisions. `BloomFilter` is a transparent `U64` value type with two deterministic probes. It can prove definite absence without allocation, but a positive `filter.maybe_contains(value)` result remains probabilistic and must be followed by exact equality or collection lookup when false positives are unacceptable. `Map<key, value>` provides empty/singleton construction, safe optional lookup, trapping index lookup, insertion/replacement, Boolean collision-chain removal, alias-visible clear, membership, length, and indexed setting. `Set<key>` provides empty/singleton construction, length, emptiness, membership, idempotent Boolean insertion, collision-chain removal, and clear. Both use a deterministic separate-chaining runtime with sixteen initial buckets and measured load-1 geometric growth that relinks entries from stored hashes without user calls. Map key/value/entry iterators and Set iterators are allocation-free per yielded element after production Starshine scalar replacement; hash traversal order remains intentionally unspecified.

`Iter<t>` is declared with `Option<t>` and exposes only `next(self) -> Option<t>`. Exhaustion returns `None` repeatedly. `for pattern in iterable { ... }` calls `iterable.iter()` once and consumes `next()` until `None`; the compiler lowers it to the existing functional loop. Immediate Option construction and matching are scalarized to locals in production binaries, while escaping Option values retain the normal WasmGC enum representation.

`FixedArray<t>` uses carrier-specialized unboxed WasmGC backing and implements structural Eq/Ne when `t: Eq`. `get(index)` returns `Option<t>`; index syntax, indexed setting, `set`, `get_unchecked`, and `set_unchecked` trap on out-of-bounds indices. Growable `Array<t>` uses the same six carrier families and adds make/reserve/shrink/truncate/copy/extend, strict fill/copy/slice ranges, deque-like mutation, immutable variants, splice, search, structural equality, callbacks, stable sorting, flattening, and value/key/entry iterators. Bulk construction and movement lower to WasmGC `array.new`, `array.copy`, and `array.fill`; removed reference slots are cleared. The compiler-support `Arena<t>` facade keeps dense I32 IDs, reserves `-1` for missing values, rejects other negative IDs, and adds checkpoints, rollback, and spans without weakening Array's U32 boundary. See [`docs/research/array-api-and-performance-2026-08-16.md`](../docs/research/array-api-and-performance-2026-08-16.md). `container[key]` and block-item-only `container[key] = value` select the ambient `IndexedGet<key, value>` and `IndexedSet<key, value>` traits, so the syntax is not array-specific.

`dew.std.encode` defines `Encode<t_err>` with fallible receiver-based `encode(self) -> Result<Bytes, t_err>`. `dew.std.decode` defines fallible decoding from Bytes. Package values validate before encoding, and package decoders return errors instead of exposing a trusted trapping path. `SemVer` retains prerelease and build identifiers, compares by Semantic Versioning 2.0.0 precedence, and supports exact, caret, tilde, wildcard, and Git package requirements. Package codecs impose explicit limits from 1 MiB for `dew.json` through 256 MiB for installed capsules.

`StringBuilder` appends every signed and unsigned integer width directly as decimal text, including exact signed minima, without constructing a temporary String. `dew.std.encoding.utf8` provides zero-copy String/StringView encoding, strict validation and decoding with the first malformed byte offset, and deterministic lossy decoding with U+FFFD replacement. `dew.std.blake3` provides deterministic one-shot BLAKE3-256 over Bytes plus the first little-endian U32 lookup lane used by compiler cache packs. `dew.std.integrity.sha256` provides portable one-shot SHA-256 over Bytes and returns 32 digest bytes as `FixedArray<U8>`.

`BytesBuilder` remains the name of the one-shot, consuming construction type. A future `Buffer` would imply a reusable mutable/random-access abstraction and should be designed separately rather than aliasing the builder.

The compiler performs a deterministic leading-import prepass, loads only selected on-disk `dew.std` source paths from a fixed compiler registry, independently collects the selected compiler-owned modules, freezes their immutable interfaces, and resolves user code only through those interfaces. `dew.std.preamble`, `dew.std.option`, and `dew.std.result` are ambient unless `--no-default-preamble` is used; text, builder, bytes, WASI, and lane modules remain selective. Private text-runtime declarations live in their own compiler-owned module, and immutable range-copy implementations call private raw intrinsics rather than depending on public builder modules. Unused imported signatures, functions, and nominal layouts are removed before final Wasm type/function indexing.

Direct compiler-known WebAssembly operations are source-addressable only through `dew.std.wasm.intrinsics`; `@identifier` is reserved for imported module aliases rather than raw intrinsic names:

```dew
import dew.std.wasm.intrinsics as @wasm

let narrowed = @wasm.i64_trunc_i32(value)
```

The module is generated from the compiler's backend inline-builtin surface. It exposes every currently source-addressable scalar, conversion, memory, packed-lane, and SIMD operation with a `wasm_`-prefixed public name, while retaining `i64_trunc_i32` as the first-published compatibility spelling. It also exposes `wasm_bytes_load_u8x16(Bytes, U32)`, a bounds-checked representation bridge that loads sixteen logical bytes from GC-backed `Bytes`; unlike `wasm_v128_load(U32)`, it does not address linear memory. The generator fails when a backend inline builtin lacks a declaration, and the bootstrap source is generated from the same output.

`NullableRef<t>` represents exact nullable WasmGC foreign references. Its type argument must be one foreign nominal type; primitive, structural, and nested nullable arguments are rejected. A non-null foreign `t` widens to `NullableRef<t>` without an emitted instruction. Nullable-to-non-null conversion stays explicit and traps on null:

```dew
let missing = @wasm.wasm_ref_null<ForeignValue>()
let is_missing = @wasm.wasm_ref_is_null(missing)
let value = @wasm.wasm_ref_as_non_null(maybe_value)
```

These operations lower directly to `ref.null`, `ref.is_null`, and `ref.as_non_null`. Other general GC, table, and host-boundary operations remain absent until Dew exposes corresponding safe carrier types and signatures.

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
let same = text == "expected" // String, StringView, and Bytes use content Eq/Ne
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

`dew.std.wasm.wasi` exposes all 46 raw `wasi_snapshot_preview1` functions with exact U32/U64/I64 ABI carriers. It requires an explicit import and is not selected by `open dew.std.*`, so the broad convenience wildcard does not retain low-level host signatures. Its U32 pointers address exported linear memory, and callers own Preview 1 record and buffer layouts. Import it with `import dew.std.wasm.wasi as @wasi`. Reachable raw calls retain their exact WASI field names; unreachable calls are removed.

The higher-level WASI Preview 1 adapter accepts GC-owned Bytes directly:

```dew
open dew.std.wasi

let written = wasi_fd_write(1u32, payload)
let input = wasi_fd_read(0u32, 65536u32)
```

WASI marshalling uses the 65,520 data bytes remaining in one reusable 64 KiB linear-memory page. Writes continue through valid partial host writes. Reads continue after full windows and stop at the requested limit, EOF, or a short read. Nonzero errno and invalid host progress trap; linear memory never owns the resulting Bytes. `Bytes.find` and `contains` specialize empty and one-byte needles, use SIMD candidate filtering for short needles, and rolling fingerprints with exact verification for long needles. `starts_with` and `ends_with` compare exact logical ranges without wrappers or copies. `StringBuilder` and `BytesBuilder` grow private GC storage geometrically, publish with `finish()`, and trap on later use. StringBuilder accepts String/StringView, checked ASCII bytes, Unicode scalar values, and strictly validated Bytes; BytesBuilder accepts arbitrary Bytes and individual U8 values.

`dew.std.testing` adds explicit-message Boolean, equality, ordering, Option-shape, and Result-shape assertions. It delegates failure to the ambient compiler-owned `assert`, so test-mode dynamic messages and production zero-I/O traps remain unchanged. Test discovery, `_test.dew`, `expect_trap`, filters, and metadata remain compiler/tooling features rather than library APIs.

`dew.std.path` validates strict workspace-relative UTF-8 paths, rejects absolute paths, parent escapes, empty/dot segments, backslashes, NUL, and paths longer than 4,096 bytes. `dew.std.fs` defines explicit filesystem capabilities, typed errors, bounded reads, recursive directory creation, and atomic write composition. `dew.std.process` defines ordered arguments, missing-aware environment lookup, separate stdout/stderr, and explicit exit. WASI adapters use a bounded Memory32 scratch window. `dew.std.facet.imports` owns every raw Facet adapter import. The grouped `core`, `fs`, `process`, `clock`, `random`, `poll`, and `net` modules expose decoded results for all 261 canonical Facet 0.1 operations. `dew.std.facet.fs` contains `fd_sync` and `fd_datasync`. Link Facet programs with `--link-wasm facet fixtures/facet/facet-adapter.wasm`.

`dew.std.io` is host-independent. `Reader.read(limit)` returns at most `limit` Bytes and uses an empty successful result for EOF; `Writer.write(value)` reports bounded progress. Exact reads, complete writes, bounded read-to-end, and bounded copy use typed `IoError` results. `BytesInput` and `BytesOutput` provide deterministic in-memory implementations. Importing the module does not import WASI or add linear memory; `dew.std.wasi` remains the GC-Bytes adapter and `dew.std.wasm.wasi` is the separate raw Preview 1 surface.

`dew.std.json` implements strict RFC 8259 parsing in Dew source. `JsonValue::Number` preserves the exact validated lexeme; arrays and object members preserve source order; duplicate keys are rejected during parsing and serialization; UTF-8, escapes, surrogate pairs, trailing input, nesting, value count, input bytes, and decoded string bytes have explicit policies and errors. Compact-owning `json_parse` remains the default. `json_parse_retained` explicitly shares clean String and number ranges with the whole input, and `json_parse_document` retains both the source and strict tree so source-preserving output is explicit. `json_parse_raw_document` validates and retains only source until explicit materialization. Specialized `json_validate` skips eager value construction. `JsonNumber` validates constructed lexemes once, and parsed validated-number modes avoid repeated serialization validation; legacy Number(String) remains checked. Canonical parse modes also produce `JsonString` provenance so clean parsed strings skip serialization rescans while escaped strings remain checked. `json_parse_reader`/`json_write` compose with portable `Reader`/`Writer`; they are bounded whole-value facades rather than a separate token-stream parser. Whitespace, string-special, and scalar-delimiter scans use generated `U8x16` operations, `u32_ctz`, and generic GC-backed text load bridges. Regenerate its bootstrap mirror with `python3 tools/generate_json_std.py`.

`dew.std.math` uses type-prefixed names because Dew does not permit duplicate top-level function names. Integer `*_wrapping_*` operations expose fixed-width wrapping semantics; `*_checked_*` returns `Option` instead of trapping on overflow or zero divisors. Signed exact `*_abs` and invalid clamps trap. Floating bit conversion is exact, min/max preserve selected NaN payloads and define signed-zero selection, and clamp rejects NaN bounds while preserving a NaN input. The generated source and bootstrap mirror are refreshed with:

```text
python3 tools/generate_math_std.py
```

After editing the text or WASI standard sources, regenerate their portable bootstrap providers:

```text
python3 tools/generate_string_std.py
python3 tools/generate_utf8_std.py
python3 tools/generate_wasi_std.py
python3 tools/generate_wasm_intrinsics_std.py
python3 tools/generate_bloom_filter_std.py
python3 tools/generate_sha256_std.py
python3 tools/generate_facet_bindings.py
python3 tools/generate_host_std.py
python3 tools/generate_facet_adapter.py
python3 tools/generate_json_std.py
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

The package driver loads requested lane files from the selected on-disk `dew.std` package. Generated lane byte tables remain portable bootstrap providers selected only by `--bootstrap-std` or compiler-only APIs. Diagnostics-free standard frozen interfaces are cached persistently by exact selected source content under `.dew/cache/interfaces`; executable bodies and later lowering artifacts are still analyzed normally.

Physical carriers are:

```text
I8x4 U8x4 I16x2 U16x2                         -> i32
I8x8 U8x8 I16x4 U16x4 I32x2 U32x2            -> i64
I8x16 U8x16 I16x8 U16x8 I32x4 U32x4
I64x2 U64x2 F32x4 F64x2                       -> v128
```

For packed peer types with the same carrier, `Into` preserves every bit and
emits no instruction. The result type selects the conversion:

```dew
fn integer_view(value: F32x4) -> I32x4 {
  value.into()
}
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
