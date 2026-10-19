# Late transform import source selection

## Defect

A transform can call `ctx.import_module("dew.std.map", "generated_map")`
and create a body that reads `@generated_map.selected_marker`.
When the selected on-disk `std/map.dew` declares that value, the body must use
those selected bytes.

The CLI previously loaded only imports visible before expansion, plus the
transform library dependencies. A later map import could therefore be absent
from `StandardLibrarySources`. Its per-path embedded-source fallback then
silently replaced the selected package source. The native compiler pipeline,
run through the JS CLI, rejected the generated field reference because the
embedded map has no `selected_marker`.

The original reproduction is under `.tmp/late-import-source/`. Before the fix,
the compile failed with `UnsupportedExpressionInference` at the generated field
reference: 1.430 seconds, peak RSS 402,320 KiB. This is a whole-process sample,
not a measurement of loader allocations.

## Change

`load_compilation_standard_sources` detects transform syntax and asks the loader
to retain the complete fixed standard registry. It does not add these files as
manifest modules. Parse-event preparation and module collection still select
the required modules after expansion. Ordinary source manifests retain their
sparse dependency closure.

Complete-registry loading reads and hashes each registered path once. It skips
import scans because all registered dependency paths are already present. A
missing registered source is a visible loader error. An updated late source
changes the standard source fingerprint. `--bootstrap-std` still selects the
explicit embedded source mode.

At this change, the fixed registry has 90 files with 917,135 source bytes.
Those bytes are retained only for transform builds; this count is not a heap
allocation estimate.

## Checks

- Native generated-import test: 1 passed in 7.921 seconds. It checks caller map
  bytes, binary emission, and absence of an unused JSON module.
- Native source loader tests: 8 passed in 4.890 seconds. They include source
  reads, source fingerprints, transitive imports, and missing files.
- `python3 tools/test-late-transform-imports.py PATH/TO/dew_cli.js` checks the
  on-disk CLI path without a Moon build. It runs a normal program with an unused
  source file absent, executes generated values 42 and 43 from selected map
  sources, and checks the missing-file diagnostic. Logs and per-process time
  and peak RSS samples are in `.tmp/late-transform-imports/`.
- The command test fails on the saved old CLI as expected: the ordinary sparse
  case passes in 0.871 seconds with 361,252 KiB peak RSS; the selected-marker
  case fails in 1.403 seconds with 399,648 KiB peak RSS. Evidence:
  `.tmp/late-import-source/before-suite.log`. Each case is a separate Node
  process. These are single samples, not performance gain claims.
- Updated JS CLI build: exit 0 in 1.579 seconds, peak RSS 618,712 KiB.
  The on-disk command tests all pass: ordinary sparse build, 0.853 seconds and
  341,888 KiB; selected value 42, 1.492 seconds and 402,748 KiB; changed value
  43, 1.457 seconds and 408,176 KiB; missing selected map, correct exit 2 in
  0.221 seconds and 185,388 KiB. Output and separate stderr/status files are
  `.tmp/late-import-source/build-js.*` and
  `.tmp/late-import-source/after-suite.*`.

## Time and memory repeat check

Three alternating old/new process pairs compile the same ordinary program and
the same transform program that adds a map import and returns 42. All caches
are off. The generated Wasm bytes are identical across each case's six outputs.
For the transform case, median time is 1.5104 seconds before and 1.4951 seconds
after; median peak RSS is 404,568 KiB before and 404,516 KiB after. For the
ordinary control, median time is 0.8625 seconds before and 0.8509 seconds after;
peak RSS ranges overlap (324,628–363,976 KiB before, 339,644–363,792 KiB after).

These three-sample results show no clear added time or peak-memory cost at this
scale. They do not isolate the loader: the updated compiler also has other
transform fixes. Peak RSS is a whole-process high-water mark and does not prove
equal allocation cost. No gain is claimed.

The harness is `.tmp/late-import-source/measure.py`; exact command lines,
samples, output digests, compiler digests, environment, and inputs are in
`measurement-samples.json`, `measurement-identity.json`, and `measurement.*`
under that directory. Each compiler call has separate stdout and stderr.
Saved compiler files are `before-cli.js` and `after-cli.js` there.

## Dew request packaging limit

`src/self_host_bootstrap_fixture/main.mbt` packages a fixed list of standard
modules directly in `request.modules`. The list includes map but does not
include every standard module. The Dew request consumer has no separate source
pool for later standard import selection. A transform-generated import outside
that packaged list can still fail with a missing-module error. Adding every
standard module to the manifest would also analyze unused modules; this change
does not do that. The request path needs a separate source pool and selection
step after expansion to support every late standard import without that cost.
