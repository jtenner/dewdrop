# F32 long-source rounding and exponent cancellation

The independent core review's long-literal risk is confirmed for the self-host
compiler. A Python `Fraction` oracle produced 29 cases: long midpoint neighbors
at nine F32 boundaries and two sources with exponents above 10,000 that cancel
leading fractional zeros. Eight cases failed before the fix. The failures
include the largest subnormal, the smallest normal, the previous value below
the largest finite number, and exponent cancellation. Native lexing passes the
same reference values.

The F64 approximation can be a few F64 steps from an exact F32 midpoint when
long sources bypass exact F64 correction. Requiring that approximation to equal
the midpoint therefore loses the exact decimal's side. The 10,000 exponent cap
also changes the value of a source such as 20,000 fractional zeros followed by
`1000000059604644775390625e20001f32`.

## Correction

Long source spans or exponent magnitudes use the bounded exact F32 midpoint
comparison even when the F64 approximation is not exactly the midpoint. The
approximation locates the adjacent F32 values; the original digits decide the
side. An exact tie explicitly selects the even F32 bit pattern. Sources with
at most 256 mantissa bytes and exponent magnitude at most 256 keep the old fast
path. Within that small-source region, cases outside the F64 exact limits are
already below the F32 range, so they cannot cross an F32 rounding boundary.

The exponent scanner now saturates at the U32 storage limit rather than 10,000.
Decimal order and scale subtraction use I64. Very large remaining scale shifts
are capped at 1,000 decimal places, beyond the finite F64 range. This bounds
scale work even when an exponent has many digits. It also avoids U32 addition
wrap when large exponents and source lengths combine. The F64 exact helper
narrows the order to I32 only after its existing range check.

The midpoint still needs at most 113 decimal digits. This change adds no
source-sized integer, new scratch array, runtime algorithm builtin, or module
special case. The native implementation needed no production change.

## Exact reference and tests

`data/f32-long-range-2026-10-18/oracle.json` stores exact midpoint numerators,
denominators, decimal prefixes, and lower F32 bits. `oracle.py` uses independent
binary search and exact rational comparisons to select the nearest F32 value.
It checks 56 cases with 1,024 and 65,536 extra digits, both sides and exact ties,
and cancellation after 10,001 and 20,000 leading zeros. All 56 pass.

`src/tokenizer/f32_long_range_wbtest.mbt` and
`self_host/compiler/tokenizer_f32_long_range_test.dew` contain matching tests.
The self-host file is in the smoke parser/tokenizer list. Both new native test
groups pass in 0.445 seconds. The six self-host numeric test groups, including
the existing 42-case matrix and long-source groups, pass: generation 0.365
seconds, execution 0.114 seconds. Initial red and final green logs are in
`.tmp/f32-long-range-review`. No compiler activity exceeded 30 seconds.

## Current-source scaling check

The same isolated midpoint fixture was built from the corrected tokenizer and
compared with the bounded version pinned at `ee41a4b1`. Its source and generator
hashes, complete build command and log, reference build identity, and all 40 raw
samples are saved in `data/f32-long-range-2026-10-18/current-scaling-samples.json`.
The corrected fixture took 0.313 seconds to build.

Five fresh Node processes per version alternate at each length. The harness
uses `--no-liftoff --expose-gc`, warms up once, prepares source outside the timed
call, and checks the result bits. Median call times are:

| Added digits | Bounded reference ms | Current correction ms |
| --- | --- | --- |
| 1,024 | 0.006552 | 0.006853 |
| 4,096 | 0.016882 | 0.017362 |
| 16,384 | 0.059382 | 0.059061 |
| 65,536 | 0.229001 | 0.228570 |

Measured heap growth is 29,000 bytes for both versions at all lengths. These
small timings show no material regression at the largest input. They do not
establish whole-compiler speed or native runtime performance. Heap deltas are
not allocation counts; fixed scratch size follows from the code's array bound.
