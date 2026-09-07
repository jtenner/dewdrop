# Method result context

The shared Bytes probe exposed a self-host inference ordering defect:
`builder.append_byte((index % 251u32).into())` reported ten conversion candidates.
The inner method was rejected before the outer method supplied its U8 parameter
type. Native compilation already accepted the expression.

During the existing source-order method pass, an ambiguous or unmatched method
now remains unpoisoned in a retry queue. Unique method selections still commit
their full signature constraints. Only pending methods are retried. A round
continues only if at least one entry leaves the queue; a runtime assertion checks
that it cannot grow. Two reusable buffers bound queue storage by the number of
pending methods. No arbitrary pass limit is added.

After a round makes no progress, the usual diagnostic pass runs on all remaining
entries. A true ambiguity still reports its exact candidates; no first-candidate
fallback or broad conversion exception is used. This change covers local,
imported, and declared-bound method selection. It is not a replacement for the
separate physical carrier worklist or a claim that all inference scheduling is
complete.

Tests include an imported receiver method whose parameter constrains an inner
conversion, a genuinely ambiguous conversion with no required result type, and
the unchanged Bytes execution probe in both compilers.

The shared Bytes checks pass with the fix. The clean A/B/C bootstrap passes in
159.714 seconds, with matching B/C SHA-256
`df19716a8126930fd8c2cd0c0d34784199d5342bbf8d400bf56967ceaaecdf80`.
The bootstrap and its compiler build/execution stages exceed 30 seconds and
remain performance bugs.

The final hardening lane passes all 232 tests, including both new method-context
tests, all 29 exact invariant records, and all shared execution probes in 53.211
seconds. Its duration remains a performance bug.
