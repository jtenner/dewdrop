# Unit pattern bindings and stored markers

A derived enum with a Unit payload exposed a mismatch between logical values
and physical storage. A Unit payload has a null reference storage marker but
produces no operand or Wasm local. The physical pattern pass propagated the
reference marker into the binding and produced an absorbing Unit/eqref conflict.

Pattern propagation and verification now use a shared field-carrier helper.
Only a selected field with a declared Unit or generic-erasure storage
certificate can translate its marker to logical Unit. A wrong scalar field
retains its scalar carrier; it cannot become a valid Unit certificate. Normal
physical-field reads still describe the actual storage type.

The emitter checks the frozen local carrier and the field certificate before
omitting a Unit binding store. A missing non-Unit local remains an error.
Tests cover Unit between scalar payloads, a one-field storage mutation, and
real derived output in both compilers. The initial corrected plan exposes the
emitter's missing-local error; the emitter is fixed too. The combined hardening
lane passes 365 tests, 108 exact failure records, and all shared execution
corpora in 57.726 seconds. The Unit test lives in the existing constructor-flow
test file. Full-lane checks are still running with the separate derive and
bound-call fixes. No speed work is included.
