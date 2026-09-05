# Raw Wasm array Unit storage

Raw `WasmArray<Unit>` construction failed in the native compiler with
`UnsupportedExpression(..., -101)`. The self-host compiler emitted an
`array.new` with a missing stack operand. Both failures have reduced source
tests, shared between the native and self-host execution lanes.

## Storage rule

Unit has no logical stack value. A raw array still needs one physical value
per cell. Its Unit cells now use null reference markers. This is an explicit
storage adapter, not a change to Unit function parameters, results, or enum
payloads.

- Construction evaluates the length and initial value in source order, then
  supplies the marker to `array.new`.
- Writes evaluate the array, index, and source value, then supply the marker.
- Reads execute `array.get` and drop the marker. Bounds traps still occur.
- Generic, Error, and Never evidence cannot select Unit marker storage.

The native fragment and specialization planners use a separate raw-array
storage helper. The existing logical/enum carrier helper is unchanged. Both
emitters perform the matching storage steps. The generated semantic interface
was refreshed; this also records already-implemented shuffle, module-origin,
closure-signature, and raw-instruction API changes from earlier commits.

## Checks

- The semantic test checks Unit storage separately from logical erasure and
  rejects Generic, Error, and Never storage evidence.
- Three shared execution cases check Unit effects and length, an out-of-bounds
  read, and an out-of-bounds write. Unexpected case IDs cannot pass the oracle.
- `tools/test-native.sh`: 796 tests passed, 64.241 s.
- `tools/test-integration-native.sh`: 266 tests passed, 46.171 s.
- `tools/dew-test/run.sh`: all existing checks and three new cases passed,
  15.212 s.
- `tools/test-self-host-hardening.sh`: all tests, numeric failure records,
  and execution probes passed, including the three new cases, 120.986 s.
  The cold native test-generator build accounts for most of this time.
- `tools/check-generated.sh`: passed, 16.207 s.
- `tools/check-self-host-bootstrap.sh --clean --fast`: passed, 203.045 s.
  B/C raw and linked SHA-256 are identical:
  `045263efaa6c8f36b1268da62f9613a932ca7646d57ffa47c5a742809a18780f`.
  A build took 35.170 s; A execution 71.183 s; B execution 76.478 s.

Runs over 30 seconds remain performance bugs. These checks do not close the
remaining standard-library migration or the complete physical ABI audit.

## Remaining work

Remove the compiler's legacy `FixedArray` method dispatch and use its existing
Dew bodies. Complete raw product storage and multiple-type-parameter tests.
Move Array fields and growth into Dew with checked raw instruction contracts.
Compile-time `is_unit::<t>()` and branch replacement are a separate, unimplemented
language change; this patch does not add them. The remaining queue is recorded
in [`../../agent-todo.md`](../../agent-todo.md).
