# Remove the obsolete Map query-demand rule

The self-host query context still recognized every `dew_map_` builtin prefix.
It created a separate logical-argument demand map and propagated that demand
through callers. No production Map builtin remains: Map hashing, equality,
storage, and iteration already use ordinary Dew functions and trait evidence.
The prefix was the only producer of the separate map.

The prefix rule, demand map, propagation worklist, and consumer branch are now
removed together. Query/projection and bound-call demand still use the initial
source-graph closure. Bound trait evidence is not removed or replaced with
physical carrier matching.

The old test declared a removed runtime builtin and tested its special rule.
Its replacement uses valid ordinary generic identity functions. String and
Bytes calls can share that body's reference-carrier instance because it neither
queries their types nor selects a trait implementation. The test checks source
diagnostics, absence of query demand, requests, linking, and physical bodies.
Existing bound-call/query and real Map execution tests retain the contrasting
cases that do need exact logical identity.

The Map policy now rejects the old prefix in query-demand construction. It
fails before the fix (0.053 seconds), then all four policy tests pass (0.039
seconds). Hardening passes 523 tests, 184 exact records, and all shared runtime
and semantic probes, including 12 real Map checks (60.138 seconds). Generated
checks pass (4.321 seconds). Clean bootstrap passes (189.471 seconds), with
identical B/C raw and linked SHA-256:
`4262cf4463a8225112ee5d015d9850c9ef05b1ff9abdbed3521d764f1e41a137`.
Runs above 30 seconds remain recorded speed defects.
Provider code and the FFI surface are unchanged. No speed work is included.
