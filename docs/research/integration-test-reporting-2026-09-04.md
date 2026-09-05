# Native integration test reporting

The integration lane measures each owning file through `self_host_measure`,
matching the routine native lane. A file that takes more than 30 seconds reports
a compiler performance bug rather than hiding it in an aggregate duration.

One failed file no longer prevents the remaining independent files from running.
Every failing test keeps its original diagnostic, and the script returns failure
if any file fails. This is needed when a representation change affects multiple
stored type-index assertions: one run must show all of those failures.

`bash -n tools/test-integration-native.sh` passes. The packed builtin migration
uses this lane and records its runtime results in
`docs/research/raw-wasm-builtins-2026-09-04.md`.
