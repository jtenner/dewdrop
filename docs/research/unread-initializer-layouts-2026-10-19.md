# Physical layouts used by unread initializers

A normal runtime initializer can construct a private record, pass it through a
generic function, then read a field. The initializer still runs when the stored
global value is never read. Its record layout must therefore reach emission.

The native and Dew physical planners collected nominal layout demand from
reachable callable bodies but did not scan module initializer bodies. A minimal file with
one `Payload` record and `let unread = identity(Payload::{ value: 1i32 }).value`
failed during normal Wasm emission with `UnsupportedExpression(..., 6)`. The
same failure occurs with an imported generic identity helper and with 129
different record initializers. These controls contain no transform code.

The normal-runtime root selector now marks each initializer that it already
plans to execute as a root declaration. Physical layout demand uses one body
scanner for callable bodies and marked initializer bodies. Explicit transform
root selection remains sparse: it marks only the initializer declarations that
the transform actually reaches. No additional generic specialization pass or
whole-module type retention was added.

The Dew specialization selector now records normal runtime initializer
declarations in its existing reachable set. Its type-demand pass scans the
selected initializer bodies with the same type-demand scope as callable bodies.
The set still excludes unread initializers during explicit transform planning.

Backend regressions check both a local and an imported generic helper. They
require the record heap to be present and the emitted module to validate. The
existing transform root tests remain the control for unused initializer frames.
A Dew type-demand test also requires exactly one record heap for the minimal
unread-initializer source.

Before-fix source controls and exact CLI identity are saved in
`.tmp/transforms-v3/initializer-layout/`. The three no-transform controls failed
in 2.2105, 2.3349, and 2.0632 seconds respectively. The original transform case
is retained in `.tmp/transforms-v3/frame-runtime-root/`.

The two Native backend tests pass in 10.400 seconds. The combined Dew suite
passes all 115 tests, including the three physical-type-demand cases. The new
test uses its own lowering setup and requires exactly one record heap. Logs:
`.tmp/transforms-v3/products-initializers-native.log` and
`.tmp/transforms-v3/products-initializers-dew-fixed.log`.

The rebuilt JavaScript CLI
`c3e81fa2108f6d7d36d4127f5f8dc74ca7fd918d032f1d8fae6119aac4d94dac`
now compiles, validates, and runs the original 129-initializer transform control.
It returns 42. The log is
`.tmp/transforms-v3/products-initializers-js-runtime.log`. Fresh self-host
compiler requests remain pending; this result is from the Native implementation.
The combined Dew lane took 36.111 seconds and exceeds the activity bound.
