# Wave 1 item 04: relative path parts

Base: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Branch: `worker/wave1-item-04`. Sole worker. No B-tree edits.

Test checkpoint: seven new tests in `std/tests/path_parts_test.dew` define
filename, optional validated parent, stem, and optional extension. Last dot
wins except at filename byte zero. Trailing dots give an empty extension.
A single component has no parent. See `std/README.md` for the API and example.
Cases cover UTF-8, repeated dots, dotfiles, exact 4096 bytes, overflow and
escape checks. Existing host escape tests are unchanged.

This checkpoint is red by inspection: the four methods do not yet exist in
`std/path.dew`. No compiler command has run at this checkpoint.

Baseline: owner G0 PASS WITH KNOWN RED; 355 public std tests, 41 separate
private B-tree tests, 42 traps and 4121 operation probes. Eight public provider
tests are not counted again. Mission A reviewed the eight snapshot differences
at this dependency checkpoint. No snapshots will change. SDK remains
`/data/home/.moon`, Moon 0.1.20261023, core 0.10.17+d971670cd.
