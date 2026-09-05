# SIMD lane and shuffle immediates

All 96 valid extract/replace lane descriptors now have exact opcode, index,
input, and result contracts. Library declarations state their immediate directly,
for example `i64x2.replace_lane 1`. The two compiler alias tables for fixed lanes
and named shuffle recipes are removed; their history remains in git.

Shuffle descriptors use `i8x16.shuffle` followed by exactly sixteen indices in
0..31. Both compilers parse canonical decimal indices with one space between
them. There is no compiler whitelist of reverse, zip, or concatenate recipes.
Those index sequences remain in the library source generator. The generic Wasm
intrinsic module preserves the same library APIs and accepts arbitrary valid
shuffle descriptors. The parser bounds its input to 45..61 bytes before scanning.

The existing one-instruction contracts now cover 290 fixed descriptors. Native
tests additionally compile three arbitrary shuffle descriptors, check every
physical input/result mutation, and require `UnsupportedBuiltin` for out-of-range
indices, missing/extra indices, and noncanonical decimal forms. This uncovered
a fallback that treated malformed raw Wasm names as host imports. Such names
now stay on the intrinsic path and report an error before module emission.
The native lane passes 790 tests in 75.901 seconds; the backend rebuild exceeds
30 seconds and remains a performance bug.

The new FFI declarations are selected from the unchanged pinned provider. Their
indices are explicit checked constants or come from the bounded shuffle parser.
The source-reference preflight runs before compiler generation.

Self-host hardening passes 130 tests, 25 failure records, all 290 fixed descriptor
validation cases, a custom shuffle execution test, and 168 focused value checks.
The completed lane took 17.823 seconds after the initial C rebuild. Library
execution passes 303 tests and all value matrices in 16.758 seconds. Generated
source checks pass. Partial vector memory operations remain the final
SIMD migration batch.
