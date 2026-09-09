# Check lowered early-exit evaluation sequences

A lowered evaluation sequence must contain at least one expression and end
at its first non-fall-through child. Its complete flow summary must equal the
ordered composition of its children, including return, break, continue, and
divergence effects. The source child graph checks this before physical planning.
The emitter repeats the same checks with phase-7 records before scheduling any
of the sequence's expressions. The old anonymous emission assertions are gone.

The checks use the existing checked child spans/ownership and syntax graph.
They do not replace the full instruction shadow stack or freeze source IR.

The first attempted negative fixture was an ordinary direct call, which did
not lower to this IR form. That run failed the fixture assertion rather than
demonstrating the missing check (58.762 seconds). The corrected fixture uses
the existing non-returning constructor source. All five mutations then failed
to trap on the old child verifier (58.265 seconds). The mutations are repeated
at the emitter boundary; each probe checks all nine numeric fields.

Hardening passes 793 tests, 398 complete numeric records, and all shared
execution checks (59.014 seconds). The lane exceeds the 30-second budget and
remains a timing bug. Library checks pass (26.775 seconds), as do generated
sources and policies (4.232 seconds). Clean bootstrap passes in 168.663 seconds.
B/C raw and linked bytes agree:
`2266d594e0b2a73532c5f0157487ad6645944ceaf372e6a74589d53a1003766a`.
This run also covers the preceding specialization request-index commit.
Compiler A build and A/B executions exceed 30 seconds and remain timing bugs.
