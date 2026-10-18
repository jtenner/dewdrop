# Host imports in self-host hardening

The linked hardening test module retains function imports from MoonBit,
Starshine, and Facet. The ordinary test runner and the exact-record runner
provided only WASI `fd_write`. Both stopped during instantiation with a missing
`__moonbit_fs_unstable` module. The linked file has one WASI function, 27 MoonBit
filesystem functions, one `spectest` function, and 261 Facet functions.

The hardening script now selects the ordinary runner's existing
`--allow-unused-host-imports` option. The exact-record runner uses the same
throw-on-call policy. It creates the unused function stubs once and shares them
across probes. Its real `fd_write` remains active. Non-function imports and calls
to an unused host function remain visible failures. No filesystem or Facet host
operation is implemented by these stubs.

The existing linked file now passes all 1,022 ordinary tests in 0.647 seconds and
all 504 exact invariant records in 23.553 seconds. These runs use the same Wasm
bytes that failed instantiation before the runner changes. JavaScript and shell
syntax checks pass. An independent GPT review found no confirmed defect.

The complete hardening lane passes in 58.733 seconds, including the tests,
exact records, all 47 emission corpora, and semantic probes. Peak child-process
RSS is 708,548 KiB. The aggregate lane remains above the 30-second timing limit.

Four manual host-import contract checks also pass in 0.129 seconds: strict
imports still fail without the option; an unused function import can load;
an actual host call fails in the ordinary runner; and the same call fails in
the exact-record runner. Both call checks require the named host-call error,
so a missing Wasm trap or another assertion failure cannot count as success.
The fixtures, check script, and raw logs are in
`.tmp/capture-boundary-review/host-import-contract.py` and adjacent files.
