# Array bulk functions and erased values

## Library changes

`make`, `copy`, `copy_within`, `fill`, `slice`, and `extend` now run as Dew
functions. Their native declaration-ordinal lowering entries are removed.
`copy_within` copies backward for right overlap. Range checks use subtraction,
so unsigned additions cannot make an invalid range appear valid. `extend`
captures the original source length before mutation, including self-extension.
The element expression passed to `make` or `fill` is evaluated only once.
Growth stays in the existing push operation; bulk extension does not need a
second reservation algorithm.

The policy test checks all standard modules, the intrinsic facade, and the
generated ordinal registry. It rejects the six old opaque builtin targets.

This is not the full Array migration. Storage, growth, reserve, shrink, basic
mutation, and iteration still have legacy compiler runtime paths. Unreachable
legacy bulk emission builders also remain until that removal is complete.

## Correctness fixes required by these tests

- Native Unit array elements use a null storage marker. Unit expressions,
  locals, arguments, and results remain erased. Reads drop the stored marker;
  writes and literals evaluate the source before adding it. Storage locals have
  the marker's reference type. Option payload layout demands from inferred
  bodies were fixed in the separate inferred-enum commit.
- Self-host Unit runtime calls have explicit storage adapters. Specialization
  creates a separate Ref request before linking. The adapter selects the same
  declaration with that exact shape, checks parameter/result counts and operand
  carriers, adds the Unit marker on writes, and discards it on reads. Missing or
  duplicate targets and ABI mismatches publish numeric context before trapping.
  This does not normalize Unit, Generic, or Error to Ref, and adds no new builtin
  target or runtime algorithm. These adapters are transitional with the legacy
  storage implementation.
- Calls with erased specialization slots use their frozen call target and
  evaluation schedule, including the receiver exactly once. Carrier-only runtime
  lookup cannot select an erased adapter as a storage function.
- Self-host literals insert Unit storage markers after each source evaluation.
- Self-host index reads use their frozen result carrier. The emitter no longer
  replaces it with a generic-source guess; a 264-line reconstruction path was
  removed. Other legacy index selection shortcuts remain separate open work.

## Execution evidence

Thirteen library tests cover overlap, bounds, overflow, empty ranges, aliases,
reference identity, Unit effects, options, iteration, and expected traps.
A shared ten-case execution oracle runs in both compilers. The self-host probe
decodes a native compiler request containing the real library source, rather
than handwritten substitutes. A missing request or a failed source phase is a
test failure, not a skip.

Checks before the clean bootstrap:

- Native: 793 tests; 74.397 seconds (`/tmp/dewdrop-array-native.log`).
- Library: 319 tests plus all scalar, memory, SIMD, arithmetic, math, product,
  callback, member, and ten array execution checks; 5.575 seconds
  (`/tmp/dewdrop-array-library-runtime.log`).
- Full integration: 266 tests; 48.458 seconds
  (`/tmp/dewdrop-array-integration.log`).
- Generated sources and policy checks: 17.348 seconds
  (`/tmp/dewdrop-array-generated.log`).
- Self-host hardening, invariant records, and shared execution probes:
  19.602 seconds (`/tmp/dewdrop-array-final-hardening.log`).

The native backend lane took 36.780 seconds. It and compiler activities above
30 seconds remain performance bugs. Correctness work has not hidden them.

The clean bootstrap then passed in 202.999 seconds. B and C, both raw and linked,
have SHA-256 `74a41a4e3190d72911b7a9d26baf7650101316fc3ac80161fbed42a0d9029da0`.
The A build and A/B executions exceeded 30 seconds. Log:
`/tmp/dewdrop-array-clean-bootstrap.log`.
