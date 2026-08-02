# UTF parity harness

This harness compiles real Dew source through semantics, lowering, Starshine validation, and Wasm encoding, then executes the result in Node.

It verifies the GC-backed `array<v128>` String/Bytes ABI and the strict UTF-8 algorithms derived from `JairusSW/utf-as` commit:

```text
fe082b498f4b72bdbd1bf1e081acc9f45e200af9
```

Coverage includes:

- ASCII and mixed 2/3/4-byte UTF-8;
- sequences crossing 16-byte GC chunk boundaries;
- stray continuation, overlong, surrogate, out-of-range, and truncated forms;
- exact byte lengths;
- UTF-16 unit counts;
- zero-copy String-to-Bytes backing sharing;
- shared StringView and Bytes ranges at every physical V128 alignment;
- strict length-based view, end-exclusive shared subarray, copied slice, and compact operations;
- StringView equality, nested normalized views, byte conversion, UTF-16 length, and String conversion;
- geometrically grown StringBuilder append for String and StringView values;
- exhaustive ASCII append and boundary/random Unicode scalar encoding;
- checked valid Bytes append plus malformed-input traps;
- exact flat String, StringView, and arbitrary Bytes concatenation across independent start alignments;
- first-byte search, absence reporting, contains, prefix, and suffix matching across every physical start alignment;
- exact substring search for empty, one-byte, short SIMD-filtered, long rolling-fingerprint, overlong, random, malformed, repetitive, deliberate-hash-collision, and 64 KiB stress inputs;
- exhaustive all-byte search at all 16 starts, boundary-length range/concat/builder matrices, and invalid UTF-8 interior edges at every alignment;
- String/String, String/StringView, StringView/StringView, and StringView/String find/contains/prefix/suffix matrices for short and long Unicode needles at byte positions 0, 1, 15, 16, 17, 31, 32, and 63 across every backing alignment;
- geometrically grown BytesBuilder append for arbitrary bytes and individual U8 values;
- all 256 possible one-byte inputs;
- valid and malformed sequences starting at every offset across two V128 chunks;
- checked Bytes-to-String conversion for valid data and Wasm traps for malformed data;
- exact String/Bytes equality across empty, short, tail, and multi-chunk values;
- dynamic byte access and out-of-bounds Wasm traps;
- deterministic random raw byte vectors;
- deterministic random valid Unicode strings.

Run:

```text
tools/utf-parity/run.sh
```

The current deterministic set performs 17,471 executable checks. Generated Dew, expectations, and Wasm are ignored and must not be committed.
