# Local Wago workers for source transforms

The user authorized a local Wago plugin that creates Wago workers on
2026-10-20. The lack of a built-in Wago worker API is no longer an external
blocker. This change adds the local host plugin after the checked trait-value
path.

The user also authorized local Wago plugin additions for missing instructions.
If Starshine cannot emit a required instruction, add and test that support in
Starshine, push the change to its remote, and update the Dewdrop pin. Follow each
repository's instructions and keep those dependency changes separate.

Keep the source-transform interpreter. A worker runs that compiler/interpreter;
it must not execute source transforms as separately generated Wasm programs.
Reuse compiled compiler code where the pinned Wago API permits it. Keep each
worker's mutable compiler state, transform globals, budgets, and error state
separate. Bound worker count, queue size, input bytes, and retained results.

Only independent transform applications can run together. Stacked transforms
and generated-source dependencies retain their required ordering. Publish
results and reports in deterministic source order. Worker errors, timeouts, and
cancellation must remain visible and must not publish a partial successful
compiler output or cache artifact. Check serial/parallel output and resource
report equality, and measure compiler time and process memory.

## Implementation

The local plugin is implemented under `tools/wago-transform-host/`. It exports
five byte-channel functions and uses at most two owned worker instances. Workers
reuse the same compiled compiler and run the existing interpreter. They receive
source snapshots, not compiler handles or another Wasm program. Stacked
annotations remain one job. The source codec uses version 1 with strict byte and
count bounds, checksums, complete input, and original source/report sites.

The parent checks each returned function's UTF-8, syntax, nesting, size, and exact
original header before accepting any reports. It publishes source and reports
in source order. Signature, adapter, import, declaration, and source-evaluation
changes that need ordering repeat the whole round serially. Candidate reports
are discarded before replay. Host traps, deadlines, cancellation, and malformed
messages remain visible failures. Output/cache publication retains the normal
final compiler checks.

The host accepts 64 jobs, 16 MiB per job, and 32 MiB per batch/result. It rejects
busy pools before copying input and rejects nested workers. Each worker publishes
once. A 120-second batch context inherits caller cancellation. Child instances
close and finish on every return. The compiler reserves 1 MiB of function source,
8 KiB of metadata, and a bounded allowance for each annotation report. This
currently sends at most 31 simple jobs in one round; larger bounds use serial
execution. These are message bounds, not managed-heap or process-memory caps.

Workers are enabled only by `DEW_TRANSFORM_WORKERS=2`. Empty or `0` keeps serial
execution. Other values are errors. Node and the Native compiler remain serial.
The host source and complete patch set are included in artifact identity. The
builder snapshots, hashes, and builds the same bytes in a fresh private source
copy. It does not change a Go module cache or a Wago checkout.

## Shared-collector race and isolation

The final buffer tests exposed a real race in pinned Wago. Ordinary `Fork`
instances shared one collector. Wago parked a guest and released the collector
lease before a host argument type check; another child then allocated while
that check read the handle table. The failing race log is
`.tmp/transforms-v5/resources/transform-worker-host-complete.log` (25.507 s).
The shared collector also forced guest compute under the global execution lock.
A host callback barrier alone did not prove parallel guest compute.

`patches/managed-isolated-fork.patch` adds an explicit `ForkIsolated` path to the
private pinned Wago source. Ordinary forks keep their behavior. Isolated forks
reuse code and retain Runtime ownership, hooks, policy, limits, cancellation and
managed cleanup. Each has a new private reference store and collector. Reference
imports are rejected. The registered private domain can root its own plugin
arguments; general collector ownership and token checks stay in force. The
existing independent-execution policy then permits per-instance native locks.
The first real parallel CLI request then failed with `compiled module is
closed`. The CLI did not keep its module handle live through invocation. The
public compiled owner's finalizer could close its handle while the parent still
retained a frozen execution snapshot. `cli-module-lifetime.patch` adds a deferred
module close for the full run, preserving instance/module/Runtime close order.
It does not bypass any public closed-code check. The failed 157.459-second run
is retained in `transform-worker-wago-parity.log` and is not a passing sample.

The next real request reached the fork and showed that the compiler uses a Wasm
start section, with no `__dew_init` export. The plugin now uses normal Wasm start
initialization, and its test fixture does too. It also showed that the Dew
backend exported only main. The core native build had the worker entry, but B
and C lost it. A new test read the encoded export section and failed on a missing
ordinary public function (14.355 s).

The Dew emitter now exports unique nongeneric public top-level functions from
the root module, using exact checked declarations and target indices. Private
helpers and implementation methods stay private. Ambiguous names fail clearly.
No worker name or standard-module path selects this rule. The regression passes
for an I64 function, a Unit entry and a private helper (14.840 s).

Starshine needed a general FFI export-construction API. Commit
[`1b237952167f582abd492aec27adf10c5a6c9e60`](https://github.com/jtenner/starshine-mb/commit/1b237952167f582abd492aec27adf10c5a6c9e60)
adds a byte-based function-export builder. Its first test failed on the missing
API. All 20 bridge tests, FFI build and FFI consistency check pass. The change is
pushed to `dewdrop-function-exports-20261020`, and Dewdrop pins that commit. This
is a source update, not a package release. No new Wasm opcode is needed.

## Checks and review

All 315 Dew transform tests pass (106.291 s for execution). Five protocol tests
cover the compiler message path. One compares complete source/cache/report bytes
to serial execution, including stacked mutable state. The others test replay
without partial reports, changed signatures/imports/declarations, malformed headers,
checksums, function sites, UTF-8, changed headers, added functions, and report
sites. The full lane exceeds the 30-second target and remains a performance fault.

B and C are identical at SHA-256
`a8f29a03453dc2b9dbe85c88bb9e4741a15d1c19da03580b605bbeb89f231186`.
The compiler is 2,724,036 bytes. Bootstrap takes 88.790 s; individual build and
execution stages remain below 30 s. Logs are in
`.tmp/transforms-v5/resources/transform-workers-export-bootstrap.log`. The final
export section contains the Unit worker entry and the ordinary Wasm start section.

The isolated patched host checks pass in 26.526 s. The final host, including the
CLI lifetime fix and normal Wasm start fixture, passes the same checks in 22.859 s. They include internal private
store/collector/code identity, independent execution, reference-import rejection,
complete close, and existing fork cancellation controls. Plugin tests use the Go
race detector and cover real two-worker overlap, state isolation, complete
source-order result bytes, disabled/busy rejection before input access, error
priority over result overflow, missing/duplicate publication, nested workers,
invalid buffers, traps, deadlines, and pool reuse. Five adapter tests pass too.
Evidence: `.tmp/transforms-v5/resources/transform-worker-isolated-host-final.log`
and `transform-worker-start-host.log`.

Read-only reviews inspected the compiler protocol, host, builder, adapter, and
isolation patch. The source-admission gap and shared-collector race were fixed
and their test cases retained. No open confirmed defect remains in those reviews.
The final header review also confirms that body-only rendering preserves exact
header bytes, including comments, spacing, newlines and generic parameters.
Claude review was unavailable because its normal account quota was exhausted.
No Claude review or native ARM64 performance result is claimed.

## Performance limits

Each job currently repeats full source preparation and semantic checking. Two
workers also add private heaps and message copies. Small transforms can cost more
time and memory. Keep workers off by default. The real Wago serial/parallel
harness records commands, exact build hashes, fresh native cache homes, elapsed
time, peak process RSS, and equal generated Wasm/cache bytes.

The first successful native run uses 2 GiB heap and 512 MiB nursery per instance.
Both requests are cold cache misses, validate, and return 42. The host logs two
worker applications only in parallel mode. Full generated Wasm and transform
cache bytes, including all reports, are identical:

- Wasm: `89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb`.
- Cache: `c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240`.

| Mode | Elapsed seconds | Peak process RSS, KiB |
| --- | ---: | ---: |
| Serial | 92.426880 | 3,260,208 |
| Two workers | 135.473999 | 8,061,880 |

The complete check takes 232.196 s. This is a performance fault, not a speed
gain. These are one-sample cold process measurements on a shared Linux AMD64
host; native code compilation is included. They do not isolate transform CPU
time, allocator traffic, retained guest heap, or native ARM64 behavior.
Raw commands, hashes, and samples are stored in
[`data/transform-workers-2026-10-20/large-heap.json`](data/transform-workers-2026-10-20/large-heap.json).
Local logs are `.tmp/transform-workers/run-aszike1u/{serial,parallel}.log` and
`.tmp/transforms-v5/resources/transform-worker-wago-parity-start.log`.
The host is committed as `a3e4ae1c0a`.



The final check defaults to a 512 MiB heap and 64 MiB nursery per instance.
The same compiler and host pass again, with the same Wasm and cache hashes:

| Mode | Elapsed seconds | Peak process RSS, KiB |
| --- | ---: | ---: |
| Serial | 93.303425 | 1,340,032 |
| Two workers | 169.749898 | 2,217,528 |

The full check takes 266.934 s and remains a timing fault. Peak process RSS is
lower in this pair, at the cost of a longer worker request. This is a bounded
memory setting for the test, not proof of a universal best heap size. One cold
sample per mode does not establish a stable runtime ratio. Workers remain off
by default. Use `DEW_TRANSFORM_GC_HEAP` and `DEW_TRANSFORM_GC_NURSERY` to choose
other check settings; these values are passed as explicit Wago CLI arguments.
Raw samples and identities are in
[`data/transform-workers-2026-10-20/small-heap.json`](data/transform-workers-2026-10-20/small-heap.json).
Logs are `.tmp/transform-workers/run-rvr6ozve/{serial,parallel}.log` and
`.tmp/transforms-v5/resources/transform-worker-small-heap.log`.


## Final compiler checks

The nine capture-cell checks pass (7.288 s generation, 1.400 s linking,
0.084 s execution). The first private runner omitted shared test helpers and
failed visibly. The corrected runner copies the four original helpers, including
their diagnostic trace, with no compiler or test assertion change. Its log is
`.tmp/transforms-v5/resources/transform-workers-final-complete-checks.log`.

The Native CLI rebuild takes 38.251 s, a timing fault. It compiles the public
parallel example in 0.844 s; the 16,863-byte output validates and returns 42.


The final B compiler passes all 66 public transform examples: each output
validates and returns 42. All 18 negative cases give the required diagnostic
and publish no output. The full request lane takes 338.869 s, a timing fault.
This includes the new trait/state/stacked-transform worker example in ordinary
serial mode. The two real Wago runs above cover its parallel mode separately.
