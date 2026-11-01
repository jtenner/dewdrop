# Wave 1 item 02: ASCII trim views

Dependency: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Test checkpoint: five new tests for six exact ASCII whitespace bytes,
all 128 ASCII byte values, empty/all-whitespace text, interior whitespace,
NUL, non-ASCII spaces, UTF-8 boundaries, and nonzero view starts.
The API contract and example are in `std/README.md`.
The tests precede implementation; the trim methods do not yet exist.
No compiler command has run at this checkpoint. Gates and timings follow.

## Implementation checkpoint

Six new tests now include empty nonzero-start and all-whitespace views.
The six methods use ordinary Dew byte scans. `trim_ascii` composes the
start and end scans. String entry points first make a full shared view.
No builtin, compiler rule, module identity, or B-tree file changes.

For a valid UTF-8 view, every removed byte is below 128 and is therefore
a complete one-byte scalar. A lead byte or continuation byte is at least
128, so scanning stops before it. The end scan checks `index > 0` before
subtracting one. The start scan checks `index < length` before reading.
The existing `string_view_range` checks the resulting scalar boundaries.

The scan uses a fixed number of U32 locals. Existing `bytes_view` stores
`source.chunks` with new start/length fields; it does not copy payload.
Each one-sided view trim creates one range record; both-sided trim creates
two. String convenience adds one full-view record. Payload allocation is
zero; range-record use is O(1). A small result retains its source buffer.
Runtime heap measurements include GC/JIT noise and are not allocation counts.

First locked gate: generator check passed (0.02 s, 12,312 KiB peak RSS).
Native test-generator build failed before Dew tests ran: C compiler `cc1`
was killed. Elapsed 92.83 s, peak RSS 2,490,244 KiB. This exceeds 30 s
and is a visible compiler performance failure, beyond the accepted 67.88 s
cold baseline. Retry uses process-local `MOON_CC=/usr/bin/clang` and `-j 1`;
there is no SDK change. Full initial log is retained locally in `.tmp/gates.log`.
Gates are pending at this implementation checkpoint.
