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

The Dew helper reuses `self_host_big_decimal`, `self_host_f64_dyadic`, and
`self_host_decimal_compare_dyadic`. It adds no runtime algorithm builtin
and no new source-list dependency. It stays in `tokenizer.dew` so existing
explicit parser source lists include it. The new test file is included in
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

The full native tokenizer suite passes all 45 tests. Final measured lane:
0.357 seconds. The isolated target avoids other agents' build jobs:

```sh
DEW_NATIVE_TEST_PACKAGES=tokenizer tools/test-native.sh --target-dir /tmp/dewdrop-implementation-2026-10-18/f32-build
```

The final self-hosted grouped suite passes all 29 tests, including both
numeric tests, parser recovery, and existing tokenizer/parser tests.
Generation took 4.750 seconds, linking 1.126 seconds, and execution
0.066 seconds. The final source hashes are recorded in
`.tmp/malformed-escape-recovery/source-sha256.json`; logs are
`.tmp/malformed-escape-recovery/green-{generate,link,tests}.log`.
The production tokenizer SHA-256 used in that run is
`13259ff00c58cdc0da81bee68b47e0d66090bd2ca011588676ba1fc5e8e84d7a`.

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
