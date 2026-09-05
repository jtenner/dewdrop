# Frozen closure construction targets

Body planning now selects each lambda's exact linked function and closure type.
Verification checks module, owning declaration, lambda, specialization, function
index, and closure type identity. Emission consumes those frozen selections and
checks them again; it no longer resolves the lambda function/type independently.
Closure type selection is construction metadata, not an inferred nominal owner.

A one-field negative test replaces the lambda entry with its parent function.
The verifier reports exactly one BOD-607 diagnostic, and the emitter's matching
predicate rejects the same mutation. Missing targets remain missing.

Validation: 127 hardening tests, 25 numeric records, 114 focused execution checks,
and all 66 shared callback cases pass. Native integration also passed all 266
tests. The complete integration command took 42.222 seconds and reported its
aggregate performance limit; individual lanes remained below 30 seconds.
Calls and function references inside generic lambda bodies are the next
specialization regression cases.
