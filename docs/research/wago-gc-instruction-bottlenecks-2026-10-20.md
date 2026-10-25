# Wago GC instruction costs — 2026-10-20

The largest confirmed cost is the interaction between `struct.new` and array
allocation. A native struct allocation reserves 512 handles. A handle is a small
object ID. An array allocation can cancel that reservation after only one or two
handles were used. Returning the unused handles costs more than the array work.

`array.new_fixed` is the main trigger. `array.new_default` is next. A smaller
batch cuts about one third from this full compiler job. A small test confirms
the same allocation pattern. It also shows why a smaller global batch is not
the complete fix: struct-only allocation benefits from the larger batch.

All measured runs below finished before the reboot. No sample spans the reboot.
The installed Wago binary and the local branch were not changed by these tests.
Diagnostic source changes are in private copies under
`.tmp/wago-local-perf-2026-10-20/`.

## Inputs and checks

- Local Wago: `e2fe43ffc83d31b16c7d82e66dc5a97782db942d`, branch
  `dewdrop/local-gc-perf-20261020`.
- Base: `7997c86c36e05cfba4c4f39cabb026a318f55fc0`, with the existing private
  reference safety and worker patches.
- Linux/amd64, Ryzen 7 8845HS, 16 logical CPUs, Go 1.27.1.
- Full job: the existing Dewdrop compiler Wasm and the request for
  `examples/transforms/parallel.dew`, with two transform applications.
- Compiler SHA-256:
  `c64fcf044b72cb7356ad598a35670045931337cfa7a6bb9d5916cd304b23fba6`.
- The request changes only the two length-prefixed output paths from the earlier
  profile request. Its source, compiler settings, and forced transform cache miss
  are the same for every engine and batch setting.
- Full Wago jobs use eight native compiler workers, serial transform execution,
  a 512 MiB GC heap, a 64 MiB nursery, and a fresh absolute `WAGO_HOME` except for
  the explicit warm native-cache check. They use private Facet hosts built from
  the compared Wago sources. These are separate from the bare installed CLI.

The selected GC smoke suite passed with `wago_regalloccheck`, including reference
roots, native code serialization, branch casts, null extern conversions, and
large array cancellation. Total test/build time was 3.819 seconds. This was not
the full upstream suite. See [smoke.json](data/wago-local-perf-2026-10-20/smoke.json).

Every accepted full job produced the same output and transform-cache hashes.
The output passes Wasm validation and returns `main() == 42` in Node:

- Output: `89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb`.
- Transform cache: `c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240`.

## Instruction ranking

The diagnostic host adds one named Go frame and a counter for each helper ID.
Counters reset after instance setup. Only the serial guest invocation is counted.
This table uses the build **without native source tracing**. Counts and batch
totals match the separate source-tracing run exactly.

These are executed Go helper calls, not total instruction counts. Successful
native paths are not counted. CPU times cover work inside each helper, including
its allocation and batch cleanup. Native code and the outer transition cost are
outside these rows.

| Instruction / helper path | Calls | Default batch: helper CPU seconds | Batch 32: helper CPU seconds |
| --- | ---: | ---: | ---: |
| `array.new_fixed`, native refill | 22,237,969 | 39.09 | 7.44 |
| `struct.new` | 30,354,650 | 18.43 | 12.17 |
| `array.new_default`, native refill | 8,327,645 | 12.39 | 2.22 |
| `array.get` | 90,707,302 | 3.06 | 2.96 |
| `array.new` | 3,727,628 | 2.36 | 1.02 |
| `ref.cast` | 20,913,295 | 0.88 | 0.69 |
| `array.set` | 15,707,906 | 0.63 | 0.72 |

Call counts in the table are for the default batch. The smaller batch causes more
refill calls. It still removes much more work than it adds. `struct.get` reaches
Go only 17 times in this job. This does not measure the cost of its native path.

Raw data: [default counts](data/wago-local-perf-2026-10-20/helper-counter-default-counts.json),
[batch 32 counts](data/wago-local-perf-2026-10-20/helper-counter-batch32-counts.json),
[default CPU profile table](data/wago-local-perf-2026-10-20/helper-counter-default-cpu.log),
[batch 32 CPU profile table](data/wago-local-perf-2026-10-20/helper-counter-batch32-cpu.log).

## Exact allocation interaction

The array allocation helper calls `CancelNativeAllocationBatch` before its
potentially collecting allocation. `discardNativeStructHandles` then returns
unused handles and trims the nursery handle list.

| Helper that triggers cancellation | Batches canceled | Mean handles used per batch | Unused handles returned |
| --- | ---: | ---: | ---: |
| `array.new_fixed`, native refill | 22,228,599 | 1.41 of about 512 | 11,349,784,773 |
| `array.new_default`, native refill | 6,882,222 | 7.67 of about 512 | 3,470,906,716 |
| `array.new` | 935,573 | 17.66 of 512 | 462,490,908 |

These are reservation slots, not billions of allocated objects. Across all
recorded helpers, 15.29 billion reserved slots are returned unused with the
default batch. Batch 32 reduces this to 0.91 billion.

The line profile puts 48.85 cumulative CPU seconds in
`discardNativeStructHandles` with the counters enabled. Its largest lines are:

- 23.08 seconds checking that each unused handle is free.
- 6.61 seconds checking that the nursery list tail matches the reserved batch.
- 11.73 seconds scanning the batch again to retain live handles.

Batch 32 reduces that function to 5.92 cumulative CPU seconds. These times overlap
the instruction rows above; do not add them to the table. A lighter CPU profile
without the instruction counters also found this function: 30.72 cumulative
CPU seconds, about 26% of that run's sampled CPU time.

Source locations in the local Wago worktree:

- `src/wago/gc_array_helper.go`: allocation-time cancellation before the helper
  switch.
- `src/core/runtime/gc/native/native_alloc.go`: `reserveNativeHandles`,
  `CancelNativeAllocationBatch`, and `discardNativeStructHandles`.
- `src/core/runtime/gc/native/native_alloc_batch_amd64.go`: the existing
  `WAGO_AMD64_GC_STRUCT_BATCH` override.

See the [line profile](data/wago-local-perf-2026-10-20/instruction-lines-discardNativeStructHandles.log).

## Full-job check

| Same helper-counter host | Wall seconds | User + system CPU seconds | Peak RSS KiB |
| --- | ---: | ---: | ---: |
| Default 512-handle batch | 145.752 | 146.116 | 1,123,088 |
| 32-handle batch | 95.383 | 95.956 | 1,246,072 |

This is a 34.6% lower wall time for this pair. Both runs use the same binary and
the same generated native artifact bytes. The native artifact SHA-256 is
`09c851a691ccb9f402197b00455c8e2854ca8b331178d91d742c94ced70f1de2`.
Only the batch environment setting changes. Both outputs pass the same checks.

The uninstrumented local host also passes with batch 32 in 83.712 seconds. Its
earlier default runs took 125.331 and 133.270 seconds. Other user jobs were active;
load changed between runs. There are few full samples. Use these as evidence of
the removed work, not a precise general speed ratio or a memory improvement.

## Small reproduction on the installed CLI

[allocation-mix.wat](data/wago-local-perf-2026-10-20/allocation-mix.wat) has two
exports. Each runs 500,000 loop iterations. One makes two structs per iteration.
The other also makes an array with `array.new_fixed`, then reads values from both
objects. Results are checked against integer sums. All runs load the same saved
native artifact through the installed Wago runtime.

Three samples per case, with reversed batch order in the middle round:

| Allocation pattern | Batch 512 median | Batch 32 median |
| --- | ---: | ---: |
| Structs only | 21.6 ms | 29.3 ms |
| Structs mixed with arrays | 824.8 ms | 242.6 ms |

These are process times, including startup and instance setup. The mixed case is
3.4 times faster with the smaller batch. The struct-only case favors 512. This
supports reducing wasted reservations for mixed allocation, while keeping large
batches for long struct-only sequences.

Run the reproduction from the Dewdrop root with:

```sh
python3 docs/research/data/wago-local-perf-2026-10-20/allocation_mix.py
```

## Compile latency and remaining cost

The installed runtime builds the compiler Wasm into a native artifact in a
median 0.568 seconds with one worker and 0.262 seconds with eight workers. Each
case has three samples and performs a fresh build. The local stack shows no clear
gain over the base in this step. See
[native-summary.json](data/wago-local-perf-2026-10-20/native-summary.json).

For the full request, base runs took 112.678 and 104.885 seconds; the default local
stack took 133.270 and 125.331 seconds. The order was base, local, local, base.
The local stack's warm native-cache run passes in 124.915 seconds. Saving native
code therefore does not remove the long execution step. A fresh Node process
passes the same request in 3.470 seconds. It uses the existing Node Facet host.

Native leaf-PC probes found hot array access routines and the shared GC resolver.
However, only 658 of 2,871 native observations have exact instruction source maps.
The rest stay marked as unknown source, with their known function or shared
region retained. The probes have no stacks and do not measure hardware CPU time.
They cannot give a complete native instruction ranking. No records were dropped;
the sampler reported no errors and about 2.10 seconds of total stop overhead.

The largest confirmed target is allocation batch cancellation and refill.
Array reads remain a useful second target because of their volume and hot native
routines. The measured Go cost of reference casts is much smaller. More native
compiler workers cannot remove this execution cost.

## Next fix and retained data

First, reduce repeated scans of unused reservation slots, or adapt batch size to
mixed struct/array allocation. Preserve the handle ownership and live-root rules.
The tested environment override is a workaround for this job, not a changed
global default. No runtime algorithm change was installed.

The [data directory](data/wago-local-perf-2026-10-20/) keeps timings, commands,
hashes, CPU profiles, counters, scripts, and source fixtures.
[summary.json](data/wago-local-perf-2026-10-20/summary.json) collects the main values.
Large native source maps, probe samples, binaries, and output artifacts remain
under `.tmp/wago-local-perf-2026-10-20/`.

Two development failures are retained as rejected runs: the first full-job
harness passed an absolute request path, and the first instruction-host build
lacked a diagnostic API forwarding function. Both were corrected before the
accepted runs. Neither failure is counted as a Wago correctness result.
