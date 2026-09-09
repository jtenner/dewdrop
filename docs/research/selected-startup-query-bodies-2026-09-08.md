# Startup dependencies use selected query bodies

A source probe calls `choose<I32>` from a global initializer. The function's
Unit branch reads that same global; its I32 branch returns 42. The self-host
compiler executes it correctly (0.191 seconds), but the native compiler aborts.
The focused native regression identifies an unchecked callable lookup in
`compile_time_fragment_template` (11.654 seconds). A module-let body may be
query-sensitive through its calls, but is not a generic callable template.

After excluding module-let bodies from template deferral, the same regression
reports a false eager initialization cycle (10.207 seconds). Startup dependency
analysis was reading the source template instead of the selected private IR.

Startup work records now retain the exact specialization key. The scheduler
indexes the already-selected call records by caller body, caller key, and
expression. It checks duplicate targets and stored identities. The visited set
uses body plus logical instance key. Query-sensitive generic functions require
their selected cached body; missing instances cannot fall back to a template.
Each cached instance retains its declaration ID, checked with its module ID.
Ordinary physical-only specializations can still share an unchanged source body.
No query is evaluated again by startup analysis.

Tests keep real cycles visible, visit two logical instances of one body, and
mutate one call/cache field at a time. Every internal-state negative checks the
complete nine-field failure record. The shared query corpus now also executes
the removed-cycle branch and two-instance global initialization in both
compilers. The first fixed test passes in 9.935 seconds; the first six focused
tests pass in 10.767 seconds. The final focused startup lane passes 23 tests
(13.944 seconds), including all eight new selected-instance tests. Integration
passes 268 tests (59.833 seconds), the routine native lane passes 1,256 tests
(174.837 seconds), and library execution passes 326 tests plus all shared
corpora, including 98 query checks (40.034 seconds). Generated checks pass
(18.100 seconds). Self-host hardening passes 632 tests, 270 exact records, and
all shared corpora, including 98 query checks (159.494 seconds). Clean Node
bootstrap passes (184.830 seconds). Compiler B and C are byte-identical with
SHA-256 `c2e0ae580b0acdab98876581b6115d4873170909f261f96ce67df337cf603fe2`.

This does not supply effect analysis for arbitrary indirect calls or prove the
self-host scheduler's cross-module order. Those remain separate work. Compiler
runs above 30 seconds remain recorded speed bugs; no speed work is included.
