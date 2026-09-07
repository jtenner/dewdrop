# Module schedule checks

Both compilers now validate the dependency schedule after graph construction and
again at the physical linker entry. Validation is linear in modules and edges.
It checks parallel module arrays, nonempty SCCs, owned and contiguous SCC spans,
total module coverage, duplicate members, dependency spans, dependency indices,
and dependency-before-consumer order. The self-host check also verifies the
stored module-to-component map. Cycles within one component remain valid.

All bounds checks use subtraction before any span-end addition or arena access.
The check does not attempt to re-prove mutual reachability inside each SCC;
that remains the SCC algorithm's obligation, tested with valid cycles.

Self-host failures publish LNK-501 in phase 5. `expression` holds the relevant
module/component position; the missing sentinel denotes a graph-wide error.
`expected`, `actual`, and `detail` identify the violated contract. Detail tags:

| Tag | Contract |
| --- | --- |
| 0 | Dependency span count |
| 1 | SCC member count |
| 2 | Nonempty SCC |
| 3 | Contiguous SCC span start |
| 4 | SCC span bounds |
| 5 | SCC member index |
| 6 | Unique module membership |
| 7 | Stored component identity (self-host) |
| 8 | Dependency span bounds |
| 9 | Dependency module index |
| 10 | Dependency order |
| 11 | Total span coverage |
| 12 | Component-map length (self-host) |

Three native tests pass (8.465 seconds). Eight self-host tests cover valid
ordered graphs, cycles, empty graphs, and seven one-field negative mutations.
The host verifies all nine numeric failure fields for each negative test.
The combined hardening lane passes 252 tests, 38 exact records, and all shared
execution probes in 37.387 seconds (generation: 7.042 seconds).

An earlier cold run took 127.266 seconds, with 96.434 seconds in generation;
its graph tests passed but a new, separate constructor fixture had a syntax
error. The constructor fixes are a separate change.
Runs above 30 seconds remain performance bugs.

The routine native lane passes all 949 tests in 122.722 seconds. Semantic tests
take 71.490 seconds and backend tests 37.632 seconds; both exceed the limit.

This completes the SCC schedule checks, not the broader linker checklist item:
all physical base/identity checks and import-offset cleanup remain open.
