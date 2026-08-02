# Map/Set growth benchmark

This benchmark generates a deterministic Dew workload containing explicit Map and Set insertions and lookups. Explicit operations avoid depending on future Dew loop lowering and make the generated operation count stable.

Run both Node and Wago Core 3 measurements with:

```text
tools/wago-map-bench/run.sh
```

Optional environment variables control the workload:

```text
COUNT=512 CALLS=20 ROUNDS=7 tools/wago-map-bench/run.sh
```

The benchmark builds under `.tmp/map-growth-bench`, instantiates one module per engine, warms the exported `main`, and reports median nanoseconds per complete workload. Wago also reports host allocation per invocation. The workload uses a deterministic full-period LCG key sequence so bucket occupancy exercises realistic collisions rather than sequential perfect distribution.

Threshold selection measurements are recorded in `docs/research/hash-map.md`. Benchmark numbers are comparative and should be refreshed on the same machine/runtime before changing the growth threshold.
