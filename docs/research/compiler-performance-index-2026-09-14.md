# Compiler performance changes, 2026-09-14

This index groups the measured compiler changes by their implementation commits.
The primary agent implemented all fixes; the four audit agents only reviewed code.

## Generator build repair

The string benchmark and UTF parity generators now format filesystem errors with
`@debug.to_string`. The current error type no longer supports the old direct
`to_string` calls. This restores the native check lane without changing generated
programs. The final native workspace check passed in 8.963 seconds.
