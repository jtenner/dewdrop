# Typed physical diagnostic reasons

The derived Unit payload failure exposed another audit gap: its first physical
diagnostic had code zero. self_host_body_diagnostic_code recognizes only a
subset of the messages passed by field, constructor, pattern, local, flow,
result, and raw-intrinsic checks. Unknown message text silently maps to zero.

Use a typed reason enum instead of recovering the code from a message string.
Each enum case has an explicit stable numeric code and a diagnostic description.
The three physical diagnostic constructors derive both fields from that reason.
String-pattern call failures and raw-intrinsic errors should carry the same
typed reason; emitter-facing String errors render its description explicitly.
An added reason must extend exhaustive code/description matches, not fall back
to zero or discard the original body/expression context.

Existing call reasons retain codes 701–709 and BOD-607; conflict/convergence and
missing-body/root reasons retain their current codes. Field/constructor/pattern
selection checks belong to BOD-608, loop ownership to BOD-609, false divergence
to BOD-611, local initialization/assignment to ABI-710, return operands to
ABI-711, and body results to BOD-612. Raw opcode contract failures use ABI-714;
missing operand plans retain ABI-704 and missing body plans BOD-610.

Keep scratch diagnostic labels as text: they describe temporary-local purposes,
not failure codes. Update the focused code tests and add a positive/mutated
physical plan check for a formerly zero-code failure. Do not change expected
trap handling to accept arbitrary errors. Native failure coverage and complete
full-reference validation remain separate audit work.

Implemented in `semantic_physical_diagnostic_reasons.dew`: 41 exhaustive cases
provide the code and display text. All three body diagnostic factories accept
the enum. String-pattern failures retain it until the record boundary; raw
intrinsic checks retain it until the body record or emitter text boundary.
The string-to-code lookup and its zero fallback are deleted. Scratch labels
remain unchanged.

The red lane compiles and reports all 28 formerly unmapped cases as failures
in 139.943 seconds; existing cases and execution corpora still pass. The first
expanded test used a nonexistent module lookup helper, which compilation
rejects in 13.256 seconds. The test now uses the fixture's source module table.
The green lane passes 415 tests, 114 exact invariant records, and all execution
corpora in 52.604 seconds. The added checks cover every enum code and text and
a valid field plan with only its selected field ID removed. That mutation
checks BOD-608, body/declaration/module identity, expression/source offset,
physical function/specialization, and expected/actual carriers. Clean bootstrap
passes in 169.188 seconds. B/C raw and linked SHA-256 match:
`5d1d12e3aafbcb28814808f41b33ba6790ff229fdaa750839e1559c787d13fb1`.
Native and provider implementations are unchanged. Runs over thirty
seconds remain speed work, not part of this fix.
