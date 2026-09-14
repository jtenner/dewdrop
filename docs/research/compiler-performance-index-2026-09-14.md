# Compiler performance changes, 2026-09-14

This index groups the measured compiler changes by their implementation commits.
The primary agent implemented all fixes; the four audit agents only reviewed code.

## Generator build repair

The string benchmark and UTF parity generators now format filesystem errors with
`@debug.to_string`. The current error type no longer supports the old direct
`to_string` calls. This restores the native check lane without changing generated
programs. The final native workspace check passed in 8.963 seconds.

## Cache and parser work

Use byte views to avoid extra decode copies. Retry malformed cached ASTs with full
diagnostic paths while successful reads use short paths. Prehash owner sort keys,
binary-search saved cache indexes, index loaded owners, and use a set for merging.
Full digest, corruption, duplicate-owner, and V1 ordering checks remain. The final
cache lane passed 22 tests; loaded 4,096-entry lookup fell from 28.65 to 0.488 ms.
