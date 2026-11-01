# Mission A fixture review evidence

The [main report](../stdlib-fixture-fixes-2026-11-01.md) records all eight
verdicts, source references, full-diff scope, commands, and gate results.
The owner has accepted G0 as PASS WITH KNOWN RED. This work does not revisit
the accepted 67.88-second cold build.

Evidence is in `data/stdlib-fixture-fixes/`:

- Eight `*.diff.gz` files retain every baseline hunk and custom-fact byte.
- `before.log.gz` is the fresh full failing run. All eight diffs match the
  historical baseline exactly; 453 of 461 pass, with 922 compiler calls.
- `review.py` checks every old hunk line against base `b9fcc8ea` and replays
  the reviewed candidates in memory. For the four large fixtures, explicit
  maps check all retained function bodies and all removed forwarding bodies.
- `review-before.jsonl` and `review-after.jsonl` record candidate hashes,
  full custom-fact line hashes, hunk counts, and exact body-check results.
- `check-wat.py` parses and validates base/current WAT, then checks both
  Node and Wago output against the unchanged JSON expectations. It uses
  temporary files, shows failed subprocesses and assertions, and times all
  parse/validate calls and the Wago runner build.
- `wat-runtime.log` records the first old/candidate run. The later
  `wat-runtime-replay.log` comes from the saved, repeatable script.

No blanket update was run. Each WAT was copied from its own reviewed
candidate into its exact expected path, with its own report section and
bounded commit. This changes no compiler code and needs no native unit or
compiler integration test lane beyond the full snapshot lane.

The final full run passes **461/461**, with no escalations, in **198.09
seconds**. Its 922 compiler calls each finish below 30 seconds; the longest
is 1.880 seconds. `after.log.gz` retains the complete run and `results.json`
records the counts and times. Build files and generated caches were removed.
