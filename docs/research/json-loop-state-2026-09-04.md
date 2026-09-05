# JSON loops use Unit state

The complete standard-library runtime lane exposed five
`NonExhaustiveFunctionalLoop` diagnostics in JSON parsing and validation. Each
loop used a Boolean seed and matched only `true`; the Boolean type also contains
`false`. These loops do not use a state value. Their actual cursor and builder
state already reside in locals and the parser object.

The five loops now seed and continue with `Unit` and use a wildcard arm. Their
existing `break` values, error paths, and cursor updates are unchanged. No
fallback arm hides a missing state or a parsing failure. The embedded native
source is regenerated from `std/json.dew`.

Verification uses `tools/dew-test/run.sh`, which compiles the complete library
test set twice, checks byte equality, and executes the resulting Wasm tests.
The prior run failed visibly with the five diagnostics in 15.791 seconds.
After the change, all 291 library runtime tests and builtin trap probes pass;
the two compilations are byte-identical. The lane takes 14.658 seconds.
