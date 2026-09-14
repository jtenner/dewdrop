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

## Semantic work

Compute only the requested interface closure. Reuse content hashes only for
modules completed in this invocation, retaining full refresh and stale-cache
checks. Intern imported structural types with owned keys and preserve first IDs.
Interface freezing fell from 3.86 s to 303 ms in pass two. Imported-type creation
fell from 797.15 to 2.99 ms in pass three. New ID and scratch-ownership tests and
all 36 existing import tests passed.

## Backend facts

Propagate effects through a reverse-caller worklist. Use a direct array for
emitted function provenance and signature facts. Exclude elided and signature-only
functions; assert valid, unique emitted indices. Chain and inline-function
regressions pass, as do the backend integration lanes.

## Core linker

Use a running cursor to map recursion groups, and index whether each type has a
declared subtype. Keep bounds checks and the previous handling of relative and
invalid supertype references. The 4,096-import complete-link probe fell from
13.01 to 3.87 ms, including index construction. Marker queries agree with the
old scan, and linked modules pass validation.

## Bootstrap identity experiment

Extract the existing fingerprint loop for a native benchmark. Hashing the built
compiler plus standard sources took 128.29 ms; the current source check took
52.28 ms. Reject the artifact-hash variant and retain production identity behavior.
All nine bootstrap tests pass. This does not measure a generated build-time stamp.

## Shared evidence and next work

The benchmark tools measure each operation. Full-build comparisons alternate
compiler snapshots and require identical Wasm. The latest 128-module build fell
from 2.228 to 1.559 seconds. The latest validation has 326 passing tests, and
self-host A/B/C core bytes match the baseline; B and C reach a fixed point.

- [First audit and scaling probes](compile-scaling-2026-09-14.md)
- [Second audit and hot-path probes](compile-hotpaths-2026-09-14.md)
- [Third audit and every self-host step](compile-imports-2026-09-14.md)

Remote master diverged during this work and pins another Starshine revision.
Publish the tested snapshot on `perf/compiler-compile-times`. Next, reconcile the
Starshine revisions with master and rerun integration and self-host checks. Then
profile the roughly 20-second Dew compiler executions, and address the initial
31.446-second native linker build-plus-link. Neither is fixed by the measured
many-module gains. These steps are future work, not completed results.
