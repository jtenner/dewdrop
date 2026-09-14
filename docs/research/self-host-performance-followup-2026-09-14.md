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

## Function names for profiling

Preserve function names through linker index remapping and cleanup. The new native
regression failed before this change and passes afterward; all 19 core-linker
tests pass. Invalid debug indices remain non-semantic. The baseline compiler with
names has identical executable sections and resolves the numeric Node samples.
`tools/summarize-self-host-profile.py` reads those names and can verify executable
sections against the original compiler before mapping profile samples.

## Self-host compiler fixes

Allocate known-size Bool and U32 arrays directly, with count and capacity equal to
the requested length. Reuse the existing exact call index and assert valid,
matching function slots. Two Dew tests check fill, growth, mutation, and generic
call classification against the old scan, including misses. Both pass through
`tools/test-self-host-performance.sh`.

The same-request benchmark alternates saved compilers, discards one warm-up pair,
and measures three pairs. Median compilation falls from 18.402 to 14.294 seconds.
All eight executions produce identical output. The full A/B/C bootstrap also
passes and reaches a fixed point. `tools/benchmark-self-host-compile.py` provides
the repeated measurement and exact output check.

## Cold linker build fix

The native linker fixture now selects GCC with `-O2 -pipe -flto=8`, retaining
wrapping arithmetic, aliasing flags, and the MoonBit mimalloc configuration.
The same-C-file build falls from 25.576 to 7.264 seconds. Median linker runtime
also improves from 5.326 to 5.175 seconds, with identical output in every run.
A fresh MoonBit target directory takes 10.442 seconds to build the whole tool;
the first B/provider link takes 5.138 seconds. The combined 15.580 seconds stays
below the 30-second limit. This setting is scoped to the native linker fixture.
