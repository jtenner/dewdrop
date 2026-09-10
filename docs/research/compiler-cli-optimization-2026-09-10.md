# Compiler CLI optimization pipeline, 2026-09-10

The CLI now supports an ordered Starshine schedule for `build`, `run`, and
`test`, plus `optimize` for an existing Wasm artifact. The profile targets emitted
program execution speed, with size as a second objective. This is not a claim
about self-hosted compiler execution speed.

## CLI contract

```sh
tools/dew build program.dew -o program.wasm --optimize speed
tools/dew run program.dew --optimize speed
tools/dew test program.dew program_test.dew --optimize speed
tools/dew optimize input.wasm -o output.wasm
tools/dew build --optimize speed --print-passes
```

Profiles are `none`, `speed`, and `O4s`. Builds, runs, and tests default to `none`;
`optimize` defaults to `speed`. Explicit custom schedules use repeated
`--starshine-pass NAME` options. Order and duplicates are preserved. They cannot
be combined with a named profile. Every enabled schedule uses optimization
level 4 and shrink level 1. No relaxed trap or floating-point rules are enabled.
`--print-passes` emits version-1 JSON and does not compile source.

The `O4s` profile is the pinned Starshine stock schedule:
`duplicate-function-elimination, vacuum, reorder-locals, strip-debug`.
It is not Binaryen's larger O4 pipeline. HIR and lowering output reject enabled
optimization. Wasm and WAT outputs support it; WAT uses the existing print step.

The bootstrap builds the pinned native optimizer. `DEW_STARSHINE` can select a
specific executable for an experiment. Whole-build cache keys include its
contents, the ordered passes, and the optimization levels. Inner compiler caches
keep the ordinary source fingerprint. Optimization writes beside the requested
output and publishes by rename after success. A failed pass reports its ordered
schedule and keeps the raw input and prior output; it cannot publish a successful
whole-build cache entry. The `dew.tests` metadata survives test optimization.

## Method

The initial screen compared 13 pass orders over ten generated workloads. It
exposed runtime faults that validation alone missed. The fixes are recorded in
[the counter study](starshine-loop-counter-2026-09-10.md) and
[the local-lifetime study](starshine-local-lifetimes-2026-09-10.md).
The latter also records the Wago typed-select fix in
[PR #600](https://github.com/wago-org/wago/pull/600).

Selection uses runtime first, size second, among schedules that pass all source
fixtures in both engines. It uses the geometric mean of paired time ratios over
all ten workloads. A failed workload disqualifies a schedule; measurements from
only the surviving workloads cannot win. No schedule is claimed to be best for
every program.

Final measurements use seven fresh Node processes per workload, 41 timed samples
per process, 150 ms warmup per variant, and a common batch calibrated to at least
5 ms on the unoptimized module. Variant order rotates between samples. Every
batch has a checked result. CPU affinity is 8,10. Our compiler, fuzz, and test
jobs are stopped during timing. Engine compilation is recorded separately.
Paired 95% bootstrap intervals describe these repeated samples, not uncertainty
across all possible programs or machines.

The input compiler is the committed Dewdrop compiler at `928eef9a` (SHA-256
`14908686777956b3b6b9d9e124ed47c0cb58581c5e135670f1fd689bc74f91d6`). This keeps
unrelated working-tree source changes out of the comparison. Reports retain the
optimizer binary hash, tool versions, every sample, encoded size, non-custom size,
and code-section size. Stripping metadata is not counted as a code-size gain.

## Selected schedule and measured results

CLI `speed` is experiment `fold-flat-coalesce` (also named `cli-speed` in the
checked-in experiment config). Its exact order is:

1. `duplicate-function-elimination`
2. `precompute`
3. `inlining`
4. `local-cse`
5. `simplify-locals-nostructure`
6. `coalesce-locals`
7. `vacuum`
8. `remove-unused-module-elements`
9. `memory-packing`
10. `reorder-locals`
11. `strip-debug`

The early passes remove duplicate work and expose local simplifications. The
repaired no-structure local pass precedes local coalescing. Vacuum removes
resulting debris; module cleanup and memory packing follow inlining; local
reordering and debug stripping run last. This ordering passed the whole source
corpus before measurement. The unsafe historical experiment named `speed` is
not used by the CLI.

Runtime has first priority. `fold-flat-coalesce` has the lowest measured geometric
mean time ratio, 0.86760 versus O4s: **13.24% less time**, equivalent to 1.153x
speed. Encoded bytes total **51,922 versus 59,293**, a **12.43% reduction**.
After excluding custom sections, the reduction is **12.12%** (51,922 versus
59,084). Code-section bytes total **49,411 versus 53,031**, a **6.83% reduction**.
The result therefore includes real code/data reduction, not just metadata removal.
Totals count one module per workload; the two JSON workloads share one module.
Counting that module once gives 43,078 to 37,872 bytes, a 12.09% reduction.

| Final candidate | Time / O4s (geometric mean) | Total encoded bytes | Checked workloads |
| --- | ---: | ---: | ---: |
| O4s | 1.00000 | 59,293 | 10/10 |
| fold-coalesce | 0.88652 | 52,423 | 10/10 |
| fold-flat-locals | 0.87117 | 52,615 | 10/10 |
| fold-flat-coalesce | 0.86760 | 51,922 | 10/10 |
| fold-flat-code | 0.86840 | 51,760 | 10/10 |
| fold-code | 0.89237 | 52,258 | 10/10 |

The code-folding alternative is very close in time (0.86840), with 162 fewer
bytes. This run does not establish a statistically distinct ranking between
those two near-tied candidates. The selected schedule has the lower measured
time and one fewer transform. The earlier screen's local-pass candidate failed
two JSON workloads; its eight-workload average was excluded from selection.

| Workload | O4s median ns/call | CLI speed median ns/call | Paired time ratio | 95% paired interval |
| --- | ---: | ---: | ---: | --- |
| array-growth | 1362.1 | 930.3 | 0.6799 | 0.6737–0.6878 |
| array-reserved | 1343.5 | 835.9 | 0.6321 | 0.6087–0.6578 |
| bytes-hash | 3881.6 | 5742.1 | 1.4808 | 1.4677–1.4978 |
| enum-payload | 243.5 | 196.8 | 0.8102 | 0.8039–0.8189 |
| hash-map | 787.4 | 845.6 | 1.0656 | 1.0565–1.0736 |
| json-canonical | 10595.7 | 9369.9 | 0.8817 | 0.8792–0.8844 |
| json-roundtrip | 10999.0 | 9812.7 | 0.8850 | 0.8776–0.8915 |
| ordered-map | 3530.8 | 3771.6 | 1.0646 | 1.0511–1.0781 |
| string-hash | 10581.7 | 5651.5 | 0.5295 | 0.5187–0.5380 |
| tail-loop | 3222.6 | 3220.5 | 0.9999 | 0.9990–1.0010 |

Byte hashing is **48.1% slower**, and both map tests are about **6.5% slower**.
String hashing takes **47.1% less time**; arrays take **32.0–36.8% less**, JSON
**11.5–11.8% less**, and the enum workload **19.0% less**. Tail-loop timing is unchanged.
Use `O4s` or a custom pass order when the regressions match the application's hot
path. This profile is an empirical default for these workloads, not a promise
of faster execution for every module or engine. Timing uses Node; Wago provides
an independent correctness gate, not a second speed result.

The machine is an AMD Ryzen 7 8845HS, Linux 6.12.107, Node v26.8.1. Recorded
one-minute system load reaches 10.81 while old jobs leave the load average;
no other compiler/fuzz/test process is running during the timed rounds. Normal
host services remain active. The CPU affinity and paired rounds reduce noise
but do not remove it. The report includes load at every round.

The speed schedule's optimizer command takes a median **5.088 ms**, maximum
**20.544 ms**, over these ten modules. O4s takes 2.839 ms median, 8.513 ms maximum.
These are one invocation per workload, including process startup, not a
pass-local microbenchmark. The full benchmark takes **217.612 seconds**; this
aggregate exceeds the repository's 30-second budget and remains a performance
bug. The full fixture/native/fuzz timings are in the local-lifetime study.

Compact evidence lives in `docs/research/data/starshine-cli-2026-09-10/`:
`screen.jsonl`, `confirmation.jsonl`, and `summary.json`. It retains all timed
samples, per-round medians, module sizes, checked statuses, and binary hashes.
The final optimizer was built from the changes now committed as Starshine
`48d6337ce`; its hash is
`c12666b64811f3ed5548b28735d46d9eda85c098d81b12f3a83f57250bfcaf5f`.
Raw environment metadata records the earlier HEAD because the build and start
of measurement preceded the commit; the binary bytes did not change.

## Local build and CLI verification

The bootstrap native suite passes 8/8 tests in 0.547 seconds. The integration
runner executes real CLI commands, verifies the exported result, checks Wasm and
WAT output, runs/list tests with retained metadata, checks exact pass order and
repeated passes, and verifies cache misses/hits after optimizer identity changes.
It also checks that a failed transform preserves the previous output and cannot
publish a successful cache entry. The final extra cases exercise default pinned
optimizer discovery and byte-identical copying with `--optimize none`.

The first complete CLI run takes 117.668 seconds. Its first `dew test` invokes a
native release build of the test generator and takes 99.874 seconds; this cold
build is a performance bug. All 25 commands in that run have their expected
status. The expanded warm run passes all 28 command checks in **7.302 seconds**.
Both runs are retained in `cli-validation.json`.

The direct JSON prefix comparison in `direct-pass.json` uses one warmup and
seven rotating rounds. The old loop-only optimizer takes 8.235 ms median; the
fixed optimizer takes 8.270 ms, both producing 15,519 bytes. Binaryen 131 takes
6.275 ms and produces 12,485 bytes. All three outputs validate and return 86
from both JSON exports. These include command startup and do not establish
exact pass-local time or broader parity. The Binaryen command disables custom
descriptors: an initial all-features attempt emitted exact heap types that
require an experimental Node feature, so that attempt was excluded and repeated
with the supported feature set.

## Reproduce

```sh
python3 tools/test-cli-optimization.py \
  --starshine _build/native/release/build/jtenner/starshine/cmd/cmd.exe
python3 tools/starshine-experiments/runner.py --skip-build \
  --pipeline O4s --pipeline cli-speed --runtime node --runtime wago
python3 tools/starshine-experiments/benchmark.py \
  --pipeline O4s --pipeline cli-speed --rounds 7 --samples 41 --target-ms 5
```

The runner's default compiler must first be built from the source revision being
measured; pass `--compiler PATH --starshine PATH` to replay exact prebuilt tools.
The historical experimental profile named `speed` remains a failing trial in
`pipelines.json`; the CLI profile is named `cli-speed` in that experiment file.
