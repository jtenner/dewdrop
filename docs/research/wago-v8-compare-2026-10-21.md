# Dewdrop on Wago and V8: 2026-10-21

The same Dewdrop compiler and request were run three times per engine. The
median wall times are **49.255 seconds on Wago** and **3.676 seconds on V8**.
Wago takes **13.40 times as long**. V8 parity has not been reached.

| Engine | Run 1 (s) | Run 2 (s) | Run 3 (s) | Median (s) |
| --- | ---: | ---: | ---: | ---: |
| Wago, local GC stack `69c165ace` | 65.628 | 49.180 | 49.255 | 49.255 |
| V8, Node 24.21.0 | 3.643 | 3.676 | 3.718 | 3.676 |

The first Wago run is slower than the other two. These results do not establish
the cause of that variation. Each Wago run used a fresh native cache. Every
process was new. The order was Wago/V8, V8/Wago, Wago/V8. Runs were serial;
no compiler builds or test suites ran alongside them in this task. The machine
was shared. The times include engine compilation, startup, Dewdrop compilation,
and file output. Output validation ran after the timed process.

The workload is the existing `examples/transforms/parallel.dew` compiler request
with two transform applications, run without guest transform workers. It is
not a complete compiler self-build. The transform-result cache missed on all
six runs. Both output hashes matched on every run, the output Wasm passed
validation, and the output program returned `42`.

The Wago measurement uses the existing private Facet host linked to the GC
source of the installed `local-gc-69c165ace` stack. No unpublished GC experiment
is included. The Node run uses the same compiler bytes, without substitution.
The two engines use their respective Facet host implementations.

- Compiler SHA-256: `c64fcf044b72cb7356ad598a35670045931337cfa7a6bb9d5916cd304b23fba6`.
- Request SHA-256: `077b0ff0271706cc3034f3e06c7a228f227c49aeec7786d21373b2072af89c72`.
- Output Wasm SHA-256: `89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb`.
- Output cache SHA-256: `c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240`.
- V8 version: `13.6.233.17-node.53`.

Exact commands, elapsed and CPU times, memory use, machine load, binary hashes,
logs, and summary are in [the saved data](data/wago-v8-compare-2026-10-21/).
The run script uses the existing measured and checked
[`measure.py`](data/wago-local-perf-2026-10-20/measure.py) harness.
