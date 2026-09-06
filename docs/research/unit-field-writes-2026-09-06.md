# Unit writes to generic fields

The Map<key, Unit> replacement test exposed a missing self-host storage marker.
The source value correctly emitted no stack operand, but struct.set still
required the generic field's erased reference slot.

Assignment now inserts a null marker only when the exact field declaration and
physical storage have the existing Unit-erasure certificate. A missing
certificate reports an error. Receiver and value evaluations remain in source
order. The shared member fixture checks direct and indexed Unit assignment,
with visible effects from both receiver and value.

Self-host hardening and shared tests pass (52.996 seconds). The full lane remains
a performance bug over 30 seconds. Native library and shared tests also pass
(the measured log is `/tmp/dewdrop-unit-write-library.log`). The ordinary Map
candidate now passes all eight execution checks in both compilers; self-host
request compilation and execution took 1.767 seconds.

Map production migration and the rest of the compiler audit are still open.
