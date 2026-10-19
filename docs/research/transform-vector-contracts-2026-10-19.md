# Exact compile-time vector instruction contracts

Review baseline: `c3b4a18574d8715399578dc7daa81e48454da093`.
Reviewed commit: `127cce2bf9e8f79338916a9c77ddcf11da344fe1`.
Review packet: `.tmp/transforms-v3/byte-vector-review/`.

## Confirmed defects

The Native vector interpreter selected operations from a family name and an
operation suffix. This accepted names absent from the backend's exact Wasm
instruction catalog. Examples were `i8x16.mul`, `i64x2.popcnt`,
`f32x4.copysign`, and `i32x4.extract_lane_s 0`. A transform could call such a
builtin, discard its result, and emit a valid function body. The invalid call
then disappeared before backend validation. An unknown name containing
`.narrow_` could also reach an unchecked second argument read.

Both vector interpreters parsed shuffle selectors with the general decimal
immediate helper. Unlike the backend catalog, that helper accepted leading
zeroes. For example, `i8x16.shuffle 01 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15`
could execute in a transform although it was not a valid builtin descriptor.

These findings were confirmed by source and dispatch tracing. No compiler
probe was run during the review. The new source tests check the discarded-result
trigger directly; their execution status is recorded below.

## Change

`tools/generate_transform_vectors.py` now emits the Native instruction arity
check from the same catalog as the Dew vector dispatcher. The Native VM checks
this exact name and argument count before it accesses an operand. Unknown
instructions fail with a visible unsupported-instruction diagnostic. This also
keeps linear memory instructions outside the pure vector VM.

Separate small Native and Dew shuffle parsers accept exactly sixteen ASCII
decimal selectors in the range 0 through 31. They reject leading zeroes, extra
spaces, missing lanes, and trailing text. They parse directly into one lane
array; there is no split array or temporary string for each lane. Valid dynamic
shuffle descriptors remain supported.

The static check uses a generated string match. It creates no per-call map or
array. The dynamic shuffle path creates one lane array. No runtime speed,
compiled code size, or memory measurement has been made.

## Exact coverage

The catalog contains 194 fixed descriptors, 96 concrete lane descriptors, and
three bitwise descriptors (`v128.and`, `v128.or`, `v128.xor`): 293 total. Dynamic
`i8x16.shuffle` is one further descriptor family. The existing generated Wasm
oracle suite has three samples for each catalog descriptor and one shuffle
pattern, for 882 assertions in 19 tests. This is coverage of the current pure
catalog, not all Core Wasm SIMD instructions. The 72 memory catalog rows are
outside this interpreter. The generator check now verifies both generated VM
outputs.

New focused tests cover absent opcode names, malformed lane spelling, argument
count before operand access, malformed shuffle text, and valid boundary
selectors 0 and 31. Six Native driver source tests cover four nonexistent
instructions, a leading-zero shuffle, and a valid shuffle that emits 42.

## Validation status

- Generator update: passed, 0.020 seconds.
- Generator `--check`: passed, 0.022 seconds.
- `git diff --check`: passed.
- Compiler and VM tests: pending the root agent's shared build slot.

Native commands for the root agent:

```sh
DEW_NATIVE_TEST_PACKAGES=transforms tools/test-native.sh
DEW_NATIVE_TEST_PACKAGES=compiler_driver/transforms_vector_contracts_wbtest.mbt tools/test-native.sh
```

Add `self_host/compiler/transform_vector_contracts_test.dew` to the measured
Dew transform test source list before generating and running that module.
The compiler source discovery already includes the new non-test helper.

## Other review results and limits

Two independent GPT reviews found no confirmed byte or scalar bit defect.
The byte review checked exact byte escaping, backing storage, unaligned chunk
reads, and source emission. Useful missing cases include byte views crossing a
16-byte boundary, empty builders, and builder bytes containing quote and
backslash. The scalar review checked rotation masking, zero rotations, sign
extension, result widths, and 252 cheap formula comparisons. Useful missing
cases include all-one rotation counts, high-bit inputs, and typed i64 source
execution. These are test gaps, not confirmed defects.

The vector review found no confirmed arithmetic mismatch for valid catalog
operations. It checked narrow saturation source interpretation, extension,
extended multiplication, pairwise sums, dot wrapping, float conversions, and
float bit preservation. It did not execute an additional arithmetic oracle.
Claude review was unavailable under the reported usage limit; no Claude
assessment is claimed. Full execution and runtime-backed regression results
remain the root agent's validation task.


## Executed checks

All 75 Native VM tests passed in 2.437 seconds, including the four new contract
tests and 882 vector oracle cases. All six source rejection/control tests passed
in 5.868 seconds. The complete Dew suite passed 91 tests, including the three
new vector contract tests: generation 7.102 seconds, link 1.415 seconds, execution
7.713 seconds. The generator check passes. These are completion times, not speed
or memory gains. The first Dew fixture run found an inline-block parse error;
its corrected source is the tested version.
