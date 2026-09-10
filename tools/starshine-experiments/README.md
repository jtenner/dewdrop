# Starshine execution experiments

Run every Dew module snapshot through Starshine, then check the saved output and
trap expectations in Node and Wago:

```sh
python3 tools/starshine-experiments/runner.py
```

The runner builds the native snapshot compiler and the pinned native Starshine
CLI once. Each command has a measured wall time. Fixture compilation,
optimization, validation, and execution have a 30 second timeout. Native builds
have a larger limit; any command above 30 seconds is marked as a performance bug.
Failures stay in the report and make the command return a nonzero status. The
runner continues through the other fixtures. It never updates expectations.
A compiler crash includes its exit code, assertion text, and stack output, even
when the fixture expects a source error.

The default pipeline is `O4s`. This pinned CLI does not accept the spelling
`-O4s`; the equivalent is `--optimize-level 4 --shrink-level 1 --optimize`.
Its expanded pass list is duplicate-function-elimination, vacuum,
reorder-locals, strip-debug. All trials use the default trap-preserving rules.

```sh
# Use binaries that were already built from the current source.
python3 tools/starshine-experiments/runner.py --skip-build

# Compare explicit ordered pass lists, defined in pipelines.json.
python3 tools/starshine-experiments/runner.py --skip-build \
  --pipeline O4s --pipeline prune --pipeline fold-inline

# Focus on one fixture. Choose one engine only when debugging that engine.
python3 tools/starshine-experiments/runner.py --skip-build \
  --fixture text/concat --runtime node

python3 -m unittest discover -s tools/starshine-experiments -p 'test_*.py'
```

When current compiler errors prevent emission, also check the fixed optimizer
corpus from the checked-in WAT files. This is a separate lane; it does not replace
the source run or hide its errors:

```sh
python3 tools/starshine-experiments/runner.py --skip-build --from-wat
```

Run each standard-library test file and the complete exported-operation probes:

```sh
moon build --target native --release src/dew_test_gen
python3 tools/starshine-experiments/library.py
```

The library runner shares the normal suite's probe list and Node assertion
consumers. Each test file is compiled separately so one source failure does not
hide the other tests. All builtin trap exports must raise a Wasm runtime trap.

Measure ten workloads with fresh Node processes, warmup, a common batch size,
rotating variant order, and a checked result for every timed batch:

```sh
python3 tools/starshine-experiments/benchmark.py \
  --pipeline O4s --pipeline prune --pipeline fold-inline
```

The benchmark uses source generators from the existing array, map, hash, enum,
tail-recursion, and JSON benchmarks. Default settings are five fresh processes,
31 samples per process, and a batch calibrated to at least 3 ms on the baseline.
Wasm engine compilation is recorded separately. Do not run compiler or other
benchmark jobs at the same time as runtime measurements. Failed variants remain
failures in the report; they do not receive speed measurements.

The default benchmark compares O4s, prune, and fold-inline. Smaller inlining
limits (`inline-small`, `inline-budget`) are also available. The initial
`cleanup`, `speed`, `gc-speed`, `peephole`, `casts`, `heap`, and `heap-prune`
trials have known failures. They remain available to reproduce those failures.

Check the CLI fixtures, package and Wasm callers, Facet imports, and the UTF,
SWAR, and WASI parity suites:

```sh
python3 tools/starshine-experiments/cli.py --pipeline O4s --pipeline fold-inline
python3 tools/starshine-experiments/consumers.py --pipeline O4s --pipeline fold-inline
```

The consumer runner uses the normal ABI and parity checkers. Each parity checker
also accepts an optional Wasm path as its first argument. Compiler errors and
intentional assertion failures are checked before optimization. Facet coverage
checks all 261 imports and executes the ABI version query with a test host; it
does not exercise every host service. Source errors stay in the report.

Locate the first pass that changes a fixture's behavior:

```sh
python3 tools/starshine-experiments/isolate.py \
  --fixture control-flow/short-circuit-runtime --pipeline cleanup \
  --output .tmp/starshine-prefix-check
```

This checks every prefix and keeps validation and execution failures separate.
`testdata/repro-0.wat` and `testdata/repro-1.wat` are reduced examples of the
terminal-return defect fixed in the pinned Starshine revision.

Keep compact evidence and paired speed ratios with resampled 95% intervals:

```sh
python3 tools/starshine-experiments/summarize.py \
  .tmp/starshine-experiments/report.json .tmp/starshine-benchmarks/report.json \
  --output .tmp/starshine-summary
```

Supply every report wanted in `summary.json` on the same call. Evidence uses
JSONL, with one metadata line and one line per case or workload. Benchmark
evidence keeps every timed sample. Module bytes, bytes without custom sections, and code
section bytes are separate, so metadata removal cannot appear as a code win.

Results and Wasm files remain under `.tmp/`. `report.json`
contains tool/source identities, commands, timings, diagnostics, sizes, binary
hashes, and runtime results. Each fixture also has a `result.json`. Use a distinct
`--output` directory to preserve a previous run. The default is four workers;
use `--jobs 1` for isolated compile/optimization timing.

These execution checks complement the canonical WAT and reproducible compiler
checks in `tools/module-snapshots/run.sh`. Optimized WAT is expected to differ,
so this experiment does not compare it with the unoptimized WAT snapshots.

Research and measurements: [September 2026 experiment](../../docs/research/starshine-execution-pipelines-2026-09-10.md).

The compiler CLI also supports `tools/dew build --optimize speed` and
`tools/dew optimize input.wasm -o output.wasm`. See the
[CLI pipeline study](../../docs/research/compiler-cli-optimization-2026-09-10.md)
for the chosen order and its measured limits. The old experiment named `speed`
in `pipelines.json` is a retained failing trial; it is not the CLI speed profile.

`testdata/wago-typed-select.wat` reduces the Wago-only typed-select fault without
using Starshine. It selects the same struct reference for both arms, then checks
reference identity. Parse it with `wasm-tools parse`, then use the Node and Wago
snapshot runners. Correct execution has no output and no trap. Wago currently
traps at `unreachable`; Node passes. The local Wago repair in
[PR #600](https://github.com/wago-org/wago/pull/600) consumes the complete reference
type and passes this case. This separates the runtime defect from the
`remove-unused-brs` pass that first emits the instruction in the source case.

The final `cli-speed` schedule is `fold-flat-coalesce`: precompute and inlining,
then local CSE, repaired no-structure local simplification, coalescing, vacuum,
module cleanup, memory packing, local reordering, and debug stripping, preceded
by duplicate-function elimination. All 461 source fixtures pass their expected
checks in Node and Wago under this order. The ten-workload confirmation gives
13.24% less geometric-mean time and 12.43% fewer total encoded bytes than O4s;
byte hashing and maps regress. The full per-workload table and retained samples
are in the [CLI study](../../docs/research/compiler-cli-optimization-2026-09-10.md).
