# Module startup input contracts

The source startup builder previously trusted SCC spans and member lists. A
missing member could silently drop a global. A duplicate member could repeat
one. The self-host builder also used value zero or body zero when lookup failed.

Both compilers now check module identities, parallel value tables, declaration
identity and kind, source body identity and kind, all SCC and edge spans, unique
complete SCC membership, and dependency-first component order before building
steps. The result retains checked body records in source-value order. Startup
does not repeat a lookup or select the first body as a fallback.

Cycles inside a correctly formed component remain semantic diagnostics. These
checks do not prove strong connectivity of each component; phase comparisons
and the SCC algorithm's separate proof remain necessary for that obligation.
They also do not constitute full indirect-call effect analysis or full linker
freeze.

## Tests and measured runs

Each negative case starts from valid input and changes one field. Tests check
all nine numeric record fields, not just the occurrence of a trap.

- Before the fix, the six new self-host cases produced four intended failures:
  omitted values, duplicate values, missing bodies, and backward dependency
  order were accepted. The other two cases trapped through old array checks.
  The full run took 73.113 seconds; existing checks still passed.
- An earlier run accidentally included the existing 1,024-value self-host
  stress test in the small hardening lane. It was stopped after 171.334 seconds.
  The original stress test remains unchanged in its source file; the small
  contract fixture does not include it. This is recorded as a speed defect,
  not a passing test.
- First native build exposed tuple-loop and test error-signature mistakes
  (1.176 seconds); those are corrected.
- Native contract cases: 10 pass, 33.412 seconds including dependent builds.
- Self-host hardening: 663 tests, 294 exact records, and all shared execution
  checks pass, 178.599 seconds including the native generator rebuild.

- Full native lane: 1,268 tests pass, 218.023 seconds.
- Native integration: 268 tests pass, 65.789 seconds.
- Library execution: 326 tests and all shared corpora pass, 37.888 seconds.
- Generated-source and policy checks pass, 19.114 seconds.

- Clean Node bootstrap passes, 187.722 seconds. Compiler B and C have identical
  raw and linked bytes:
  `3c89d181e1cbe7d1666ba155592be70b122f177df41a953d92b61d7206bb5239`.

Runs above 30 seconds remain speed defects. No speed work is part of this change.
