# Starshine execution evidence

See the [research report](../../starshine-execution-pipelines-2026-09-10.md) for
the result, method, limits, and reproduction commands. All data formats are
version 1. `$DEWDROP` stands for the repository root. Full Wasm binaries and raw
command logs remain in the corresponding `.tmp/<campaign>/` directories.

`summary.json` contains counts and paired benchmark statistics for all 19
campaign reports below. The JSONL files start with one `metadata` object and
then contain one `case` or `workload` object per line. Successful commands retain their
program, wall time, and exit status. Failing commands also retain arguments,
output, and timeout state. Case output and binary hashes remain available.

| Files | Evidence |
| --- | --- |
| `starshine-O4s.jsonl` | Current workspace source baseline and O4s; 88 baseline failures remain visible |
| `starshine-committed-O4s.jsonl` | Clean compiler source run; 46 baseline failures remain visible |
| `starshine-wat-candidates.jsonl` | Initial O4s, cleanup, speed, and gc-speed sweep |
| `starshine-wat-small-candidates.jsonl` | Peephole, casts, heap, and prune sweep |
| `starshine-wat-refined-candidates.jsonl` | Heap, inlining, CSE, and precompute with pruning |
| `starshine-wat-combined-candidates.jsonl` | Combined inlining and folding orders |
| `starshine-committed-library.jsonl` | Original library run, including the constructor defect and two setup failures |
| `starshine-library-repaired.jsonl` | Corrected SHA import and builtin-trap checker |
| `starshine-library-candidates.jsonl` | Library evidence that exposed the encoder defect |
| `starshine-library-combined.jsonl` | Combined pipeline library checks |
| `starshine-final-fixtures.jsonl`, `starshine-final-library.jsonl` | Fixed release; eight pipelines pass all executable inputs |
| `starshine-inline-fixtures.jsonl`, `starshine-inline-library.jsonl` | Both smaller inlining limits pass all executable inputs |
| `starshine-consumers-rechecked.jsonl` | ABI, package, Facet, UTF, SWAR, and WASI checks; two source failures |
| `starshine-cli-confirmation.jsonl` | O4s and fold-inline CLI run; saved diagnostic mismatch |
| `starshine-final-benchmarks.jsonl` | First five-process, eight-pipeline speed sweep |
| `starshine-inline-screen.jsonl` | Three-process screen of smaller inlining limits |
| `starshine-confirmation.jsonl` | Final seven-process comparison with CPU affinity 8,10 |

Benchmark JSONL keeps every timed sample, batch size, process median, input
expectation, module size, code-section size, and engine compile time. Compare
paired process medians; do not count samples within one process as independent
process runs. The final research conclusions use `starshine-confirmation.jsonl`.

Additional diagnostic evidence:

- `short-circuit-prefix.json`: simplify-locals first introduces the runtime loop.
- `finalizer-replay.json`: external validation and execution after the return
  repair; includes constructor and member-call assertions.
- `vacuum-10000.json`: exact generated comparison command, Binaryen 131 identity,
  counts, size deltas, elapsed time, and 20 original-CLI replay results. The
  generated lane has no runtime-equivalence claim.
- `native-validation.json`: measured build/interface commands and full native
  suite result. `slow-native-test.txt` records the existing slow DAE stack.

Regenerate the corpus and benchmark files with
`tools/starshine-experiments/summarize.py`, passing all desired `report.json`
paths on one call. That tool overwrites `summary.json` with the supplied set.
