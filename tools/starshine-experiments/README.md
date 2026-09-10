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

The default pipeline is `O4s`. This pinned CLI does not accept the spelling
`-O4s`; the equivalent is `--optimize-level 4 --shrink-level 1 --optimize`.
Its expanded pass list is duplicate-function-elimination, vacuum,
reorder-locals, strip-debug. All trials use the default trap-preserving rules.

```sh
# Use binaries that were already built from the current source.
python3 tools/starshine-experiments/runner.py --skip-build

# Compare explicit ordered pass lists, defined in pipelines.json.
python3 tools/starshine-experiments/runner.py --skip-build \
  --pipeline O4s --pipeline cleanup --pipeline speed --pipeline gc-speed

# Focus on one fixture. Choose one engine only when debugging that engine.
python3 tools/starshine-experiments/runner.py --skip-build \
  --fixture text/concat --runtime node

python3 -m unittest discover -s tools/starshine-experiments -p 'test_*.py'
```

Results and Wasm files remain in `.tmp/starshine-experiments/`. `report.json`
contains tool/source identities, commands, timings, diagnostics, sizes, binary
hashes, and runtime results. Each fixture also has a `result.json`. Use a distinct
`--output` directory to preserve a previous run. The default is four workers;
use `--jobs 1` for isolated compile/optimization timing.

These execution checks complement the canonical WAT and reproducible compiler
checks in `tools/module-snapshots/run.sh`. Optimized WAT is expected to differ,
so this experiment does not compare it with the unoptimized WAT snapshots.

Research and measurements: [September 2026 experiment](../../docs/research/starshine-execution-pipelines-2026-09-10.md).
