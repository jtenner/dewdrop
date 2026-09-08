# Text Debug migration tests

The shared corpus preserves exact quoted String and Bytes output, escape rules,
and UTF-8 bytes. It covers empty input, all 256 byte values, offset views,
generic dispatch, and output beyond one scratch window. Host writes are limited
to three bytes; errno, zero progress, and excess progress must trap after one
host call, not fail at compilation or instantiation.

The current implementation passes all 15 cases: native compilation
0.397 seconds; execution 0.045 seconds. Formatting still belongs to the old
runtime. Migration must use the library's declared storage/access contract,
without adding new opaque access builtins or implicit standard-module imports.

## String migration, September 8

String formatting now uses `__dew_debug_quoted_text` in the Dew preamble.
It preserves quoted output, escapes control bytes, retains UTF-8 bytes, flushes
before a four-byte escape can cross the scratch boundary, and uses the existing
checked foreign-write loop. The count is checked before U32 overflow.

The three existing byte-storage declarations now live once in the preamble.
The old `dew.std.text_runtime` entry names remain ordinary Dew forwarding
functions, so qualified library APIs remain available. This adds no opcode,
opaque operation, module-path dispatch, or guessed storage cast. It does not
complete the separate text storage migration. The preamble needs no hidden
import of a text facade to format a literal.

The native and provider String runtime entries are removed. Their shared
private formatter remains for Bytes until its separate commit. Native text
checks pass (15 cases, compile 9.772 seconds, execute 0.047 seconds). The new
policy tests fail five checks before removal (0.036 seconds). The provider
boundary test fails before removal (18 pass, 1 fail; 6.576 seconds), then all
19 provider tests pass (6.626 seconds). Provider commit: `06f2373a6`.

The shared text corpus is now wired into native library and self-host checks.
The separate import-free dispatch fixture also checks String's byte count and
Bytes output without any explicit standard-module imports. Full validation
passed: library 326 tests plus all shared cases (32.105 seconds), self-host
462 tests and 137 numeric records plus all probes (151.683 seconds), native
1,149 tests (175.195 seconds), and integration 268 tests (57.821 seconds).
The provider rebuild took 10.761 seconds; consumer regeneration took 4.017
seconds. No FFI signature changed. Generated checks pass (12.801 seconds).
The clean bootstrap passes (171.649 seconds), with identical B/C SHA-256
`d65f2148e3501ec04ccb188b5197421778597f4b7266a7618d69cf49cd6ec3ed`.
Runs above 30 seconds remain speed bugs; no speed work is included.

## Storage research (still separate work)

A separate local storage probe attempted to reinterpret a primitive Bytes
value as a declared three-field wrapper. Native compilation rejects the
reference-to-reference `unsafe.bitcast` in 0.406 seconds. That rejection is not
a passing storage test and must not be relaxed to make guessed layouts work.
The existing compiler text wrapper also uses a precise non-null chunk-array
field; an eqref-shaped user field alone does not prove physical identity.

Possible next design to evaluate: general one-to-one WasmGC `struct.get` and
`struct.new` intrinsics, with signatures checked against complete physical
field types. Primitive text values could then expose their real storage through
declared intrinsic signatures, without reinterpreting a guessed user wrapper.
The operations must resolve their operand/result physical types from semantic
identity, never the standard module path or function name. Scalar byte/vector
extraction, views, bounds, copies, builders, and Debug escaping would be ordinary
Dew functions above those instructions. This is not implemented or approved as
a layout proof: field ownership, exact heap/nullability, and preamble dependency
closure still need validation. Do not add opaque text access builtins to bypass
those checks.

Further source check: native `wasmgc_value_type` maps String, Bytes, StringView,
StringBuilder, and BytesBuilder to the same `WasmStringRefValue`. The backend
then lowers that marker to nullable eqref, not an exact text-wrapper heap type
(`starshine_code.mbt`, `starshine_program_value_type`). Thus this marker cannot by
itself select a safe `struct.get` heap type, or distinguish a builder from an
immutable range. The proposed instruction path needs exact planned heap types
or an explicit checked cast to a declared, proven layout. A hidden cast inside
a supposedly one-instruction builtin is not a solution. Raw-array nominal
values also currently use nullable eqref in these signature paths; a field
spelled `WasmArray<V128>` alone does not prove the non-null chunk-array field.
