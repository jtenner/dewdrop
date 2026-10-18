# Native live lambda capture shapes

The native base fragment planner checked capture owners and spans, but selected
capture cells, closure fields, and lifted parameters without checking their
physical shapes. Its storage helpers accept Generic, Error, and product shapes
as references. The selected-instance planner and the Dew compiler already have
concrete capture shape checks.

The base planner now checks live concrete captures after capture metadata checks
and before physical planning. It uses the existing SPC-301 record and includes
the module, owning declaration, root body, lambda expression, and relative capture
position. Elided lambdas and unspecialized generic callable templates keep their
existing path. Selected instances retain their checks after type substitution.
The wider physical-boundary audit remains open.

Concrete scalar shape checks return before allocating a shape worklist. Product
checks use the existing iterative checker. The added module scan is linear in
capture count and retains no new collection. This is a source-level allocation
assessment, not a measured allocation count or a runtime speed claim.

## Tests and validation

The exact-record regression first returned Ok instead of SPC-301: six tests
passed and one failed in 8.562 seconds. The final focused file passes all nine
tests in 8.322 seconds. Cases cover escaping closures, lifted captures, mutable
cells, Generic/Error roots and product leaves, a second capture, distinct body
and declaration IDs, concrete shapes, elided lambdas, and generic templates.
Existing lambda shape tests retain their full failure-record checks.

The full native lane passes all 1,470 tests in 299.607 seconds. The generated
checks pass in 17.692 seconds with installed `bun@1.4.3` and
`wasm-tools@1.262.0` selected through `mise exec`. Initial generated checks stopped
because those installed tools had no selected version; the tools were selected
for the command without changing global configuration.

The integration lane passes all 272 tests in 76.471 seconds. The library lane's
343 tests and shared execution checks pass in 72.506 seconds. Peak child-process
RSS is
93,000 KiB for integration and 2,259,348 KiB for the library lane. These are
absolute lane measurements, not a baseline comparison or compiler allocation
counts. The full native, integration, and library totals exceed 30 seconds and
remain recorded timing defects. The longest individual native test group is
14.885 seconds; the longest integration group is 16.546 seconds.

Self-host hardening passes all 1,022 tests, 504 exact records, 47 emission
corpora, and semantic probes in 58.733 seconds. Peak child-process RSS is
708,548 KiB. Cold hardening test generation, including the native generator
rebuild, took 31.280 seconds; the warm run took 5.917 seconds. The cold phase
and aggregate lane remain timing defects.
The complete run exposed a separate host-import gap in the runners, fixed in
`d79bfa8d57`; see the
[runner note](self-host-hardening-host-imports-2026-10-18.md).
All 15 stress tests pass in 0.336 seconds.

All 15,235 pinned Starshine tests pass in 101.966 seconds, with 65,012 KiB
peak child-process RSS. The final run selects installed Binaryen 133 through
`mise exec github:WebAssembly/binaryen@ersion_133`, as well as Bun and wasm-tools.
Earlier provider runs stopped at the unselected wasm-tools or Binaryen shims;
the final complete run has no failed tests. Its aggregate time remains above
the 30-second limit.

The clean `tools/check-self-host-bootstrap.sh --clean --fast` lane passes in
57.608 seconds, with 1,097,176 KiB peak child-process RSS. Compiler B/C core,
raw linked, and final bytes match. The B/C linked SHA-256 is
`e7211b7fa9daf63b820717fe9b8b90ae0fb8668f003e32c1587951941a3e01ab`.
The native A source build takes 15.333 seconds; A and B execution take
14.646 and 15.284 seconds. Each measured phase is below 30 seconds. The
aggregate lane remains above that limit.

Raw logs, command arguments, memory samples, and the source build identity are in
`.tmp/capture-boundary-review`. Measurements use x86_64 Linux, MoonBit
`0.1.20261012 (748b63c)`, and Node `v24.21.0`.

Claude Code could not inspect the change because its session limit was reached.
Its exit status was 1. The read-only review packet and stdout/stderr are at
`/tmp/dewdrop-capture-review-34bpztl7`. The separate GPT review found no confirmed
defect. It noted that negative tests call the checked preflight directly: the
native panic-test runner cannot require an exact abort record from the full
planner. The planner hook was checked by source review, and valid full-planner
cases remain covered.

The source-local follow-up is now complete; see the
[mutable source-local log](native-mutable-capture-source-shapes-2026-10-18.md).
This change checks the capture record; that follow-up checks the separate
source-local fact and selected cell storage.
