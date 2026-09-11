# Evidence for the deeper Starshine study

Read [the study](../starshine-deep-pipeline-2026-09-10.md) for decisions and limits.
All formats are version 1. Paths use `$DEWDROP` for the repository root; `.tmp`
paths preserve the original experiment locations. To repeat a run elsewhere,
use the same source/compiler revision and the paths for that checkout.

- `validation.json`: native tests, build, runtime regression, CLI checks, and timings.
- `master-rebase.json`: the rebase to remote master, all 461 fixtures under the
  three shipped/reference profiles, 48 byte-identical benchmark outputs, and
  17 known failures that still reproduce with the rebased native build.
- `corpus-summary.json`: all five source sweeps, complete counts, and durations.
- `discovery.jsonl`: 32 initial orders with Starshine `48d6337ce`.
- `ordered-screen.jsonl`: 20 orders after the SSA fix at `30c63c455`.
- `ordered-wave2.jsonl`: 10 local-coalescing variations.
- `ordered-wave3.jsonl`: three corrected long orders, all fixtures passing.
- `ordered-wave4.jsonl`: inlining/local-order variations; the no-coalescing
  candidate passes all fixtures. The other four candidates retain failures.
- `defects.json`: every failed fixture, input hash, category, and full diagnostic.
  Categories are this investigation’s classification, not a semantic oracle.
- `heap-prefix-*.json`: the first failing Heap2Local prefixes before the SSA repair.
- `deep-core-map-prefix.json` and `deep-nested-pattern-prefix.json`: exact first
  failures from repeated local cleanup after control simplification.
- `o4z-queue.json`: the real 73-slot expanded JSON-module O4z order.
- `benchmark-screen.jsonl`: initial three-process screen without byte deduplication.
- `benchmark-confirmation.jsonl`: all 16 workloads, seven processes, 41 samples,
  explicit equal-byte aliases, encoded sizes, and per-command durations.
- `summary.json`: per-workload ratios/intervals and aggregates for both benchmark runs.
- `final-aggregate.json`: paired ratios versus the old speed profile, with 95%
  resampling intervals over process ratios within each fixed workload.
- `optimizer-command-times.json`: five rotating rounds on each of the 15 distinct
  raw inputs; every output hash matches the runtime-measured artifact.
- `pass-attribution.json`: full order versus removing Heap2Local or SSANoMerge.
  These are output-attribution experiments, not extra approved CLI profiles.
- `fuzz-ssa-regular.json` and `fuzz-ssa-dedicated.json`: the 10,000-case generated
  comparison summaries. Both use explicit Binaryen 131 and a prebuilt optimizer.
- `ssa-fuzz-triage.json` and `ssa-fuzz-dedicated-triage.json`: all 40 retained
  mismatch inspections and byte comparison to the old `b92bf0767` binary.
- `cli-cold.json` and `cli-warm.json`: CLI commands, status, output, and timings.
  Nonzero commands are intentional negative checks in the passing CLI test.

Corpus JSONL starts with one metadata record and then one record per fixture.
Each compact timing row is `[program, seconds, exit_code, timeout]`. Successful
variant outputs equal the recorded baseline output; hashes and all output sizes
are retained. Failed rows retain their full diagnostic. No errors or timeouts
are converted into passes. Benchmark JSONL retains every runtime sample;
`equivalent_to` means that exact Wasm bytes shared samples with the named entry.

Raw artifacts remain under `.tmp/starshine-deep-logs` in the original workspace.
The small permanent SSA reproducer and executable regression live in the pinned
Starshine source tree. The experiment configuration and source generators are
in `tools/starshine-experiments`.
