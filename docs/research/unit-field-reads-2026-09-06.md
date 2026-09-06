# Unit field reads

The ordinary Dew Map prototype exposed a general field-read defect. A generic
field specialized to Unit has no native physical field. The native emitter
still tried to look up that field and rejected an otherwise valid body.

Native emission now evaluates and drops the receiver without loading a value.
The self-host compiler uses an erased reference slot for generic fields. It
accepts that slot only with the exact declaration's existing Unit-storage
certificate, reads the slot, then drops its marker. Missing or unrelated field
evidence is not accepted.

The shared member-call fixture checks both a direct read and a generic indexed
read through a receiver with a visible side effect. Each receiver runs once.

## Checks

- Native minimal regression failed before the fix (9.599 seconds), then passed
  (9.686 seconds).
- Native library and shared execution checks passed (12.523 seconds).
- Self-host hardening passed, including the shared member fixture, 225 tests
  and 29 invariant records (54.839 seconds).
- Performance bug: the full hardening lane still exceeds 30 seconds.

This does not complete the field/storage audit. The Map prototype also exposed
a separate boxed tuple payload-binding error, which remains the next fix.
