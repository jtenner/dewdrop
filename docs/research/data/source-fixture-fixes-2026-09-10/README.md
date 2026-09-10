# Source fixture repair evidence

See [the research note](../../source-fixture-failures-2026-09-10.md).

- `initial.jsonl`: all 46 original source failures reproduced on committed code.
- `all-pipelines.jsonl`: fresh source, all 461 fixtures, 17 explicit pipelines,
  Node and Wago. Each failed trial remains visible. Metadata records binary and
  source identities; per-case records retain sizes, outputs, timings, and errors.
- `summary.json`: counts by pipeline and paired benchmark summaries when present.
- `source-validation.json`: official reproducible snapshots and native test counts.
- `snapshot-command-timings.jsonl`: all official snapshot command timings.
- `pipeline-performance-bugs.json`: every over-budget optimizer command.
- `inlining-regular.json`, `inlining-profile.json`: 10,000 comparisons per lane
  against Binaryen 131, including exact tool identities and commands.

`$DEWDROP` denotes the repair checkout. `$OUTER_DEWDROP` denotes the parent
workspace that supplied pinned tools and stored temporary outputs. The broad
17-pipeline run intentionally retains rejected candidates, so its overall status
is failing even though every baseline and eleven pipelines pass.

Large modules and full logs are under `.tmp/source-failure-logs` in the parent
workspace. Saved results are evidence for the listed hashes, not every future
workspace edit.
