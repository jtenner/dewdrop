# Frozen expression reads

The emitter's exact-carrier reader preferred source heuristics over most saved
carriers. It recognized constants, walked local initializers and nearby branches,
selected methods by name, and treated consumed nodes as their previous expression.
The logical-operand reader added an eight-step unwrap scan and call-result guesses.
Both readers could hide a missing plan, unknown/conflicting carriers, mismatched
carrier copies, or the wrong specialization.

Both now use the same checked reader as discard emission. The reader requires
the owning body, expression record, selected specialization, concrete carrier,
matching carrier copies, and non-fall-through flow for Never. Unit/Never keep
their logical no-value behavior. It does not infer a replacement from source.
Six unused recovery helpers are removed with the old scans. Shared reads live
in `starshine_expression_values.dew`, separate from local-slot planning.

Thirteen one-mutation negative tests compare all nine numeric failure fields.
Twelve exercise both entry points; the last checks a lambda's parent declaration
instead of the anonymous declaration in its virtual source body. Error context
comes from the checked physical plan. Existing discard tests use the same reader.

The baseline passes 830 tests and fails all twelve intended missing-trap cases
in 91.695 seconds. The first fix passes 842 tests, 432 exact records, and all
shared execution probes in 91.242 seconds. The first lambda fixture incorrectly
used expression zero; its literal is expression one. The exact-record check
exposed that setup assertion rather than accepting any trap. After correction,
final hardening passes 843 tests, 433 records, and shared execution probes in
88.137 seconds. A source-policy test still read the old file after extraction;
updating its path and extending the recovery ban gives green generated checks
in 4.593 seconds (the first policy run failed in 0.941 seconds).

Clean bootstrap passes in 177.642 seconds. Raw and linked compiler B/C outputs
share SHA-256 `8546f30b3df6a8f9053e185a92212df600f09990cf542a074e30813f729a1383`.
This also covers the preceding required signature-scope body checks.

This removes these expression recovery paths, not every backend shape helper.
Full heap/nullability agreement and the full instruction shadow stack remain
separate tasks. Runs above 30 seconds remain timing defects; no speed work is
included.
