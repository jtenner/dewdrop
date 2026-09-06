# Queue library entry points

Queue now calls circular-buffer functions through ordinary Dew bodies. No Queue
builtin operation or declaration-ordinal method table selects its implementation.
The source loader includes the new circular-buffer dependency.

The public FIFO API is unchanged. `queue_enqueue` traps if a supplied bounded
buffer rejects the value; it cannot silently lose the value. Queue constructors
always select a growable buffer. Iteration does not remove values.

Three execution tests cover growth after wrap, alias-preserving clear and reuse,
and iteration in logical order. The semantic test checks source, import, resolved
type, inference, and lowering diagnostics. The source-policy test first failed
with the old builtins present.

This commit removes Queue's entry-point dispatch. The circular-buffer storage
implementation remains a separate data-type migration. Its shared native and
self-host execution corpus will also cover Queue with Unit, product, and
reference values.

## Measured checks and visible failure

- Queue policy: 2 tests passed (0.039 seconds).
- Native integration after the dependency fix: 266 passed (75.951 seconds).
- New full stdlib execution: compilation fails before execution (11.921
  seconds). The old ring emitter declares an eqref scratch local for an I64
  value in generic `queue_enqueue`. This failure is retained, not skipped or
  accepted as a passing execution test. The next storage migration must fix it.

The integration run above 30 seconds remains a performance bug.
