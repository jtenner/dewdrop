# One self-host trait evidence search

The standalone evidence API had its own solver-based search. Inference and
compile-time queries already used the checked logical search. The standalone
copy returned absence at depth 64 and could not retain an instantiated generic
bound. No ordinary compiler phase called that older search.

The standalone API now delegates to the same logical witness search. Its result
is `Result<Option<Witness>, String>`: absence, success, and failure are distinct.
Cycle and resource-limit errors retain CT-013 and CT-012. The search keeps active
obligations and unwinds them before it returns a failure.

Evidence tree construction now starts from a selected witness. Generic arguments
keep full logical types, rather than only reference/scalar shapes. Each node
stores only its direct children. The old builder appended recursive descendants
into its parent's child span; the new builder collects direct roots separately.
An error returns `Err`, not a valid-looking empty tree.

The hardening lane now includes this API's existing tests and new cases for 65
prerequisite levels, exact child spans, cycles, and a one-field resource-budget
mutation. Native inference's separate solver search and implementation/interface
type traversal limits remain open audit work.

Measured validation: 289 hardening tests, 61 exact failure records, and all
shared execution probes pass in 58.742 seconds. The clean bootstrap passes in
161.340 seconds. B/C core and linked bytes match; linked SHA-256:
`aa2df0aa0a2b7a7f73d2dc060b81cb81907f7dfebbe9d91bfb68935fc7d7a2aa`.
Runs above 30 seconds remain speed defects; no speed changes are included.
