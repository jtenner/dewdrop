# Exact F32 literal rounding — 2026-10-18

## Confirmed fault

The MoonBit lexer parsed a decimal as F64 and then narrowed it to F32.
The self-hosted lexer did the same. Near an F32 midpoint, the first conversion
can lose which side the source value is on. Narrowing then picks the wrong
F32 neighbor.

A failing input is:

```dew
1.0000000596046447753906250000000000000001f32
```

Its exact value is `1 + 2^-24 + 10^-40`. The midpoint between F32 bit
patterns `0x3f800000` and `0x3f800001` is exactly `1 + 2^-24`.
Thus the required nearest result is `0x3f800001`. The old lexer returned
`0x3f800000`. Python `Fraction` confirms both the exact side and that the
first F64 result is the midpoint. The native regression test failed before
the fix with `1065353216 != 1065353217` (0.378 seconds).

## Change and bounds

Both lexers keep the F64 parser and narrowing fast path. An F32 midpoint has
at most 25 binary significant digits. A nonzero low 28 bits of the F64
significand rules out such a midpoint, so ordinary decimal inputs return at
once. Exact F32 values also return unchanged.

For the remaining values, the lexer finds the two adjacent F32 values and
their exact F64 midpoint. Only when the parsed value equals that midpoint
does it compare the original decimal value exactly. A value below the
midpoint selects the lower neighbor; one above selects the upper neighbor;
a tie keeps the existing ties-to-even result. The overflow midpoint uses
the finite mathematical successor `2^128` to the largest finite F32.

The MoonBit helper builds the midpoint's exact decimal digits. It needs at
most 113 digits and at most 150 small multiplication passes. Source scans
are linear in source length. Separators, leading zeros, decimal position,
and signed decimal exponents are compared without making a source-sized
integer. A large exponent is capped only beyond the range that any resident
String length can balance. The normal path makes no digit array.

The Dew helper now uses the same bounded midpoint-digit method as the
MoonBit helper. It uses one `FixedArray<U32>` of 113 digits (452 bytes of
numeric payload, plus its GC header), then scans the source twice. It uses
I64 for decimal orders, so source-length subtraction cannot wrap at I32.
It does not build an integer from the source digits. Runtime assertions
check the midpoint exponent and scratch capacity, with `TOK-301` and
`TOK-302` diagnostic messages. It adds no runtime algorithm builtin and
no new production source-list dependency. Both numeric test files are in
the full smoke parser/tokenizer test list.

This corrects F32 selection when an F64 parse loses the side of an F32
midpoint. It does not replace the F64 decimal parser or promise a new F64
accuracy policy. Unary minus remains a separate token.

## Validation

`src/tokenizer/f32_rounding_wbtest.mbt` has the original witness and 42
reference cases. The boundary matrix uses exact `Fraction` arithmetic:
for 12 adjacent positive F32 pairs, form the midpoint and add zero or a
small exact dyadic epsilon of either sign. The epsilon is small enough
that all three values round to the same F64 midpoint. Expected F32 bits
come from the exact side, with ties selecting the even neighbor.

Pairs cover zero/minimum subnormal, odd and even subnormal neighbors,
maximum subnormal/minimum normal, both sides of a normal power of two,
odd/even normal neighbors, largest finite values, and overflow. Additional
cases cover separators, exponent normalization, zero, far underflow,
far overflow, and an ordinary exact value. The same 42 cases are in
`self_host/compiler/tokenizer_f32_decimal_test.dew`.

The full native tokenizer suite now passes all 46 tests. Final measured lane:
0.344 seconds. The isolated target avoids other agents' build jobs:

```sh
DEW_NATIVE_TEST_PACKAGES=tokenizer tools/test-native.sh --target-dir /tmp/dewdrop-implementation-2026-10-18/f32-build
```

The first self-hosted grouped suite passed all 29 tests, including the
42-case numeric matrix and parser recovery tests. After the bounded-scratch
follow-up below, a focused module containing the numeric matrix, original
witness, and both long-source tests passes all four test groups. Final
prebuilt-generator time is 0.308 seconds and execution time is 0.051 seconds.
Its logs are `/tmp/dewdrop-review-2026-10-18/f32-bounds/{generate,test}.log`.
Tokenizer SHA-256 for that bounded-scratch validation: `abb88363f58e8c7a52655ebac70bef57898fc6ceb478b7ec433cc6a69019f94a`.

## Short-literal cost

Environment: Linux x86_64, MoonBit `0.1.20261012` (`748b63c`),
GCC `14.2.0` (Debian `14.2.0-19`). Corrected helper SHA-256:
`346d617a87472ed7a394e7a8e5a58ad4f3ec6053935658699d0debad346d209d`.
Benchmark harness SHA-256:
`5573fe96fa07eef4e17f772ee573c92cca6793667a998da80cfbf9baafee9571`.

The checked-in benchmark compares the old parse-and-narrow path with
parse-and-correct in the same native executable. It processes five values
per iteration: `1.25`, `1.1`, `0.01`, `3.14159265`, and `1.0e-30`.
`@bench.T.keep` retains each result. Both sides use the same parser and
callback structure. The benchmark does not include lexing, source I/O,
full compiler phases, or rare exact midpoint comparisons.

```sh
moon bench --target native --no-parallelize --target-dir /tmp/dewdrop-implementation-2026-10-18/f32-build src/tokenizer/f32_decimal_bench_wbtest.mbt
```

The first correction, before the low-bit guard, reported 216.65 ns for
the old path and 225.79 ns for the correction per five values. The final
run reported 216.62 ns and 220.29 ns respectively (about 1.7% added cost
in this small benchmark, about 0.73 ns per literal). The final command,
including native build and benchmark, took 3.146 seconds. The benchmark
reports 10 samples of 100,000 iterations per side. Full final output:

```text
[jtenner/dewdrop] bench tokenizer/f32_decimal_bench_wbtest.mbt:2 ("bench f32 decimal old narrowing") ok
time (mean ± σ)         range (min … max) 
 216.62 ns ±   0.47 ns   216.04 ns … 217.75 ns  in 10 × 100000 runs
[jtenner/dewdrop] bench tokenizer/f32_decimal_bench_wbtest.mbt:15 ("bench f32 decimal midpoint correction") ok
time (mean ± σ)         range (min … max) 
 220.29 ns ±   0.18 ns   219.96 ns … 220.55 ns  in 10 × 100000 runs
Total tests: 2, passed: 2, failed: 0.
self-host timing: f32 native optimized benchmark: 3.146 seconds

```

These are one process's microbenchmark statistics, with no CPU pinning.
They do not establish whole-compiler runtime, allocation counts, native
code-size changes, or behavior on another architecture. The fixed-size
midpoint scratch bound is from the representation and code, not an RSS
measurement. No whole-compiler speed or memory gain is claimed.

## Reference generation

For each `lower_bits` in `[0, 1, 2, 0x7ffffe, 0x7fffff, 0x800000,
0x3f7fffff, 0x3f800000, 0x3f800001, 0x3f800002, 0x7f7ffffe,
0x7f7fffff]`, decode the IEEE value to an exact `Fraction`. Treat
`0x7f800000` as the mathematical finite successor `2^128`. Then:

```python
midpoint = (value(lower_bits) + value(lower_bits + 1)) / 2
log = midpoint.numerator.bit_length() - midpoint.denominator.bit_length()
epsilon = Fraction(2) ** (log - 100)
for side in [-1, 0, 1]:
    exact = midpoint + side * epsilon
    assert Fraction(float(exact)) == midpoint
    expected = lower_bits + (side > 0 or (side == 0 and lower_bits % 2 == 1))
```

Convert each exact rational to a terminating decimal with 600-digit
Decimal precision, keeping the decimal point and exponent. Alternate
`F` and `f32` suffixes. The checked-in tests contain the resulting source
bytes and expected bit patterns, so runtime tests need no Python or host
float parser. The initial evidence and generated JSON remain under
`/tmp/dewdrop-review-2026-10-18/features/`.

## Follow-up: bounded self-host midpoint work

An independent backend review found a cost fault in the first self-host
correction. Unlike the existing F64 exact path, that correction had no
source-digit or exponent cap. For `1.000000059604644775390625` followed by
many zeroes, it made a full source-sized integer and repeatedly multiplied
by five. This did quadratic digit work and used source-sized scratch.
That implementation is the **before** control below. Its source is from
commit `6a881286bc3f3a99e3f02b08224f313eada894d7`.

The replacement keeps the existing cheap fast path. Its exact comparison
builds only the midpoint's digits, with the fixed 113-digit array described
above. The two source scans ignore separators and compare decimal orders
before a digit comparison. Extra leading and trailing zeroes do not make
scratch storage larger. Exponents use the scanner's existing policy; this
change does not expand its exponent cap or replace the approximate F64 path.

New tests cover 1,024, 4,096, 16,384, and 65,536 added digits. For each size,
a tie uses trailing zeroes, a value just above has a final `1`, and a value
just below uses the previous midpoint decimal prefix followed by `9`s.
A separate case has 4,096 leading fractional zeroes and a compensating
`e4097`. Native tests also cover all 12 long tie/below/above cases.
An independent source review checked the new scratch bounds, carry values,
I64 decimal orders, separator handling, and zero padding, with no defect found.

### Scaling fixture and controls

The checked-in fixture and harness are in
[`data/f32-midpoint-bounds-2026-10-18`](data/f32-midpoint-bounds-2026-10-18/).
The fixture prepares a guest `Bytes` value before the timed call. It calls
`self_host_round_f32_decimal` with that source and the exact F64 midpoint,
which isolates the corrected path from token scanning. It checks the returned
F32 bits (`0x3f800000`) in every process. The old and new builds use the same
fixture and generator. They differ in tokenizer source. These are WasmGC execution
measurements in Node, not native-code or emulated-target measurements. The
fixture needs no Starshine provider.

For each length, three fresh Node processes per implementation alternate.
Node v24.21.0 runs with `--no-liftoff --expose-gc` on Linux x86_64. A small
warmup runs before input preparation. The harness forces GC before the timed
call, records `performance.now`, `process.memoryUsage().heapUsed` before and
after the call, and `process.resourceUsage().maxRSS`. Input construction and
source retention are outside the measured call. The compiled fixture identities
are in `samples.json` and are SHA-256 hashes of the exact executed Wasm.
Each prebuilt-generator step took under 0.4 seconds; each Node process took
under 0.34 seconds. No compiler activity reached 30 seconds.

| Added digits | Sample | Before ms | After ms | Before heap growth B | After heap growth B | Before peak RSS KiB | After peak RSS KiB |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1024 | 1 | 0.091913 | 0.006523 | 32416 | 29000 | 57404 | 57356 |
| 1024 | 2 | 0.093656 | 0.006122 | 32416 | 29000 | 57492 | 57460 |
| 1024 | 3 | 0.092133 | 0.005761 | 32416 | 29000 | 57404 | 57456 |
| 4096 | 1 | 1.137870 | 0.016061 | 46176 | 29000 | 57308 | 57120 |
| 4096 | 2 | 1.183606 | 0.022783 | 46176 | 29000 | 57468 | 57380 |
| 4096 | 3 | 1.118274 | 0.017644 | 46176 | 29000 | 57332 | 57344 |
| 16384 | 1 | 19.338522 | 0.056226 | 99792 | 28168 | 57436 | 57328 |
| 16384 | 2 | 17.428339 | 0.056676 | 99792 | 29000 | 57668 | 57052 |
| 16384 | 3 | 16.802442 | 0.056306 | 99792 | 28168 | 57584 | 57424 |
| 65536 | 1 | 287.220859 | 0.235673 | 335352 | 29000 | 57864 | 57580 |
| 65536 | 2 | 274.691073 | 0.218060 | 335352 | 29000 | 57900 | 57356 |
| 65536 | 3 | 274.922068 | 0.220134 | 335352 | 29000 | 57872 | 57400 |

For 65,536 added digits, the median isolated call fell from 274.922068 ms to
0.220134 ms. From 4,096 to 65,536 digits (16 times more source), the old median
rose from 1.137870 ms to 274.922068 ms (about 242 times), while the new median
rose from 0.017644 ms to 0.220134 ms (about 12 times). The small timings contain
fixed call and counter costs, so these ratios are observations, not universal
speed guarantees. The algorithm does linear source work plus a bounded
midpoint conversion.

Measured heap growth was 29,000 bytes for the new path at every size. Heap deltas
include V8 bookkeeping and uncollected transient values; they are not exact
allocation counts or the 452-byte scratch payload. Peak RSS is too noisy to
resolve this small scratch change. The fixed scratch claim comes from the array
bound. No peak-RSS reduction or native-machine allocation gain is claimed.

Reproduce from the repository root, using the existing release test generator:

```sh
python3 docs/research/data/f32-midpoint-bounds-2026-10-18/build.py /tmp/dewdrop-f32-midpoint-bounds
python3 docs/research/data/f32-midpoint-bounds-2026-10-18/measure.py /tmp/dewdrop-f32-midpoint-bounds
```

The build harness saves generator output and rejects failures. Each generation
has a 25-second limit. Each fresh runtime sample has a 20-second limit. The
measurement harness writes new raw samples beside its Wasm inputs. The checked-in
`samples.json` contains the rerun's 24 samples, environment, and binary hashes.
The before tokenizer is pinned to `6a881286bc3f3a99e3f02b08224f313eada894d7`;
the after tokenizer is pinned to `ee41a4b19a19614d3e0175fdb884aec15106e087`.
`build.json` and the sample report record both tokenizer hashes, the exact
prebuilt generator hash, all common input and harness hashes, actual commands,
exit status, elapsed build time, output hashes, and complete build logs. The
build record also captures repository head, working-tree status, and a diff
hash. No source revision is inferred from a binary hash. The two pinned fixture
builds each took 0.298 seconds. The matching build logs are checked in beside
the samples.

Long-literal correctness was checked separately after these pinned controls.
See [the long-range correction](f32-long-range-rounding-2026-10-18.md).
