# Checked body indices

Date: 2026-09-07

Physical planning now checks expression, local, block, pattern, and arm spans
against their arenas before any body range arithmetic. Invalid spans record
ARN-101, phase 6, with body identity, arena length, span length, and an encoded
arena kind/start. Body-relative expression lookup checks ownership before
subtraction and records ARN-102 with the expression and owning span.

The shared pure helper validates spans with subtraction, not an overflowing
`start + length`. Tests cover empty spans, both ends, U32 boundaries, overflow,
and invalid ownership. Four mutation probes check complete numeric records.
The body slot helper uses the machine index range; physical body entry provides
the stronger check against the actual arenas.

Validation:

- Hardening: 257 tests, 42 exact failure records, and all emission probes pass.
  Cold run: 127.079 seconds; native test generation: 96.590 seconds.
- Clean A/B/C bootstrap passes; B/C core and linked hash:
  `f4b9beabb40c90945309ad99899c76fbe59d4e0ea2e8993416fbdbacb50ef77d`.
  A build: 39.172 seconds; A execution: 42.046; B execution: 53.512.

All stages above 30 seconds remain performance bugs. This change does not
claim to finish arena checks in inference, flow, or solver rollback.
