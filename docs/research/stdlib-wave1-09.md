# Item 09: sorted array bounds

Dependency: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
First checkpoint adds four tests. The APIs are absent at this checkpoint;
this is a red source checkpoint, not a passing candidate.

Contract: `array_lower_bound`, `array_upper_bound`, `array_binary_search`
take `(values, key, comparator)`. Their `_range` forms take
`(values, key, start, end, comparator)`. Ranges are `[start, end)`;
invalid ranges trap. Bounds return absolute indices, including `end`.
Empty ranges return `start` (search returns None) without comparisons.
Input must be sorted by the same strict weak order. The comparator must
not change the array or its ordering during a call. Equivalence means
neither key precedes the other; search selects the first equivalent index
in the range. Sortedness is a caller requirement, not an O(n) check.
Natural `Array<t: Lt>` methods use `<`. No new ordering trait is added.

Tests cover both orders, every small range, duplicates, reference keys,
empty/singleton inputs, and a linear oracle plus comparison limits.
Evidence and commands will be added after implementation.
