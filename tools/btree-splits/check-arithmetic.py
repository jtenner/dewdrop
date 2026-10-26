#!/usr/bin/env python3
"""Check every legal capacity/gap against the selected plain split equations."""
import json
import sys
from pathlib import Path

cases = 0
for capacity in range(12, 1024):
    minimum = max(capacity // 8, 4)
    small = min(2 * minimum, capacity // 2)
    for index in range(capacity + 1):
        separator = small - 1 if index == 0 else capacity - small if index == capacity else capacity // 2
        left = separator + int(index <= separator)
        right = capacity - separator - int(index <= separator)
        assert left >= minimum and right >= minimum, (capacity, index, 'occupancy')
        assert left + right + 1 == capacity + 1, (capacity, index, 'key sum')
        assert 0 <= separator < capacity, (capacity, index, 'separator bounds')
        assert (separator + 1) + (capacity - separator) == capacity + 1, (capacity, index, 'child sum')
        gap = index if index <= separator else index - separator - 1
        old_target = separator if index <= separator else capacity - separator - 1
        assert 0 <= gap <= old_target < capacity, (capacity, index, 'fresh target gap')
        cases += 1
report = dict(capacities=[12, 1023], gaps=cases, failures=0,
              checks=['M/A/j split equations', 'minimum counts', 'all-node key sum', 'child move count', 'fresh gap bounds before insertion'])
if len(sys.argv) > 1:
    Path(sys.argv[1]).write_text(json.dumps(report, indent=2)+'\n')
print(f'{cases} arithmetic split cases passed')
