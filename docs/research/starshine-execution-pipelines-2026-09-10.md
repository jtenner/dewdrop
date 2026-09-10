# Starshine runtime and pass-order experiments

Date: 2026-09-10. Goal: preserve Dew execution, reduce module size where possible,
and prefer runtime speed over size. Validation alone is not proof of correct
execution.

**Result:** `fold-inline` is the best measured speed candidate for this workload
mix. A separate confirmation run used **9.6% less runtime** (geometric mean)
and **10.4% fewer total module bytes** than O4s. It has a serious byte-hash
regression and smaller map regressions. Use `prune` when those operations
dominate: it saves **4.1% of total bytes**, with no useful measured speed gain.
The full results, exact pass order, and limits are below. Compiler defaults have
not changed; the experiment runners apply the selected pipeline explicitly.

## Starting state

- Dewdrop HEAD: `286e881b` at the start. The workspace has existing compiler and
  self-host edits. These are used for the build but are not part of this work's
  commits. Reports record a hash of the workspace diff and the compiler binary.
- Pinned Starshine: `8d82581f51627a452062d8965e40601c106de1f3`.
- Node: `v26.8.1`. Moon: `0.1.20260827`.
- 460 module snapshot fixtures: 405 executable fixtures and 55 expected compiler
  failures. Discovery includes multi-file, imported-module, and test-mode cases.
- Stock `O4s` means optimize level 4 and shrink level 1. The CLI requires the
  explicit level flags. In `starshine-mb/src/passes/optimize.mbt`, the current
  fast preset expands to duplicate-function-elimination, vacuum, reorder-locals,
  strip-debug. The full compatibility scheduler is reserved for `O4z`.

## Method

`tools/starshine-experiments/runner.py` compiles each fixture, validates it, and
checks output and trap expectations with the existing Node and Wago consumers.
It then optimizes the same input for each selected pass list, validates the
result with wasm-tools, and repeats the execution checks. Expected diagnostics
are checked too. The runner retains commands and full failure messages and
continues through the corpus. No snapshot is rewritten. Failed execution cannot
count as a passing size or speed result.

`pipelines.json` keeps explicit pass order. Candidate names are experiment
labels, not compiler defaults or claims of correctness. Implicit traps remain
enabled. No closed-world or trusted compiler-fact assumptions are added.

## Initial checks

The three runner unit tests first failed because the runner did not exist, then
passed after implementation. They cover changed output, changed output before a
trap, command error diagnostics, and timeouts.

The first release native snapshot compiler build took **100.993 seconds**. This
exceeds the repository's 30 second limit and is a build performance bug. It is
separate from individual Dew fixture compile time.

## Corpus baseline and first pass sweep

The current workspace source run finished with 371 passing runtime fixtures,
one matching compiler-error fixture, and 88 baseline failures. A separate
checkout at `f3e8fa9e` produced 371 passing runtime fixtures, 43 matching
compiler-error fixtures, and 46 baseline failures. These include stale
diagnostics, compiler assertions, and one baseline runtime error. Neither source
run had a Starshine failure among the modules admitted to optimization. Source
failures must stay visible; the experiment does not update those snapshots.

The committed compiler was built in native debug mode in 13.244 seconds. Its
test-module compiler built in 8.840 seconds. The release Starshine CLI build took
187.591 seconds, another build performance bug.

To check every optimizer input despite those compiler failures, the next run
assembled the checked-in WAT snapshots. All 405 baseline modules passed Node and
Wago. Stock O4s passed all 405. The 55 compiler-error fixtures have no WAT and
are explicitly counted as such; this lane does not test their diagnostics.

The first ordered candidates passed 308/405 (`cleanup`), 309/405 (`speed`), and
321/405 (`gc-speed`). The failures include invalid output, optimizer crashes,
30-second optimizer limits, and valid modules that loop forever at runtime.
`control-flow/short-circuit-runtime` is one runtime-loop case for `cleanup`.
These candidates cannot be selected on size or speed grounds.

The library run compiled each of the 25 standard test files and all 43 operation
probe modules. This found a missing `open dew.std.fixed_array` in the SHA-256
test, hidden by imports in the aggregate test module. Adding that import makes
the isolated SHA-256 corpus test pass before and after O4s. Builtin trap probes
use an all-export trap checker; their intentional failing assertion is not an
ordinary test that should return normally.

The constructor operation probe found a separate O4s failure: the CLI final size
cleanup removes a `return` that discards values below the result on the operand
stack. Falling through the function leaves those values on the stack and creates
invalid Wasm. A two-parameter, one-result function reproduces the failure. The
regression is in the CLI final cleanup, not the public `vacuum` pass alone.

## Terminal return fix

Starshine commit `f56444542` fixes both unconditional removal sites: the final
size candidate in `src/passes/pass_manager.mbt` and the final encoder cleanup in
`src/cmd/cmd.mbt`. Each collects changed functions and validates the candidate
fallthroughs with one shared module environment. Functions that need to discard
extra stack values retain their return. Ordinary redundant returns still go.
The CLI regression uses a raw instruction array because WAT parsing can
normalize away the failing shape before the test reaches the encoder.

Both regressions failed before their respective fixes. The pinned native suite
then passed **10,985/10,985 tests**, in **334.775 seconds**. A large existing DAE
threshold test spent minutes repeating type lookups; its saved stack is in
`data/starshine-2026-09-10/slow-native-test.txt`. The fixed release build took
173.200 seconds. These exceed the 30 second compiler activity target.
`moon info starshine-mb/src/cmd starshine-mb/src/passes` passed in 3.346 seconds,
with no public API change. The native debug generator build took 26.675 seconds.

The dedicated aggregate Vacuum GenValid profile compared 10,000 cases at seed
`0x5eed` against Binaryen 131 in 43.566 seconds. It used the explicit release
Starshine binary and eight subprocess workers. There were 7,830 normalized
matches and no validation, generator, or command failures. The other 2,170
cases belong to two already documented smaller-output families: 1,080 hazard
cases at -2 bytes and 1,090 local-set prefix cases at -1 byte. All 20 saved
differences replay byte-identically with the original CLI. This classifies them
as pre-existing differences; this generated lane does not prove execution.
Total canonical bytes: Starshine 509,081; Binaryen 512,331.

The fixed release passed all 405 saved modules in Node and Wago and all 68
library modules in Node for O4s, prune, inline-prune, cse-prune,
precompute-prune, inline-cse, inline-fold, and fold-inline. This is 3,240
optimized fixture modules and 544 optimized library modules, each checked
against the same baseline assertions. The source compiler failures above stay
separate and visible.

## Pass search and execution failures

Seventeen pass lists were exercised, including O4s. Each custom list uses
optimize level 4, shrink level 1, and the default trap-preserving rules.
The initial trials used the original pinned CLI; the ten retained lists were
rechecked with the fixed release. Counts in this table refer to the 405 saved
executable modules. Compiler-error fixtures have no optimizer input.

| Pass list | Passed | Failed | Finding |
| --- | ---: | ---: | --- |
| O4s | 405 | 0 | Stock reference; separate library return bug fixed |
| cleanup | 308 | 97 | Includes valid output that loops |
| speed | 309 | 96 | Crashes, validation errors, and execution failures |
| gc-speed | 321 | 84 | Same failure classes |
| peephole | 318 | 87 | Includes exact heap-type output rejected by Node |
| casts | 399 | 6 | Execution failures |
| heap | 399 | 6 | Execution failures |
| heap-prune | 404 | 1 | Illegal cast in fixed-array runtime |
| prune, inline-prune, cse-prune, precompute-prune | 405 each | 0 | Also passed all 68 library modules |
| inline-cse, inline-fold, fold-inline | 405 each | 0 | Also passed all 68 library modules |
| inline-small, inline-budget | 405 each | 0 | Also passed all 68 library modules |

Prefix replay of `cleanup` on `control-flow/short-circuit-runtime` passes after
duplicate-function-elimination, precompute, and optimize-instructions. Adding
**simplify-locals** first causes the runtime timeout, although validation passes.
All later prefixes still fail. The saved prefix report retains every step.
This pass defect, the six cast failures, and the heap2local illegal cast remain
open in Starshine's backlog. None is counted as a successful optimization.

The 68 library modules contain **326 standard tests** in 25 source files and
43 operation probe modules. Additional consumer coverage passed for both O4s
and fold-inline:

- Four external Wasm ABI callers: v128, aggregate callback, enum callback, and
  eqref fallback. Every caller checks its returned value.
- Multi-module CLI build, explicit preamble, two linked package tests, and the
  intentionally failing assertion with its required Unicode message.
- Facet: all 261 imports remain; a test host checks one ABI-version call and its
  result. This does not claim execution of all 261 host services.
- UTF: **17,471** comparisons; SWAR: **61,000**; WASI: **196**.
- The standard compile-pass and run-pass CLI fixtures.

The added consumer lane has 12 passing cases, one correct expected source error,
and two baseline failures. Runtime trait evidence traps with `illegal cast`
before optimization. The imported package fixture fails its dependency
interface hash check before emission. The standard CLI error fixture also
differs from its saved diagnostic by a `dew:` prefix and a blank line. These
are recorded source/CLI failures, separate from optimizer failures. Existing
compiler and self-host edits remain outside these commits.

## Runtime measurements

Hardware: AMD Ryzen 7 8845HS, Linux x86-64, Node **v26.8.1**. The confirmation
processes use CPU affinity **8,10**. No experiment compiler, test, or fuzz jobs
ran alongside their timed execution. An unrelated fuzz process was present
during part of the first exploratory run; that run is not the final estimate.
The independent confirmation used seven fresh Node processes per workload,
41 samples each, 150 ms warmup per variant, and one common batch size calibrated
to at least 5 ms on the unoptimized baseline. Variant order rotates by sample.
Every call contributes to an expected batch checksum. Wrong outputs or traps
prevent timing results. This is steady-state runtime, including JS-to-Wasm call
overhead and GC; it is not a startup or peak-memory benchmark.

The source compiler is the native debug build from the clean `f3e8fa9e` checkout;
its SHA-256 is
`33f7e05b4a9b0cd82630020b876e609c455efc064a10a33b6971dbc26b6a58cc`.
The fixed Starshine release SHA-256 is
`09b1a598ee2b038d8eea5329c34e4485d11451c50a04d0d1fc178833d90ae10c`.
Each variant starts from exactly the same emitted bytes. Native compiler build
mode does not change between compared variants. Reports retain tool hashes,
workspace diff hashes, CPU affinity, load averages, and every sample.

Times below are medians of the seven process medians, in microseconds per call.
The time ratio is the geometric mean of paired process ratios. Its interval
uses 10,000 deterministic bootstrap resamples of those seven pairs. A ratio
below 1 means less time. The samples are not treated as 287 independent runs.
Intervals describe run noise on this machine, not all engines or applications.

| Workload | O4s µs | fold-inline µs | Paired time ratio (95% interval) | O4s bytes | fold-inline bytes |
| --- | ---: | ---: | --- | ---: | ---: |
| Array growth, 256 pushes | 1.351 | 0.919 | 0.684 (0.674–0.693) | 3,201 | 2,946 |
| Reserved array, 256 pushes | 1.346 | 0.820 | 0.620 (0.599–0.645) | 3,187 | 2,944 |
| Hash map, 32 inserts | 0.813 | 0.864 | 1.067 (1.063–1.071) | 2,977 | 2,587 |
| Ordered map, 32 inserts | 3.618 | 4.002 | 1.099 (1.079–1.115) | 7,287 | 6,504 |
| Byte hash, 2,048 bytes | 3.840 | 6.135 | 1.609 (1.586–1.636) | 3,516 | 3,220 |
| String hash, 2,048 bytes | 11.026 | 6.088 | 0.559 (0.550–0.571) | 3,558 | 3,228 |
| Enum payload, 32 cases | 0.241 | 0.242 | 0.999 (0.990–1.007) | 2,833 | 2,809 |
| Tail loop, 10,000 steps | 3.217 | 3.216 | 1.0003 (1.0000–1.0007) | 304 | 71 |
| JSON round trip | 11.086 | 9.995 | 0.902 (0.899–0.905) | 16,215 | 14,423 |
| Canonical JSON round trip | 10.565 | 9.556 | 0.905 (0.901–0.909) | 16,215 | 14,423 |

The enum inputs are 0, 1, 41, and 127. JSON calls rotate through 1–4 round trips
of the same 86-byte document. Other workloads use fixed inputs from the existing
benchmark generators. This set covers library operations; it is not a broad
application benchmark, and several inputs are compile-time constants.

| Confirmation result | O4s | prune | fold-inline |
| --- | ---: | ---: | ---: |
| Geometric mean time ratio | 1.0000 | 0.9982 | **0.9040** |
| Total module bytes | 59,293 | 56,841 | **53,155** |
| Total bytes without custom sections | 59,084 | 56,841 | **53,155** |
| Geometric mean code-section ratio | 1.0000 | 0.9961 | 0.9683 |
| Median optimizer time per module | 2.649 ms | 2.600 ms | 4.455 ms |
| Maximum optimizer time per module | 8.737 ms | 8.627 ms | 13.062 ms |

Total module bytes fall by 10.35%; bytes without custom sections fall by 10.04%.
The geometric mean *whole-file* size reduction is 20.54%, but that gives the
tiny tail-loop module equal weight: 209 of its 233 removed bytes are custom
metadata. The total-byte and code-section figures prevent that from appearing
as a large code reduction. The two JSON exports are timed separately, so their
shared module is counted twice in the ten-workload totals.

Across the saved fixture corpus, fold-inline reduces total size from 823,420 to
765,023 bytes (**7.09%**). Of 405 modules, 381 shrink, 16 stay equal, and 8 grow.
The largest increase is 149 bytes in `return-drop-never-carriers-runtime`.
All 68 library modules shrink, from 523,459 to 439,459 total bytes (**16.05%**).
These size results are not runtime measurements for those fixtures.

Source compilation in the confirmation run took a median 0.592 seconds and a
maximum 1.077 seconds. The larger consumer lane includes a 2.56 MB UTF module:
O4s took 4.533 seconds and fold-inline 6.919 seconds to optimize it. The 0.56 MB
WASI module took 0.013 / 1.638 seconds. These are single-command wall times;
they are not repeated pass microbenchmarks. Engine compilation is also saved,
but identical modules can share Node's engine cache within a process, so those
values must not be read as independent cold-start comparisons.

## Selected pass order

For this workload mix, use `fold-inline`:

```text
duplicate-function-elimination
precompute
inlining
local-cse
vacuum
remove-unused-module-elements
memory-packing
reorder-locals
strip-debug
```

The first five-process sweep found time ratios of 0.9106 for inline-prune,
0.9108 for inline-cse, 0.9086 for inline-fold, and 0.9021 for fold-inline.
Folding before inlining helps the JSON cases in this set. These close aggregate
values are not proof of a general ordering rule. The separate confirmation
repeats the larger gain against O4s, not a statistically conclusive ranking of
all near-tied orders.

The additional three-process screen capped one-caller inlining at 4 or 20
instructions. The smaller option also disables flexible and partial inlining.
Their time ratios were 0.9815 and 0.9844. Both still slowed byte hashing and lost
the large array gains, so they were not selected. Their corpus and library
execution checks nevertheless passed and remain in the evidence.

Use `prune` for workloads dominated by byte hashing or maps. Its order is
duplicate-function-elimination, remove-unused-module-elements, memory-packing,
vacuum, reorder-locals, strip-debug. No single tested order is fastest for every
workload. Do not choose per-fixture winners and present them as one pipeline.

## Reproduce and inspect

Build the tools serially, then run each lane. Native release builds can exceed
the 30 second target; their time is recorded as a build performance problem.

```sh
python3 tools/starshine-experiments/runner.py \
  --pipeline O4s --pipeline fold-inline --output .tmp/starshine-source
python3 tools/starshine-experiments/runner.py --skip-build --from-wat \
  --pipeline O4s --pipeline fold-inline --output .tmp/starshine-wat
moon build --target native --release src/dew_test_gen
python3 tools/starshine-experiments/library.py \
  --pipeline O4s --pipeline fold-inline
python3 tools/starshine-experiments/cli.py \
  --pipeline O4s --pipeline fold-inline
python3 tools/starshine-experiments/consumers.py \
  --pipeline O4s --pipeline fold-inline
taskset -c 8,10 python3 tools/starshine-experiments/benchmark.py \
  --pipeline O4s --pipeline prune --pipeline fold-inline \
  --rounds 7 --samples 41 --target-ms 5
python3 -m unittest discover -s tools/starshine-experiments -p 'test_*.py'
```

Choose available CPU numbers on a different machine. The commands above use the
current compiler by default. To reproduce the measured compiler input exactly,
build `src/module_snapshot_gen` and `src/dew_test_gen` in native debug mode in a
clean checkout of `f3e8fa9e`, with its pinned dependencies available, then pass
their paths through `--compiler` and `--test-compiler`. The experiment's checkout
is retained at `.tmp/starshine-clean`. Its snapshot compiler is
`.tmp/starshine-clean/_build/native/debug/build/jtenner/dewdrop/module_snapshot_gen/module_snapshot_gen.exe`;
its test compiler is
`.tmp/starshine-clean/_build/native/debug/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe`.

[Compact evidence](data/starshine-2026-09-10/README.md) retains all case failures,
binary identities, command timings, raw benchmark samples, and the paired
summary. Large binaries and full build logs stay under `.tmp/`. The five harness
tests passed in 0.253 seconds. No failed source snapshots were rewritten.
