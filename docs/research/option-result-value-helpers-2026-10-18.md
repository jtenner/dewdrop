# Option and Result value helpers

`Option` now has ordinary Dew `map`, `and_then`, and `unwrap_or_else` methods.
`Result` also has `map_err`. Method generics permit changed scalar and reference
payloads. Callbacks run once only on the selected branch. Lazy defaults are
skipped when a value is present. Result defaults receive the error value.

No compiler rule or builtin was added. Existing explicit matches remain valid.
The checked-in bootstrap sources are generated from the two library files by
`tools/generate_option_result_std.py`; `tools/check-generated.sh` checks parity.

The new tests failed before implementation with 16 missing-method diagnostics
and no parse errors (0.213 s). With the methods, the focused test module built
in 0.250 s and all six tests passed under Node. The four new tests cover changed
payload/error types, branch forwarding, skipped callbacks, mutable captures,
and exact callback counts. Compilation used the existing release test generator
and an ordinary importing user module. Tests live in
`std/tests/option_result_test.dew` and run in the normal standard-library lane.

These helpers are a value API improvement. No speed or allocation gain is
claimed, and existing library loops were not replaced. Hot code can keep an
explicit match; a later broad replacement must first compare runtime and
generated allocations with that match.
