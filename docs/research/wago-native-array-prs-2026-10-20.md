# Wago GC improvements, separate PRs, and local install

The [fresh three-run Wago/V8 comparison](wago-v8-compare-2026-10-21.md)
measures the installed `69c165ace` GC stack at a median 49.255 seconds versus
3.676 seconds for V8. All six outputs match. Wago takes 13.40 times as long.

## Review branches

Each branch starts at `origin/main`, commit
`ed76fd17957fd472b92a69d2fa3f5f63680f2cd5`. The two new branches each have one
commit and one GC improvement. Each commit includes tests, benchmarks, and docs.

| PR | Improvement | Pushed commit | Local cherry-pick |
| --- | --- | --- | --- |
| [999](https://github.com/wago-org/wago/pull/999) | Adapt canceled struct batches | `1153cd382` | `ce9e051d6` |
| [1000](https://github.com/wago-org/wago/pull/1000) | Share nursery handles with small arrays | `861842347` | `17282fb59` |
| [1001](https://github.com/wago-org/wago/pull/1001) | Native `v128` array access | `ac425c11c` | `f9c0e7a18` |

PR 999's benchmark commit `4738f4e6f` was picked as `6b351ee9c`. Its TinyGo
benchmark portability commit `668413a17` was picked as `62e70329e`.

Workspaces:

- `/home/dev/Projects/wago-gc-native-batch-cancel`, branch `perf/gc-native-batch-cancel`.
- `/home/dev/Projects/wago-gc-shared-nursery-pr`, branch `perf/gc-shared-nursery`.
- `/home/dev/Projects/wago-gc-vector-array-pr`, branch `perf/gc-vector-array-access`.

The original combined experiment remains at
`/home/dev/Projects/wago-gc-shared-nursery`. It is not a review branch.

## Measurement

The shared-nursery loop improved about 15 times. Vector array reads improved
22.11 times and writes improved 26.78 times. The checked V8 comparison still
fails: Wago is 5.47 times slower for the read loop and 6.36 times slower for writes.

The final serial full-job check took 63.582962 seconds in Wago and 3.486970
seconds in V8, a ratio of 18.23. No test builds ran during this pair. This is one
pair, not a statistical speed claim. Earlier Wago results were 123.955 seconds
before these fixes, 93.822 after batch adaptation, 79.588 after shared nursery
allocation, and 71.240 after vector access while other builds were active.

Both engines used compiler SHA-256
`c64fcf044b72cb7356ad598a35670045931337cfa7a6bb9d5916cd304b23fba6`
and request SHA-256
`077b0ff0271706cc3034f3e06c7a228f227c49aeec7786d21373b2072af89c72`.
Both output hashes matched the preceding checks, the Wasm validated, and the
output program returned 42. The result cache missed. The full compiler check
uses the existing private Facet host linked to the same GC source files as the
installed runtime.

The final profile removes all 90.7 million vector array-get helper calls. It
records 49.40 seconds in generated native code; that code needs more attribution
before assigning its full cost to GC. V8 parity is not achieved.

## Checks and install

Full standard, register-checked, and benchmark-module suites pass on the combined
candidate. Independent review branches pass their focused runtime and compiler
tests. Docs checks pass. The installed GC stack passes its GC/runtime tests with
register checks and the vector compiler selection check with codegen statistics.

The first broad run used `GOWORK=off`, which broke the nested installer test.
TinyGo build tests also needed `GOFLAGS=-buildvcs=false` in the local temporary
source setup. Complete reruns with the workspace enabled and that stamping flag
pass. The pinned Core 3 reference interpreter and PowerShell invariant locale
were supplied. Initial failures remain in the raw logs.

Installed source is
`/home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago`, branch
`dewdrop/local-gc-perf-20261020`, commit
`f9c0e7a18b31ea3dd95485e2ff70b6b9378bf05e`. Changelog conflicts kept both sides.
The pre-existing ARM64 `call.go` edit retains SHA-256
`33b8f91b38727df8487afc9c7a99d6c59bca0ed5d8be1b927c0ad6fefa2f0818`.

Selected version: `local-gc-f9c0e7a18`, standard profile, normal Go build.
Manager: `/home/dev/.local/bin/wago`.
Runtime:
`/home/dev/.local/share/wago/versions/local-gc-f9c0e7a18/standard/normal/wago-runtime`.

Builds, hashes, installation checks, exact commands, and full timing pairs are
in `/home/dev/Projects/dewdrop/.tmp/wago-v8-target`. The install manifest is
`install/installation.json`; the installed-command checks are
`install/verification.json`. Previous installed versions remain available.

```sh
wago --json --version
```


## Follow-up changes on 2026-10-21

Three independent improvements were added to existing public PRs and pushed:

| PR | Public commit | Local stack commit | Change |
| --- | --- | --- | --- |
| [976](https://github.com/wago-org/wago/pull/976) | `4b0e4e201` | `22d1a0e5e` | Canonical ID shortcut before subtype intervals |
| [1000](https://github.com/wago-org/wago/pull/1000) | `9dc876800` | `e95c8f7a8` | Native small uniform arrays with dynamic lengths |
| [948](https://github.com/wago-org/wago/pull/948) | `924cfbb4c` | `0efd9ac6c` | One resolution for a final cast and numeric/vector field read |

The identity microloops improve 1.38–1.41x, with a 3.69% proper-subtype control
regression. That change alone does not improve the full compiler beyond noise.
Dynamic uniform mixed allocation improves 68.30x at equal warmed invocation
counts. Cast/field-read loops improve 2.15x for i32 and 20.86x for v128. The latter
loops remain 11.55x and 13.27x slower than V8; dynamic uniform allocation remains
7.28x slower. These figures do not establish instruction latency in isolation.

The combined full compile measures 63.386 seconds after identity, 59.467 after
dynamic uniform arrays, and 50.551 after field-read fusion. A later control on
the same final host measures 51.985 seconds. Wasm and cache hashes match the
previous recorded hashes; validation passes and `main` returns 42. The identical
compiler on V8 previously measured 3.487 seconds, so parity is not reached.

A proposed array-cast/read fusion in the `perf/gc-vector-array-access` worktree
improves small scalar/vector loops about 1.8x, but regresses the full workload
to 77.117 seconds. It remains uncommitted and is excluded from the install.
Instruction profiling is in progress to explain that regression.

The full checked stack exposed an existing prefix-copy diagnostic: a bounded
RAX save/restore writes a live pending-load address before restoring it. New
[PR 1002](https://github.com/wago-org/wago/pull/1002), public `5225c0e9e`, local
`69c165ace`, uses an allocated scratch instead. It removes the temporary borrow
and its extra save/load/slot, keeping the checker intact. The new integer-predicate
regression fails on the parent and sums all forty distinct f32/f64 loads after
the fix. The complete origin/main checked compiler package passes.

The local stack now ends at `69c165ace`; its only user change remains the original
ARM64 `call.go` blank-line deletion with SHA-256
`33b8f91b38727df8487afc9c7a99d6c59bca0ed5d8be1b927c0ad6fefa2f0818`.
Installed and selected `local-gc-69c165ace` at `/home/dev/.local/bin/wago`. Both
manager and runtime build in 4.8 seconds. All 24 install/smoke checks pass.
Full final checked tests pass in 148.747 seconds; the nested benchmark suite
passes in 27.330 seconds. The initial standard suite had one transient ETXTBSY
plugin-install failure; its full package repeat passes. The final standard rerun after the scratch repair passes in 135.131 seconds.
A full compile using compiler sources verified against the installed stack takes
50.272 seconds, with identical valid output. Raw logs and timings are in
`.tmp/wago-next-gc-perf/`; public PR research notes include their small-loop data.
