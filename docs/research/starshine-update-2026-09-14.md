# Starshine update, September 14, 2026

The submodule advances from `6d17355e575c05ed2ac8dbad286e08a6eb00cb72`
to `983dfb180031ad8640b19e2f30bebc143524f348` by fast-forwarding
`origin/master`, adding 211 commits. The update includes optimizer correctness
repairs, performance work, and public IR interface changes.

`tools/test-integration-native.sh` and
`tools/check-self-host-bootstrap.sh --fast` both pass on this workspace.
Existing compiler and source changes were committed separately before this pin.

The first integration run exposed the new third argument on `ArrayLoad` and
`ArrayStore`. The linker now preserves their alignment and offset while remapping
the backing type. These arguments cannot select a linear memory, so they must
not go through the linear-memory index remapper. A bounded linker regression
checks nonzero offsets and changed type indices; all 15 linker tests pass in
3.699 seconds.

The new atomic setters and waitqueue instructions also require explicit linker
cases. Waitqueue heap types have no compiler-facts v1 representation: omit that
optional fact rather than invent a heap type. The provider build exposed stale
generated FFI exports in the upstream checkout. Regenerating the Dew consumer
and its exact provider fingerprint took 4.301 seconds. A check against the original export metadata failed: it omitted three exports
present in the rebuilt provider. Local Starshine commit `de52f1d14` saves the
regenerated wrapper source, export metadata, and FFI documentation on top of
upstream `983dfb180`. `bun ffi check` passes with 4,214 exports in 6.433 seconds.
The Dew consumer and fingerprint now record that local revision; regeneration
took 4.053 seconds. The submodule is clean. Neither repository has been pushed.

Logs are under `.tmp/starshine-update-20260914/`. Initial failed runs are retained.

## Completed bootstrap checks

The updated provider passes all 151 routine backend tests. The initial updated
bootstrap passes with identical B/C SHA-256
`6275a58f46fc15928fa3a0985d7255d375b161885363d3275eafd903b46ce798`.
A's source build took 16.405 seconds, A emitted B in 20.886 seconds, and B
emitted C in 20.845 seconds. The cold native link took 34.587 seconds (a
performance bug); warm links took 5.571 and 5.580 seconds.

The bootstrap after the Array literal change also passes. See its
[implementation record](array-literal-calls-2026-09-14.md) for current timings.

The final integration lane passed all 271 tests. The program-link-plan group
took 43.759 seconds, a performance bug. The final linker run passed all 16 tests
in 11.203 seconds, including aggregate atomics and waitqueue identity remaps.

The final hardening lane also passes: 973 tests, 504 exact invariant failure
records, and all emission and semantic probes.
