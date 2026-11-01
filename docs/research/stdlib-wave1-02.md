# Wave 1 item 02: ASCII trim views

Dependency: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Test checkpoint: five new tests for six exact ASCII whitespace bytes,
all 128 ASCII byte values, empty/all-whitespace text, interior whitespace,
NUL, non-ASCII spaces, UTF-8 boundaries, and nonzero view starts.
The API contract and example are in `std/README.md`.
The tests precede implementation; the trim methods do not yet exist.
No compiler command has run at this checkpoint. Gates and timings follow.
