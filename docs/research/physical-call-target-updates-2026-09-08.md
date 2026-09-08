# Physical call target updates

The self-host body target setter now treats a second different known target as
SPC-303. It cannot silently retain the first target or overwrite it. Repeating
the same target is a no-op. A missing proposal adds no evidence and cannot erase
a known target. Only a missing target can acquire a known target.

The setter checks body-relative ownership before subtraction, the complete
expression-table length before reading, and the stored expression identity.
These checks report ARN-102, ARN-103, and ARN-106, respectively. Each record
retains phase 6 and the original module, declaration, body, and expression.
SPC-303 stores the old and proposed targets in expected/actual and the body slot
in detail. This change adds no target search or physical-shape fallback.

Seven tests cover the three valid update forms and four single-field failures.
The numeric checker verifies all nine fields for each failure. Against the old
setter, three negative tests returned normally; the shortened table trapped
without the required record. The red hardening run failed in 62.818 seconds.

The final hardening run passes all 521 tests, 184 exact numeric records, and all
shared execution corpora (63.367 seconds). Clean bootstrap passes in 220.244
seconds. Compiler B/C raw and linked SHA-256 hashes all match:
`edd279eeb93dabefddde9b808be418ffda8c7e1361672bb17468fb8b3f53e66d`.

Runs above 30 seconds remain timing defects; no speed work is included.
Remaining receiver-based target selection is a separate open task; this setter
check does not prove those selections correct.
