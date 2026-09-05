# SWAR parity harness repair

The parity generator did not build with the pinned MoonBit filesystem package:
`IOError` no longer exposes `to_string()`. Decode its message explicitly, as the
other compiler test drivers already do. This preserves the actual filesystem
error on failure.

`tools/swar-parity/run.sh` now passes 61,000 comparisons against its JavaScript
reference implementation. The measured compile-and-test lane took 7.945 seconds
with the packed-library migration in the worktree. Log:
`/tmp/dewdrop-packed-parity.log`.
