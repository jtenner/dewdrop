# Self-host performance follow-up, 2026-09-14

## Merge with master

Merged remote master `2423d85c` into the performance branch. Its Starshine pin
`7bf3c39c` is an ancestor of the tested local pin `de52f1d14`, so the merge retains
`de52f1d14` and includes all remote repairs. No Starshine code conflict exists.

All 271 integration tests passed after the merge. The full A/B/C self-host run
also passed with CPU profiling enabled. B and C still have linked SHA-256
`215f26625c8e00510b3428a11f350c94919a40fec828d76f03c42a0bbc24aacf`.
Logs and profiles are in `.tmp/self-host-perf-followup/`.

## Initial findings

The A-to-B CPU profile attributes about 1.9 seconds to garbage collection.
Function symbols are lost during linking, so the remaining hot functions need
names before selecting a source fix. The native linker generates an 18 MB C
translation unit; its C compilation must be timed separately from linker runtime.
