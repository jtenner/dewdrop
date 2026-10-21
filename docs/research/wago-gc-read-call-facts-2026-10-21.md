# Checked reference facts across read-only calls

The four-second full Dew compiler target is still unmet. This change gives a
small measured gain; it is not a solution to the full gap.

A module pass proves a conservative subset of internal calls cannot allocate,
write, enter a host callback, or reach an unknown helper. It admits numeric,
local, and structured control operations plus supported final GC reads and
casts/tests. It rejects imported/indirect calls, recursive components, memory,
global/table access, unsupported field storage, custom-instruction modules,
and exception-handling modules. Call edges must all resolve to proved callees.
The temporary reverse graph is released after analysis. Only one boolean per
local function remains during emission.

The source planner and emitter use the same summary. Only checked address and
extent homes survive an admitted call. Register and fresh-allocation facts
still end there. Root masks, physical validation, failure order, saved artifacts,
and the native GC ABI remain unchanged. Writes, allocation, and host calls
clear the scratch as before. Control edges and loops still clear these facts;
this change does not establish an address cache across loop iterations.

## Tests and review

The new admission regression fails before the change: two saved checks are
reused instead of three. It passes after the change, both for a numeric callee
containing a loop and a callee that reads a typed reference field. Runtime tests
cover writes, allocation, host calls, forced collections, Tiny GC, and saved
artifact reload. The test asserts a real host call and real emitted reuse.

Daybreak Blue found an initialization path that replaced the inline target
table and lost the call summary. The replacement now retains that summary.
A separate regression fails against the old constructor and passes against
the fix. The second review found no issue. Both reviews were static only.

The full AMD64 backend, collector, and runtime packages pass normally and with
`wago_regalloccheck`. The runtime also passes with combined check/stats tags.
An initial full run lacked the pinned corpus; its failure remains saved. Reusing
the installed stack's exact pinned corpus fixes the test setup without skips.

The full backend suite with combined `wago_regalloccheck,wago_codegenstats`
has pre-existing peephole-stat assertion failures. A representative failure,
`TestCommuteSelfUpdate`, reproduces on unchanged base `6894c7f8a`. Do not count
that combination as green. The ordinary checked lane and focused new stats
tests pass. All raw failures and green results remain in the evidence.

## Full-job measurements

Same pinned compiler Wasm, request, isolated host patch, 512 MiB heap, 64 MiB
nursery, fresh native/result caches, CPUs 12 and 14, and GOMAXPROCS=2. No
task-owned builds/tests ran during timing. Serial paired order: control/candidate,
candidate/control, candidate/control. All output Wasm/cache hashes match and
main returns 42. The four-second V8 reference was not rerun.

Control: 33.502955, 33.375481, 33.141059 seconds.
Candidate: 33.180142, 32.875189, 32.901640 seconds.
Medians: **33.375481 to 32.901640 seconds, 1.42% faster**. Each candidate is
faster than its paired control. Median peak RSS rises from 1,129,652 to
1,136,824 KiB, approximately 7 MiB (0.63%). The candidate remains 8.23 times
the four-second target.

The final source produces exactly the measured candidate's native hash,
`add6f6c526d786080a80c214bbaac46cd88821fc2f7e426f1f40b9093c09dc71`.
Diagnostic compilation takes 0.512 s. It reuses 4,757 checks in 1,035 functions,
versus the prior 4,429 in 1,006 functions. Native bytes rise from 25,936,107 to
25,972,987 (0.14%). Exact roots remain 25,794 safepoints, 50,438 callsites,
77 maximum roots, and 1,803,076 metadata bytes.

The refreshed current-stack diagnostic job takes 33.764 s, with 26.64 of 34.02
sampled CPU seconds in generated code. `CollectMinor` takes 4.58 cumulative
sampled seconds. This is a diagnostic run, not a matched production timing.
It confirms that tuning collection alone cannot close the gap.

Small raw reports, tests, reviews, and measurements are in
`docs/research/data/gc-read-call-facts-2026-10-21/`. Large diagnostic maps and
the exact binaries remain under `/tmp/wago-four-seconds/`. This work has not
changed the installed compiler or the existing ARM64 working-tree edit.
