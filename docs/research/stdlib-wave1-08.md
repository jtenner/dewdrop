# Wave 1 item 08: lazy iterator adapters

Dependency: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Branch: `worker/wave1-item-08`. No compiler rules or host APIs change.

## Contract

`iter_map`, `iter_filter`, `iter_take`, `iter_skip`, and `iter_enumerate`
return typed mutable wrappers implementing `Iter`. Construction does no work.
Wrappers share their state through aliases. Each wrapper stops permanently at
its first upstream `None`. Repeated terminal calls do no upstream work.
Map calls its callback once per item. Filter calls its predicate once per
pulled item, in source order, before the outer map sees accepted items.
Take uses a U32 count and does not pull after that count, including zero.
Skip discards at most its U32 count on the first request. Enumerate yields
`IterEntry<t> { index: U64, value: t }`, starting at zero; index wraps as U64.
No wrapper creates an array. Space is constant per adapter, excluding callbacks
and upstream storage. A filter request can scan the entire remaining input.

Example: `iter_map(iter_filter(array_iter(values), keep), transform)`.

## Checkpoint 1

Two new test cases specify laziness, callback order/counts and terminal state.
They require the new API, which is not yet implemented at this checkpoint.
Tests are intentionally red until checkpoint 2. No compiler command run yet.

## Baseline and scope

Owner G0: PASS WITH KNOWN RED on modern SDK. Recorded base public standard
suite: 355 passed, 0 failed; separate private B-tree: 41 passed, 0 failed;
42 builtin traps; 4121 operation probes. Eight provider tests are not counted
again. Mission A reviewed the eight historical WAT mismatches at this item's
dependency checkpoint. This item does not refresh them or run B-tree checks.
The accepted 67.88 s cold build is baseline evidence, not an item measurement.
SDK: `/data/home/.moon`, moon `0.1.20261023`, core
`0.10.17+d971670cd`. No global SDK change.

## Reproduction

All compiler commands run with an exclusive lock. The script cleans private
build output and generated Wasm on exit, including on failure.

```sh
mkdir -p .tmp
cp docs/research/stdlib-wave1-08/gate.sh .tmp/gate.sh
flock /data/workspace/wave1-control/build.lock bash .tmp/gate.sh > .tmp/gate.log 2>&1
```

The script times the generator check, focused Dew tests, production compile,
WAT decode, runtime oracle, memory sample and allocation-count probe. The
production manifest contains a separate `fixture.callbacks` module with
generic callback factories, used with both U32 and String. It checks for zero
host imports. The array/filter/map/fold benchmark compares the result with
`2 * ceil(n/2) * (ceil(n/2)-1)` using U32 arithmetic.

Allocation counts come from a scratch WAT copy with stack-neutral counters
before each `struct.new` and `array.new` instruction. These counters add no
host imports. Timing and memory samples use the original binary, never the
instrumented copy. Node heap/RSS measurements include the runtime and input
array; they are not byte-exact GC object sizes. Retained heap is measured after
an explicit GC. No speedup claim is made for this new API.

## Failed development run

First run: generator check passed (0.05 s). Focused compile failed with visible
new-source parse diagnostics (`FunctionBodyNewline`, `ExpectedObjectFieldNewline`
and typed-let syntax). No runtime tests ran. Cold compile: 77.46 s, peak RSS
2,430,556 KiB. **Performance bug: compiler activity exceeded 30 s.** Source was
then changed to use Dew block/field newlines and inferred local types. Full log
is retained privately in `.tmp/gate1.log`; no baseline failure was suppressed.

Second run: generator check passed; focused compile aborted at
`src/semantic/infer_trait_obligations.mbt:892` with
`selected implementation prerequisites lost coherent evidence` (exit 134).
Cold compile: 73.55 s, peak RSS 2,430,360 KiB. **Performance bug: over 30 s.**
No runtime tests ran. The next implementation stores a typed upstream pull
function in each wrapper. Constructors select ordinary generic `iter_next`
evidence once; wrapper Iter implementations then need no impl prerequisites.
No compiler change or source-name dispatch is used.

Third run: generator passed; both focused and production compiles failed with
visible source diagnostics. Function-valued fields must be copied to locals
before invocation; parenthesized field calls still select methods. Filter's
`else` must share the preceding closing-brace line. Empty take/skip/enumerate
tests also need explicit payload type arguments because `None` alone supplies
no payload constraint. These source errors were corrected for the next run.
Focused compile: 73.19 s (performance bug), peak RSS 2,430,712 KiB.
Production compile: 18.13 s, peak RSS 930,680 KiB. No runtime tests ran.

## Type arguments

Payload types normally come from callback parameters or result constraints.
An empty-only use of take/skip/enumerate has no payload constraint. Supply both
type arguments in that case, for example:
`iter_take::<U32, ArrayIter<U32>>(array_iter(values), 0u32)`.
The tests retain empty-only uses and state the types explicitly.

The first bounded test/documentation checkpoint is `d3929a16`.

Fourth run: **9 new focused tests passed, 0 failed**. Production compile failed
with unresolved callback factory type arguments: inference cannot infer the
factory payload from an iterator's trait bound alone. The consumer now states
`adapter_predicate::<U32>()` / `adapter_reader::<U32>()` and the String forms.
No compiler rule changed. Full log: `.tmp/gate4.log`.
Fourth-run timings: generator 0.02 s; focused cold compile 73.21 s (peak
2,430,700 KiB; performance bug); test runtime 0.03 s (46,060 KiB); production
compile 17.96 s (932,668 KiB). The focused runtime was green; the production
failure remained visible and caused gate exit 1.

Fifth run: 9 focused tests passed, 0 failed. Production compile reported only
`consumer.dew:44:26 NoMatchingMethod` for String equality. The production
consumer now explicitly opens `dew.std.string`, which owns String equality.
The standard test runtime already opens that module. Production compile:
17.57 s, peak RSS 932,660 KiB. Full log: `.tmp/gate5.log`.

The production probe is the focused compiler integration case. It uses
`src/module_snapshot_gen` with `CompilerPipelineOptions::production`, ordinary
module loading, semantic inference, specialization, physical planning and
binary emission. The standard test probe uses `src/dew_test_gen` and compiler
test metadata. There are no compiler/backend changes, new standard modules,
identity slots, registry edits or API `.mbti` changes. The orchestrator owns the
combined full standard/native/integration lanes. Existing baseline counts are
not counted again in this item.

Sixth run: generator passed (0.02 s); focused tests passed **9/9** (compile
75.80 s, peak RSS 2,430,720 KiB; runtime 0.04 s, 46,184 KiB). The production
consumer compiled successfully (18.81 s, 932,780 KiB); WAT decode passed
(0.47 s). Import inspection passed with **zero host imports**. The evidence
harness then failed because it incorrectly required `dew.metrics`, which
`module_snapshot_gen` does not emit. This is a harness error, not a compiler
failure. It was replaced with checks for the actual `compiler.facts` section
and four concrete scalar/reference identity/predicate bodies in emitted WAT.
The unavailable metric is not reported as a specialization count. Full failed
harness output remains in `.tmp/gate6.log`. Cold compile over 30 s remains a
performance bug.

Evidence continuation uses the unchanged, private production WAT from that
successful compile. It assembles a scratch binary and runs the corrected
checks, then removes all generated binaries before releasing the lock:

```sh
cp docs/research/stdlib-wave1-08/evidence.sh .tmp/evidence.sh
flock /data/workspace/wave1-control/build.lock bash .tmp/evidence.sh > .tmp/evidence.log 2>&1
```

The full `gate.sh` now uses the same corrected checks for fresh reproduction.

## Final result: READY candidate

No functional blocker remains. Focused Dew tests: **9 new, 9 passed, 0 failed**.
Production integration: **15 passed, 0 failed** (imports, compiler facts, four
concrete callback bodies, two cross-module callback results and seven sum
oracles). Instrumented allocation checks: **12 passed, 0 failed** (six sums
and six exact backing-array counts). Generator check passed. Evidence
continuation exited 0; all its commands took less than 30 s. No test failure
was converted to an expected pass. Full standard/native lanes were not rerun;
the accepted base counts above remain separate.

| Final command (exact arguments in gate/evidence scripts) | Wall s | Peak RSS KiB |
| --- | ---: | ---: |
| `python3 tools/generate_iter_std.py --check` | 0.02 | 11,972 |
| `moon run --target native src/dew_test_gen -- ...` | 75.80 | 2,430,720 |
| `node tools/dew-test/run.mjs --wasm .tmp/iter-tests.wasm` | 0.04 | 46,184 |
| `moon run --target native src/module_snapshot_gen -- ...` | 18.81 | 932,780 |
| `wasm-tools print .tmp/iter-consumer.wasm -o .tmp/iter-consumer.wat` | 0.47 | 7,512 |
| `wasm-tools parse .tmp/iter-consumer.wat -o .tmp/iter-consumer.wasm` | <0.01 | 8,892 |
| `node --expose-gc docs/research/stdlib-wave1-08/check.mjs` | 0.19 | 101,560 |
| `python3 docs/research/stdlib-wave1-08/instrument.py` | 0.01 | 10,916 |
| `wasm-tools parse .tmp/iter-instrumented.wat -o .tmp/iter-instrumented.wasm` | <0.01 | 8,704 |
| `node docs/research/stdlib-wave1-08/allocations.mjs` | 0.03 | 53,588 |

**Known performance bug:** the clean native generator build/compile took
75.80 s, above 30 s. This is additional to the accepted baseline 67.88 s cold
build. Compiler/SDK changes are outside this item. Earlier cold times are
listed above; private logs retain all warnings, diagnostics and `/usr/bin/time`
records. They remain in `.tmp/gate1.log` through `.tmp/gate6.log` and
`.tmp/evidence.log`.

### Runtime and memory

Node v22.23.3, five warmup calls, then twenty measured calls per size, with
explicit GC before and after. Measurements include building the input array.

| Input items | 20 calls, ms | Heap increase before GC, bytes | Retained heap delta, bytes | Sample RSS, bytes |
| --- | ---: | ---: | ---: | ---: |
| 1,024 | 0.472 | 49,528 | -3,264 | 55,513,088 |
| 65,536 | 19.375 | 5,270,608 | -16 | 66,256,896 |
| 262,144 | 82.317 | 21,044,792 | 24 | 103,997,440 |

Post-GC deltas are within measurement noise. No speedup or exact object-byte
claim is made. Wrappers hold constant state; the input backing is O(n).
The current backend still allocates transient Option objects: measured struct
allocations are `n + 2*ceil(n/2) + 8`. This is **not** an allocation-free
pipeline. For n = 0, 1, 2, 17, 1024, 65536, counts are respectively
8, 11, 12, 43, 2056, 131080. Every size executes exactly **one array allocation**,
the input backing. There are no intermediate arrays.

The emitted module is 13,378 bytes with 37 struct and 6 array allocation sites
across all three exported probes. It has 6 loops in total: 2 String comparison
loops, 2 specialized filter loops, 1 fold loop and 1 input-fill loop. The U32
array/filter/map/fold consumer reaches **3 loops** (fill, filter, fold); map
adds no loop. U32 and reference identity callbacks emit distinct concrete
`i32 -> i32` and `eqref -> eqref` bodies; the predicates likewise specialize.

Production WAT SHA-256:
`18dfd2e33320ade9601e81f3babb70593c0224dab344c5ad3d71f56b923a4dea`.
Only scratch WAT is kept privately; no generated binary is committed.

### Handoff files and cleanup

Changed implementation: `std/iter.dew` and generated
`src/standard_sources/standard_iter_sources.mbt`. Tests:
`std/tests/iter_adapters_test.dew`. Contract/example: `std/README.md`.
This report and the small sources/scripts under
`docs/research/stdlib-wave1-08/` preserve the production case and measurement
method. No generator source change was needed.

The lock-exit traps removed `_build`, `.mooncakes`, `.dew/cache` and generated
Wasm/harness files before releasing the lock. No B-tree file, snapshot, module
identity, global SDK file or unrelated source changed. No push was made.

Fifth-run cold compile timing (also a performance bug): 74.97 s,
2,430,276 KiB. Its focused runtime took 0.03 s (46,464 KiB).

## Combined landing gate

Item 08 on integration `5bfc21a0`: full `bash tools/dew-test/run.sh`
exited 0. Public tests: 374 passed (365 prior + 9), private: 41 passed.
Builtin traps and all 42 operation check scripts passed. Repeat bytes match.
Relevant native lane `DEW_NATIVE_TEST_PACKAGES=standard_loader bash
tools/test-native.sh` passed all 31 tests in 13.66 s. Local Clang wrapper
uses -g0 -O0 and bracket-depth 4096; SDK unchanged. Compiler calls over
30 s remain visible in the full log. Exact lane times are in
`data/stdlib-wave1/landing-08-{std,native}.log.gz`. Build output removed.
