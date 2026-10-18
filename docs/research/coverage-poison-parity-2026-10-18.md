# Coverage checks on failed types

A failed match value must not add a missing-pattern error. The self-host flow
check previously classified both error types and unresolved variables as open
coverage domains. The native check already uses an error domain for these types.

The self-host check now marks these domains as errors. It skips missing-pattern
and redundant-arm errors for that domain. It still checks each arm's flow, so a
functional loop arm that falls through is still reported.

Valid member projections stay open. A generic owner can keep a symbolic member
projection until specialization. Native `reduce_member_type` preserves that
case; `zonk_member_type` turns a failed concrete projection into `BodyErrorType`.

Read-only native checks with the existing release CLI:

- Generic `field_type<t>("item")`, empty match: one `NonExhaustiveMatch`, 0.218 s.
- Same type, unconditional catch-all: accepted, 0.258 s.
- Invalid `field_type<I32>("item")`, empty match: `CT-032` only, 0.214 s.
- Unknown match value: `UnknownValueName` only, 0.192 s.

A private self-host probe with clean collection confirmed a resolved error type,
one extra missing case, and one extra flow diagnostic (generation 4.737 s, link
1.140 s, run 0.057 s). Match bodies need a line break after the opening brace
for the self-host parser.

The parity tests cover resolved error types, failed expression types,
and functional-loop arm flow. All compiler calls used a wall clock. Raw private
probe files and logs are in
`/tmp/dewdrop-implementation-2026-10-18/coverage-poison/`.

Combined current-source Dew validation passed 63 tests in 0.461 s, including
all poison and generic-domain controls. Generation took 4.653 s and linking
took 1.119 s.

Final native validation passed 53 flow tests in 8.837 s. The full Dew suite
passed all 1,353 tests in 1.381 s (generation 6.748 s, link 1.338 s).
