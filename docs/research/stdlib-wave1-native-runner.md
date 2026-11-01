# Native test runner: missing search tool

The first final native lane used a reduced PATH without Codex's `rg`.
The routine runner's process substitution lost the search exit code and
selected no semantic, backend, or compiler-driver files. It returned zero
in 20.54 seconds despite visible `rg: command not found` diagnostics.
This result is not a full native pass and is excluded from campaign counts.

`tools/test-native.sh` now checks `rg` before selecting tests and exits 127
with a clear message if it is absent. The final retry preserves the inherited
PATH. No compiler or Dew algorithm changes. The original log is preserved
as `data/stdlib-wave1/final/native-setup.log.gz`; the complete retry is saved
separately. A reduced-PATH run confirms the diagnostic and status before any
compiler command.

The runner also checks the file-list pipeline status and rejects an empty list.
A failing search shim reproduced the old zero exit; the same shim now gives
exit 1, retains the search diagnostic, and names the source directory.
Both checks run before any compiler activity.
