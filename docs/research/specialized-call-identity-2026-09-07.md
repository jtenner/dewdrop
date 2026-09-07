# Specialized call identity checks

The native recorder no longer discards a different target for an existing
`(body, caller specialization, expression)` key. It checks declaration identity,
target ABI key, and each forwarded evidence operand before accepting a replay.
The same check protects evidence function references. A rejected replay changes
neither the call arena nor its evidence arena. Corrupt evidence spans report
ARN-101 before indexing; target or operand disagreement reports SPC-303.

The self-host compiler checks the complete source call map after its request
work queue and receiver normalization, before physical fragments can erase
source target identity. Two exact integer keys identify a call: body ID and
the packed caller-specialization/expression pair. Duplicate identical records
are valid. Different declarations or target specializations produce SPC-303
with module, body, expression, declaration, expected, actual, and caller context.
This adds a source boundary check; it does not replace the existing physical
call-map check or make late receiver normalization safe by itself.

## Tests and measurements

- Native: two focused tests pass. They cover all three source-key fields,
  exact replay, changed declaration, changed ABI, evidence count/order, arena
  preservation, and a malformed evidence span. Warm run: 0.023 seconds.
- Self-host: 242 hardening tests, 31 exact trap records, and all shared emission
  and semantic probes pass. The three added tests cover exact source identity
  and both target disagreements. The host checks the complete numeric record.
  Warm lane: 37.130 seconds; generation: 6.964 seconds.
- The first cold hardening build took 104.324 seconds and exposed invalid
  typed-local syntax in the new verifier. The syntax was fixed before the
  passing run. Runs above 30 seconds remain performance bugs.
- Clean A/B/C bootstrap passes in 158.426 seconds. A build: 42.637 seconds;
  A/B execution: 41.376/52.640 seconds. B/C core and linked bytes match:
  `44b10b2a19b92b188fff974a47fbd6d0263f7f5004ae9ff3ec51eab7c3c1da8c`.

Exact selection without source-name/first-candidate fallbacks remains open.
