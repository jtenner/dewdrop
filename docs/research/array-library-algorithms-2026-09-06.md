# Array algorithms in Dew

Status: complete. All Array algorithms run in Dew. Native/shared tests,
self-host tests, clean bootstrap, stress, and pinned-provider checks pass.

All 13 remaining Array functions now have ordinary Dew bodies: allocation,
unchecked reads/writes, push/pop/clear, iterator creation/advance/check, reserve,
shrink, and truncate. Unchecked operations still trap outside logical length.
Reserve checks addition before growth and avoids overflow when doubling.

The iterator declares its owner and cursor. It observes the owner's current
length, including growth and truncation after iterator creation. Raw storage
keeps scalar carriers and existing product box adapters; Unit effects remain in
the normal evaluation schedule.

Clearing copies default storage without manufacturing a logical T. If an unused
slot exists, the last slot supplies the default. A full array allocates one
temporary default slot. The cleared range then doubles through overlap-safe
`array.copy` calls. This uses constant extra space and does not assume literals
or Map-produced arrays have a hidden sentinel. A pop from full storage needs
one temporary allocation; later pops reuse the now-unused default slot.

Compiler defects exposed so far:

- Native let bindings checked the unspecialized local shape when deciding
  whether Unit needed a local slot. The check now uses the selected type.
- Native call arguments omitted nominal casts for generic call results.
- Self-host if emission used a recovered result instead of the frozen plan.
- Ordinary Map forwarding bodies need logical key identity, not only eqref,
  to retain String equality. Their runtime adapters are not compile-time
  queries. A separate `logical_arguments` set retains exact keys through generic
  callers without making them run branch removal or guarded trait resolution.
  A regression checks distinct String/Bytes requests and zero query instances.
- Self-host Map payload access and literal Option payload patterns must use
  the selected body's concrete type argument, not a generic reference guess.
- Clean bootstrap exposed a separate dead-code/poison-state collision. The
  [dead-state fix](typed-dead-expression-state-2026-09-06.md) preserves errors
  while marking only proven unreachable expressions as dead.

Both compilers now call the selected Dew functions. Native operation/method
ordinal dispatch and the ArrayIter layout override are removed. The policy
suite forbids all old Array algorithm builtin names in every standard module.
Array literal construction and shared legacy collection builders still need
their separate migration; this change does not claim to remove those paths.

The shared corpus has 28 checks. It covers overflow before allocation, logical
bounds inside spare capacity, growth, shrinking, truncation, iterator mutation,
Unit effects, scalar and product storage, and reference clearing. The reference
clearing test has a live-element control and checks the null/cast trap from the
removed slot. A generic Unit local and a scalar Option literal pattern retain
regressions for the compiler faults exposed here.

## Validation

- Native routine lane: 921 tests pass, 136.880 seconds. The semantic lane took
  86.986 seconds and the backend lane took 36.275 seconds.
- Native integration lane: 266 tests pass, 49.831 seconds.
- Generated sources and policy checks pass, 17.052 seconds. The Array policy
  suite has eight tests.
- Standard library: 319 tests and all shared cases pass, 21.376 seconds. The
  shared Array corpus has 28 checks in both compilers.
- Self-host hardening: 225 tests, 29 invariant records, and all emission/semantic
  probes pass, 53.420 seconds. This includes the dead-branch/live-poison and
  runtime-logical-key regressions, String Map equality, and 28 Array checks.
- Clean bootstrap passes, 179.043 seconds. Compiler B/C linked bytes share
  SHA-256 `fa623c142fb5ef67692fbbeff7e519e605bad8495c2aa200d296283d03ceb6c2`.
  Their core bytes share
  `838ec8a356b3474e2c0e3aff5e603524b0f41a9c3cedabe3bf147ed3408decc9`.
  Compiler A build took 44.816 seconds; A/B executions took 47.436 and 66.529
  seconds. All core and linked Wasm validators passed.
- Stress lane: 15 tests pass, 0.130 seconds.
- Full pinned Starshine lane: 10,982 tests pass, 281.997 seconds. Its invalid
  module fixture prints a validator error as expected; the suite has zero
  failing tests.
- Final warm generated-source, policy, metadata, and CLI checks pass,
  3.606 seconds.

Activities above 30 seconds are performance bugs, not reasons to omit
verification. No Starshine provider source or FFI bindings changed in this
migration.
