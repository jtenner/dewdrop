"""Check the committed boundary prefixes with exact rational arithmetic."""
from fractions import Fraction
from pathlib import Path
import json
import sys

sys.set_int_max_str_digits(0)


def value(bits):
    if bits == 0x7F800000:
        return Fraction(2) ** 128
    exponent, significand = bits >> 23, bits & 0x7FFFFF
    return Fraction(significand if exponent == 0 else significand + (1 << 23)) * Fraction(2) ** (
        -149 if exponent == 0 else exponent - 150
    )


def nearest(exact):
    low, high = 0, 0x7F800000
    while low + 1 < high:
        middle = (low + high) // 2
        if value(middle) <= exact:
            low = middle
        else:
            high = middle
    midpoint = (value(low) + value(high)) / 2
    return low + int(exact > midpoint or (exact == midpoint and low % 2 != 0))


rows = json.loads(Path(__file__).with_name("oracle.json").read_text())
checked = 0
for row in rows:
    lower = row["lower_bits"]
    midpoint = Fraction(int(row["midpoint_numerator"]), int(row["midpoint_denominator"]))
    assert midpoint == (value(lower) + value(lower + 1)) / 2
    for length in [1024, 65536]:
        for side in [-1, 0, 1]:
            source = (row["below_prefix"] if side < 0 else row["midpoint_prefix"])
            source += ("9" if side < 0 else "0") * length
            source += "1" if side > 0 else ""
            source += row["suffix"][:-3]
            exact = Fraction(source)
            expected = lower + int(side > 0 or (side == 0 and lower % 2 != 0))
            assert (exact > midpoint) - (exact < midpoint) == side
            assert nearest(exact) == expected
            checked += 1
for zeros in [10001, 20000]:
    source = "0." + "0" * zeros + "1000000059604644775390625e" + str(zeros + 1)
    assert Fraction(source) == Fraction(1) + Fraction(2) ** -24
    assert nearest(Fraction(source)) == 0x3F800000
    checked += 1
print(json.dumps({"arithmetic": "fractions.Fraction", "cases": checked, "result": "pass"}))
