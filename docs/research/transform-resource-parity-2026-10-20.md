# Shared transform resource charges

This change gives the native and Dew interpreters the same logical resource
policy. It also removes repeated source and field scans. These counts are work
estimates, not measured heap usage.

## Policy

- A checked source call charges one entry event: 32 units plus 16 per argument.
  Cold and cached calls use the same events. AST and bytecode execution keep the
  same source events.
- Name queries charge once, rather than once per declaration inspected. Imported
  type fallback, fresh-name collisions, field reads, and type-node results keep
  explicit costs. A reflected-expression query charges once for the query and
  once per returned node; binary-search steps do not consume source work.
- Raw String storage reads charge 16 plus UTF-8 byte length on every read. The
  internal cache cannot change this fee. Diagnostic lists wrap immutable
  compiler-owned messages at 16 units per entry. Reading message storage uses
  the ordinary String rule; different checker wording does not change list cost.
- Work exhaustion leaves both counters unchanged. Allocation exhaustion consumes
  its work event and keeps the allocation counter within its limit. Array copy
  completes and checks every source read before any destination write.
- Module, declaration, alias, annotation and fresh-name indexes are plan metadata.
  Wide record field indexes keep the original mutable cells. Small records and
  views retain bounded scans. Record duplicate names use the last binding; view
  layout duplicate names use the first position, as before.

The lookup and annotation notes in this directory describe the index structures,
raw scaling samples, source identities, added memory, and measurement limits.
No claim about constant memory, retained heap savings, or isolated allocations
follows from peak process RSS.

## Checked-source comparison

`tools/dew-test/transform-resource-counts.json` holds version-1 reports for 18
public examples, including two annotations in the text example. Each source has
an exact SHA-256. `tools/generate_transform_resource_tests.py` validates the
source hashes and generates native and Dew tests from one report set. Its check
mode rejects stale generated tests. The native output uses `moonfmt`.

The native compiler measured all examples without a transform-result cache.
The current paired suites pass all 18 cases in each implementation. They check
module, file, function, transform, offset, work, and allocation work. The text
annotations use 55,212/1,040,851 and 38,406/707,380 work/allocation units in both
engines. The focused VM cases also check cold/warm calls, arithmetic, plain
matches, qualified unit patterns, discard bindings, unrelated reflected-type
entries, UTF-8 cache reads, failures at budget boundaries, and atomic copy reads.

The cost comparison exposed and fixed source-semantic differences:

- Dew charged a second lookup event for a qualified unit pattern. Tuple payload
  patterns retain their separate checked-path charge.
- Dew reused `$for_iter`; native used `$for_iter_OFFSET`. Dew now keeps distinct
  generated names. This preserves reflected labels and nested scope bindings.
- Dew expanded a top-level discard into two expression items, including an empty
  block. It now keeps the same single evaluated binding as native.
- Dew skipped imported operator selection for primitive receivers. It now keeps
  selected source implementations, missing-method errors and ambiguity. A
  separate scalar proof can still remove a selected call. Narrow shift tests
  check the standard masks in bytecode and whole-function interpreter fallback.
- Dew indexed packed type results by source ID after lambdas. Reflection now
  maps each body's and lambda's source span to its inference-job span. Both
  expression and block types are covered. A control build with the old mapping
  and correct imports fails the two new value assertions; the fixed build passes.

## Evidence and timing

Raw logs, traces, source snapshots and process samples are retained under
`.tmp/transforms-v5/resources/`. Temporary per-event tracing was removed before
validation. It never forms part of the production resource policy.

- Native CLI JavaScript build: 1.813 seconds.
- Eighteen native example processes: 27.118 seconds total; each process records
  elapsed time, peak RSS and exact reports in `native-samples.json`.
- Native paired driver tests: 18/18, 22.831 seconds, including a new test build.
- Dew paired test generation/link/execution: 6.987/1.287/15.298 seconds;
  whole invocation 28.174 seconds, 18/18 pass.
- Focused native and Dew resource tests: 14/14 each.
- Reflection old-mapping control: 3 pass, 2 fail on the intended type assertions.
  Fixed mapping with required Array imports: 5/5 pass.
- Imported primitive operator tests: 18/18 pass after two intended red failures.
  The narrow-shift result check fails before the fix and passes after it.

Earlier full-suite and collection runs above 30 seconds remain recorded faults;
this change does not claim those aggregate activities are below that limit.
The initial native release benchmark build took 31.608 seconds. The first paired
Dew report invocation took 31.087 seconds. A historical 18-process collection took
34.511 seconds. A private trace comparison used a quadratic alignment algorithm
and was stopped; charge totals and linear comparisons replaced it.

Two initial regression attempts failed on test setup or syntax before they
reached the intended checks. Those logs remain visible. They are not successful
red controls. A missing Array import also exposed a separate early frame-setup
failure. Both engines now check the selected transform's saved body error before
frame setup. Dew also excludes saved bad helper bodies at both specialization
queue gates and frame-proof export. Reached calls still use the saved body error;
unused and unreached helpers stay deferred. The tests explicitly require the
final normal source check to reject each unchanged bad helper.

Broader compiler, bootstrap, request and host checks are recorded separately
when run against the final frozen source set. This note does not claim they
have already passed.

The wider native transform lane passed 313/313 tests across 31 measured groups.
Its 199.925-second aggregate is a recorded timing fault. After the early body
guards, native VM 135/135 and driver body-guard 15/15 checks passed; the latter took
27.511 seconds. Dew body guards passed 20/20 in 16.801 seconds; generation, linking
and startup made that invocation 30.557 seconds, another recorded timing fault.

The production `tools/test-transforms.sh` lane passed all 272 Dew tests. Its native
generator build took 27.703 seconds; generation/linking took 7.326/1.350 seconds.
Execution took 79.820 seconds and the complete invocation 120.812 seconds. Both
execution and total are recorded timing faults. The helper barrier's final
native 15-case file passed in 27.511 seconds. These checks do not make a claim
that the full suite is now fast.


## Discard tails and nonreturning blocks

A fresh compiler bootstrap exposed two ordinary compiler defects after discard
parsing was aligned. Dew HIR still converted `_` bindings to expression items.
A final non-Unit initializer then leaked its value into the surrounding block.
All parser lets now keep ordinary HIR let semantics, including Unit at a normal
block tail. The initializer is still evaluated once. Repeated discard names get
separate checked locals. The old wildcard-collection expectation was corrected,
and its seven existing body tests are now registered in the transform lane.

A second defect affected the physical block-result helper. A final let whose
initializer never returns has checked non-fallthrough flow. The helper ignored
that flow and returned Unit. It now reads the existing flow flag and returns
Never before it checks the tail shape. Return operands, call operands and local
initializers retain their physical checks. This adds one flag read and branch,
with no new storage. The new physical-pipeline test checks Never, normal Unit,
and normal String controls. It failed at the intended Never assertion before
the fix (13.220 seconds) and passed after it (13.012 seconds).

The prior bootstrap failures and exact inputs are retained in
`bootstrap-discard-tail-red/` and `bootstrap-block-flow-red/`, with matching logs
and input hash manifests under the evidence directory. No verifier was relaxed
to make these builds pass.

The first clean A/B/C bootstrap passed, including B semantic probes and exact
core, raw and linked B/C equality. Compiler B and C SHA-256 is
`d5c9a004ee14f8f88a3a2e8792e8f842979a26995aeb052cb26cc65238e6851b`.
Native A source build took 18.824 seconds; A and B source compilation took
21.870 and 24.653 seconds. The full 78.842-second invocation remains a timing
fault. `bootstrap-before-builtin-fix-inputs.json` records that frozen source/provider set.

Six ordinary Wasm controls passed: discard, named-unused, and nonreturning-let
in both engines. All validate and return 42. Discard and named-unused code
sections are byte-identical within each engine: Native 71 bytes and Dew 75 bytes.
Their main functions each declare three locals. This proves no extra emitted
code or local slot for the discard spelling in this small control; it does not
prove that unused bindings need no HIR metadata or physical slots. The existing
local-read search can still scale with bindings times expressions. No general
compile-time or memory improvement is claimed for that path. Raw function body
hashes and local counts are in `discard-runtime/layout.json`. The complete six
control invocation took 10.195 seconds.

Independent GPT review covered the resource snapshot, the discard fix, and the
physical-flow addendum. No confirmed defect remained in that scope. Review
reports list unread auxiliary evidence and limits. Claude Code could not review:
its weekly quota is unavailable until October 24. No Claude assessment is claimed.


## Static builtin callees in global initializers

The first real-request run passed 23 examples, then the constants example
trapped at invariant 504 in the initializer dependency walk. Its selected
multiplication source body called a builtin. Dew consumed a statically selected
ordinary callee during lowering, but omitted the builtin-call case. That left a
syntactic callee as `PlannedModuleValueGet(0)`. The dependency walk correctly
rejected that phantom global read. The fix adds the builtin case to the same
producer rule as direct calls. Function-value calls and the missing-global
assertion stay unchanged. This adds no new pass or storage.

A standalone regression uses a custom multiplication builtin, a source wrapper,
and two genuine global initializers. It checks consumed static callees, retained
real global reads, dependency order and physical plans. Before the fix it fails
the intended real-module-let assertion (13.109 seconds). The real failed request
and its compiler are retained in `constants-red.bin`, `requests-constants-red.log`
and `bootstrap-before-builtin-fix/`. The stopped request batch took 78.630 seconds,
another recorded timing fault. A fresh compiler build and request rerun follow
the producer fix; the earlier bootstrap alone does not prove the fix.

The complete native integration lane passed 272 tests in 17 files. Its total
74.269 seconds is a timing fault; each measured file stayed below 30 seconds.
The full Dew lane before the builtin fix passed 281 tests, with 79.898 seconds
for execution and 93.195 seconds in total. Both are timing faults. These were
passing checks; they did not cover the new ordinary builtin-initializer case.


## Final frozen checks after the builtin producer fix

The new builtin regression passed in 12.971 seconds. The clean A/B/C bootstrap
passed again, including exact core/raw/linked B/C equality and semantic probes.
B and C SHA-256 is
`0ca187dc82e8fd2486db3747617e1f25474439378f8a3ed43d62a15b5cf4e636`.
Native A source build took 18.713 seconds; A and B compilation took 21.642 and
24.197 seconds. Total bootstrap time was 77.968 seconds, a recorded timing fault.
The final Native-produced A SHA-256 is
`456dd4c4a899fc21a4af5bd60c1fb6cd22f54a1e32050f36a4258c80af4a71a4`.
All 251 compiler source/provider inputs still matched their saved hashes after
the actual request run.

- Full Dew transform lane: 282/282 pass. Execution 79.307 seconds and full
  invocation 92.625 seconds are timing faults.
- Saved previously failing constants request: compile 4.477 seconds, validate,
  initialize once, main returns 42. The compiler assertion stays enabled.
- Actual Wasm requests: all 64 positive examples compile, validate and return 42;
  all 18 negative cases give the expected diagnostic and write no output.
  Batch time 247.905 seconds is a timing fault; each request is measured.
- Named function identity: 11 cases pass, including one startup and two main
  calls in each instance. Whole invocation 18.231 seconds.
- Initializer schedule file: all 23 selected tests pass, including missing,
  out-of-range and wrong-declaration global dependency guards. Private build
  includes its existing helper file, with 375 registered tests; this is a
  23-case selected result, not a claim that all 375 were run. Whole invocation
  13.523 seconds.
- New durable `tools/test-transform-source-pool.sh`: both actual Wasm cases pass
  in 8.014 seconds. A pool-only imported annotation works. A generated import
  selects a new module, executes its own transform, resolves another pooled
  constant module, and finally returns 42. An unselected invalid-UTF-8 module
  remains unparsed. Independent read-only review found no test defect.
- Native formatting: all 18 changed `.mbt` files match `moonfmt` output. Shared
  report generation checks reject stale source data and generated tests.

Current Wago passed the real local request in one instance. The output validates
and returns 42. Native execution took 158.635 seconds; the complete check took
163.092 seconds, with peak process RSS 2,947,428 KiB. These times remain faults,
and peak process RSS is not retained guest heap. The host is pinned Wago
`2dd978ccda6f`, Facet v0.1.0, with `-p8`, 2 GiB heap and 512 MiB nursery. No worker
API or second payload was added. A first wrapper attempt could not start because
`/usr/bin/time` was absent. The existing Python `os.wait4` harness then recorded
the successful run. Logs and process samples are saved in
`.tmp/wago-probe/resource-current-2026-10-20.{log,json}`.

A same-request comparison with the exact HEAD compiler is recorded separately.
The older 115-second Wago evidence used an earlier compiler and cannot isolate
the resource/index change. No current full-compiler speed gain is claimed.

The exact HEAD compiler (`d88744ab`, saved Wasm SHA-256
`f0f5477fd4c53402d162fc4387bb1e54433893a7510f8100bcc73beb17a51f93`)
also passed the same request and host configuration. It took 152.442 seconds,
with peak RSS 2,970,548 KiB. Current execution was 158.635 seconds and its complete
check peaked at 2,947,428 KiB. The current RSS sample includes the build/adapter
wrapper; the HEAD sample measures the host process directly. Both peaks are
dominated by host execution. One fresh process per build on a shared host does
not establish a speed trend or a retained-memory change. The older 115-second
sample is not the exact HEAD control. Raw baseline samples are in
`.tmp/wago-probe/resource-head-2026-10-20.{log,json}`. Compiler, host and request
identities are in `wago-comparison-identity.json`; emitted output identities are
in `wago-output-comparison.json`.

Current output: 11021 bytes; HEAD output: 9884 bytes. Both outputs validate and return 42; this control does not claim identical code.
