# Never local initializers

## Cause

The native backend did not emit a `let` with a `Never` initializer. Physical
local planning correctly assigns no Wasm local slot to `Never`. Block emission
then accepted a missing slot only for `Unit` and returned `InvalidLocal` for
`Never`, after it had emitted the initializer.

The transform interpreter exposed the bug in `ct_match` with its non-returning
`let _ = while 0u32 { ... }` expression. The local plan had local ID 14, type
`-12`, and shape `NeverPlannedValueShape`.

## Fix

Block emission now accepts a missing local slot for both `Unit` and `Never`.
The initializer still emits its control transfer. No local write is needed,
and no local slot is added. Other missing local slots still return an error.

The self-host backend already has this rule in
`self_host/compiler/starshine_physical_locals.dew` and its block emitter.

`src/dew_test_gen/main.mbt` now prints the callable and local plan when code
emission returns `InvalidLocal`. This work runs only on an emission error.

## Checks

- Small saved compiler reproduction: `InvalidLocal` before the fix, 0.344241 s.
- Native regression before the fix: code emission failed, 9.840 s.
- Native regression after the fix: 1 passed, 8.353 s.
- The regression checks that the local has `Never` shape and that the emitted
  Wasm module validates. Its final value is unreachable, as in `ct_match`.
- Full-source direct generation before the fix: 6.711111 s, peak child RSS
  213,612 KiB. This reached the exact `ct_match` failure.

Raw output is in `.tmp/transforms/never-local-red.log`,
`.tmp/transforms/never-local-native-red.log`,
`.tmp/transforms/never-local-native-green.log`, and `.tmp/transforms/dew-5.log`.
Full transform generation now succeeds in `.tmp/transforms/dew-6.log`.
Its 62.042 s total includes the native generator rebuild and exceeds the project
30 s limit. Linking took 16.830 s. All 7 transform tests passed in 0.067 s.

## Cost

The fix adds no data structures, local slots, or generated instructions. It adds
one shape alternative on the missing-local error path. Native test times include
test build work and do not establish a runtime speed change.
