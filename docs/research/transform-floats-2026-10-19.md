# Scalar float execution

The interpreter stores F32 and F64 as distinct bit values, rather than integer
values. Checked primitive proofs now retain these kinds through generic values,
patterns, fields, and call results. Integer raw-bit access rejects float values.

Scalar float Wasm operations execute locally. The Dew compiler uses one-to-one
Wasm instructions. The native compiler uses Float arithmetic for F32 and Double
arithmetic for F64. F32 never uses a Double intermediate for binary arithmetic
or square root. Nearest rounds ties to even and preserves negative zero. Min and
max select the correct zero sign. Arithmetic NaNs use a canonical quiet NaN;
absolute value, negation, copy-sign, and reinterpret preserve the input payload.

Integer conversions check the truncated value against the exact half-open range
before calling a host conversion. Saturating conversions clamp, including NaN to
zero. Unsigned 64-bit conversions handle the upper half without an overflowing
signed conversion. No float is accepted by the integer unsafe-cast path.

Native VM tests passed 37/37 in 1.281 seconds. Two normal checked examples
(float execution and overload selection) passed in 10.547 seconds. The direct
Dew transform module passed 26/26 in 0.094 seconds, including float rounding and
conversion limits. The full compiler fixed-point test passed: stage A source
build 18.849 seconds, A execution 21.058 seconds, B execution 21.493 seconds.
No scalar float operation adds a foreign host call.

The interpreter implements saturating conversion with source range checks and
existing host conversion instructions. The generated host function set does
not require new Starshine FFI instruction exports. Float SIMD execution remains
a separate open item.
