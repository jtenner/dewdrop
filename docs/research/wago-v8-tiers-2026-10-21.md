# V8 tier isolation on the fixed compiler job

Default V8 remains the performance target. The flags below are an experiment to
separate compiler strategy from input and runtime differences. They are not a
replacement baseline.

| V8 configuration | Three samples, seconds | Median, seconds |
| --- | --- | ---: |
| Default | 4.001797, 3.957847, 4.019342 | 4.001797 |
| Baseline only (`--liftoff-only`) | 24.106539, 23.956034, 23.522779 | 23.956034 |
| Optimizing only (`--no-liftoff`) | 7.213450, 7.220931, 7.265433 | 7.220931 |

The only per-configuration change is the V8 flag. The compiler and request bytes
are identical; all nine output Wasm/cache hashes match, Wasm validates, and main
returns 42. Runs are serial, on CPU12,14, with transform workers disabled and
result-cache misses. No task-owned build or test runs during this matrix.

Default V8 takes 5.99 times less time than baseline-only V8. This shows that
optimizing execution and tier strategy have a large effect on this job. It does
not identify a single optimization, isolate tiering compile cost from execution,
or prove that a small emitter change can close the gap. Optimizing-only startup
also differs from default tiering; its slower result is not a reason to change
the primary 4-second target.

The separate current Wago control matrix has a 37.189-second median. That is
still much slower than V8's 4-second default. Its native object checks and
dependent memory loads remain the main profile targets. The 23.956-second V8
baseline-only result is diagnostic context, not a parity claim.

The script, Node/V8 versions, exact hashes, raw commands, logs and per-run output
checks are in [the data directory](data/wago-v8-tiers-2026-10-21/summary.json).
The matrix completes at 2026-10-21 10:44 UTC.
