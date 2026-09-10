# Call payload result evidence

This closes T10-6 and T10-10 of the bounded correctness batch.

The unused exact-call payload helper had a method-name fallback and only test
callers. It and its secondary payload helper are removed. The retained source
planning tests still check clean inference and physical plans. Two shared Wasm
fixtures now execute generic `Envelope<a>` and reordered `Result<b, a>` calls.

The active unresolved-call result reader now uses the expression's inferred
type and caller specialization. It no longer selects a method by name to obtain
a replacement type. Error stays Error. Constructor and variant payload callers
pass the caller specialization through this reader.

The mutation regression fails on the old implementation: an Error result is
replaced with I64 from the method. It passes after the change. In the combined
batch, all 948 hardening tests and shared probes pass in 89.000 seconds,
including 336 callback checks. Generated/policy checks pass in 4.983 seconds.
The removed helper is also covered by a policy check against reintroduction.

See `ten-part-type-and-payload-audit-2026-09-10.md` for final batch validation.
