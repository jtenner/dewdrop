# Native test failure collection

Date: 2026-10-18.

The routine native lane now runs all selected owning files after a test fails.
Each failure and its timing remain visible. The script returns a nonzero status
if any selected file fails. This matches the complete integration lane and
avoids repeating earlier passing files to find the next fault.

No test result is replaced or ignored. Compiler activities still use the same
timing helper and the same 30-second warning. Run `bash -n tools/test-native.sh`
to check the script syntax. The final validation report records the full runs.
