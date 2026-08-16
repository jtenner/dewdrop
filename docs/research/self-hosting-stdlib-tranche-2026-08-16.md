# Self-hosting standard-library tranche — August 16, 2026

## Result

The compiler-oriented library gaps SH-05 through SH-08 are implemented.

The tranche adds:

- structural `Eq`/`Ne` for `FixedArray<t: Eq>`;
- deterministic `Show` for `Array`, `FixedArray`, `Option`, and `Result`;
- direct decimal append methods for every signed and unsigned integer width on
  `StringBuilder`;
- a bounded deterministic compiler-diagnostic renderer;
- an I32-ID `Arena<t>` facade over growable Array;
- portable Dew-native BLAKE3-256 and its little-endian 32-bit lookup lane.

No public Array bounds were weakened. SHA-256 package verification can remain in
the bootstrap launcher for the first fixed point.

## FixedArray specialization correction

Generic `FixedArray<t>` methods exposed two backend gaps because FixedArray is a
direct carrier-specialized WasmGC array rather than a wrapper:

1. specialized generic signatures retained the erased reference-array carrier;
2. exact nominal values loaded through generic FixedArray and Array paths were
   not cast before calls requiring concrete nominal references.

Specialization now maps `FixedArray<t>` parameters and results to the exact
carrier selected for `t`. Call emission inserts required nominal casts for
FixedArray and collection-get results, including same-module calls. Scalar,
wide, and nominal-reference structural equality execute in Node and Wago.

## StringBuilder integer output

`StringBuilder` now provides:

```dew
append_i8(value: I8)
append_i16(value: I16)
append_i32(value: I32)
append_i64(value: I64)
append_u8(value: U8)
append_u16(value: U16)
append_u32(value: U32)
append_u64(value: U64)
```

The implementation appends decimal digits directly. It allocates no temporary
String and handles each signed minimum through an unsigned magnitude without
overflow.

Integer `Show` uses these methods after exact byte-limit accounting.

## Structural Show

The deterministic forms are:

```text
Array / FixedArray  [first, second]
Option               None | Some(value)
Result               Ok(value) | Err(error)
```

Nested values use the existing explicit `Show` evidence and retain the existing
1 MiB output and depth-64 limits. Map equality and rendering remain excluded
because traversal order is intentionally unspecified.

## Compiler diagnostics

`render_compiler_diagnostic` renders this exact form:

```text
path:line:column: level[code]: message (byte offset)
```

It accepts an explicit U32 byte limit. Required size is computed before
publication, so a limit failure returns
`CompilerDiagnosticRenderError::LimitExceeded(required, limit)` without exposing
partial output. Paths, codes, and messages retain their exact UTF-8 bytes;
embedded message newlines are preserved.

## Arena

`Arena<t>` is a compiler-support facade over `Array<t>`:

- IDs are I32;
- `-1` is the only missing sentinel;
- other negative IDs trap at the reviewed I32-to-U32 boundary;
- push returns dense IDs;
- checked and unchecked get/set are available;
- checkpoints, rollback, truncate, reserve, fill, copy, spans, and span slices
  are supported;
- the underlying Array remains U32-indexed and bounds checked.

## BLAKE3

`dew.std.blake3` contains a scalar portable BLAKE3-256 implementation using
U32 add/XOR/rotate compression, 64-byte blocks, 1024-byte chunks, and the
specified parent tree. `blake3(Bytes)` returns `FixedArray<U8>` of length 32;
`blake3_hash32(Bytes)` returns the first little-endian U32 lane used by cache-pack
indexes.

The source is compiler-owned, selectively loaded, and embedded by
`tools/generate_blake3_std.py`.

## Tests

Coverage includes:

- FixedArray equality for scalar, wide, and nominal-reference carriers;
- every integer width, including signed minima and unsigned maxima;
- nested collection and sum Show output;
- exact and over-limit compiler diagnostics;
- Arena dense IDs, sentinel behavior, copying, spans, and rollback;
- rejection of negative non-sentinel Arena IDs;
- official BLAKE3 short, block, chunk, and multi-chunk vectors;
- BLAKE3 32-bit lane compatibility;
- byte-identical WAT snapshots and Node/Wago execution.

All repository module snapshots were regenerated after the standard-source and
physical-type changes so stale type-index snapshots no longer mask regressions.
