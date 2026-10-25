# Astra review and further Wago GC work

The user asked Astra to find concrete runtime improvements, then asked Claude
for an independent bottleneck review. Each accepted fix follows the same path:
separate review branch, tests and measurements, ready PR, then cherry-pick into
the local combined GC branch. Unproven large rewrites are not speed claims.

## Profile scope

Astra read the existing cast-kind profile: 41.86 of 51.45 seconds (81.36%) is
generated native code; minor GC totals about 5.05 seconds (9.82%). The Go
ArrayCopy helper totals only 0.35 seconds (0.68%). Promotion sorting accounts
for about 0.54 seconds. These are diagnostic profile observations, not release
benchmark times. Helper counts alone do not establish the time spent there.

## Accepted changes

| Change | Ready PR | Public commit | Local pick |
| --- | --- | --- | --- |
| One native abstract-array cast and length read | [1003](https://github.com/wago-org/wago/pull/1003) | `7e6927f68` | `6b2e39210` |
| Stable bounded promotion buckets | [1005](https://github.com/wago-org/wago/pull/1005) | `2a2c75b4b` | `41a4e4b2c` |
| Integer leaf inlining with exact GC roots | [1007](https://github.com/wago-org/wago/pull/1007) | `a59763770` | `f71a0eb1d` |

The first change is tested against the complete installed GC stack. A paired
control/candidate/candidate/control test uses CPU 12,14, GOMAXPROCS=2, fresh
native caches, and the same compiler/request bytes. Control times are 49.893
and 49.134 seconds. Candidate times are 47.190 and 47.832 seconds. Medians are
49.514 and 47.511 seconds, a 4.04% drop. All output hashes match and main is 42.
The host remains shared. No task-owned build or test overlaps this lane.

The installed-stack small-loop result is 20.40x for cast/length and 7.29x when
allocations are mixed in. The earlier 39.36x loop result used an older base
without native general array.len. It must not be reported as the gain over the
installed stack. Read-only Go helpers already preserve allocation batches.

The full normal suite passes for PR1003. Its full checked run passes compiler,
collector, and public runtime packages; the plugin-install package has a
transient ETXTBSY failure and passes on rerun. Checked benchmark tests, focused
codegen/register checks, legacy metadata, 24 live locals, forced GC/Tiny profiles,
ARM64 interval tests under QEMU, and same-codec old/new native artifact execution
pass. The combined pick preserves the user's ARM64 source edit and matches the
measured candidate production functions.

Promotion buckets preserve the exact old stable sort order and failure points.
The comparison-sort fallback and 1.25 MiB scratch cap bound its cost. Microbench
sorting improves 9.5–17.3x against the combined stack's cached comparator, but
the profile limits any full-job saving to about half a second. The combined
fallback must keep its pre-existing cached allocation keys.

Getter inlining accepts only local.get0/final-cast/same-type-field-read/end.
It keeps dynamic null/type/extent checks. Astra found that an eliminated call
must still consume its source root-mask entry; otherwise later allocating calls
use the wrong masks and exact-root admission fails. The regression fails with
that cursor advance removed. Normal and checked focused tests cover all scalar,
packed, vector, and reference results, traps, and live roots across collection.

## Independent Claude review

Claude Code completed a read-only Opus review. The full independent report is
[stored here](wago-claude-bottlenecks-2026-10-21.md). It read existing profiles,
source and compiler WAT; it did not run new timing tests. Its speed estimates
are hypotheses, not measurements. The main proposals are:

1. Inline bounded numeric leaf functions while keeping exact GC call masks.
2. Retain proven final-type facts across calls, without retaining raw addresses.
3. Keep freed nursery handles in order to improve handle-table locality.
4. Extend the existing reference register ABI to ordinary direct calls.
5. Reduce the dependent loads in checked object resolution.

Astra reviewed the report. It recommends straight-line i32/i64 leaves first,
with no calls, GC, memory, globals or control flow, and explicit source-call
mask consumption. Forwarders should start with exact Wasm signature equality.
A type fact alone does not justify removing the runtime's extent checks.
Sparse compaction must not duplicate already-free reserved handles. The
reference ABI helper already exists but ordinary reference-parameter calls
still use wrappers. The numeric-leaf fix is now ready as PR1007 and picked locally.

## Experiments kept out of the install

Getter loops improved about 1.30x for i32 and 1.26x for v128. The full paired
job did not improve: control 52.599/51.786 seconds, candidate 56.560/52.755,
median 52.192 to 54.658 seconds (4.72% higher). Shared-host load changed during
this run. The change is not published or installed; the result is insufficient
to claim a full-job gain. Source analysis also suggests extra resolver bodies
in callers could increase code size. Neither explanation is proven.

## Incoming safety fixes

A read-only watcher checks the open upstream GC/compiler PR heads every minute
while this task runs. It records snapshots and changes under
`.tmp/wago-next-gc-perf/upstream-watch-*`. Never use the shared repository's
FETCH_HEAD as a stable commit reference; another checkout may update it.

- PR1002 added test `847b3531e` and fix `e85aabe0b`. The staged spill suffix
  invalidates the cached spill extent so later spills cannot overwrite it.
  The regression failed before the fix. Local picks are `17bf49e24` and
  `22ba58656`; full affected packages pass ordinary and checked runs in
  40.502/42.532 seconds.
- PR1003 added test `f600f30c9` and fix `44ac1bbf2`. Independent root types
  added at runtime must use the new subtype kind encoding. Otherwise a struct
  can be accepted as an abstract array. The regression failed before the fix;
  ordinary and checked tests pass in 19.116/21.277 seconds. Local picks are
  `7d219e5d8` and `20992c540`.
- Astra found that the final-struct cast/get resolver entered a function's
  trap tail before restoring saved R9/R10/R11. Failed casts overwrote dirty
  globals, including with native addresses. Its dedicated test failed before
  the fix. Commit `492475e0c` restores pins in two cold failure blocks before
  trap handling; success instructions are unchanged. Ready PR [1006](https://github.com/wago-org/wago/pull/1006), public
  commit `021d36398`, local pick `0fde6f6b1`. Full ordinary/checked repository
  runs pass in 35.574/34.777 seconds after the checkout environment is restored.

- PR980 added test `3dfadf1ec` and fix `0a45af623` for disabled general
  array-length shared stubs. The regression failed then passed in 4.724/4.987
  seconds. Local picks are `35d4c9dcf` and `b46adbb87`.
- The same guard was missing from PR1003's new adjacent cast/length path.
  Extended codegen tests failed before repair. Public commit `21fb47c09`
  updates PR1003; local pick `03b405471` includes it. Normal/checked focused
  tests pass in 15.986/15.529 seconds. Default generated code is unchanged.

The PATH install is now `local-gc-03b405471`. Both manager/runtime builds take
about 5.09 seconds. All 27 CLI/build/smoke checks pass, including abstract-array
loops, 24 live integer locals, scalar/vector fields, mixed constructors, four
dynamic array sizes, and an older native artifact. The combined backend,
collector and runtime packages pass normal/checked in 43.932/42.191 seconds;
focused checked diagnostics pass in 0.570 seconds. The user ARM64 call.go edit
keeps SHA256 `33b8f91b38727df8487afc9c7a99d6c59bca0ed5d8be1b927c0ad6fefa2f0818`.

A broad extra run with both codegen stats and register-check instrumentation
reports existing pure-integer peephole-count failures, including
TestCommuteSelfUpdate alone. The required register-check suite and focused GC
stats tests pass. Logs are retained; these optional failures are not hidden.
Astra is checking the corresponding base behavior while preparing the next PR.

Raw Astra measurements and validation logs are under `.tmp/wago-next-gc-perf`.
PR1003 and PR1005 include bounded research notes and raw results in their Wago
`docs/research` folders.

Final measured update: PR1007 removes 11,886 compiler calls. Three-sample
medians are 47.499 to 45.916 seconds (3.33% lower), versus V8 4.017 seconds.
See [the full follow-up record](wago-gc-followup-2026-10-21.md) for samples,
root admission, safety picks, source identity and final installation.
